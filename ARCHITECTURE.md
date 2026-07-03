# ARCHITECTURE.md

> Phân tích kiến trúc kỹ thuật của `attendance-system`, theo từng khía cạnh được yêu cầu: kiến trúc tổng thể, Firebase, Riverpod, Models, Services, Authentication, Routing, UI. Tài liệu chỉ mô tả code hiện có, không đề xuất thay đổi.

## 1. Kiến trúc tổng thể

Hai app Flutter (`attendance_mobile`, `attendance_admin`) — mỗi app là một **monolith client** theo kiểu **feature-first, layered architecture**, không có backend riêng, không có domain layer tách biệt khỏi framework (models import trực tiếp `cloud_firestore`).

Mỗi feature dưới `lib/features/<feature>/` có tối đa 3 tầng con:

```
feature/
├── domain/         model thuần (constructor + fromFirestore + toFirestore + getter tiện ích + copyWith)
├── data/            *Repository — lớp DUY NHẤT được phép gọi FirebaseFirestore/FirebaseAuth trực tiếp
└── presentation/    Riverpod provider (StateNotifier/Future/Stream) + Screen/Widget (Consumer*)
```

Đây là **kiến trúc 3 lớp đơn giản (Repository pattern)**, không phải Clean Architecture đầy đủ — không có use-case/interactor layer, không có interface/abstract cho repository (không dùng dependency inversion — provider luôn `new Repository()` trực tiếp cụ thể, không mock được qua interface).

Điểm quan trọng nhất về kiến trúc tổng thể: **hai app không chia sẻ code cho nhau** (không phải monorepo package/melos) — mọi model, helper, theme, hằng số bị **copy-paste và duy trì độc lập** ở cả hai project. Đây vừa là điểm đơn giản hoá (không cần setup workspace), vừa là rủi ro chính của dự án (dễ lệch dữ liệu/logic giữa hai app theo thời gian — xem mục 3 và PROJECT_OVERVIEW.md).

## 2. Firebase

### 2.1 Cấu hình

- Cả hai app trỏ tới **cùng một Firebase project**: `attendance-management-sy-34105` (xác nhận qua `firebase_options.dart` và `firebase.json` của từng app).
- Mobile khai báo cấu hình cho Android + Web; Admin khai báo cho Web (`firebase.json` của admin chỉ có `web`).
- Không tìm thấy file `firestore.rules` hoặc `firebase.json` chứa cấu hình Firestore Security Rules trong repo — nghĩa là rules (nếu có) được quản lý ngoài repo này (Firebase Console) hoặc dự án đang chạy với rules mặc định/khác không được version-control cùng code.

### 2.2 Dịch vụ Firebase dùng

| Package | Mục đích | Ghi chú |
|---|---|---|
| `firebase_core` | Khởi tạo `Firebase.initializeApp()` trong `main.dart`/`main_dev.dart` | bắt buộc trước `runApp` |
| `firebase_auth` | Đăng nhập email/password, đổi mật khẩu, reset mật khẩu | không dùng Google/Phone/Anonymous sign-in |
| `cloud_firestore` | Toàn bộ dữ liệu nghiệp vụ | không dùng offline persistence config tuỳ biến, dùng API mặc định |
| `firebase_storage` | Có khai báo dependency ở cả hai app | **không tìm thấy code nào sử dụng thực tế** trong các file đã đọc (avatar dùng field `avatarUrl` dạng string, chưa thấy upload flow) |

### 2.3 Cấu trúc dữ liệu Firestore (collection map)

| Collection | Document ID | Ghi/Đọc bởi | Ghi chú |
|---|---|---|---|
| `users` | Firebase Auth `uid` | cả 2 app | Chứa cả admin lẫn employee, phân biệt qua field `role`. Admin's `EmployeeRepository` lọc `role == 'employee'` khi liệt kê nhân viên. |
| `attendance` | `"<yyyy-MM-dd>_<uid>"` (tự ghép chuỗi, không dùng `.add()`/auto-id) | mobile ghi (checkIn/checkOut), cả 2 app đọc | 1 document = 1 ngày công của 1 người. Không có sub-collection. |
| `company_settings` | cố định `"main"` (`AppConfig.companySettingsDocId`) | admin ghi (settings_repository), cả 2 app đọc | Document đơn (singleton), dùng `SetOptions(merge: true)` khi admin cập nhật. |
| `departments` | auto-id | admin ghi/đọc, mobile chỉ đọc (tra tên phòng ban trong `home_provider.dart`) | Model: `name`, `managerUid`, `createdAt`. |
| `leave_requests` | auto-id | admin đọc + duyệt (`leave_repository.dart`), mobile có model nhưng **chưa có repository/UI thực hiện tạo đơn** | Field `status`: `pending`/`approved`/`rejected`. |
| `notifications` | auto-id | admin ghi (`sendNotification`), mobile có model nhưng **chưa có nơi đọc/hiển thị** trong code đã thấy | |

### 2.4 Kỹ thuật đáng chú ý

- **Tạo tài khoản nhân viên không làm mất phiên đăng nhập admin**: `EmployeeRepository.addEmployee()` (admin) khởi tạo một `FirebaseApp` phụ (`Firebase.initializeApp(name: 'SecondaryApp', ...)`), tạo user qua `FirebaseAuth.instanceFor(app: secondaryApp)`, rồi `secondaryApp.delete()` — tránh việc `createUserWithEmailAndPassword` tự động đăng nhập vào tài khoản mới và đá admin ra khỏi phiên hiện tại.
- **Chặn double check-in**: dựa vào doc ID xác định (`date_uid`) + kiểm tra `existing.exists` trước khi ghi, không dùng transaction — về lý thuyết có race condition nhỏ nếu 2 request check-in gửi đồng thời, nhưng với 1 người dùng 1 thiết bị thì rủi ro thấp.
- Các câu query dùng nhiều field kết hợp (`where uid == ... + orderBy attendanceDate`, `where attendanceDate range`) — cần Firestore composite index tương ứng (không thấy file `firestore.indexes.json` trong repo).

## 3. Models (domain layer)

Tất cả model là **plain Dart class** (không dùng `freezed`/`json_serializable`/code-gen), theo một khuôn mẫu thống nhất:

```dart
class XModel {
  final ...;
  const XModel({...});
  factory XModel.fromFirestore(DocumentSnapshot doc) { ... }  // parse thủ công, có fallback `?? default`
  Map<String, dynamic> toFirestore() { ... }
  XModel copyWith({...}) { ... }
}
```

Model chính và nơi định nghĩa (⚠ = định nghĩa **trùng lặp độc lập** ở cả hai app, không share code):

- `UserModel` (mobile only, `features/auth/domain/user_model.dart`) — admin không có model tương đương, dùng thẳng `EmployeeModel` cho cùng collection `users`.
- `EmployeeModel` (admin only) — về bản chất là "UserModel nhìn từ góc admin", cùng đọc/ghi collection `users`, field gần như giống hệt `UserModel` nhưng khai báo riêng.
- ⚠ `AttendanceModel` — định nghĩa riêng ở mobile và admin. Bản mobile có thêm `isCompleted`, `isOnTime`, `isLateStatus`, `isDayShift`, `isNightShift`, `shiftLabel`, `statusLabel`; cần đối chiếu kỹ nếu sửa field ở một bên.
- ⚠ `CompanySettingsModel` — định nghĩa riêng ở mobile và admin, **kể cả toàn bộ logic nghiệp vụ tính ca** (`getCurrentShift`, `calculateIsLate`, `calculateEarlyLeave`) bị copy y hệt ở cả hai file. Sửa nghiệp vụ ca làm việc bắt buộc phải sửa đồng thời cả hai.
- ⚠ `LeaveRequestModel`, `NotificationModel`, `DepartmentModel` — cũng định nghĩa lặp lại ở cả hai app với field giống nhau.

Điểm cần lưu ý: `fromFirestore` luôn dùng `data['field'] ?? defaultValue`, nghĩa là model **không phân biệt được "field bị thiếu" và "field = giá trị mặc định"** — chấp nhận được với dữ liệu hiện tại nhưng là điểm dễ gây bug âm thầm nếu schema Firestore thay đổi.

## 4. Services

Tầng `services/` (chỉ có ở mobile) tách biệt với `data/` (repository) — dùng cho các API không phải Firestore:

- **`GpsService`** (`attendance_mobile/lib/services/gps_service.dart`): bọc package `geolocator`.
  - Kiểm tra location service bật/tắt, xin quyền runtime, lấy vị trí với `LocationAccuracy.high` + timeout 15s.
  - **Chặn fake GPS**: kiểm tra `position.isMocked` và throw exception nếu phát hiện — đây là một control chống gian lận chấm công.
  - Tính khoảng cách qua `Haversine.calculateDistance()` (thuần toán học, không gọi API ngoài) và so sánh với bán kính cho phép.
- **`GpsNotifier`/`gpsProvider`** (`services/gps_provider.dart`): bọc `GpsService` bằng Riverpod `StateNotifierProvider`, nhưng **không thấy được dùng trong luồng check-in thực tế** — `AttendanceRepository` tự khởi tạo `GpsService()` riêng (`final GpsService _gpsService = GpsService();`) thay vì inject qua Riverpod. Có nghĩa là `gpsProvider` hiện là một đường dẫn song song, không thống nhất với cách repository lấy vị trí.
- **`ExportService`** (admin only, `core/services/export_service.dart`): static class xuất báo cáo chấm công ra Excel (`package:excel`) và PDF (`package:pdf` + `printing`, dùng font Google Roboto để hỗ trợ tiếng Việt), có styling thương hiệu "UMC" (màu đỏ `#B91C1C`). Không phải Firebase Cloud Function — xuất file hoàn toàn phía client rồi share/print qua package `printing`.

## 5. Authentication

- Cơ chế: **Firebase Auth email/password** thuần tuý, không OAuth/SSO.
- **Phân quyền không dùng Custom Claims** — sau khi `signInWithEmailAndPassword` thành công, mỗi `AuthRepository.login()`/`signIn()` phải tự đọc thêm document `users/{uid}` để kiểm tra `role` và `isActive`, nếu không hợp lệ thì **chủ động gọi `signOut()` ngay** rồi throw Exception tiếng Việt để hiển thị lên UI.
  - Mobile: chỉ chấp nhận `role == 'employee'`.
  - Admin: chỉ chấp nhận `role == 'admin'` (chấp nhận cả literal `'admin'` lẫn hằng số `AppConfig.roleAdmin` — dấu hiệu code từng được refactor hằng số nhưng chưa dọn hết chỗ hardcode cũ).
- **State auth** được quản lý ở 2 nơi tách biệt, không liên thông:
  1. `authProvider` (Riverpod `StateNotifierProvider<AuthNotifier, AuthState>`) — chỉ chứa `isLoading`/`error` (mobile) hoặc thêm `isSuccess` (admin), dùng để hiển thị trạng thái loading/lỗi trên form đăng nhập.
  2. **Routing guard đọc thẳng `FirebaseAuth.instance` / `FirebaseAuth.instance.authStateChanges()`**, hoàn toàn độc lập với `authProvider` ở trên (xem mục Routing). Tức là "đăng nhập thành công" (auth state) và "kết quả UI của form login" (authProvider state) là hai khái niệm tách rời trong code.
- Đổi mật khẩu (`change_password_page.dart`, mobile) dùng `reauthenticateWithCredential` trước khi `updatePassword` — tuân thủ yêu cầu bảo mật của Firebase Auth cho thao tác nhạy cảm.
- File rỗng đáng chú ý: `attendance_admin/.../auth_gate.dart` (0 dòng) và `admin_model.dart` (0 dòng) — dấu vết của một cách tiếp cận auth đã bị bỏ (có thể từng định làm class `AuthGate`/`AdminModel` riêng rồi đổi hướng dùng router redirect + `EmployeeModel` chung).

## 6. Routing

Cả hai app dùng `go_router`, nhưng khác cách triển khai:

### Mobile (`core/router/app_router.dart`)
- `AppRouter.router` là **`static final`** (khởi tạo một lần, không qua Riverpod).
- `refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges())` — một `ChangeNotifier` tự viết bọc quanh Stream, để router **tự động redirect ngay khi trạng thái đăng nhập Firebase thay đổi** (không cần rebuild widget cha).
- Logic redirect: chưa đăng nhập → ép về `/login` (trừ khi đang ở `/login` hoặc `/forgot-password`); đã đăng nhập mà đang ở `/login` → đẩy về `/home`.
- Có `_rootNavigatorKey` riêng và `/change-password` khai báo `parentNavigatorKey: _rootNavigatorKey` để màn hình này hiển thị full-screen, nằm ngoài `StatefulShellRoute` (không bị bottom nav bao quanh).
- 4 tab chính dùng `StatefulShellRoute.indexedStack` (mỗi tab giữ state/scroll position riêng khi chuyển qua lại): `/home`, `/history`, `/leave` (hiện là `Scaffold` placeholder tĩnh, chưa nối màn hình thật), `/profile`.

### Admin (`routes/app_router.dart`)
- `routerProvider` là **Riverpod `Provider<GoRouter>`**, đọc qua `ref.watch(routerProvider)` trong `MyApp` — khác cách mobile dùng static field.
- Redirect **đọc trực tiếp `FirebaseAuth.instance.currentUser`** tại thời điểm điều hướng, **không** có `refreshListenable` lắng nghe stream — nghĩa là nếu trạng thái đăng nhập đổi (ví dụ bị signOut do session hết hạn) mà không có điều hướng nào kích hoạt lại `redirect`, UI có thể không tự động bật về `/login` cho tới khi người dùng thực hiện một điều hướng khác.
- Dùng `ShellRoute` đơn (không phải indexed stack) bọc `MainLayout` cho 5 route con: `/dashboard`, `/employees`, `/attendance`, `/leave`, `/settings`, cộng thêm route dev ẩn `/dev/seed-departments`.
- Đăng xuất thực hiện trực tiếp trong `MainLayout` (gọi `FirebaseAuth.instance.signOut()` rồi `context.go('/login')`), không qua `authProvider`/`AuthNotifier.signOut()`.

## 7. UI

- **Design system riêng cho mỗi app**, không share: mỗi app có `shared/theme/{app_colors, app_spacing, app_text_styles, app_theme}.dart` định nghĩa độc lập, dùng `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(...))`.
- **Admin** có bộ nhận diện thương hiệu rõ ràng: màu đỏ chủ đạo `#B91C1C` ("UMC"), logo `assets/logo_umc.jpg`, xuất hiện xuyên suốt AppBar, Sidebar, và cả file xuất Excel/PDF — cho thấy đây là dự án được đặt hàng/tuỳ biến cho một tổ chức cụ thể tên "UMC", không phải app mẫu chung chung.
- **State-driven UI qua Riverpod**: hầu hết screen là `ConsumerWidget`/`ConsumerStatefulWidget`, dùng `ref.watch(xProvider)` để rebuild và `AsyncValue.when(loading/error/data)` cho các `FutureProvider`/`StreamProvider` (ví dụ `DashboardScreen`, `SettingsScreen`).
- **Side-effect qua `ref.listen`**: lỗi/thông báo thành công không đặt trong `build()` mà lắng nghe qua `ref.listen<XState>(xProvider, (prev, next) { ... SnackBar ... })` — pattern nhất quán ở cả `HomeScreen` và `CheckInScreen` (mobile) để tránh gọi `ScaffoldMessenger` trong lúc build.
- **Skeleton loading**: mobile có `HomeSkeleton`/`SkeletonContainer` riêng cho trạng thái loading (thay vì spinner đơn giản), admin dùng `LoadingWidget` với message tuỳ biến.
- **Responsive đơn giản qua `LayoutBuilder`**: `DashboardScreen` (admin) đổi số cột `GridView` theo `constraints.maxWidth` (1/2/4 cột) — cách tiếp cận responsive thủ công, không dùng package layout riêng.
- **Biểu đồ**: chỉ admin dùng `fl_chart` (`BarChart` cho thống kê chấm công 7 ngày ở Dashboard).
- Text tiếng Việt được **hardcode trực tiếp trong widget** (không có lớp i18n/l10n, không dùng `.arb`/`intl_translation`) — toàn bộ app chỉ có 1 ngôn ngữ cố định.
