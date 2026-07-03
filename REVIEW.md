# REVIEW.md

> Đánh giá kỹ thuật dự án `attendance-system` với vai trò Senior Flutter Developer (10+ năm kinh nghiệm). Đây là tài liệu **chỉ đọc** — không có dòng code nào bị sửa trong quá trình review.
>
> Phạm vi: cả hai app (`attendance_mobile`, `attendance_admin`), tập trung vào kiến trúc, Flutter/Riverpod, Firebase, models, services/repository, routing, error handling, logging, UI, dead/duplicate code, bảo mật, hiệu năng và bug tiềm ẩn.

## Tóm tắt mức độ nghiêm trọng

| # | Vấn đề | Mức độ |
|---|---|---|
| 1 | Lưu credential/PII thật (email, UID, mật khẩu) trong source code | **Critical** |
| 2 | Toàn vẹn dữ liệu GPS chấm công hoàn toàn dựa vào client, không có rule server-side trong repo | **Critical** |
| 3 | Lưu cấu hình công ty (Settings screen) làm mất `rotationStartDate` → reset toàn bộ chu kỳ xoay ca | **Critical** |
| 4 | Phân quyền role/isActive chỉ kiểm tra ở client sau khi đăng nhập Firebase Auth | **High** |
| 5 | `double.parse`/`int.parse` không try-catch trong Settings screen | **High** |
| 6 | Mobile `AttendanceModel` ép kiểu cứng field có thể null → crash toàn bộ danh sách chấm công | **High** |
| 7 | Mật khẩu mặc định `123456` cho mọi nhân viên mới, không ép đổi mật khẩu lần đầu | **High** |
| 8 | So khớp lỗi bằng chuỗi text (`e.toString().contains(...)`) để quyết định luồng UI | **High** |
| 9 | Không có logging/crash reporting nào trong production | **High** |
| 10 | Admin đọc toàn bộ collection `attendance` không phân trang, lọc phía client | **High** |
| 11 | Hai cơ chế xác định lịch làm việc song song, không đồng bộ | **High** |
| 12 | Route dev ẩn `/dev/seed-departments` được build vào bản production | **Medium-High** |
| 13 | `EmployeeRepository.deleteEmployee` không xoá tài khoản Firebase Auth tương ứng | **Medium** |
| 14 | Không có interface/abstraction cho Repository → vi phạm DIP, không test được | **Medium** |
| 15 | Model trùng lặp hoàn toàn giữa hai app (7+ file) | **Medium-High** |
| 16 | `DashboardRepository._getWeeklyAttendance()` chạy 7 query tuần tự thay vì song song | **Medium** |
| 17 | Đọc lại `company_settings`/`users` dư thừa khi chuyển tháng lịch sử chấm công | **Medium** |
| 18 | Rebuild toàn bộ `HomeScreen` khi bất kỳ field nào trong state đổi (không dùng `select`) | **Medium** |
| 19 | Email bị `.toUpperCase()` trước khi đăng nhập ở mobile, không rõ lý do | **Medium** |
| 20 | UI không nhất quán: dialog xác nhận, màu thương hiệu, nhãn trạng thái/ca làm | **Medium** |
| 21 | Dead code: file rỗng, màn hình không route, provider không dùng, widget không dùng | **Medium** |
| 22 | Không có Firestore composite index file trong repo cho các query nhiều điều kiện | **Medium** |
| 23 | `authProvider` (Riverpod) tách rời hoàn toàn khỏi cơ chế bảo vệ route thực tế | **Low-Medium** |
| 24 | Lỗi kỹ thuật thô (`$err`, mã lỗi Firebase) hiển thị trực tiếp cho người dùng cuối | **Low** |
| 25 | `ConfirmDialog`/`Validators` (admin) được xây dựng đầy đủ nhưng không được dùng | **Low-Medium** |

---

## 1. Kiến trúc (Clean Architecture / SOLID / Separation of Concerns)

### 1.1 Không có interface cho Repository → vi phạm Dependency Inversion Principle
- **Mức độ:** Medium
- **Nguyên nhân:** Mọi `*Provider` (`attendanceRepositoryProvider`, `employeeRepositoryProvider`...) trả về **class cụ thể** (`Provider((ref) => AttendanceRepository())`), không có `abstract class IAttendanceRepository`. Notifier/Widget phụ thuộc trực tiếp vào implementation.
- **Cách khắc phục:** Định nghĩa interface cho mỗi repository, provider trả kiểu interface; cho phép override bằng fake/mock trong test qua `ProviderScope(overrides: [...])`.
- **File liên quan:** `*/data/*_repository.dart` và `*/presentation/*_provider.dart` ở cả hai app.

### 1.2 Business logic nằm trong Repository thay vì tầng domain/use-case riêng
- **Mức độ:** Medium
- **Nguyên nhân:** `AttendanceRepository.checkIn()`/`checkOut()` (mobile) vừa gọi Firestore, vừa tính khoảng cách GPS, vừa áp dụng quy tắc nghiệp vụ (giờ kết thúc ca, đi muộn/về sớm) trong cùng một method — không có lớp use-case/service nghiệp vụ tách biệt khỏi lớp truy cập dữ liệu.
- **Cách khắc phục:** Tách một `AttendanceService`/use-case nhận `Position` + `CompanySettingsModel` + `UserModel` làm input thuần, trả về quyết định (được phép check-in hay không, `isLate`, `status`...); Repository chỉ còn nhiệm vụ đọc/ghi Firestore.
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`

### 1.3 UI (widget) tự orchestrate side-effect + xử lý lỗi thay vì thông qua Controller/Notifier
- **Mức độ:** Medium
- **Nguyên nhân:** `EmployeeScreen._showEmployeeDialog()` gọi thẳng `ref.read(employeeRepositoryProvider).addEmployee(...)` bên trong `onPressed`, tự quản lý loading dialog (`showDialog` lồng nhau) và try/catch ngay trong widget — logic điều phối (orchestration) đáng lẽ thuộc về một Notifier.
- **Cách khắc phục:** Tạo `EmployeeFormNotifier extends StateNotifier<AsyncValue<void>>` tương tự cách `LeaveActionNotifier` đã làm đúng ở `leave_provider.dart`, để `EmployeeScreen` chỉ `ref.watch`/hiển thị.
- **File liên quan:** `attendance_admin/lib/features/employee/presentation/employee_screen.dart`

### 1.4 Hai cơ chế xác định "lịch làm việc" độc lập, không đồng bộ (SoC bị vi phạm ở cấp nghiệp vụ)
- **Mức độ:** High
- **Nguyên nhân:** `CompanySettingsModel.getCurrentShift()` (cấu hình động từ Firestore, chu kỳ `rotationDays`/`rotationStartDate`) và `WorkScheduleHelper` (mobile, hardcode mốc `2026-06-01` + quy tắc tuần chẵn/lẻ) đều tự quyết định "hôm nay là ngày gì / ca gì" nhưng không tham chiếu lẫn nhau. `home_provider.dart` dùng cả hai cho hai mục đích khác nhau trong cùng một màn hình.
- **Cách khắc phục:** Gộp thành một nguồn sự thật duy nhất (single source of truth) cho lịch làm việc, đọc từ `company_settings`, loại bỏ mốc ngày hardcode trong `WorkScheduleHelper`.
- **File liên quan:** `attendance_mobile/lib/core/utils/work_schedule_helper.dart`, `attendance_mobile/lib/features/settings/domain/company_settings_model.dart`, `attendance_admin/lib/features/settings/domain/company_settings_model.dart`

### 1.5 Không chia sẻ code giữa hai app (kiến trúc tổng thể)
- **Mức độ:** Medium (nguyên nhân gốc của nhiều vấn đề duplicate/model ở mục 5, 12)
- **Nguyên nhân:** Hai project Flutter độc lập, không dùng melos/workspace/package dùng chung — mọi model, helper, theme bị copy-paste.
- **Cách khắc phục:** Tách một package Dart thuần (`attendance_core`) chứa model, `DateHelper`, `Haversine`, hằng số `AppConfig`, rồi cả hai app cùng phụ thuộc vào package đó qua `path:` dependency.
- **File liên quan:** toàn bộ `*/domain/*.dart`, `*/core/utils/*.dart` ở cả hai app.

---

## 2. Flutter (Widget tree / Rebuild / Performance)

### 2.1 `HomeScreen` rebuild toàn bộ khi bất kỳ field nào trong `HomeState`/`AttendanceState` đổi
- **Mức độ:** Medium
- **Nguyên nhân:** `ref.watch(homeProvider)` và `ref.watch(attendanceProvider)` theo dõi **toàn bộ object state**; khi `isLoading` bật/tắt lúc check-in, cả `CustomScrollView` (bao gồm `HomeHeader`, `MonthlyStats`, `RecentAttendance`) đều rebuild dù chỉ `CheckinCard` cần thay đổi.
- **Cách khắc phục:** Dùng `ref.watch(homeProvider.select((s) => s.todayAttendance))` v.v. cho từng widget con, hoặc tách state thành nhiều provider nhỏ hơn theo từng phần UI.
- **File liên quan:** `attendance_mobile/lib/features/home/presentation/home_screen.dart`

### 2.2 Admin: `DataTable` không phân trang/virtualize cho danh sách toàn cục
- **Mức độ:** High (xem thêm mục 10, 14)
- **Nguyên nhân:** `AttendanceScreen`/`EmployeeScreen` build toàn bộ `DataRow` từ một list đã load hết vào bộ nhớ, không dùng `PaginatedDataTable`/`ListView.builder`. Với hàng nghìn bản ghi, thời gian build UI và bộ nhớ tăng tuyến tính không giới hạn.
- **Cách khắc phục:** Dùng `PaginatedDataTable` hoặc phân trang server-side bằng `startAfterDocument`/`limit()`.
- **File liên quan:** `attendance_admin/lib/features/attendance/presentation/attendance_screen.dart`

### 2.3 `SettingsScreen` gọi `addPostFrameCallback` mỗi lần `StreamProvider` emit
- **Mức độ:** Low
- **Nguyên nhân:** Trong `build()`, mỗi lần `settingsStreamProvider` phát dữ liệu mới (kể cả do chính client vừa `updateSettings()`), callback được đăng ký lại — không có vấn đề chức năng rõ ràng nhưng là anti-pattern (side-effect trong `build`) dễ gây khó đoán khi state phức tạp hơn.
- **Cách khắc phục:** Dùng `ref.listen` ở cấp `ConsumerStatefulWidget.build` thay vì `WidgetsBinding.addPostFrameCallback` lồng trong `.when(data: ...)`.
- **File liên quan:** `attendance_admin/lib/features/settings/presentation/settings_screen.dart`

### 2.4 `Image.network` cho logo không có cache đĩa
- **Mức độ:** Low
- **Nguyên nhân:** Logo UMC tải từ URL ngoài (`umcvietnam.vn`) mỗi lần cold-start, chỉ dựa vào `ImageCache` trong bộ nhớ (mất khi tắt app).
- **Cách khắc phục:** Dùng package `cached_network_image` hoặc nhúng logo local (đã có sẵn `assets/logo_umc.jpg` ở admin, mobile lại tải qua mạng).
- **File liên quan:** `attendance_mobile/lib/features/home/presentation/widgets/home_header.dart`

---

## 3. Riverpod (Provider / State Management / DI)

### 3.1 `gpsProvider`/`GpsNotifier` là provider "mồ côi", không được dùng trong luồng thực tế
- **Mức độ:** Medium (trùng với mục Dead code)
- **Nguyên nhân:** `AttendanceRepository` tự tạo `GpsService()` trực tiếp (`final GpsService _gpsService = GpsService();`) thay vì nhận qua constructor/Riverpod, khiến `gpsProvider` không được widget nào tiêu thụ và không thể mock khi test.
- **Cách khắc phục:** Inject `GpsService` vào `AttendanceRepository` qua constructor, và để `attendanceRepositoryProvider` cung cấp nó từ `gpsServiceProvider`.
- **File liên quan:** `attendance_mobile/lib/services/gps_provider.dart`, `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`

### 3.2 `HomeNotifier` tự `new AttendanceRepository()` thay vì nhận qua provider
- **Mức độ:** Low-Medium
- **Nguyên nhân:** Không nhất quán với các Notifier khác (`AttendanceNotifier` nhận `AttendanceRepository` qua constructor từ `ref.read(attendanceRepositoryProvider)`), khiến `homeProvider` không thể override dependency khi test.
- **Cách khắc phục:** `HomeNotifier(this._repo)` nhận repository qua constructor, `homeProvider` build bằng `ref.watch(attendanceRepositoryProvider)`.
- **File liên quan:** `attendance_mobile/lib/features/home/presentation/home_provider.dart`

### 3.3 Không nhất quán chính sách `autoDispose`
- **Mức độ:** Low
- **Nguyên nhân:** Chỉ `dashboardStatsProvider` dùng `.autoDispose`; các `StreamProvider` khác (`employeesStreamProvider`, `attendanceStreamProvider`, `leaveRequestsStreamProvider`, `settingsStreamProvider`) sống suốt vòng đời app dù người dùng rời khỏi tab tương ứng trong `ShellRoute` — do `ShellRoute` giữ toàn bộ cây widget nên có thể là chủ đích, nhưng không có ghi chú/quyết định rõ ràng.
- **Cách khắc phục:** Quyết định rõ chính sách theo từng provider (nên `autoDispose` cho stream nặng, ít dùng) và ghi chú lý do.
- **File liên quan:** `attendance_admin/lib/features/*/presentation/*_provider.dart`

### 3.4 `authProvider` (Riverpod) không liên thông với cơ chế bảo vệ route thực tế
- **Mức độ:** Low-Medium (chi tiết ở mục Routing/Authentication)
- **Nguyên nhân:** `authProvider` chỉ chứa `isLoading`/`error` để hiển thị trên form login; toàn bộ quyết định "đã đăng nhập hay chưa" nằm ở `FirebaseAuth.instance` được đọc trực tiếp trong `GoRouter.redirect`, tạo ra hai nguồn trạng thái auth riêng biệt trong cùng một app.
- **Cách khắc phục:** Có một `authStateProvider` (StreamProvider bọc `authStateChanges()`) làm nguồn sự thật duy nhất, cả router lẫn UI form đều `watch` từ đó.
- **File liên quan:** `*/features/auth/presentation/auth_provider.dart`, `*/core/router/app_router.dart` hoặc `*/routes/app_router.dart`

---

## 4. Firebase (Authentication / Firestore / Security / Data structure)

### 4.1 Toàn vẹn dữ liệu chấm công GPS hoàn toàn dựa vào client
- **Mức độ:** Critical
- **Nguyên nhân:** `latitude`, `longitude`, `distance`, `isLate`, `isEarlyLeave`, `status` đều được **tính toán trên thiết bị** rồi ghi thẳng vào Firestore qua `.set()`/`.update()`. Cơ chế chống gian lận duy nhất là kiểm tra `Position.isMocked`, vốn không phát hiện được nhiều công cụ giả lập vị trí (đặc biệt trên Android đã root hoặc app đã bị chỉnh sửa để tự fabricate `Position`/gọi thẳng Firestore SDK với dữ liệu tuỳ ý). Đây là rủi ro cốt lõi cho một hệ thống mà mục đích chính là đảm bảo tính xác thực của dữ liệu chấm công.
- **Cách khắc phục:** Chuyển việc tính `distance`/`isLate`/`status` sang Cloud Function (Callable Function) nhận toạ độ thô, tự tính toán và ghi bằng quyền Admin SDK; Firestore Security Rules chặn client ghi trực tiếp các field này.
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`, `attendance_mobile/lib/services/gps_service.dart`

### 4.2 Không có Firestore Security Rules trong repo để xác minh phân quyền server-side
- **Mức độ:** High (không thể xác nhận rules thực tế trên Firebase Console)
- **Nguyên nhân:** Không tìm thấy file `firestore.rules` nào trong repo. Toàn bộ kiểm tra `role`/`isActive` chỉ nằm trong `AuthRepository.login()`/`signIn()` ở tầng ứng dụng Dart — một client bị sửa đổi (hoặc gọi thẳng Firestore REST API) có thể bỏ qua hoàn toàn các kiểm tra này nếu rules không siết chặt tương ứng.
- **Cách khắc phục:** Viết & version-control `firestore.rules` xác thực `request.auth.uid`, đối chiếu `role`/`isActive` ngay trong rules cho từng collection (`users`, `attendance`, `company_settings`, `departments`, `leave_requests`).
- **File liên quan:** không có file — đề xuất thêm `firestore.rules` ở gốc mỗi app hoặc gốc repo.

### 4.3 Doc ID `attendance` dựa vào giờ local của thiết bị, không có timestamp server-side đối chiếu
- **Mức độ:** High
- **Nguyên nhân:** `DateHelper.toDateString(DateTime.now())` và toàn bộ tính toán đi muộn/về sớm dùng `DateTime.now()` phía client. Người dùng chỉnh giờ hệ thống điện thoại có thể chấm công vào "ngày" hoặc "giờ" khác với thực tế, hoặc chấm công 2 lần cho 2 "ngày ảo" khác nhau trong cùng một ngày thực.
- **Cách khắc phục:** Dùng `FieldValue.serverTimestamp()` làm nguồn thời gian chính thức, tính `isLate`/ngày thông qua Cloud Function (đi kèm khắc phục mục 4.1).
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`, `attendance_mobile/lib/core/utils/date_helper.dart`

### 4.4 Không có file cấu hình composite index cho các query nhiều điều kiện
- **Mức độ:** Medium
- **Nguyên nhân:** Các query như `where('uid', ...).where('attendanceDate', isGreaterThanOrEqualTo: ...).where('attendanceDate', isLessThanOrEqualTo: ...)` hoặc `where('uid', ...).orderBy('attendanceDate')` cần composite index; không có `firestore.indexes.json` trong repo để deploy đồng bộ theo môi trường/project mới.
- **Cách khắc phục:** Chạy `firebase firestore:indexes` lấy cấu hình hiện tại và commit `firestore.indexes.json`.
- **File liên quan:** `attendance_mobile/lib/features/home/presentation/home_provider.dart`, `attendance_mobile/lib/features/attendance/presentation/attendance_history_provider.dart`, `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`

### 4.5 `EmployeeRepository.deleteEmployee` không xoá tài khoản Firebase Auth tương ứng
- **Mức độ:** Medium
- **Nguyên nhân:** Chỉ `_db.collection('users').doc(id).delete()`, không gọi API xoá Auth user (vốn cần Admin SDK/Cloud Function vì client không tự xoá tài khoản người khác). Tài khoản Auth "mồ côi" vẫn tồn tại vĩnh viễn, email không thể tái sử dụng để tạo nhân viên mới, và về lý thuyết tài khoản cũ vẫn có thể "tồn tại" cho các luồng auth khác (reset password...) dù không login được vào app.
- **Cách khắc phục:** Viết Cloud Function `onDeleteEmployee` (Firestore trigger) hoặc Callable Function dùng Admin SDK để xoá cả `auth.users` khi xoá `users/{id}`.
- **File liên quan:** `attendance_admin/lib/features/employee/data/employee_repository.dart`

---

## 5. Models (Naming / Validation / Serialization)

### 5.1 Nullability của `AttendanceModel` lệch nhau giữa hai app → rủi ro crash
- **Mức độ:** High (xem chi tiết ở mục 15.2 — Potential bugs)
- **Nguyên nhân:** Bản mobile ép kiểu cứng `(data['attendanceDate'] as Timestamp).toDate()` (không cho phép null), trong khi bản admin coi field này là nullable (`DateTime?`). Cùng một collection Firestore nhưng hai "hợp đồng" dữ liệu khác nhau.
- **Cách khắc phục:** Thống nhất một schema (nên làm `attendanceDate` nullable ở cả hai, có `?? fallback` an toàn khi parse).
- **File liên quan:** `attendance_mobile/lib/features/attendance/domain/attendance_model.dart`, `attendance_admin/lib/features/attendance/domain/attendance_model.dart`

### 5.2 Không có validation ở tầng model
- **Mức độ:** Medium
- **Nguyên nhân:** `role`, `status`, `shift` chỉ là `String` tự do, không dùng `enum`. Một giá trị sai chính tả (`"aproved"` thay vì `"approved"`) sẽ không gây lỗi biên dịch/runtime rõ ràng, chỉ lặng lẽ rơi vào nhánh `default` của `switch` khi hiển thị label.
- **Cách khắc phục:** Chuyển các trường trạng thái sang `enum` (`enum LeaveStatus { pending, approved, rejected }`) với hàm `fromString`/`toString` tường minh, fail-fast khi gặp giá trị lạ (log cảnh báo thay vì âm thầm bỏ qua).
- **File liên quan:** toàn bộ `*/domain/*_model.dart`

### 5.3 Serialization thủ công lặp lại, dễ thiếu field
- **Mức độ:** Medium
- **Nguyên nhân:** Không dùng `json_serializable`/`freezed`; mỗi model tự viết `fromFirestore`/`toFirestore`. `UserModel.toFirestore()` (mobile) dùng `Timestamp.fromDate(createdAt)` cứng, còn `EmployeeModel.toFirestore()` (admin, ghi cùng collection `users`) lại dùng `createdAt != null ? ... : FieldValue.serverTimestamp()` — hai cách xử lý timestamp khác nhau cho cùng một field của cùng một collection.
- **Cách khắc phục:** Áp dụng code-gen (`freezed`/`json_serializable`) hoặc ít nhất thống nhất một quy ước xử lý timestamp dùng chung.
- **File liên quan:** `attendance_mobile/lib/features/auth/domain/user_model.dart`, `attendance_admin/lib/features/employee/domain/employee_model.dart`

### 5.4 Đặt tên: `EmployeeModel` (admin) và `UserModel` (mobile) là hai model cho cùng một collection `users`
- **Mức độ:** Low
- **Nguyên nhân:** Field gần như trùng khớp 100% nhưng tên class khác nhau, gây khó khăn khi onboard người mới hoặc tìm kiếm code liên quan đến "user" trong toàn repo.
- **Cách khắc phục:** Đặt tên nhất quán (ví dụ cả hai đều gọi là `UserModel` hoặc `EmployeeModel`) nếu tách package chung (mục 1.5).
- **File liên quan:** `attendance_mobile/lib/features/auth/domain/user_model.dart`, `attendance_admin/lib/features/employee/domain/employee_model.dart`

---

## 6. Services & Repository

### 6.1 Lỗi nghiệp vụ được throw dưới dạng `Exception(String)` không có mã lỗi
- **Mức độ:** High (chi tiết ở mục 8.2)
- **Nguyên nhân:** Không có custom exception class (`class OutsideRadiusException implements Exception`), toàn bộ lỗi là `Exception('chuỗi tiếng Việt')`.
- **Cách khắc phục:** Định nghĩa các exception class riêng cho từng loại lỗi nghiệp vụ (đã hết ca, đã check-in, ngoài bán kính...), UI switch theo `is ExceptionType` thay vì so khớp chuỗi.
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`

### 6.2 Đoạn code kiểm tra bán kính GPS lặp lại y hệt trong `checkIn()` và `checkOut()`
- **Mức độ:** Low-Medium (trùng mục Duplicate code)
- **Nguyên nhân:** Cùng khối "tính distance → so sánh radius → throw" được viết lại nguyên văn ở cả hai hàm trong cùng một file.
- **Cách khắc phục:** Trích xuất thành private method `Future<Position> _getValidatedPosition(CompanySettingsModel settings)`.
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (dòng ~48-74 và ~289-315)

### 6.3 Admin `AttendanceRepository`/`DashboardRepository` không có caching hay giới hạn — mỗi widget tự gọi lại
- **Mức độ:** Medium (xem mục 14)
- **Nguyên nhân:** Không có tầng cache/dedupe giữa các repository độc lập cho cùng dữ liệu `attendance`.
- **Cách khắc phục:** Cân nhắc một `attendanceRepositoryProvider` dùng chung giữa Dashboard và Attendance screen, hoặc giới hạn field/limit truy vấn theo nhu cầu thực tế của từng màn hình thay vì luôn lấy toàn bộ collection.
- **File liên quan:** `attendance_admin/lib/features/dashboard/data/dashboard_repository.dart`, `attendance_admin/lib/features/attendance/data/attendance_repository.dart`

---

## 7. Routing

### 7.1 Admin router không có `refreshListenable` theo dõi trạng thái đăng nhập
- **Mức độ:** Medium-High
- **Nguyên nhân:** `redirect` đọc `FirebaseAuth.instance.currentUser` tại thời điểm điều hướng, không lắng nghe `authStateChanges()` như bản mobile. Nếu phiên bị vô hiệu hoá (token thu hồi, tài khoản bị khoá) khi admin đang ở giữa một trang, app sẽ không tự động đẩy về `/login` cho đến khi có điều hướng khác xảy ra.
- **Cách khắc phục:** Thêm `refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges())` giống bản mobile.
- **File liên quan:** `attendance_admin/lib/routes/app_router.dart`

### 7.2 Route dev ẩn `/dev/seed-departments` được biên dịch vào bản production
- **Mức độ:** Medium-High
- **Nguyên nhân:** Route này nằm trong `routerProvider` chính thức (không tách build flavor/config riêng cho dev), chỉ cần biết URL và đã đăng nhập admin là có thể kích hoạt `batch.set()` ghi đè collection `departments`.
- **Cách khắc phục:** Bọc bằng `kDebugMode`/build flavor riêng, hoặc xoá khỏi router production và chỉ chạy seeder qua script/CLI nội bộ.
- **File liên quan:** `attendance_admin/lib/routes/app_router.dart`, `attendance_admin/lib/dev/department_seeder.dart`

### 7.3 Tab "Nghỉ phép" (mobile) là placeholder tĩnh trong route chính thức
- **Mức độ:** Medium
- **Nguyên nhân:** `GoRoute(path: '/leave', builder: (_, __) => const Scaffold(body: Center(child: Text('Nghỉ phép'))))` — tính năng chưa hoàn thiện nhưng đã lên bottom-nav chính thức, người dùng thật sẽ thấy màn hình trống.
- **Cách khắc phục:** Ẩn tab khỏi bottom nav cho tới khi hoàn thiện, hoặc hoàn thiện luồng tạo/xem đơn nghỉ phép (model `LeaveRequestModel` đã có sẵn ở mobile nhưng chưa có repository/provider/UI).
- **File liên quan:** `attendance_mobile/lib/core/router/app_router.dart`, `attendance_mobile/lib/features/home/presentation/main_shell_screen.dart`

---

## 8. Error Handling

### 8.1 `double.parse`/`int.parse` không được bọc try-catch, validator không kiểm tra định dạng số
- **Mức độ:** High (bug cụ thể, tái hiện được)
- **Nguyên nhân:** `_buildTextField()` dùng validator chung `v == null || v.isEmpty ? 'Không được để trống' : null` cho cả các field số (Latitude, Longitude, Radius, Chu kỳ xoay ca). `_saveSettings()` gọi `double.parse(...)`/`int.parse(...)` **ngoài khối try-catch** khi build `CompanySettingsModel`. Nếu admin gõ ký tự không phải số (ví dụ dán nhầm text), form vẫn "hợp lệ" (không rỗng) nhưng `parse` sẽ ném `FormatException` không được bắt, gây crash/luồng lưu cấu hình bị treo không rõ nguyên nhân với người dùng.
- **Cách khắc phục:** Dùng `Validators.numeric` (đã có sẵn trong `core/utils/validators.dart` nhưng không được dùng!) cho các field số, và đưa toàn bộ việc dựng `CompanySettingsModel` vào trong khối `try`.
- **File liên quan:** `attendance_admin/lib/features/settings/presentation/settings_screen.dart` (hàm `_saveSettings`, dòng ~205-218)

### 8.2 So khớp lỗi bằng nội dung chuỗi (string matching) để điều khiển luồng UI
- **Mức độ:** High
- **Nguyên nhân:** `attendance_provider.dart` (mobile) dùng `e.toString().contains('Ca làm việc đã kết thúc')` để quyết định set `isShiftEnded = true`; `change_password_page.dart` dùng `errorMsg.contains('wrong-password')`. Chỉ cần đổi một chữ trong message tiếng Việt ở Repository là logic UI hỏng âm thầm, không có cảnh báo lúc biên dịch.
- **Cách khắc phục:** Dùng custom Exception class hoặc mã lỗi (`errorCode`) thay vì so khớp câu chữ hiển thị.
- **File liên quan:** `attendance_mobile/lib/features/attendance/presentation/attendance_provider.dart`, `attendance_mobile/lib/features/auth/presentation/change_password_page.dart`

### 8.3 Hiển thị lỗi kỹ thuật thô trực tiếp cho người dùng cuối
- **Mức độ:** Low
- **Nguyên nhân:** `error: (err, _) => Center(child: Text('Lỗi: $err'))` xuất hiện ở nhiều màn hình admin (Dashboard, Attendance, Employee, Leave, Settings) — hiển thị nguyên văn exception/mã lỗi Firestore cho end-user.
- **Cách khắc phục:** Map lỗi kỹ thuật sang thông điệp thân thiện, log chi tiết kỹ thuật ở nơi khác (xem mục 9).
- **File liên quan:** `attendance_admin/lib/features/*/presentation/*_screen.dart`

---

## 9. Logging

### 9.1 Không có logging/crash reporting nào trong mã nguồn production
- **Mức độ:** High
- **Nguyên nhân:** Không có package logging (`logger`, `firebase_crashlytics`, `sentry`...) trong `pubspec.yaml` của cả hai app. Toàn bộ lỗi trong Repository/Notifier chỉ được `catch` và chuyển thành `String` hiển thị lên UI (SnackBar/Text) — nếu người dùng đóng thông báo mà không chụp màn hình, sự cố **không để lại dấu vết nào** để dev điều tra sau này. Với một hệ thống chấm công ảnh hưởng trực tiếp đến lương, đây là thiếu sót vận hành nghiêm trọng.
- **Cách khắc phục:** Tích hợp `firebase_crashlytics` (đã sẵn Firebase project) hoặc tối thiểu `debugPrint`/`log()` có cấu trúc ở mọi nhánh `catch`, kèm gửi lỗi nghiêm trọng lên Crashlytics/Sentry.
- **File liên quan:** toàn bộ `*/data/*_repository.dart`, `*/presentation/*_provider.dart` (không có file logging nào để trỏ tới)

### 9.2 `print()` còn sót trong code (dev scripts)
- **Mức độ:** Low
- **Nguyên nhân:** `create_test_user.dart`, `demo_seeder.dart`, `seed_firestore.dart` dùng `print()` — chấp nhận được cho dev tooling nhưng các file này vẫn được biên dịch vào app bundle dù không được gọi từ `main.dart` (chỉ `main_dev.dart` gọi `demo_seeder.dart`).
- **Cách khắc phục:** Đảm bảo các file `dev/` không được import bởi entrypoint production (`main.dart`) — hiện tại `create_test_user.dart` được `main_dev.dart` import nhưng không gọi hàm nào (dead import) và `main.dart` (chính thức) không đụng tới các file dev, nên không rủi ro runtime, nhưng nên tách hẳn ra ngoài `lib/` (ví dụ thư mục `tool/`) để không đóng gói vào app.
- **File liên quan:** `attendance_mobile/lib/dev/*.dart`

---

## 10. UI consistency

### 10.1 Màu thương hiệu UMC bị hardcode ở nhiều nơi dưới nhiều dạng khác nhau
- **Mức độ:** Medium
- **Nguyên nhân:** `AppColors.primary` (`#B91C1C` — admin) được dùng ở phần lớn nơi, nhưng `main_layout.dart` và `sidebar.dart` lại hardcode trực tiếp `Color(0xFFB91C1C)`/`Color(0xFFB91C1C)` thay vì tham chiếu `AppColors.primary`. Đổi màu thương hiệu trong tương lai sẽ phải tìm-và-sửa thủ công thay vì sửa một chỗ.
- **Cách khắc phục:** Luôn dùng `AppColors.primary`, không hardcode mã hex trực tiếp trong widget.
- **File liên quan:** `attendance_admin/lib/layout/main_layout.dart`, `attendance_admin/lib/layout/sidebar.dart`

### 10.2 Dialog xác nhận không nhất quán — có widget dùng chung nhưng không được dùng
- **Mức độ:** Medium
- **Nguyên nhân:** `ConfirmDialog` (đầy đủ, có `isDanger`, style chuẩn) tồn tại trong `shared/widgets/` nhưng `EmployeeScreen._showDeleteConfirm()` và `LeaveScreen._showDecisionDialog()` tự dựng `AlertDialog` riêng với style/màu nút khác nhau.
- **Cách khắc phục:** Thay các `AlertDialog` thủ công bằng `ConfirmDialog.show(...)` đã có sẵn.
- **File liên quan:** `attendance_admin/lib/shared/widgets/confirm_dialog.dart`, `attendance_admin/lib/features/employee/presentation/employee_screen.dart`, `attendance_admin/lib/features/leave/presentation/leave_screen.dart`

### 10.3 Nhãn hiển thị ca làm việc không khớp nhau giữa hai app cho cùng dữ liệu
- **Mức độ:** Medium
- **Nguyên nhân:** Với cùng giá trị `shift == 'day'`: mobile `AttendanceModel.shiftLabel` hiển thị **"Ca ngày"**, còn admin `AttendanceModel.shiftLabel` hiển thị **"Ca sáng"**. Nhân viên và quản trị viên nhìn cùng một bản ghi nhưng thấy hai cách gọi tên ca khác nhau.
- **Cách khắc phục:** Thống nhất nhãn hiển thị (đi kèm việc gộp model ở mục 1.5/15).
- **File liên quan:** `attendance_mobile/lib/features/attendance/domain/attendance_model.dart` (dòng ~220-231), `attendance_admin/lib/features/attendance/domain/attendance_model.dart` (dòng ~81-87)

### 10.4 Loading indicator không nhất quán màu sắc
- **Mức độ:** Low
- **Nguyên nhân:** Đa số nơi loading dùng `color: AppColors.primary` tường minh; riêng `CustomButton` (dùng cho nút Đăng nhập, Đổi mật khẩu) dùng `CircularProgressIndicator()` mặc định không set màu.
- **Cách khắc phục:** Set `color: Colors.white` (tương phản với nền nút màu primary) hoặc theo `AppColors` thống nhất.
- **File liên quan:** `attendance_mobile/lib/shared/widgets/custom_button.dart`

---

## 11. Dead code

| File | Mô tả | Mức độ |
|---|---|---|
| `attendance_admin/lib/features/auth/presentation/auth_gate.dart` | File rỗng (0 dòng), không được import ở đâu | Low |
| `attendance_admin/lib/features/auth/domain/admin_model.dart` | File rỗng (0 dòng), không được dùng | Low |
| `attendance_mobile/lib/features/attendance/presentation/checkin_screen.dart` | Màn hình đầy đủ nhưng không được route tới (bị thay bởi `CheckinCard` nhúng trong `HomeScreen`) | Medium |
| `attendance_mobile/lib/features/attendance/presentation/gps_test_screen.dart` | Không được route tới | Low |
| `attendance_mobile/lib/services/gps_provider.dart` | `gpsProvider`/`GpsNotifier` không được widget/repository nào tiêu thụ | Medium |
| `attendance_admin/lib/core/utils/validators.dart` | `Validators` (email/phone/password/numeric...) không được gọi ở bất kỳ form nào trong admin | Medium (đáng lẽ nên dùng để sửa mục 8.1) |
| `attendance_admin/lib/shared/widgets/confirm_dialog.dart` | `ConfirmDialog` không được gọi ở đâu (xem mục 10.2) | Medium |
| `attendance_mobile/lib/features/home/presentation/widgets/shift_selector.dart` qua `checkin_card.dart` | `ShiftSelector` luôn được truyền `enabled: false` ("Luôn khóa, ca được tự động xác định") → nhánh `onTap`/`onShiftChanged`/`HomeNotifier.selectShift()` không bao giờ được kích hoạt trong production | Low |

**Cách khắc phục chung:** xoá các file rỗng/không dùng, hoặc nếu giữ lại cho roadmap tương lai thì thêm ghi chú `// TODO` giải thích lý do giữ, tránh gây nhầm lẫn cho người đọc code sau này.

---

## 12. Duplicate code

| Nội dung trùng lặp | Vị trí | Mức độ |
|---|---|---|
| `CompanySettingsModel` (bao gồm cả logic nghiệp vụ xoay ca — xem mục 15.1 để thấy hậu quả) | mobile & admin `features/settings/domain/company_settings_model.dart` | **High** |
| `AttendanceModel` (nullability lệch nhau — mục 5.1) | mobile & admin `features/attendance/domain/attendance_model.dart` | High |
| `LeaveRequestModel`, `NotificationModel`, `DepartmentModel` | mobile & admin tương ứng | Medium |
| `DateHelper` | mobile & admin `core/utils/date_helper.dart` | Low |
| `AppColors`/`AppSpacing`/`AppTextStyles`/`AppTheme` | mobile & admin `shared/theme/*.dart` | Low |
| Khối kiểm tra bán kính GPS lặp trong cùng 1 file (mục 6.2) | `attendance_mobile/.../attendance_repository.dart` | Low-Medium |
| Logic màu/nhãn trạng thái chấm công (late/early/absent) cài lại ≥3 nơi với màu khác nhau | `AttendanceModel.statusLabel` (x2), `AttendanceStatusBadges`, `AttendanceScreen._buildStatusBadge` | Medium |
| Validate mật khẩu tối thiểu 6 ký tự viết tay lặp lại ≥3 nơi thay vì tái dùng `Validators.password` | `login_form.dart`, `change_password_page.dart`, `employee_screen.dart` | Low |

**Cách khắc phục chung:** tách package Dart dùng chung (mục 1.5) cho model/helper; với các đoạn logic UI lặp (status badge), tạo một widget/hàm dùng chung duy nhất.

---

## 13. Security risks

### 13.1 Credential/PII thật bị commit vào source code
- **Mức độ:** Critical
- **Nguyên nhân:** `create_test_user.dart` hardcode một email Gmail thật kèm mật khẩu `'123456'` để `createUserWithEmailAndPassword`. `demo_seeder.dart` hardcode 4 UID Firebase Auth thật và email cá nhân thật (Gmail cá nhân, email trường đại học) trực tiếp trong mã nguồn — nếu repo này từng/đang được push lên một remote (GitHub...), đây là rò rỉ thông tin cá nhân và mật khẩu ra công khai (hoặc ít nhất cho bất kỳ ai có quyền đọc repo).
- **Cách khắc phục:** Xoá mật khẩu/email/UID thật khỏi source, dùng biến môi trường (`--dart-define`) hoặc file cấu hình cục bộ nằm trong `.gitignore` cho dữ liệu seed; đổi mật khẩu của các tài khoản demo/test đã bị lộ.
- **File liên quan:** `attendance_mobile/lib/dev/create_test_user.dart`, `attendance_mobile/lib/dev/demo_seeder.dart`

### 13.2 Toàn vẹn dữ liệu GPS dựa hoàn toàn vào client (xem chi tiết mục 4.1)
- **Mức độ:** Critical

### 13.3 Phân quyền role/isActive chỉ enforce ở tầng client (xem chi tiết mục 4.2)
- **Mức độ:** High

### 13.4 Mật khẩu mặc định yếu, có thể đoán được cho mọi tài khoản nhân viên mới
- **Mức độ:** High
- **Nguyên nhân:** `passwordController = TextEditingController(text: '123456')` — form tạo nhân viên gợi ý sẵn `123456` làm mật khẩu, validator chỉ yêu cầu tối thiểu 6 ký tự. Không thấy cờ "bắt buộc đổi mật khẩu lần đầu đăng nhập" được kiểm tra ở đâu (có `change_password_page.dart` nhưng không bị ép dùng).
- **Cách khắc phục:** Sinh mật khẩu ngẫu nhiên mạnh cho mỗi tài khoản mới, gửi qua kênh riêng (email), và thêm field `mustChangePassword: true` buộc điều hướng tới `change_password_page.dart` ngay sau lần đăng nhập đầu tiên.
- **File liên quan:** `attendance_admin/lib/features/employee/presentation/employee_screen.dart` (dòng 20)

### 13.5 Route dev ẩn trong bản production (xem chi tiết mục 7.2)
- **Mức độ:** Medium-High

### 13.6 Tài khoản Firebase Auth "mồ côi" sau khi xoá nhân viên (xem chi tiết mục 4.5)
- **Mức độ:** Medium

---

## 14. Performance issues

### 14.1 Đọc toàn bộ collection `attendance` không giới hạn (xem chi tiết mục 2.2)
- **Mức độ:** High

### 14.2 `DashboardRepository._getWeeklyAttendance()` chạy 7 query Firestore tuần tự
- **Mức độ:** Medium
- **Nguyên nhân:** Vòng `for (int i = 6; i >= 0; i--)` gọi `await _db.collection('attendance')...get()` từng cái một thay vì `Future.wait` — tổng thời gian tải Dashboard bằng tổng độ trễ mạng của 7 request cộng lại thay vì độ trễ của request chậm nhất.
- **Cách khắc phục:** Gom 7 query vào `Future.wait([...])` chạy song song, hoặc — tốt hơn — dùng một query range 7 ngày rồi group theo ngày ở client.
- **File liên quan:** `attendance_admin/lib/features/dashboard/data/dashboard_repository.dart` (dòng ~74-89)

### 14.3 Đọc dư thừa `company_settings` + `users` mỗi lần chuyển tháng ở Lịch sử chấm công
- **Mức độ:** Medium
- **Nguyên nhân:** `AttendanceHistoryNotifier.loadRecords()` luôn `await _db.collection('company_settings').doc(...).get()` và `await _db.collection('users').doc(uid).get()` mỗi lần gọi (kể cả khi chỉ chuyển tháng trước/sau), trong khi `HomeNotifier` gần như luôn đã có sẵn dữ liệu này trong bộ nhớ.
- **Cách khắc phục:** Tạo `FutureProvider`/`StreamProvider` dùng chung cho "company settings hiện tại" và "user hiện tại", các Notifier khác `ref.watch` thay vì tự query lại.
- **File liên quan:** `attendance_mobile/lib/features/attendance/presentation/attendance_history_provider.dart` (dòng ~103-109)

### 14.4 Rebuild diện rộng không cần thiết (xem chi tiết mục 2.1)
- **Mức độ:** Medium

---

## 15. Potential bugs

### 15.1 [Nghiêm trọng nhất] Lưu cấu hình ở Admin Settings screen xoá mất `rotationStartDate`, reset toàn bộ chu kỳ xoay ca
- **Mức độ:** Critical
- **Nguyên nhân (chi tiết kỹ thuật, đã xác minh qua code):**
  1. `CompanySettingsModel` bản admin (`attendance_admin/lib/features/settings/domain/company_settings_model.dart`) có `rotationStartDate` là tham số **optional, không bắt buộc** (`this.rotationStartDate` không có `required`).
  2. `SettingsScreen._saveSettings()` dựng `CompanySettingsModel` mới **không hề truyền `rotationStartDate`** (form UI cũng không có ô nhập cho field này) → giá trị mặc định là `null`.
  3. `toFirestore()` của model này viết tường minh `'rotationStartDate': rotationStartDate != null ? ... : null` — tức là **luôn ghi key `rotationStartDate` vào map, kể cả khi null**.
  4. `SettingsRepository.updateSettings()` gọi `.set(settings.toFirestore(), SetOptions(merge: true))`. Với `merge: true`, Firestore **chỉ bỏ qua các key hoàn toàn không có mặt trong map** — nhưng vì `rotationStartDate` **có mặt** trong map với giá trị `null`, Firestore sẽ **ghi đè field đó thành `null`** trong document thực tế.
  5. Hậu quả: **mỗi lần admin bấm "Lưu cấu hình"** (dù chỉ để đổi tên công ty hay bán kính GPS), field `rotationStartDate` trong `company_settings/main` bị xoá về `null`.
  6. Phía mobile, `CompanySettingsModel.fromFirestore()` xử lý field null bằng fallback `DateTime.now()` — nghĩa là **mốc gốc của toàn bộ chu kỳ xoay ca 14 ngày bị reset về "hôm nay"** ngay sau khi admin lưu cấu hình, làm **toàn bộ nhân viên có thể bị đảo lộn ca làm việc (ca ngày ↔ ca đêm)** một cách không chủ đích, không có cảnh báo nào cho admin.
- **Cách khắc phục:** (1) Thêm ô nhập/hiển thị `rotationStartDate` vào `SettingsScreen` và luôn round-trip giá trị hiện có; hoặc (2) sửa `SettingsRepository.updateSettings()`/`_saveSettings()` để chỉ gửi các field thực sự có trên form (loại bỏ `rotationStartDate`/`updatedAt` khỏi map thay vì gửi `null`); (3) về lâu dài, gộp một `CompanySettingsModel` duy nhất giữa hai app (mục 1.5) để tránh lệch schema như thế này tái diễn.
- **File liên quan:** `attendance_admin/lib/features/settings/presentation/settings_screen.dart` (hàm `_saveSettings`), `attendance_admin/lib/features/settings/domain/company_settings_model.dart`, `attendance_admin/lib/features/settings/data/settings_repository.dart`, hệ quả ở `attendance_mobile/lib/features/settings/domain/company_settings_model.dart` (dòng 69-74, fallback `DateTime.now()`)

### 15.2 Mobile `AttendanceModel.fromFirestore` có thể crash toàn bộ danh sách chấm công vì ép kiểu cứng
- **Mức độ:** High
- **Nguyên nhân:** `attendanceDate: (data['attendanceDate'] as Timestamp).toDate()` không có null-check, nhưng chính admin model (ghi vào cùng collection) coi field này là nullable, và mobile lẫn admin đều có khái niệm "bản ghi ảo" (`virtual_$day`) ngụ ý dữ liệu không hoàn chỉnh là chuyện bình thường. Nếu bất kỳ document thật nào trong Firestore từng thiếu field này (do lỗi ghi, migration cũ, hoặc thao tác tay trên Console), toàn bộ `snapshot.docs.map((doc) => AttendanceModel.fromFirestore(doc))` sẽ ném exception ngay tại phần tử lỗi, làm hỏng **toàn bộ danh sách** (không phải chỉ 1 dòng) vì không có try-catch per-item.
- **Cách khắc phục:** Bọc từng `fromFirestore` trong try-catch, bỏ qua/log riêng document lỗi thay vì để cả `.map()` throw; đồng thời làm field nullable với fallback hợp lý như bản admin.
- **File liên quan:** `attendance_mobile/lib/features/attendance/domain/attendance_model.dart` (dòng 73-76), `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (hàm `getAllAttendance`)

### 15.3 Email bị `.toUpperCase()` trước khi đăng nhập ở mobile, không có lý do rõ ràng
- **Mức độ:** Medium
- **Nguyên nhân:** `login_form.dart`: `email: _emailController.text.trim().toUpperCase()`. Đây là dòng bất thường — không xuất hiện ở bản đăng nhập admin, không khớp với cách `AuthRepository.login()` chỉ `.trim()` (không đổi hoa/thường). Dù Firebase Auth thường không phân biệt hoa/thường với email nên có thể "vẫn chạy được", đây rõ ràng là code không chủ đích (có thể copy nhầm từ logic viết hoa `employeeCode` ở nơi khác) và tiềm ẩn rủi ro nếu sau này có tích hợp nào khác (Cloud Function, hệ thống email) so khớp email phân biệt hoa/thường.
- **Cách khắc phục:** Xoá `.toUpperCase()`, chỉ giữ `.trim()` như các nơi khác.
- **File liên quan:** `attendance_mobile/lib/features/auth/presentation/widgets/login_form.dart` (dòng 32)

### 15.4 Đơn nghỉ phép: `request.startDate?.day` dùng null-aware operator trên field không nullable
- **Mức độ:** Low
- **Nguyên nhân:** `LeaveRequestModel.startDate` được khai báo `required this.startDate` (không nullable), nhưng `leave_provider.dart` viết `request.startDate?.day` — thừa, không gây lỗi nhưng cho thấy thiếu nhất quán/hiểu nhầm về kiểu dữ liệu, dễ che giấu một lỗi thật nếu sau này field được đổi thành nullable mà quên xử lý trường hợp null thực sự.
- **Cách khắc phục:** Bỏ toán tử `?.` thừa, hoặc nếu ý định là cho phép null thì đổi field thành `DateTime?` một cách tường minh.
- **File liên quan:** `attendance_admin/lib/features/leave/presentation/leave_provider.dart` (dòng ~30)

### 15.5 Race condition lý thuyết khi check-in đồng thời
- **Mức độ:** Low
- **Nguyên nhân:** `checkIn()` kiểm tra `existing.exists` rồi mới `.set()` — hai request gần như đồng thời (double-tap nút, hoặc lỗi mạng khiến client tự động retry) có thể đều vượt qua bước kiểm tra trước khi bước ghi xảy ra, dẫn tới ghi đè lẫn nhau thay vì báo lỗi "đã check-in rồi". Rủi ro thấp với 1 người dùng/1 thiết bị nhưng vẫn là race condition không dùng transaction.
- **Cách khắc phục:** Dùng `_db.runTransaction()` bọc quanh đọc-kiểm tra-ghi.
- **File liên quan:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (hàm `checkIn`)

---

## Ghi chú cuối

Toàn bộ review dựa trên việc đọc trực tiếp mã nguồn hiện có tại thời điểm đánh giá, không chạy ứng dụng và không thể xác minh cấu hình phía server (Firestore Security Rules, Cloud Functions nếu có nằm ngoài repo). Mục 15.1 là phát hiện có mức độ tin cậy cao nhất (đã truy vết đầy đủ đường đi của dữ liệu từ UI → Model → Repository → Firestore → model bên kia đọc lại) và nên được ưu tiên xác minh/khắc phục trước tiên vì ảnh hưởng trực tiếp đến tính đúng đắn của dữ liệu chấm công/lương của toàn bộ nhân viên.
