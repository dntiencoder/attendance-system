# FOLDER_STRUCTURE.md

> Cấu trúc thư mục thực tế của repo (chỉ liệt kê những gì đã xác nhận bằng cách đọc trực tiếp, không suy đoán). Chỉ mô tả `lib/` của hai app — bỏ qua thư mục platform sinh tự động (`android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`) và `build/`.

## Cấp gốc repo

```
attendance-system/
├── README.md                  # 2 dòng, chỉ ghi "GPS Attendance System using Flutter and Firebase"
├── CLAUDE.md                  # hướng dẫn cho Claude Code (đã tạo trước đó)
├── attendance_mobile/         # Flutter app cho nhân viên
└── attendance_admin/          # Flutter app cho quản trị viên (web)
```

Mỗi app là một Flutter project độc lập (pubspec.yaml, firebase_options.dart, firebase.json riêng) — **không có workspace/melos dùng chung**, không có package Dart nào được share giữa hai app (mọi model/helper trùng lặp code, xem ARCHITECTURE.md).

---

## `attendance_mobile/lib/`

```
lib/
├── main.dart                       # entrypoint chuẩn: init Firebase → runApp(MyApp)
├── main_dev.dart                   # entrypoint dev: init Firebase → DemoSeeder.cleanAndSeed() → runApp(MyApp)
├── app.dart                        # MyApp (MaterialApp.router + AppTheme + AppRouter)
├── firebase_options.dart           # cấu hình Firebase sinh bởi FlutterFire CLI
│
├── core/
│   ├── constants/
│   │   └── app_config.dart         # hằng số: role, status nghỉ phép, loại notification, docId settings, bán kính GPS mặc định
│   ├── router/
│   │   └── app_router.dart         # GoRouter: redirect theo FirebaseAuth.authStateChanges, StatefulShellRoute 4 tab
│   └── utils/
│       ├── date_helper.dart        # format ngày/giờ (intl), tên thứ tiếng Việt
│       ├── haversine.dart          # tính khoảng cách GPS (m) + kiểm tra trong bán kính
│       └── work_schedule_helper.dart  # lịch làm/tăng ca/nghỉ theo tuần chẵn-lẻ (mốc cố định 01/06/2026)
│
├── dev/                             # script/màn hình chỉ dùng khi phát triển, không phải luồng chính thức
│   ├── create_test_user.dart
│   ├── demo_seeder.dart            # DemoSeeder.cleanAndSeed() — xoá & seed lại Firestore demo
│   └── seed_firestore.dart
│
├── features/
│   ├── attendance/
│   │   ├── data/attendance_repository.dart      # checkIn/checkOut/getTodayAttendance/getAllAttendance/getCompanySettings
│   │   ├── domain/attendance_model.dart         # AttendanceModel (doc `attendance/{date_uid}`)
│   │   └── presentation/
│   │       ├── attendance_provider.dart         # AttendanceNotifier (StateNotifier) — dùng bởi HomeScreen
│   │       ├── attendance_history_provider.dart
│   │       ├── attendance_history_screen.dart   # route /history
│   │       ├── checkin_screen.dart              # ⚠ không được route tới (dead code nghi vấn)
│   │       ├── gps_test_screen.dart             # ⚠ không được route tới (dead code nghi vấn)
│   │       └── widgets/attendance_filter_chips.dart, attendance_record_list.dart, attendance_summary.dart
│   │
│   ├── auth/
│   │   ├── data/auth_repository.dart            # login (chỉ chấp nhận role employee), reset/update password, updatePhoneNumber
│   │   ├── domain/user_model.dart                # UserModel (doc `users/{uid}`)
│   │   └── presentation/
│   │       ├── auth_provider.dart                # AuthNotifier — chỉ dùng cho hành động signIn/signOut, KHÔNG dùng để bảo vệ route
│   │       ├── login_page.dart, forgot_password_page.dart, change_password_page.dart
│   │       └── widgets/login_form.dart, login_header.dart
│   │
│   ├── department/
│   │   └── domain/department_model.dart          # chỉ có domain, không có data/presentation riêng ở mobile (đọc trực tiếp qua Firestore trong home_provider)
│   │
│   ├── home/
│   │   └── presentation/
│   │       ├── home_provider.dart                # HomeNotifier: tổng hợp user + attendance hôm nay + thống kê tháng + lịch sử gần đây
│   │       ├── home_screen.dart                  # route /home — màn hình chính, chứa CheckinCard
│   │       ├── main_shell_screen.dart            # bottom navigation shell (4 tab), tự refresh khi app resume
│   │       └── widgets/checkin_card.dart, home_header.dart, home_skeleton.dart, monthly_stats.dart, recent_attendance.dart, shift_selector.dart
│   │
│   ├── leave/
│   │   └── domain/leave_request_model.dart        # chỉ có model, CHƯA có repository/provider/UI ở mobile — tab "Nghỉ phép" trong router hiện là placeholder Text tĩnh
│   │
│   ├── notification/
│   │   └── domain/notification_model.dart          # chỉ có model, chưa có repository/UI ở mobile
│   │
│   ├── profile/
│   │   └── presentation/
│   │       ├── profile_screen.dart                 # route /profile
│   │       └── widgets/logout_button.dart, profile_header_card.dart, profile_info_list.dart
│   │
│   └── settings/
│       └── domain/company_settings_model.dart       # đọc qua AttendanceRepository.getCompanySettings(), không có repository riêng ở mobile
│
├── services/
│   ├── gps_service.dart             # GpsService: xin quyền, lấy vị trí, chặn fake GPS, tính khoảng cách
│   └── gps_provider.dart            # bọc GpsService bằng Riverpod (GpsNotifier) — không thấy được dùng trực tiếp trong luồng check-in (AttendanceRepository tự new GpsService())
│
└── shared/
    ├── theme/app_colors.dart, app_spacing.dart, app_text_styles.dart, app_theme.dart
    ├── utils/snackbar_utils.dart
    └── widgets/attendance_status_badges.dart, custom_button.dart, custom_card.dart, loading_widget.dart, section_title.dart, shift_chip.dart, skeleton_container.dart, stat_overview.dart
```

`test/widget_test.dart` — test mặc định do `flutter create` sinh ra, không có test nghiệp vụ.

---

## `attendance_admin/lib/`

```
lib/
├── main.dart                        # entrypoint: init Firebase → runApp(ProviderScope(MyApp))
├── app.dart                         # MyApp (ConsumerWidget, đọc routerProvider từ Riverpod)
├── firebase_options.dart
│
├── core/
│   ├── constants/app_colors.dart, app_config.dart, app_spacing.dart
│   ├── services/export_service.dart  # xuất Excel (package `excel`) và PDF (package `pdf`/`printing`), có branding "UMC"
│   └── utils/date_helper.dart, validators.dart
│
├── dev/
│   └── department_seeder.dart        # UI seed phòng ban, gắn vào route ẩn /dev/seed-departments
│
├── features/
│   ├── attendance/
│   │   ├── data/attendance_repository.dart      # khác nội dung với bản mobile — đây là bản đọc/quản trị (xem toàn bộ log), không có logic checkIn/checkOut
│   │   ├── domain/attendance_model.dart          # định nghĩa lại AttendanceModel riêng (trùng lặp, không import từ mobile)
│   │   └── presentation/attendance_provider.dart, attendance_screen.dart   # route /attendance — "Nhật Ký Chấm Công"
│   │
│   ├── auth/
│   │   ├── data/auth_repository.dart             # signIn: chỉ chấp nhận role admin, kiểm tra isActive
│   │   ├── domain/admin_model.dart                # ⚠ FILE RỖNG (0 dòng) — không dùng
│   │   └── presentation/
│   │       ├── auth_gate.dart                     # ⚠ FILE RỖNG (0 dòng) — không dùng, không import ở đâu
│   │       ├── auth_provider.dart, login_screen.dart
│   │       └── widgets/login_form.dart
│   │
│   ├── dashboard/
│   │   ├── data/dashboard_repository.dart         # DashboardStats: tổng NV, NV active, đã chấm công hôm nay, đơn nghỉ phép chờ duyệt, số phòng ban, chấm công 7 ngày gần nhất
│   │   └── presentation/dashboard_provider.dart, dashboard_screen.dart   # route /dashboard, dùng fl_chart vẽ BarChart
│   │       └── widgets/stat_card.dart
│   │
│   ├── department/
│   │   ├── data/department_repository.dart
│   │   ├── domain/department_model.dart
│   │   └── presentation/department_provider.dart   # không có màn hình/route /departments riêng; `departmentsStreamProvider` được employee_screen.dart import trực tiếp để hiển thị/chọn phòng ban trong form nhân viên
│   │
│   ├── employee/
│   │   ├── data/employee_repository.dart           # CRUD `users` (role=employee); addEmployee tạo Firebase Auth user qua secondary App để không logout admin hiện tại
│   │   ├── domain/employee_model.dart
│   │   └── presentation/employee_provider.dart, employee_screen.dart      # route /employees
│   │
│   ├── leave/
│   │   ├── data/leave_repository.dart              # getLeaveRequests (stream), updateLeaveStatus (duyệt/từ chối)
│   │   ├── domain/leave_request_model.dart          # định nghĩa lại, trùng với bản mobile
│   │   └── presentation/leave_provider.dart, leave_screen.dart            # route /leave — "Duyệt Nghỉ Phép"
│   │
│   ├── notification/
│   │   ├── data/notification_repository.dart        # chỉ có sendNotification() — admin gửi thông báo tới nhân viên
│   │   └── domain/notification_model.dart            # định nghĩa lại, trùng với bản mobile
│   │
│   └── settings/
│       ├── data/settings_repository.dart              # đọc/ghi `company_settings/main` (stream + update merge)
│       ├── domain/company_settings_model.dart          # định nghĩa lại, trùng với bản mobile (kể cả logic getCurrentShift, calculateIsLate...)
│       └── presentation/settings_provider.dart, settings_screen.dart      # route /settings — "Cấu Hình Vị Trí GPS"
│
├── layout/
│   ├── main_layout.dart              # Scaffold khung: AppBar đỏ UMC + Sidebar cố định 260px + nội dung
│   └── sidebar.dart                  # menu điều hướng tĩnh (5 mục, dùng context.go)
│
├── routes/
│   └── app_router.dart               # routerProvider (Riverpod Provider<GoRouter>) — redirect theo FirebaseAuth.instance.currentUser (đọc trực tiếp, không nghe stream)
│
└── shared/
    ├── theme/app_colors.dart, app_spacing.dart, app_text_styles.dart, app_theme.dart
    └── widgets/confirm_dialog.dart, custom_button.dart, loading_widget.dart, stat_card.dart, status_badge.dart
```

`test/widget_test.dart` — test mặc định, không có test nghiệp vụ.

### Ghi chú cấu trúc đáng chú ý

- Cả hai app đặt tên thư mục/file **giống hệt nhau** cho nhiều khái niệm chung (`attendance_model.dart`, `company_settings_model.dart`, `leave_request_model.dart`, `notification_model.dart`, `app_colors.dart`, `date_helper.dart`...) nhưng đây là **các file hoàn toàn tách biệt, copy-paste giữa hai project**, không phải cùng một file dùng chung qua package.
- Admin có thêm layer `layout/` (Sidebar + MainLayout) mà mobile không có (mobile dùng `MainShellScreen` + `BottomNavigationBar` thay thế).
- Admin có `routes/` (không phải `core/router/` như mobile) và dùng Riverpod `Provider<GoRouter>` thay vì `static final` như mobile.
