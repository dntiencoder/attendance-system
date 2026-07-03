# ROADMAP.md

> Lộ trình khắc phục dựa trên `REVIEW.md`. Mục tiêu duy nhất: đưa dự án về **trạng thái ổn định** (không crash, không lộ dữ liệu/credential, không có bug âm thầm phá dữ liệu nghiệp vụ). Đây **không phải** lộ trình tái kiến trúc.
>
> **Ràng buộc phạm vi (áp dụng cho toàn bộ roadmap):**
> - Không đổi kiến trúc (không thêm layer use-case, không interface hoá Repository, không đổi state management).
> - Không chuyển sang Clean Architecture đầy đủ.
> - Không thêm Cloud Functions.
> - Không tách package Dart dùng chung giữa hai app.
> - Không refactor lớn — mỗi task chỉ sửa trong phạm vi 1-3 file, giữ nguyên cấu trúc hiện có.
> - Không sửa code trong lúc tạo tài liệu này.

---

## Tổng quan các Phase

| Phase | Chủ đề | Số task | Bắt buộc trước khi release? |
|---|---|---|---|
| Phase 1 | Critical — chặn rủi ro bảo mật & bug phá dữ liệu | 7 | **Có, bắt buộc** |
| Phase 2 | High — củng cố an toàn dữ liệu & khả năng vận hành | 6 | **Có, nên làm trước khi mở rộng người dùng** |
| Phase 3 | Medium — hiệu năng & nhất quán | 8 | Nên làm, không chặn release |
| Phase 4 | Low — dọn dẹp / polish | 5 | Tuỳ thời gian còn lại |

---

## Phase 1 — Critical (chặn rủi ro bảo mật & bug phá dữ liệu)

Đây là các vấn đề **phải sửa trước tiên** — hoặc đang rò rỉ thông tin thật, hoặc đang âm thầm phá dữ liệu nghiệp vụ (ca làm việc), hoặc có thể làm crash tính năng lõi.

| ID | Mô tả | Ưu tiên | Độ khó | Thời gian | File ảnh hưởng | App |
|---|---|---|---|---|---|---|
| **P1-01** | Xoá email/mật khẩu/UID thật bị hardcode trong script dev; thay bằng giá trị placeholder hoặc đọc từ biến môi trường (`--dart-define`) | Critical | Thấp | 0.5 ngày | `lib/dev/create_test_user.dart`, `lib/dev/demo_seeder.dart` | Mobile |
| **P1-02** | Sửa bug mất `rotationStartDate` khi lưu Settings: thêm field này vào form (hoặc giữ nguyên giá trị cũ khi build `CompanySettingsModel` thay vì để mặc định `null`), đảm bảo `toFirestore()`/`updateSettings()` không ghi `null` đè lên giá trị đang có | Critical | Thấp-Trung bình | 0.5-1 ngày | `features/settings/presentation/settings_screen.dart`, `features/settings/domain/company_settings_model.dart`, `features/settings/data/settings_repository.dart` | Admin |
| **P1-03** | Bọc `double.parse`/`int.parse` trong `_saveSettings()` bằng try-catch; đổi validator các ô số (Latitude/Longitude/Radius/Rotation Days) sang kiểm tra định dạng số thay vì chỉ "không rỗng" | Critical | Thấp | 0.5 ngày | `features/settings/presentation/settings_screen.dart`, `core/utils/validators.dart` | Admin |
| **P1-04** | Thêm null-safety cho `attendanceDate`/các field Timestamp trong `AttendanceModel.fromFirestore` (mobile) — không ép kiểu cứng; bọc từng document trong try-catch khi `.map()` để 1 document lỗi không làm crash toàn bộ danh sách | Critical | Trung bình | 0.5-1 ngày | `features/attendance/domain/attendance_model.dart`, `features/attendance/data/attendance_repository.dart` | Mobile |
| **P1-05** | Viết và deploy `firestore.rules` cơ bản: xác thực `request.auth.uid`, kiểm tra `role`/`isActive` cho từng collection (`users`, `attendance`, `company_settings`, `departments`, `leave_requests`) thay vì chỉ dựa vào kiểm tra phía client | Critical | Trung bình | 1-2 ngày | file mới `firestore.rules` (cấu hình Firebase, không phải code app) | Không (Firebase config) |
| **P1-06** | Gỡ route `/dev/seed-departments` khỏi router chính thức, hoặc bọc bằng `kDebugMode`/build flavor để không có mặt trong bản production | Critical | Thấp | 0.5 ngày | `routes/app_router.dart`, `dev/department_seeder.dart` | Admin |
| **P1-07** | Bỏ mật khẩu mặc định `123456` pre-fill sẵn khi tạo nhân viên mới; sinh mật khẩu ngẫu nhiên đủ mạnh (hoặc yêu cầu admin tự nhập, không gợi ý sẵn) | Critical | Thấp | 0.5 ngày | `features/employee/presentation/employee_screen.dart` | Admin |

**Tổng thời gian ước tính Phase 1:** ~4-6 ngày làm việc.

---

## Phase 2 — High (củng cố an toàn dữ liệu & khả năng vận hành)

Không gây sự cố tức thời như Phase 1, nhưng để lâu sẽ tích luỹ rủi ro (race condition, không có log khi có sự cố, dữ liệu không nhất quán).

| ID | Mô tả | Ưu tiên | Độ khó | Thời gian | File ảnh hưởng | App |
|---|---|---|---|---|---|---|
| **P2-01** | Bọc thao tác kiểm tra-rồi-ghi trong `checkIn()` bằng `_db.runTransaction()` để tránh race condition double check-in khi có 2 request gần như đồng thời | High | Trung bình | 0.5-1 ngày | `features/attendance/data/attendance_repository.dart` | Mobile |
| **P2-02** | Thêm `firebase_crashlytics` (hoặc logging tối thiểu có cấu trúc) vào các nhánh `catch` quan trọng trong Repository/Notifier để có dấu vết khi sự cố xảy ra ở production | High | Trung bình | 1-2 ngày | `pubspec.yaml` (cả 2 app), các `*/data/*_repository.dart`, `*/presentation/*_provider.dart` | Cả 2 |
| **P2-03** | Chạy `firebase firestore:indexes` và commit `firestore.indexes.json` để các query nhiều điều kiện không bị lỗi `FAILED_PRECONDITION` khi deploy lên project/môi trường mới | High | Thấp | 0.5 ngày | file mới `firestore.indexes.json` | Không (Firebase config) |
| **P2-04** | Ràng buộc nút "Xoá nhân viên": chỉ cho phép xoá khi nhân viên đã bị vô hiệu hoá (`isActive == false`), kèm dialog cảnh báo rõ "tài khoản đăng nhập vẫn còn tồn tại, chỉ xoá được hồ sơ" — giảm rủi ro tài khoản Auth mồ côi mà không cần Cloud Function | High | Thấp | 0.5 ngày | `features/employee/presentation/employee_screen.dart` | Admin |
| **P2-05** | Xoá `.toUpperCase()` không rõ lý do khi gửi email đăng nhập, chỉ giữ `.trim()` | High | Thấp | <0.25 ngày | `features/auth/presentation/widgets/login_form.dart` | Mobile |
| **P2-06** | Đồng bộ mốc ngày gốc/logic giữa `WorkScheduleHelper` (hardcode `2026-06-01`) và `CompanySettingsModel.getCurrentShift()` (đọc từ `rotationStartDate`) — không gộp thành 1 model, chỉ đảm bảo cả hai cùng dùng chung một nguồn giá trị mốc ngày để tránh lệch dữ liệu "ngày làm" vs "ca làm" | High | Trung bình | 1 ngày | `core/utils/work_schedule_helper.dart`, `features/home/presentation/home_provider.dart` | Mobile |

**Tổng thời gian ước tính Phase 2:** ~4-6 ngày làm việc.

---

## Phase 3 — Medium (hiệu năng & nhất quán)

Không ảnh hưởng đến độ ổn định ngay lập tức ở quy mô dữ liệu hiện tại, nhưng nên xử lý trước khi số lượng nhân viên/bản ghi tăng lên hoặc trước khi bàn giao cho khách hàng dùng lâu dài.

| ID | Mô tả | Ưu tiên | Độ khó | Thời gian | File ảnh hưởng | App |
|---|---|---|---|---|---|---|
| **P3-01** | Thêm giới hạn (`.limit()`) hoặc mặc định lọc theo khoảng ngày cho query `getAttendanceLogs()` thay vì tải toàn bộ collection `attendance` mỗi lần mở màn hình (không cần viết lại `DataTable` thành `PaginatedDataTable`) | Medium | Trung bình | 1 ngày | `features/attendance/data/attendance_repository.dart`, `features/attendance/presentation/attendance_screen.dart` | Admin |
| **P3-02** | Đổi vòng lặp `for` tuần tự trong `_getWeeklyAttendance()` sang `Future.wait([...])` để 7 query chạy song song | Medium | Thấp | 0.5 ngày | `features/dashboard/data/dashboard_repository.dart` | Admin |
| **P3-03** | Cache kết quả `company_settings`/`users` trong `AttendanceHistoryNotifier` (lưu vào field của class) để không phải đọc lại Firestore mỗi lần chuyển tháng | Medium | Thấp-Trung bình | 0.5 ngày | `features/attendance/presentation/attendance_history_provider.dart` | Mobile |
| **P3-04** | Thay các `AlertDialog` tự dựng trong `employee_screen.dart`/`leave_screen.dart` bằng `ConfirmDialog.show(...)` đã có sẵn để đồng bộ giao diện xác nhận | Medium | Thấp | 0.5 ngày | `features/employee/presentation/employee_screen.dart`, `features/leave/presentation/leave_screen.dart` | Admin |
| **P3-05** | Dùng lại `Validators.email`/`Validators.phone` có sẵn thay vì validator inline (`v.isEmpty`) trong form thêm/sửa nhân viên | Medium | Thấp | 0.5 ngày | `features/employee/presentation/employee_screen.dart` | Admin |
| **P3-06** | Thay hiển thị lỗi thô (`'Lỗi: $err'`) bằng thông điệp thân thiện, giữ lỗi kỹ thuật gốc chỉ trong log (đã thêm ở P2-02) | Medium | Thấp | 0.5 ngày | các `*/presentation/*_screen.dart` (admin) | Admin |
| **P3-07** | Đồng bộ nhãn hiển thị ca làm giữa hai app cho cùng giá trị dữ liệu (vd. `shift == 'day'` đang hiển thị "Ca ngày" ở mobile nhưng "Ca sáng" ở admin) | Medium | Thấp | <0.25 ngày | `features/attendance/domain/attendance_model.dart` (cả 2 app) | Cả 2 |
| **P3-08** | Thay các hex màu hardcode (`Color(0xFFB91C1C)`) bằng hằng số `AppColors.primary` đã có sẵn | Medium | Thấp | <0.25 ngày | `layout/main_layout.dart`, `layout/sidebar.dart` | Admin |

**Tổng thời gian ước tính Phase 3:** ~4-5 ngày làm việc.

---

## Phase 4 — Low (dọn dẹp / polish)

Không ảnh hưởng chức năng, làm khi còn thời gian trống — giúp codebase gọn hơn và giảm nhầm lẫn cho người đọc code sau này.

| ID | Mô tả | Ưu tiên | Độ khó | Thời gian | File ảnh hưởng | App |
|---|---|---|---|---|---|---|
| **P4-01** | Xoá các file dead code: 2 file rỗng, 2 màn hình không được route tới, 1 provider không ai dùng | Low | Thấp | 0.5 ngày | `features/auth/presentation/auth_gate.dart`, `features/auth/domain/admin_model.dart` (admin, rỗng); `features/attendance/presentation/checkin_screen.dart`, `gps_test_screen.dart`, `services/gps_provider.dart` (mobile) | Cả 2 |
| **P4-02** | Thay placeholder `Scaffold(body: Text('Nghỉ phép'))` bằng màn hình "Tính năng sắp ra mắt" tử tế hơn, hoặc ẩn tạm tab này khỏi bottom nav | Low | Thấp | 0.5 ngày | `core/router/app_router.dart`, `features/home/presentation/main_shell_screen.dart` | Mobile |
| **P4-03** | Xoá toán tử null-aware (`?.`) thừa trên field `startDate` vốn không nullable | Low | Thấp | <0.25 ngày | `features/leave/presentation/leave_provider.dart` | Admin |
| **P4-04** | Set màu tường minh cho `CircularProgressIndicator` trong `CustomButton` để đồng bộ với các loading indicator khác | Low | Thấp | <0.25 ngày | `shared/widgets/custom_button.dart` | Mobile |
| **P4-05** | Thay so khớp lỗi bằng chuỗi text (`e.toString().contains(...)`) bằng 1-2 exception class nhỏ gọn ngay trong file hiện có (không tạo layer/pattern mới) | Low | Thấp-Trung bình | 0.5-1 ngày | `features/attendance/data/attendance_repository.dart`, `features/attendance/presentation/attendance_provider.dart` | Mobile |

**Tổng thời gian ước tính Phase 4:** ~2-3 ngày làm việc.

---

## Ngoài phạm vi roadmap này (cố ý không đưa vào)

Các vấn đề sau **có thật** trong `REVIEW.md` nhưng bị loại khỏi roadmap vì cách khắc phục đúng đắn đòi hỏi vi phạm ràng buộc phạm vi đã nêu ở đầu tài liệu. Ghi nhận lại để không bị quên, nhưng cần một quyết định/lộ trình riêng (ngoài phạm vi "ổn định hoá" hiện tại):

| Vấn đề (REVIEW.md) | Vì sao không đưa vào roadmap này |
|---|---|
| Toàn vẹn dữ liệu GPS hoàn toàn dựa vào client (4.1) | Khắc phục đúng cần Cloud Function tính toán lại phía server — bị loại theo yêu cầu "không đề xuất Cloud Functions" |
| Xoá tài khoản Firebase Auth khi xoá nhân viên (4.5) | Cần Admin SDK/Cloud Function để xoá user Auth từ client — đã thay bằng giải pháp tạm ở P2-04 (ràng buộc UI) |
| Không có interface cho Repository (1.1) | Là thay đổi kiến trúc (Dependency Inversion) — bị loại theo yêu cầu "không đề xuất thay đổi kiến trúc" |
| Business logic nằm trong Repository, không tách use-case (1.2) | Cần thêm layer mới — bị loại theo yêu cầu "không refactor lớn" / "không Clean Architecture" |
| Không chia sẻ code giữa hai app, model trùng lặp (1.5, 12) | Khắc phục triệt để cần tách package dùng chung — bị loại theo yêu cầu "không tách package dùng chung"; các bug *cụ thể* phát sinh từ trùng lặp (rotationStartDate, nullability, nhãn hiển thị) đã được xử lý riêng lẻ ở P1-02, P1-04, P3-07 mà không cần gộp model |
| Chuyển `role`/`status`/`shift` sang `enum` (5.2) | Thay đổi kiểu dữ liệu xuyên suốt model — rủi ro refactor lớn hơn mức cần thiết cho "ổn định" |
| Tách `EmployeeFormNotifier` khỏi widget (1.3) | Thêm state-management layer mới cho 1 màn hình — không cần thiết để đạt "ổn định", chỉ là cải thiện phong cách code |
| `PaginatedDataTable` đầy đủ / rebuild theo `select` toàn diện (2.1, 2.2) | Đã có giải pháp nhẹ hơn, không refactor UI ở P3-01; rebuild-optimization toàn diện để dành cho đợt tối ưu hiệu năng riêng |
| Xây dựng đầy đủ tính năng "Nghỉ phép" ở mobile | Là tính năng mới (feature), không phải fix ổn định — đã xử lý phần UI gây hiểu lầm ở P4-02 |

---

## Thứ tự thực hiện đề xuất

1. **Phase 1 trọn vẹn trước tiên** — đây là các vấn đề có thể đang gây rò rỉ dữ liệu thật hoặc âm thầm phá dữ liệu nghiệp vụ ngay bây giờ.
2. **Phase 2** ngay sau đó, đặc biệt P2-02 (logging) nên làm sớm vì nó giúp phát hiện các vấn đề còn lại nhanh hơn trong quá trình làm Phase 3-4.
3. **Phase 3 và Phase 4** có thể xen kẽ theo thời gian rảnh của team, không có thứ tự bắt buộc giữa hai phase này.
