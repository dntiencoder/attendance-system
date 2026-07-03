# PROJECT_OVERVIEW.md

> Tài liệu này mô tả tổng quan dự án `attendance-system`. Đây là tài liệu **chỉ đọc** — được tạo ra để hiểu dự án, không phục vụ mục đích sửa code.

## 1. Dự án là gì

Hệ thống chấm công dựa trên GPS (GPS Attendance System), gồm **hai ứng dụng Flutter độc lập** dùng chung **một backend Firebase duy nhất** (project id: `attendance-management-sy-34105`):

| App | Vai trò | Nền tảng chính | Thư mục |
|---|---|---|---|
| `attendance_mobile` | Ứng dụng cho **nhân viên**: check-in/out bằng GPS, xem lịch sử chấm công, nghỉ phép, hồ sơ cá nhân | Android / iOS (di động) | `attendance_mobile/` |
| `attendance_admin` | Ứng dụng cho **quản trị viên/HR**: dashboard thống kê, quản lý nhân viên, phòng ban, duyệt nghỉ phép, cấu hình vị trí GPS công ty, xuất báo cáo Excel/PDF | Web (desktop-first) | `attendance_admin/` |

Không có server backend tự viết (không có Node/NestJS/Express...). Toàn bộ truy cập dữ liệu đi thẳng từ Flutter client tới Firebase SDK (`cloud_firestore`, `firebase_auth`, `firebase_storage`). Điều này có nghĩa là **cấu trúc dữ liệu Firestore là hợp đồng ngầm (implicit contract) giữa hai app** — đổi field/collection ở app này mà không đổi app kia sẽ gây lỗi runtime âm thầm (không có type-safety xuyên app vì mỗi app định nghĩa model Dart riêng cho cùng một document).

## 2. Công nghệ sử dụng

- **Flutter/Dart** (SDK ^3.12.1) cho cả hai app.
- **Firebase**: `firebase_core`, `firebase_auth` (đăng nhập email/password), `cloud_firestore` (database chính), `firebase_storage` (khai báo nhưng chưa thấy dùng thực tế trong code đã đọc).
- **State management**: `flutter_riverpod` (v2) — dùng `StateNotifierProvider` + `FutureProvider`/`StreamProvider`, không dùng code-gen (`riverpod_generator`).
- **Routing**: `go_router` — mobile dùng `StatefulShellRoute.indexedStack` (bottom nav có state riêng từng tab); admin dùng `ShellRoute` đơn giản (sidebar cố định).
- **GPS**: `geolocator` + thuật toán Haversine tự viết (`core/utils/haversine.dart`) để tính khoảng cách tới văn phòng, có chặn fake-GPS (`position.isMocked`).
- **Admin-only**: `fl_chart` (biểu đồ dashboard), `excel` + `pdf` + `printing` (xuất báo cáo chấm công).
- Không có test suite thực chất — cả hai app chỉ có file mặc định `test/widget_test.dart` do `flutter create` sinh ra.

## 3. Vai trò người dùng (role) và ranh giới truy cập

Có 2 role lưu trong field `role` của collection `users`: `admin` và `employee` (hằng số ở `AppConfig.roleAdmin` / `roleEmployee`).

- **App mobile chỉ chấp nhận đăng nhập role `employee`**. Nếu tài khoản có `role == 'admin'` đăng nhập trên mobile, `AuthRepository.login()` (mobile) sẽ chủ động `signOut()` và báo lỗi *"Tài khoản quản trị vui lòng đăng nhập trên web admin"*.
- **App admin chỉ chấp nhận đăng nhập role `admin`** (chấp nhận cả `'admin'` hardcoded lẫn `AppConfig.roleAdmin` để tương thích dữ liệu cũ). Nhân viên (`employee`) đăng nhập trên admin sẽ bị `signOut()` với lỗi *"Bạn không có quyền truy cập quản trị"*.
- Cả hai đều kiểm tra thêm `isActive` — tài khoản bị khóa (`isActive: false`) sẽ bị từ chối và signOut ngay sau khi Firebase Auth xác thực thành công (tức là việc phân quyền role/active nằm ở tầng ứng dụng, đọc từ Firestore, **không phải Firebase Auth Custom Claims** và không có Firestore Security Rules được kiểm tra trong repo này — nên về lý thuyết một client bị chỉnh sửa có thể bỏ qua các kiểm tra này nếu rules phía server không siết chặt tương ứng).

## 4. Nghiệp vụ cốt lõi: ca làm việc & chấm công

Đây là phần nghiệp vụ phức tạp nhất, được cấu hình qua document đơn `company_settings/main` (`CompanySettingsModel`, được **định nghĩa trùng lặp độc lập** ở cả hai app):

- Công ty có toạ độ GPS (`latitude`, `longitude`) + bán kính cho phép (`radius`, mặc định 100m). Check-in/out bị từ chối nếu nhân viên ở ngoài bán kính này.
- Có 2 ca: `day` (ca ngày) và `night` (ca đêm), mỗi ca có giờ bắt đầu/kết thúc dạng chuỗi `"HH:mm"`.
- Nhân viên được gán vào nhóm xoay ca `shiftGroup` = `A` hoặc `B`. Ca thực tế của từng nhóm **đổi luân phiên mỗi 14 ngày** (`rotationDays`) tính từ `rotationStartDate` — xem `CompanySettingsModel.getCurrentShift()`.
- Ngoài ra còn một lịch làm việc **độc lập, hardcode riêng** ở mobile (`core/utils/work_schedule_helper.dart`) xác định ngày làm/tăng ca/nghỉ theo tuần chẵn-lẻ (chu kỳ 14 ngày tính từ mốc cố định `01/06/2026`), dùng để tính "ngày vắng" trong thống kê tháng ở màn hình Home. **Đây là hai cơ chế lịch làm việc song song, không tự động đồng bộ với nhau** — cần lưu ý khi sửa nghiệp vụ liên quan đến lịch làm việc.
- Mỗi ngày, mỗi nhân viên có tối đa **một document chấm công** (doc ID = `"<yyyy-MM-dd>_<uid>"`). Check-in tạo doc, check-out update doc đó (không có bản ghi tách biệt cho vào/ra).
- Check-in bị từ chối nếu: đã check-in hôm nay rồi, ngoài bán kính GPS, hoặc đã quá giờ kết thúc ca (được tính là vắng mặt — có xử lý ca đêm qua nửa đêm).
- Trạng thái `isLate` (đi muộn) tính lúc check-in; `isEarlyLeave` (về sớm) tính lúc check-out; `workHours` tính từ chênh lệch check-in/check-out.

## 5. Các điểm cần lưu ý khi làm việc tiếp (dead code / inconsistency)

Phát hiện trong quá trình đọc code (không sửa, chỉ ghi nhận):

- `attendance_admin/lib/features/auth/presentation/auth_gate.dart` — **file rỗng** (0 dòng), không được import ở đâu.
- `attendance_admin/lib/features/auth/domain/admin_model.dart` — **file rỗng** (0 dòng), không được dùng (admin dùng chung `UserModel`/dữ liệu thô từ `users` collection, không có model `Admin` riêng).
- `attendance_mobile/lib/features/attendance/presentation/checkin_screen.dart` và `gps_test_screen.dart` — không được route tới ở `app_router.dart` (màn hình check-in thực tế nằm trong `CheckinCard` widget nhúng vào `HomeScreen`). Có thể là code cũ còn sót lại.
- Có 2 nơi định nghĩa logic xoay ca/ngày nghỉ độc lập nhau (mục 4 ở trên) — rủi ro lệch dữ liệu khi chỉ sửa một bên.
- `lib/dev/` ở cả hai app chứa script seed dữ liệu demo (xoá & tạo lại Firestore) — **không được trỏ vào project Firebase production**.
