# 01_BACKLOG.md

**Mục tiêu:** Danh sách công việc còn lại có thể thao tác được (actionable), gộp từ `ROADMAP.md` (P2-P4 còn lại), `REVIEW.md` (các mục bị loại khỏi `ROADMAP.md`), và checklist Phase A của `PROJECT_MASTER_PLAN.md`, kèm cột theo dõi trạng thái mà các tài liệu nguồn (vốn là tài liệu chỉ đọc/đóng băng tại thời điểm viết) không có.

**Phạm vi:** Tính năng còn thiếu (Feature Backlog), nợ kỹ thuật (Technical Debt Backlog), và một bảng tóm tắt trỏ tới Bug Backlog thật (sống ở `docs/testing/02_BUG_TRACKER.md`, không lặp lại ở đây).

**Khi nào dùng:** Đầu mỗi Sprint (`02_SPRINT.md`), để chọn việc đưa vào sprint tiếp theo; cập nhật cột Status ngay khi trạng thái một mục thay đổi.

**Liên kết:** Nguồn phân tích gốc — `ROADMAP.md`, `REVIEW.md`; điều phối theo phase — `PROJECT_MASTER_PLAN.md` §3; thực thi theo thời gian — `02_SPRINT.md`.

---

## Chú giải cột

- **Priority:** Critical / High / Medium / Low (kế thừa nguyên văn từ `ROADMAP.md`/`REVIEW.md` khi mục đó có nguồn từ đó).
- **Status:** `Backlog` (chưa bắt đầu) / `Ready` (đã rõ yêu cầu, sẵn sàng làm) / `In Progress` / `Done` / `Deferred` (cố ý hoãn, có lý do) / `Blocked`.
- **Estimate:** kế thừa từ `ROADMAP.md` khi có; ước lượng mới ghi chú `(mới)`.
- **Dependency:** ID khác trong bảng này, hoặc "none".

---

## A. Feature Backlog

Tính năng còn thiếu hoặc dở dang — nguồn: `PROJECT_MASTER_PLAN.md` Phase A.

| ID | Hạng mục | Priority | Status | Estimate | Dependency | Phase |
|---|---|---|---|---|---|---|
| FEAT-01 | Nghỉ phép (mobile): repository + provider + UI tạo đơn + xem đơn của chính mình | Medium ⚠️ cần xác nhận | Backlog | 2-3 ngày | none | A |
| FEAT-02 | Notification: màn hiển thị danh sách thông báo (tối thiểu 1 app) | Medium ⚠️ cần xác nhận | Backlog | 1-2 ngày | none | A |
| FEAT-03 | Phòng ban (admin): màn quản lý CRUD riêng thay vì chỉ seed qua route dev ẩn | Low-Medium | Backlog | 1-2 ngày | none | A |
| FEAT-04 | Demo Time System: commit thay đổi hiện có + kiểm thử tay trên thiết bị thật | **Critical** (rủi ro mất công sức) | **Done** (2026-07-13, commit `9a2623e`) | 0.5-1 ngày | none | A |

⚠️ FEAT-01/FEAT-02 là tính năng mới ngoài phạm vi `ROADMAP.md` gốc — xem cảnh báo ở `PROJECT_MASTER_PLAN.md` Phase A trước khi chuyển sang `Ready`.

## B. Technical Debt Backlog

Nguồn: `ROADMAP.md` Phase 2 (còn lại sau khi P2-03 đã vô tình xong ở commit `55da6da`), Phase 3, Phase 4.

| ID | Hạng mục (ROADMAP ID) | Priority | Status | Estimate | Dependency | Phase |
|---|---|---|---|---|---|---|
| TD-01 | Transaction cho `checkIn()` chống double check-in (P2-01) | High | **Done** (2026-07-13, commit `2da7827`) — xác nhận qua review code + TD01-01 Pass; TD01-02/03/04/08 bị Blocked bởi BUG-014 (không liên quan), chưa xác nhận trực tiếp trên thiết bị | 0.5-1 ngày | none | A |
| TD-02 | **[Đổi tên 2026-07-13]** Chặn xoá nhân viên đã phát sinh dữ liệu nghiệp vụ (Attendance/Leave Request) — tách rời hoàn toàn khỏi `isActive` (P2-04, thiết kế lại theo `docs/design/EMPLOYEE_LIFECYCLE.md`, xem `docs/decision/01_DECISION_LOG.md` D-012) | High | **Done** (2026-07-13, commit `7f17397`) — TD02-04/05/06 Pass trên bản Web thật | 0.5-1 ngày (tăng nhẹ so với ước lượng gốc — cần kiểm tra tồn tại dữ liệu ở 2 nguồn thay vì đọc 1 cờ) | none | A |
| TD-03 | Đồng bộ nguồn mốc ngày `WorkScheduleHelper` ↔ `rotationStartDate` (P2-06) | High | **Done** (2026-07-13, commit `5d829ae`) — flutter analyze + build web sạch, 6 mục regression Pass trên thiết bị thật | 1 ngày | none | A |
| TD-04 | Logging/crash reporting tối thiểu ở các nhánh `catch` quan trọng (P2-02) | High | **Done** (2026-07-20, commit `a3c6d4c`) — `AppLogger` (dart:developer, không thêm package) + 11 nhánh catch quan trọng ở cả 2 app | 1-2 ngày (thực tế <1 ngày) | none | B |
| TD-05 | Xoá `.toUpperCase()` thừa khi đăng nhập email (P2-05) | High | **Done** (2026-07-20, commit `bf64a9e`) | <0.25 ngày | none | B |
| TD-06 | Giới hạn/lọc theo ngày cho `getAttendanceLogs()` (P3-01) | Medium | Backlog | 1 ngày | none | B |
| TD-07 | Song song hoá 7 query tuần tự ở Dashboard (P3-02) | Medium | **Done** (2026-07-20, commit `690aa48`) | 0.5 ngày | none | B |
| TD-08 | Cache `company_settings`/`users` trong lịch sử chấm công (P3-03) | Medium | Backlog | 0.5 ngày | none | B |
| TD-09 | Dùng lại `ConfirmDialog` thay `AlertDialog` tự dựng (P3-04) | Medium | **Done** (2026-07-20, commit `0ea3030`) — chỉ đúng 1/4 chỗ khớp hình dạng (xác nhận xoá nhân viên); 3 chỗ còn lại (form thêm/sửa, info 1-nút, dialog có TextField) không hợp `ConfirmDialog`, giữ nguyên | 0.5 ngày | none | B |
| TD-10 | Dùng lại `Validators.email/phone` thay validator inline (P3-05) | Medium | **Done** (2026-07-20, commit `311ede8`) — `login_screen.dart` + `employee_screen.dart` (email); số điện thoại giữ tuỳ chọn, chỉ validate định dạng khi có nhập | 0.5 ngày | none | B |
| TD-11 | Thông điệp lỗi thân thiện thay `'Lỗi: $err'` (P3-06) | Medium | **Done** (2026-07-20, commit `c6d48bd`) — 7 chỗ ở cả 2 app, thêm `AppLogger` ở 4 chỗ chưa có để không mất chi tiết kỹ thuật | 0.5 ngày | TD-04 | B |
| TD-12 | Đồng bộ nhãn hiển thị ca ("Ca ngày" vs "Ca sáng") (P3-07) | Medium | **Done** (2026-07-20, commit `6f34a9e`) | <0.25 ngày | none | B |
| TD-13 | Thay hex màu hardcode bằng `AppColors.primary` (P3-08) | Medium | **Done** (2026-07-20, commit `6f34a9e`) — chỉ 2 chỗ trùng khớp chính xác ở mobile; 6 chỗ `0xFFB91C1C` ở admin (khác `AppColors.primary`) cố ý chưa đụng, cần bạn quyết định riêng | <0.25 ngày | none | B |
| TD-14 | Xoá dead code (`admin_model.dart`, `checkin_screen.dart`, `gps_test_screen.dart`, `gps_provider.dart`) (P4-01) | Low | **Done** (2026-07-20, commit `bcaa2c0`) — `auth_gate.dart` đã không còn tồn tại từ trước, không cần xoá | 0.5 ngày | none | B |
| TD-15 | Thay placeholder "Nghỉ phép" bằng màn tử tế hơn (P4-02) | Low | Backlog | 0.5 ngày | **Có thể huỷ nếu FEAT-01 hoàn thành trước** | B |
| TD-16 | Xoá `?.` thừa trên `startDate` không nullable (P4-03) | Low | **Won't Fix** (2026-07-20) — tiền đề sai: `LeaveRequestModel.startDate` thực sự là `DateTime?` (nullable), `?.` là đúng và cần thiết, không phải thừa. Xoá sẽ vỡ build. Ghi chú gốc ở `REVIEW.md` 15.4 đã sai hoặc model đã đổi từ lúc đó | <0.25 ngày | none | B |
| TD-17 | Set màu tường minh cho `CircularProgressIndicator` (P4-04) | Low | **Done** (2026-07-20, commit `73ce3bb`) — chỉ cần sửa ở mobile, admin đã tự set màu sẵn | <0.25 ngày | none | B |
| TD-18 | Exception class thay so khớp chuỗi lỗi (P4-05) | Low | Backlog | 0.5-1 ngày | none | B |
| TD-19 | Dọn 23+13 warning/info còn lại từ `flutter analyze` (baseline 2026-07-13) | Medium | **Done** (2026-07-20, commit `00fd541`) — mobile 23→1 (còn lại cố ý ở `checkin_screen.dart`, chờ TD-14), admin 13→0 | 0.5-1 ngày | none | B |
| TD-20 | Gỡ dependency `firebase_storage` không dùng thực tế (cả 2 `pubspec.yaml`) | Low | **Done** (2026-07-20, commit `4cbfe08`) | <0.25 ngày | none | B |
| BUG-014 | `GpsService.getCurrentPosition()` (`gps_service.dart`) ném `TimeoutException` thô sau 15s, không có thông báo thân thiện — xem chi tiết `docs/testing/02_BUG_TRACKER.md` | Medium | Backlog | 0.5-1 ngày (cần điều tra thêm trước khi ước lượng chắc) | none | B |

## C. Out-of-Scope Backlog (Deferred có chủ đích)

Từ `REVIEW.md`, bị `ROADMAP.md` loại khỏi phạm vi ổn định hoá — giữ lại đây để không bị quên, **không đưa vào bất kỳ Sprint nào trước Phase H** trừ khi có quyết định thay đổi phạm vi (xem `04_DECISION_LOG.md`).

| ID | Hạng mục | Priority | Status | Lý do hoãn |
|---|---|---|---|---|
| OOS-01 | Interface cho Repository (Dependency Inversion) | — | Deferred | Đổi kiến trúc — cấm theo `CLAUDE.md`/`ROADMAP.md` |
| OOS-02 | Tách use-case/service layer khỏi Repository | — | Deferred | Đổi kiến trúc |
| OOS-03 | Package Dart dùng chung giữa 2 app | — | Deferred | Refactor lớn xuyên 2 project |
| OOS-04 | `enum` hoá `role`/`status`/`shift` | — | Deferred | Đổi kiểu dữ liệu xuyên suốt, rủi ro cao hơn lợi ích ở giai đoạn này |
| OOS-05 | Tách `EmployeeFormNotifier` khỏi widget | — | Deferred | Cải thiện phong cách, không cần thiết cho "ổn định" |
| OOS-06 | Cloud Function xác thực GPS phía server | — | Deferred | Cấm Cloud Functions theo phạm vi hiện tại — xem quyết định D-006 ở `docs/decision/01_DECISION_LOG.md` |
| OOS-07 | Xoá tài khoản Firebase Auth khi xoá nhân viên | — | Deferred | Cần Admin SDK/Cloud Function |

## D. Bug Backlog

Sống tại **`docs/testing/02_BUG_TRACKER.md`** — không liệt kê lại ở đây theo đúng yêu cầu "không copy lại, chỉ tham chiếu". Tóm tắt nhanh (cập nhật thủ công khi bug tracker đổi):

| Trạng thái | Số lượng (tại 2026-07-13, sau TD-01) |
|---|---|
| Fixed | 8 |
| Open | 6 (mới: BUG-014, phát hiện lúc test TD-01) |
| Tổng | 14 |

Xem chi tiết từng bug tại `docs/testing/02_BUG_TRACKER.md`.

## E. Sprint 0 (D.1 — Demo Ready) Progress

Checklist đầy đủ sống ở `PROJECT_MASTER_PLAN.md` §D.1 — không lặp lại ở đây, chỉ tóm tắt trạng thái.

| # | Việc | Status | Ghi chú |
|---|---|---|---|
| 1 | Seed 3 `leave_requests` mẫu | Deferred | Tạm hoãn theo yêu cầu — chưa cần cho buổi demo lần này |
| 2 | `company_settings.radius` | **Done** (2026-07-14) | `9999999999` → `500`m, qua `tools/firestore_backup/bin/seed_sprint0.dart` |
| 3 | Sửa `departmentId` tài khoản admin | **Done** (2026-07-14) | `dep001` (không tồn tại) → `dept_ga`, cùng script trên |
| 4 | Test tay Check In/Check Out ca ngày + ca đêm | Backlog | Cần thiết bị thật, trong bán kính 500m quanh toạ độ công ty (21.0285, 105.7848) |
| 5 | Dry-run Demo Center | Backlog | Cần thiết bị thật |

**Làm sạch + tạo lại toàn bộ dữ liệu (2026-07-14, ngoài checklist D.1 gốc, theo yêu cầu riêng):** xoá vĩnh viễn `users`/`departments`/`attendance`/`leave_requests`/`notifications` (giữ nguyên `company_settings`), backup trước khi xoá (`backup_firestore.json`, không commit — chứa PII), tạo lại bằng `tools/firestore_backup/bin/reseed_july.dart`: 5 hồ sơ (1 admin + 4 nhân viên, đúng UID Auth thật), 13 phòng ban, 52 bản ghi attendance cho 1-14/7/2026 (theo đúng logic rotation/mandatory-workday thật, không phải dữ liệu random tuỳ tiện). `leave_requests`/`notifications` để trống theo đúng mục (1) ở trên. Phát hiện phụ trong lúc này: tài khoản `EMP001 (Trần Văn Ab)` từng bị xoá khỏi `users` trước khi có rule TD-02 dù còn dữ liệu attendance (dữ liệu mồ côi) — đã được giải quyết tự nhiên qua lần làm sạch này, không cần xử lý thêm. Xem lại `docs/demo/01_DEMO_DATA.md` — tài liệu đó mô tả dữ liệu tháng 6 cũ, đã lỗi thời sau thao tác này.

Sprint 0 dừng ở đây theo quyết định 2026-07-14 — đủ cho buổi demo hiện tại, mục (4)/(5) chưa cần gấp.
