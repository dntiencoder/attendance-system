# DEMO TIME DESIGN

Tài liệu phân tích & thiết kế cơ chế mô phỏng thời gian ("Demo Time") để phục vụ demo trước giảng viên, cho phép Check In/Check Out/Shift Rotation/Business Date/Late/Early Leave hoạt động đúng tại các mốc giờ giả lập mà không phải chờ thời gian thực.

**Trạng thái: CHỈ PHÂN TÍCH — CHƯA CODE.** Chờ xác nhận trước khi triển khai.

---

## 1. Nguyên nhân

Toàn bộ quyết định nghiệp vụ chấm công (Business Date, Shift, Late, Early Leave, giới hạn Check In sớm/muộn, ân hạn Check Out ca đêm) đều neo vào `DateTime.now()` được gọi trực tiếp tại nhiều điểm rải rác trong `attendance_mobile` (repository, provider, một vài widget hiển thị). Không có điểm trung gian nào đứng giữa "thời gian hệ thống" và "logic nghiệp vụ".

Hệ quả: để demo các tình huống 07:50 (sắp đến giờ), 08:10 (late), 19:50/20:00/20:15 (chuyển ca đêm), 23:30/00:15 (Business Date xuyên nửa đêm), 07:59 hôm sau (Check Out cuối ca đêm) — người demo buộc phải đợi thời gian thực trôi qua đúng các mốc đó, hoặc phải sửa giờ hệ điều hành của thiết bị (rủi ro: làm sai lệch chứng chỉ TLS, log hệ thống, và không kiểm soát được chính xác từng phút).

Cần một điểm neo duy nhất để "thay thế" `DateTime.now()` bằng thời gian giả lập, chỉ khi ở chế độ debug, không đụng đến schema Firestore hay kiến trúc hiện có.

---

## 2. Phân loại toàn bộ nơi lấy thời gian hiện tại

### 2.1. `attendance_mobile` — Quyết định nghiệp vụ (BẮT BUỘC phải theo Demo Time)

| File | Dòng | Mục đích |
|---|---|---|
| `features/attendance/data/attendance_repository.dart` | 105 | `checkIn()` — tính Business Date, Shift, cửa sổ ca, Late |
| `features/attendance/data/attendance_repository.dart` | 236 | `getTodayAttendance()` — tính Business Date để tìm đúng document hôm nay |
| `features/attendance/data/attendance_repository.dart` | 299 | `checkOut()` — tính Business Date, ân hạn ca đêm, Early Leave |
| `features/attendance/presentation/attendance_provider.dart` | 68 | Xác định `isShiftEnded` (còn hạn Check In hay không) |
| `features/home/presentation/home_provider.dart` | 108 | `_determineAutoShift()` — ca hiện tại hiển thị ở Home |
| `features/home/presentation/home_provider.dart` | 163 | `_loadMonthlyStats()` — biên đầu/cuối tháng để đếm Late/Early/Absent |
| `features/home/presentation/home_screen.dart` | 28 | `isOffDay` — có phải ngày nghỉ bắt buộc hôm nay không |
| `features/attendance/presentation/attendance_history_provider.dart` | 68, 108, 172 | Tháng mặc định, biên "Absent" tự sinh, chặn chọn tháng tương lai |
| `core/utils/work_schedule_helper.dart` | 78 | `countAbsentDays()` — chặn "ngày chưa tới" khi đếm vắng |

### 2.2. `attendance_mobile` — Chỉ hiển thị UI (NÊN theo Demo Time để demo nhất quán, không bắt buộc)

| File | Dòng | Mục đích |
|---|---|---|
| `features/home/presentation/widgets/home_header.dart` | 18 | Chuỗi "Thứ X, dd/mm/yyyy" trên header Home |
| `features/home/presentation/home_screen.dart` | 97 | `month:` truyền cho `MonthlyStats` |
| `features/attendance/presentation/widgets/attendance_record_list.dart` | 48 | Gom nhóm "Tuần này/Tuần trước" trong Attendance History |

### 2.3. `attendance_mobile` — Audit timestamp / fallback phòng thủ (KHÔNG cần đổi)

| File | Dòng | Ghi chú |
|---|---|---|
| `features/settings/domain/company_settings_model.dart` | 76, 81, 211 | Fallback khi Firestore thiếu field + `updatedAt` khi admin sửa cấu hình — không nằm trong kịch bản demo |
| `features/attendance/domain/attendance_model.dart` | 78, 134 | Fallback chỉ chạy khi document Firestore thiếu field — không xảy ra trong luồng thực tế |
| `features/auth/domain/user_model.dart` | 57 | Fallback tương tự cho `createdAt` |

### 2.4. `attendance_mobile` — Dev/seed tooling (KHÔNG đổi — chạy trước demo, không phải runtime logic)

`lib/dev/demo_seeder.dart`, `lib/dev/seed_firestore.dart`, `lib/dev/create_test_user.dart` — dùng `DateTime.now()`/`Timestamp.now()` để tạo dữ liệu mẫu một lần, không tham gia vào flow Check In/Out lúc demo.

### 2.5. `attendance_admin` — không nằm trong luồng Check In/Out (đánh giá riêng ở mục 7)

| File | Dòng | Mục đích |
|---|---|---|
| `features/dashboard/data/dashboard_repository.dart` | 48, 75 | "Hôm nay" cho `todayCheckedIn` + cửa sổ 7 ngày cho biểu đồ Dashboard |
| `features/leave/presentation/leave_provider.dart` | 39 | `createdAt` của notification — audit |
| `features/attendance/presentation/attendance_screen.dart` | 84, 86 | Biên `initialDate`/`lastDate` của DatePicker lọc lịch sử — UI thuần |
| `core/services/export_service.dart` | 143, 183 | Nhãn "Xuất ngày" + fallback hiển thị trong PDF export |

Admin là project Flutter độc lập, build/chạy trên máy khác (máy giảng viên hoặc máy admin riêng), **không** dùng chung tiến trình với `attendance_mobile`. Vì vậy không thể "chia sẻ" Demo Time qua biến static — xem phân tích rủi ro ở mục 7.

---

## 3. Kiến trúc đề xuất: `ClockService`

### 3.1. Vì sao chọn static service thay vì Riverpod provider thuần

Codebase đã có sẵn nhóm class tiện ích static không qua DI: `BusinessDateHelper`, `WorkScheduleHelper`, `RotationCalculator`, `DateHelper`. `AttendanceRepository` cũng được khởi tạo trực tiếp (`AttendanceRepository()`) ở nhiều nơi, không phải lúc nào cũng qua Riverpod provider. Một `StateNotifierProvider` cho đồng hồ sẽ buộc phải "luồn" `ref`/`WidgetRef` xuống các class thuần Dart này — đi ngược lại "không refactor lớn, không đổi kiến trúc".

→ Chọn **static class** để giữ đúng phong cách hiện có, và có thể thay `DateTime.now()` bằng `ClockService.now()` tại từng điểm gọi mà không đổi chữ ký hàm nào.

### 3.2. Thiết kế

File mới: `attendance_mobile/lib/core/services/clock_service.dart`

```dart
import 'package:flutter/foundation.dart';

/// Điểm neo duy nhất cho "thời gian hiện tại" của toàn bộ logic nghiệp vụ.
/// DEMO OFF hoặc Release/Production -> luôn trả về DateTime.now() thật.
/// DEMO ON (chỉ khả dụng ở kDebugMode) -> trả về thời gian giả lập đã set.
class ClockService {
  ClockService._();

  static DateTime? _demoTime;

  static bool get isDemoActive => kDebugMode && _demoTime != null;

  static DateTime now() {
    if (kDebugMode && _demoTime != null) return _demoTime!;
    return DateTime.now();
  }

  static void setDemoTime(DateTime time) {
    if (kDebugMode) _demoTime = time;
  }

  static void useRealTime() {
    _demoTime = null;
  }
}
```

Điểm mấu chốt đảm bảo yêu cầu ở mục 4:
- `kReleaseMode`/production build: `kDebugMode == false` → nhánh demo không bao giờ chạy được, kể cả nếu lỡ gọi `setDemoTime()` ở đâu đó — trở thành no-op.
- Không đổi kiểu dữ liệu Firestore: `ClockService.now()` vẫn trả `DateTime`, mọi chỗ `Timestamp.fromDate(now)` giữ nguyên.
- Không có ghi/đọc nào xuống Firestore trong `ClockService` — thuần in-memory, mất khi tắt app (đúng ý "demo tool", không phải state cần persist).

### 3.3. Cách áp dụng tại call site

Tại mỗi vị trí đã liệt kê ở mục 2.1/2.2, đổi:
```dart
final now = DateTime.now();
```
thành:
```dart
final now = ClockService.now();
```
Không đổi logic xung quanh, không đổi tham số truyền vào `BusinessDateHelper`/`RotationCalculator` (các hàm này vốn đã nhận `DateTime` làm tham số, không tự gọi `DateTime.now()` bên trong — đây là điểm thuận lợi lớn, phần lõi nghiệp vụ đã tách sẵn theo đúng nguyên tắc "pure function of input time").

---

## 4. Phạm vi & ràng buộc

- Demo Time chỉ đọc/ghi được qua `ClockService.setDemoTime()`/`useRealTime()`, và cả hai đều tự vô hiệu hoá ngoài `kDebugMode`.
- UI "Developer Tools" (mục 5) chỉ được thêm vào route/entry point vốn đã ẩn sau `kDebugMode` (tương tự cách `attendance_admin` đã ẩn `/dev/seed-departments`).
- Không đổi bất kỳ field/document nào trong Firestore. `Timestamp.fromDate(ClockService.now())` ghi xuống Firestore vẫn là timestamp hợp lệ bình thường — Firestore không biết và không cần biết nó đến từ thời gian giả lập.
- Release build (`flutter build apk/ipa/web --release`) không đóng gói khác biệt gì thêm — do toàn bộ nhánh demo bị loại bởi `kDebugMode`, trình biên dịch có thể dead-code-eliminate ở release nếu cần, nhưng không bắt buộc vì chi phí runtime của một `if (kDebugMode)` là không đáng kể.

---

## 5. Đề xuất UI

Thêm 1 mục trong `ProfileScreen` (chỉ hiện khi `kDebugMode == true`), dẫn tới màn hình mới `DeveloperToolsScreen`:

```
Profile
 └── (kDebugMode) "Developer Tools"  →  DeveloperToolsScreen
                                          └── "Demo Time"
                                               ○ Use Real Time   (mặc định, chọn = ClockService.useRealTime())
                                               ○ Use Demo Time
                                                    Date: [DatePicker]
                                                    Time: [TimePicker]
                                                    [Apply]   -> ClockService.setDemoTime(...) + reload màn hình hiện có
                                                    [Reset]   -> ClockService.useRealTime()  + reload
                              Badge trạng thái: "🕒 DEMO: 20/07/2026 20:15" hiển thị nổi (banner) khi isDemoActive == true,
                              để người demo (và giảng viên) luôn biết đang xem dữ liệu giả lập, tránh hiểu nhầm là bug.
```

Route thêm vào `app_router.dart`: `GoRoute(path: '/dev-tools', builder: (_, __) => const DeveloperToolsScreen())`, chỉ được liên kết tới từ menu Profile khi `kDebugMode`.

Sau khi bấm **Apply**/**Reset**, cần chủ động gọi lại các provider đang cache dữ liệu theo giờ cũ (không có cơ chế reactive tự động vì `ClockService` là static, không phải Riverpod state) — cụ thể `ref.invalidate(homeProvider)`, `ref.invalidate(attendanceProvider)`, `ref.invalidate(attendanceHistoryProvider)`, rồi `context.go('/home')` để quay về màn hình chính xem kết quả.

---

## 6. Đánh giá ảnh hưởng — module tự động hưởng lợi

Vì `BusinessDateHelper`, `RotationCalculator`, `CompanySettingsModel.calculateIsLate/calculateEarlyLeave` vốn đã là hàm thuần nhận `DateTime` làm tham số, chỉ cần đổi ~12 điểm gọi `DateTime.now()` ở tầng trên là toàn bộ các module sau tự động chạy đúng theo Demo Time, không cần sửa thêm gì trong chính các module đó:

- **Check In / Check Out** — `AttendanceRepository` (đã đổi trực tiếp)
- **Shift Rotation** — `RotationCalculator.getCurrentShift()` (nhận `date` từ Business Date đã theo demo time)
- **Business Date** — `BusinessDateHelper.resolveBusinessDate()` (nhận `now` từ demo time)
- **Late / Early Leave** — `calculateIsLate()`/`calculateEarlyLeave()` (nhận `checkInTime`/`checkOutTime` là demo time)
- **Home** — ca hiển thị, trạng thái nút Check In/Out, thống kê tháng
- **Attendance History** — sinh "Absent" tự động, chặn chọn tháng tương lai
- **Dashboard (trong `attendance_mobile`, nếu có)** — không có màn Dashboard riêng trong mobile; số liệu tháng hiện hiển thị ở Home (`monthlyOnTime/monthlyLate/...`) đã nằm trong danh sách trên. Dashboard của **admin** là ứng dụng khác — xem mục 7.

---

## 7. Rủi ro

| Rủi ro | Mức độ | Ghi chú/giảm thiểu |
|---|---|---|
| Quên đổi một `DateTime.now()` còn sót ở nghiệp vụ | Trung bình | Danh sách mục 2.1 đã liệt kê đủ 12 điểm qua grep toàn repo; sau khi sửa nên grep lại `DateTime.now()` trong `attendance_mobile/lib/features` để xác nhận 0 kết quả còn "lọt lưới" trong nhóm nghiệp vụ. |
| **Admin Dashboard không đồng bộ với Demo Time bên mobile** | **Cao (cần quyết định trước khi demo)** | `attendance_admin` là app/tiến trình riêng, chạy trên thiết bị khác. Nếu demo mô phỏng các mốc xuyên nửa đêm (23:30 → 00:15, hoặc 07:59 hôm sau), `attendanceDate` ghi xuống Firestore sẽ mang ngày giả lập (có thể là "ngày mai" so với ngày thực tại thiết bị admin). Khi đó `DashboardRepository` (dùng `DateTime.now()` thật của máy admin) sẽ **không** đếm được record đó vào "Đã chấm công hôm nay" cho tới khi ngày thực sự trôi tới. Đây không phải bug, mà là hệ quả tất yếu của việc Demo Time chỉ tồn tại trong tiến trình mobile. Ba lựa chọn: (1) chấp nhận và giải thích trước cho giảng viên khi demo tới đoạn xuyên nửa đêm, (2) chỉ demo Dashboard bằng các mốc **cùng ngày lịch thực** (07:50–23:30), để dành các mốc qua-ngày (00:15, 07:59 hôm sau) riêng cho Home/History/Check Out trên mobile, (3) mở rộng `ClockService` sang cả `attendance_admin` (ngoài phạm vi tối thiểu ban đầu, cần xác nhận riêng nếu muốn). |
| Firebase/Firestore Timestamp | Thấp | `Timestamp.fromDate(ClockService.now())` hoạt động bình thường; Firestore không phân biệt "giờ thật" hay "giờ giả lập", chỉ nhận `DateTime`. Không ảnh hưởng `serverTimestamp()` (dùng ở admin cho `leave_request`/`department`/`employee`/`company_settings` — các collection này không nằm trong logic Demo Time). |
| Query Firestore theo khoảng ngày (`isGreaterThanOrEqualTo`/`isLessThanOrEqualTo` trên `attendanceDate`) | Thấp–Trung bình | Các query này (`home_provider._loadMonthlyStats`, `attendance_history_provider.loadRecords`) dùng `startOfMonth`/`endOfMonth` tính từ `now` — nếu `now` đã là `ClockService.now()`, query tự động đúng theo demo time, không cần sửa thêm gì ngoài đổi nguồn `now`. |
| Cache trong Riverpod provider giữ dữ liệu cũ sau khi đổi Demo Time | Trung bình | Vì `ClockService` không phát sự kiện thay đổi (static, không phải Stream/State), các provider đã load 1 lần sẽ không tự re-run. Bắt buộc UI "Apply/Reset" phải chủ động `ref.invalidate(...)` (đã nêu ở mục 5), nếu quên bước này, màn hình sẽ hiển thị dữ liệu tính theo giờ cũ dù `ClockService.now()` đã đổi. |
| Timezone | Thấp | Toàn bộ code hiện tại dùng `DateTime` local (không có `.toUtc()`/`.toLocal()` trộn lẫn trong nhóm nghiệp vụ), và thiết bị demo lẫn Firestore đều nhất quán theo local time của máy chạy app — `ClockService.now()` kế thừa đúng hành vi này, không phát sinh lệch timezone mới. |
| Người demo bấm Check In/Out thật (không phải demo) sau khi quên Reset Demo Time | Trung bình | Banner cảnh báo nổi bật ở mục 5 khi `isDemoActive == true` là biện pháp giảm thiểu chính; có thể cân nhắc thêm: tự động `useRealTime()` khi app khởi động lại (không persist qua session) — đã mặc định đúng vì `_demoTime` là biến static trong RAM, mất khi kill app. |

---

## 8. Danh sách file cần sửa (khi được duyệt triển khai)

**Mới:**
1. `attendance_mobile/lib/core/services/clock_service.dart` (mới)
2. `attendance_mobile/lib/features/dev_tools/presentation/developer_tools_screen.dart` (mới — hoặc đặt trong `lib/dev/` cho nhất quán với `demo_seeder.dart` v.v., cần thống nhất tên thư mục trước khi code)

**Sửa (đổi `DateTime.now()` → `ClockService.now()`, không đổi logic khác):**
3. `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (3 vị trí)
4. `attendance_mobile/lib/features/attendance/presentation/attendance_provider.dart` (1 vị trí)
5. `attendance_mobile/lib/features/home/presentation/home_provider.dart` (2 vị trí)
6. `attendance_mobile/lib/features/home/presentation/home_screen.dart` (2 vị trí)
7. `attendance_mobile/lib/features/attendance/presentation/attendance_history_provider.dart` (3 vị trí)
8. `attendance_mobile/lib/core/utils/work_schedule_helper.dart` (1 vị trí)
9. `attendance_mobile/lib/features/home/presentation/widgets/home_header.dart` (1 vị trí — tuỳ chọn, khuyến nghị đổi để đồng bộ hiển thị)
10. `attendance_mobile/lib/features/attendance/presentation/widgets/attendance_record_list.dart` (1 vị trí — tuỳ chọn)

**Sửa (thêm route + entry menu, không đổi logic có sẵn):**
11. `attendance_mobile/lib/core/router/app_router.dart` (thêm 1 `GoRoute`)
12. `attendance_mobile/lib/features/profile/presentation/profile_screen.dart` (thêm 1 mục menu điều kiện `kDebugMode`)

## 9. Danh sách file KHÔNG cần sửa

- `core/utils/business_date_helper.dart`, `core/utils/rotation_calculator.dart` — đã là pure function theo `DateTime` truyền vào, không tự gọi `DateTime.now()`.
- `features/settings/domain/company_settings_model.dart`, `features/attendance/domain/attendance_model.dart`, `features/auth/domain/user_model.dart` — chỉ dùng `DateTime.now()` làm fallback phòng thủ khi thiếu field Firestore, không nằm trong luồng demo.
- `lib/dev/demo_seeder.dart`, `lib/dev/seed_firestore.dart`, `lib/dev/create_test_user.dart` — công cụ seed dữ liệu, chạy trước demo, không phải runtime logic.
- Toàn bộ `attendance_admin/**` — xem quyết định ở mục 7 (rủi ro Dashboard); mặc định **không đổi** trong Phase 1, trừ khi được xác nhận mở rộng riêng.
- Mọi nơi dùng `FieldValue.serverTimestamp()` (`leave_repository.dart`, `department_repository.dart`, `employee_model.dart`, `company_settings_model.dart` bên admin) — timestamp phía server Firestore, không thể và không cần giả lập.
- Firestore Rules, Firestore schema — không đổi theo đúng ràng buộc đã nêu.

---

## 10. Đề xuất Test Plan

Thực hiện tuần tự trên 1 tài khoản nhân viên nhóm A (hoặc B), theo đúng chuỗi mốc giờ đã nêu trong yêu cầu:

| # | Demo Time | Hành động | Kỳ vọng |
|---|---|---|---|
| 1 | Hôm nay, 07:50 | Mở Home | Nút Check In khả dụng, hiển thị ca sắp tới đúng theo Shift Rotation của nhóm |
| 2 | Hôm nay, 08:10 | Check In | Thành công, `isLate = true`, status `late` (giả định ca ngày bắt đầu 08:00) |
| 3 | Hôm nay, 12:30 | Mở Home/History | Trạng thái "Đã Check In", chưa Check Out |
| 4 | Hôm nay, 13:00 | Mở History | Record hôm nay hiển thị đúng ca, đúng giờ vào |
| 5 | Hôm nay, 19:50 | Mở Home (ca đêm nhóm ngược lại) | Hiển thị đúng ca đêm sắp tới cho nhóm được xoay ca đêm hôm đó |
| 6 | Hôm nay, 20:00 | Check In (tài khoản ca đêm) | Đúng giờ, `isLate = false` |
| 7 | Hôm nay, 20:15 | Check In (tài khoản khác, ca đêm) | `isLate = true` |
| 8 | Hôm nay, 23:30 | Mở Home | Vẫn thuộc Business Date hôm nay (ca đêm chưa qua nửa đêm) |
| 9 | Hôm nay, 00:15 (tức "ngày mai" theo lịch máy) | Mở Home | `BusinessDateHelper` phải trả về Business Date = hôm nay (ngày ca đêm bắt đầu), không phải ngày lịch mới — đúng theo `ATTENDANCE_BUSINESS_FLOW.md` |
| 10 | Hôm nay, 00:15 | Check Out (tài khoản ca đêm ở bước 6/7) | Vẫn tìm đúng document đã tạo lúc 20:00/20:15 (cùng Business Date), không tạo nhầm document mới |
| 11 | Hôm sau, 07:59 | Check Out (nếu chưa Check Out ở bước 10) | Vẫn trong khung ân hạn 2 giờ sau giờ tan ca 08:00 → thành công, `isEarlyLeave` tính đúng theo cửa sổ ca đã lưu |
| 12 | Hôm sau, 07:59 | Check Out (kịch bản về sớm, ca ngày kết thúc 20:00 giả định khác) | `isEarlyLeave = true` nếu checkout trước giờ kết thúc ca đã resolve |
| 13 | Bất kỳ mốc nào | Bấm **Reset** trong Developer Tools | `ClockService.now()` quay lại `DateTime.now()` thật ngay lập tức, banner demo biến mất |
| 14 | Build `--release` | Kiểm tra không có mục "Developer Tools" trong Profile | Xác nhận `kDebugMode == false` chặn hoàn toàn UI và logic demo |

Sau khi hoàn tất bước 9–11, kiểm tra chéo dữ liệu trên Firestore Console: `attendanceDate` của các document liên quan phải đúng là ngày ca đêm bắt đầu (không bị lệch sang ngày hôm sau).

---

## 11. Ước lượng số dòng code thay đổi

| Hạng mục | Ước lượng |
|---|---|
| `clock_service.dart` (mới) | ~20 dòng |
| `developer_tools_screen.dart` (mới, UI + gọi `ClockService` + `ref.invalidate`) | ~120–160 dòng |
| Đổi `DateTime.now()` → `ClockService.now()` tại 8 file nghiệp vụ (mục 8, #3–8) | ~12 dòng sửa (1 dòng/vị trí) + 8 dòng import |
| Đổi tuỳ chọn ở `home_header.dart`, `attendance_record_list.dart` | ~2 dòng sửa + 2 dòng import |
| Thêm route + menu (`app_router.dart`, `profile_screen.dart`) | ~15–20 dòng |
| **Tổng** | **~170–220 dòng**, toàn bộ trong `attendance_mobile`, không đụng `attendance_admin`, không đụng Firestore Rules/schema |

---

## 12. Câu hỏi cần xác nhận trước khi triển khai

1. Chấp nhận rủi ro "Admin Dashboard không đồng bộ" ở mục 7 (phương án 1/2), hay muốn mở rộng `ClockService` sang `attendance_admin` luôn trong lần này (phương án 3, tăng phạm vi thay đổi)?
2. Vị trí đặt `DeveloperToolsScreen`: trong `lib/features/dev_tools/` (feature mới, đúng cấu trúc feature-first) hay gộp vào `lib/dev/` (đúng tinh thần "dev-only tooling" đã có sẵn)?
3. Có cần đổi cả 2 vị trí "tuỳ chọn" (`home_header.dart`, `attendance_record_list.dart`) hay giữ nguyên `DateTime.now()` thật cho phần hiển thị phụ, chỉ chắc chắn đổi 8 vị trí nghiệp vụ bắt buộc?

Sau khi bạn xác nhận 3 điểm trên, sẽ triển khai code theo đúng danh sách ở mục 8.
