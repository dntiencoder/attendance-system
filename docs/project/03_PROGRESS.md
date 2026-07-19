# 03_PROGRESS.md

**Mục tiêu:** Nhật ký tiến độ theo thời gian — khác với `PROJECT_MASTER_PLAN.md` (mô tả trạng thái tĩnh "nên làm gì theo Phase nào"), tài liệu này là **nhật ký** ghi lại "đã làm gì, khi nào" để nhìn lại lịch sử tiến độ thực tế, đặc biệt hữu ích khi viết Chương 3/4 (Phase G) cần kể lại quá trình phát triển.

**Phạm vi:** Một entry mỗi khi đóng 1 sprint (`02_SPRINT.md`) hoặc đạt 1 milestone, không cần ghi hàng ngày.

**Khi nào dùng:** Cuối mỗi sprint; ngay sau khi đạt bất kỳ Milestone M0-M7 nào (`PROJECT_MASTER_PLAN.md` §4).

**Liên kết:** Milestone tham chiếu `PROJECT_MASTER_PLAN.md` §4; Task tham chiếu ID ở `01_BACKLOG.md`; Risk tham chiếu `PROJECT_MASTER_PLAN.md` §7 hoặc bổ sung mới nếu phát sinh.

---

## Cách ghi 1 entry

```
## <YYYY-MM-DD>

- **Milestone:** <milestone gần nhất đã đạt hoặc đang hướng tới>
- **Phase hiện tại:** <A-H theo PROJECT_MASTER_PLAN.md>
- **Task Completed:** <danh sách ID từ 01_BACKLOG.md hoặc mô tả ngắn>
- **Task Remaining:** <danh sách ID còn lại của sprint hiện tại>
- **Risk nổi bật:** <rủi ro mới phát sinh hoặc rủi ro cũ cần nhắc lại — tham chiếu PROJECT_MASTER_PLAN.md §7 nếu đã có>
```

---

## 2026-07-13

- **Milestone:** chuẩn bị M0; đã hoàn thành việc thiết lập toàn bộ hệ thống tài liệu quản lý dự án.
- **Phase hiện tại:** chuyển tiếp từ `ROADMAP.md` Phase 1 (đã xong 7/7) sang `PROJECT_MASTER_PLAN.md` Phase A.
- **Task Completed:**
  - `PROJECT_MASTER_PLAN.md` hoàn thành, tự rà soát bởi Technical Lead (tách Phase D thành D.1/D.2, thêm Milestone M0 — xem D-011 ở `docs/decision/01_DECISION_LOG.md`).
  - Toàn bộ hệ thống tài liệu quản lý (`docs/project/`, `docs/testing/`, `docs/release/`, `docs/decision/`) khởi tạo lần đầu.
  - Baseline `flutter analyze`: 23 issue (mobile), 13 issue (admin) — toàn bộ warning/info, không có lỗi.
- **Task Remaining:** toàn bộ checklist Sprint 0 (D.1) và Sprint 1 trở đi — xem `02_SPRINT.md`.
- **Risk nổi bật:** Demo Time System (12 file) vẫn chưa commit trong working tree — rủi ro cao nhất hiện tại, xem `PROJECT_MASTER_PLAN.md` §7 rủi ro #1, task FEAT-04 ở `01_BACKLOG.md`.

## 2026-07-13 (cùng ngày, sau khi hoàn thành FEAT-04)

- **Milestone:** rủi ro #1 (Demo Time System chưa commit) đã được xử lý — chưa đạt trọn M0 (còn 4 việc data/thủ công khác của Sprint 0 chưa làm), chưa đạt M1 (còn TD-01/02/03 và FEAT-01/02/03 của Phase A).
- **Phase hiện tại:** A.
- **Task Completed:**
  - FEAT-04 hoàn thành: `flutter analyze` sạch (23 issue baseline, không phát sinh mới), MT-18→MT-22 Pass (test tay trên thiết bị thật `RMX3491`), MT-23 ban đầu Fail → phát hiện BUG-013 (route `/demo-center` không bọc `kDebugMode`, chỉ ẩn UI entry) → sửa ngay trong cùng task (mirror pattern P1-06) → MT-23 Pass sau khi sửa.
  - Commit `9a2623e` — "feat: add demo time system for simulating clock during demos" (17 file dự kiến; phát hiện thêm 1 file `.idea/caches/deviceStreaming.xml` bị cuốn theo do đã staged sẵn từ trước phiên làm việc này — đã báo cáo minh bạch, tác động không đáng kể).
  - `docs/testing/01_TEST_PLAN.md`, `docs/testing/02_BUG_TRACKER.md` cập nhật kết quả test/bug (bản thân 2 file này vẫn chưa commit — nằm trong khối tài liệu quản lý dự án chưa commit, ngoài phạm vi FEAT-04).
- **Task Remaining:** TD-01, TD-02, TD-03 (nốt Sprint 1); 4 việc còn lại của Sprint 0 (D.1); FEAT-01/02/03 (chờ xác nhận ưu tiên).
- **Risk nổi bật:** rủi ro #1 đã đóng. Rủi ro còn lại đáng chú ý nhất hiện tại: toàn bộ hệ thống tài liệu quản lý (`docs/project/`, `docs/testing/`, `docs/release/`, `docs/decision/`) và một khối công việc khác (`tools/firestore_backup/`, `docs/demo/`, `docs/report/`, `docs/review/`) vẫn chưa commit — cùng loại rủi ro như FEAT-04 trước khi xử lý, chưa có task nào trong backlog theo dõi việc này.

## 2026-07-13 (cùng ngày, sau khi hoàn thành TD-01)

- **Milestone:** vẫn đang trong Sprint 1, chưa đạt M1 — còn TD-02, TD-03.
- **Phase hiện tại:** A.
- **Task Completed:**
  - TD-01 hoàn thành: `checkIn()` đổi sang `runTransaction()`, bọc `FirebaseException` (theo `e.code`, không so khớp chuỗi) cho toàn bộ phần thân từ GPS tới transaction để hiện đúng thông báo "Không có kết nối Internet..." dù lỗi xảy ra ở bước nào. Commit `2da7827`.
  - `flutter analyze` sạch (baseline không đổi), `git diff --stat` xác nhận đúng 1 file thay đổi trước khi commit.
  - TD01-01 (Check In bình thường) Pass trên thiết bị thật.
  - Phát hiện **BUG-014** trong lúc test tay: `GpsService.getCurrentPosition()` (`gps_service.dart`, ngoài phạm vi TD-01) ném `TimeoutException` thô sau 15s — chặn TD01-02/03/04/08, khiến các test này không chạm tới được đoạn code TD-01 sửa. Đã ghi nhận vào `docs/testing/02_BUG_TRACKER.md`, không tự ý sửa (ngoài phạm vi file được duyệt).
  - Quyết định đóng TD-01 dựa trên review code + TD01-01 Pass, để TD01-02/03/04/08 lại làm việc tồn đọng chờ BUG-014 (không chặn TD-01) — quyết định của bạn, không phải tự ý của tôi.
- **Task Remaining:** TD-02 (ràng buộc xoá nhân viên theo `isActive`), TD-03 (đồng bộ nguồn mốc rotation); BUG-014 chưa có task backlog theo dõi việc sửa (mới chỉ ghi nhận).
- **Risk nổi bật:** BUG-014 (GPS timeout không xử lý thân thiện, có thể ảnh hưởng Check In thật ở nơi tín hiệu yếu) — mức Medium, chưa vào Sprint nào; nên cân nhắc thêm vào `01_BACKLOG.md` mục B ở lượt cập nhật tiếp theo nếu muốn ưu tiên xử lý trước Phase E.

## 2026-07-13 (cùng ngày, sau khi hoàn thành TD-02)

- **Milestone:** Sprint 1 gần xong — chỉ còn TD-03. Chưa đạt M1.
- **Phase hiện tại:** A.
- **Task Completed:**
  - Trong lúc làm TD-02, phát hiện thiết kế ban đầu (bắt `isActive = false` trước khi xoá) dùng sai tiêu chí — dừng lại, không code ngay, viết tài liệu thiết kế `docs/design/EMPLOYEE_LIFECYCLE.md` để chốt lại toàn bộ vòng đời nhân viên (Active/Inactive/Delete) trước khi tiếp tục. Đã duyệt, ghi nhận thành quyết định D-012 ở `docs/decision/01_DECISION_LOG.md`.
  - TD-02 đổi tên + thiết kế lại: Delete chỉ bị chặn khi nhân viên đã có dữ liệu Attendance/Leave Request (không phải theo `isActive`); Notification cố ý không tính vào điều kiện chặn.
  - Implementation: thêm `EmployeeRepository.hasBusinessData()`, viết lại `_showDeleteConfirm()`. Commit `7f17397`, chỉ đúng 2 file liên quan (tách riêng khỏi 1 dòng sửa label không liên quan vẫn còn nằm ngoài staged, bằng patch thủ công thay vì `git add` cả file).
  - `flutter analyze` + `flutter build web` sạch. TD02-04/05/06 Pass trên bản Web thật.
- **Task Remaining:** TD-03 (đồng bộ nguồn mốc rotation) — task cuối cùng của Sprint 1.
- **Risk nổi bật:** không phát sinh rủi ro mới. Bài học quy trình đáng ghi nhận: việc dừng lại để làm rõ nghiệp vụ trước khi code (thay vì implement ngay theo phân tích ban đầu) đã tránh được một thiết kế sai tiêu chí — nên tiếp tục ưu tiên "chốt nghiệp vụ trước, code sau" cho các task còn lại nếu có dấu hiệu mơ hồ tương tự.

## 2026-07-13 (cùng ngày, sau khi hoàn thành TD-03 — đóng Sprint 1)

- **Milestone:** **Sprint 1 DONE.** Đạt điều kiện M1 (Core Complete) **một phần** — xem đánh giá đầy đủ ở Sprint Review bên dưới, còn nhiều mục Phase A khác (FEAT-01/02/03) chưa làm nên chưa thể coi M1 đã đạt trọn vẹn.
- **Phase hiện tại:** A.
- **Task Completed:**
  - TD-03 hoàn thành: `WorkScheduleHelper` không còn hardcode mốc ngày gốc, toàn bộ đọc từ `CompanySettingsModel.rotationStartDate`. Không gộp chung logic "ca A/B" và "ngày làm bắt buộc" thành 1 hàm (2 quy tắc nghiệp vụ khác nhau, chỉ đồng bộ nguồn mốc ngày) — quyết định rõ trong phần phân tích trước khi code.
  - `flutter analyze` + `flutter build web` (mobile) sạch. 6 mục regression Pass trên thiết bị thật (Day/Night Shift, Rotation, Business Date, Demo Time, Attendance History, Thống kê tháng).
  - Commit `5d829ae`, đúng 4 file dự kiến, không lẫn thay đổi ngoài phạm vi.

### Sprint Review — Sprint 1

| Task | Trạng thái | Cần Regression Fix? | Bug mới phát sinh? |
|---|---|---|---|
| FEAT-04 — Demo Time System | Done (`9a2623e`) | Không | BUG-013 (route `/demo-center` thiếu `kDebugMode`) — phát hiện và **sửa ngay trong cùng task**, đã đóng |
| TD-01 — Transaction cho Check In | Done (`2da7827`) | Không | **BUG-014** (GPS `getCurrentPosition()` timeout thô, không thân thiện) — phát hiện lúc test, **chưa sửa**, đang Open trong `docs/testing/02_BUG_TRACKER.md` và đã vào `01_BACKLOG.md` (mục B, chưa vào Sprint nào) |
| TD-02 — Chặn xoá nhân viên có Business Data | Done (`7f17397`) | Không | Không — nhưng dẫn tới việc viết lại thiết kế nghiệp vụ (`docs/design/EMPLOYEE_LIFECYCLE.md`, quyết định D-012) trước khi code, không phải bug, là cải thiện thiết kế giữa chừng |
| TD-03 — Đồng bộ nguồn mốc rotation | Done (`5d829ae`) | Không | Không |

**Tổng kết:** 4/4 task Done, đúng phạm vi từng task (không có commit nào lẫn file ngoài phạm vi). 1 bug phát hiện-và-sửa-ngay (BUG-013), 1 bug phát hiện-còn-mở (BUG-014, Medium, không chặn Sprint 1 vì nằm ngoài phạm vi từng task cụ thể — thuộc `gps_service.dart`, chưa file nào trong Sprint 1 được duyệt sửa). Không cần Regression Fix bổ sung nào cho 4 task đã đóng.
- **Task Remaining:** BUG-014 (Open, chưa vào Sprint nào); toàn bộ Sprint 2 trở đi (chưa mở).
- **Risk nổi bật:** không có rủi ro mới phát sinh từ việc đóng Sprint 1. Rủi ro tồn đọng duy nhất là BUG-014, mức Medium, đã có trong backlog chờ ưu tiên.

## 2026-07-20 — Sau buổi demo báo cáo tiến độ, quay lại Phase A/Sprint 4

- **Milestone:** buổi demo báo cáo tiến độ đã diễn ra và kết thúc; mục tiêu chuyển hẳn sang Complete Project → Release Candidate → Source Freeze → Báo cáo → Bảo vệ. Chưa đạt M1 (còn FEAT-01/02/03 chờ xác nhận ưu tiên).
- **Phase hiện tại:** A/B (bắt đầu Sprint 4 — Code Quality bắt buộc).
- **Task Completed:**
  - Review toàn diện trạng thái dự án sau đợt demo: xác nhận Sprint 1 vẫn đóng hợp lệ (đã đóng 2026-07-13, trước demo); phát hiện 2 file có thay đổi lạ chưa commit không gắn task nào (`employee_screen.dart`, `attendance_repository.dart`) — đã xác nhận với bạn và `git checkout --` khôi phục về bản `HEAD`, không có gì cần commit thêm.
  - Phát hiện lệch tài liệu: `docs/testing/02_BUG_TRACKER.md` có 4 dòng (BUG-008/009/010/013) vẫn ghi `Open` dù fix tương ứng (TD-01/02/03, và fix inline của BUG-013) đã Done từ Sprint 1 — **chưa sửa**, để lại cho lượt cập nhật tài liệu tiếp theo.
  - TD-05 hoàn thành: xoá `.toUpperCase()` thừa trên email đăng nhập (`login_form.dart:32`), khớp cách `attendance_admin` xử lý. `flutter analyze` sạch (baseline 23 issue không đổi). Commit `bf64a9e`. Test tay bị bỏ qua có chủ đích theo yêu cầu (thay đổi 1 dòng, rủi ro thấp).
  - `01_BACKLOG.md` (TD-05 → Done), `02_BUG_TRACKER.md` (BUG-011 → Fixed) cập nhật theo.
- **Task Remaining:** TD-04 (logging/crash reporting, High, tiếp theo trong Sprint 4); BUG-014 (Open); TD-06 → TD-20 (Medium/Low); FEAT-01/02/03 (chờ xác nhận ưu tiên); 14 unit test (UT-01→14) + manual test suite (Sprint 5) chưa chạy lần nào; sửa lệch BUG-008/009/010/013 trong Bug Tracker (chưa làm).
- **Risk nổi bật:** không có rủi ro mới. `docs/demo/DEMO_GUIDE.md`/`01_DEMO_DATA.md` từ nay đóng vai trò tư liệu lịch sử cho D.2 (demo bảo vệ), không còn là mục tiêu vận hành trước mắt.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-04)

- **Milestone:** vẫn trong Sprint 4, chưa đạt M1/M2.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-04 hoàn thành: thêm `AppLogger` (dùng `dart:developer.log()`, không thêm package mới, đúng nguyên tắc "không thêm package nếu không yêu cầu") ở `core/utils/app_logger.dart` cho cả 2 app; gọi ở 11 nhánh `catch` quan trọng (6 file mobile, 5 file admin — attendance/auth/employee/settings/leave), không đổi luồng xử lý lỗi hiện có cho người dùng.
  - `flutter analyze` cả 2 app: đúng baseline (23/13 issue), không phát sinh mới. Test tay bị bỏ qua có chủ đích theo yêu cầu.
  - Commit `a3c6d4c`, đúng 13 file dự kiến (2 file mới + 11 file sửa), không lẫn `.idea/`/file untracked khác.
  - `01_BACKLOG.md` (TD-04 → Done) cập nhật theo.
- **Task Remaining:** BUG-014 (Open); TD-06 → TD-20 (Medium/Low, Sprint 6); FEAT-01/02/03 (chờ xác nhận ưu tiên); 14 unit test (UT-01→14, Sprint 4) + manual test suite (Sprint 5) chưa chạy; sửa lệch BUG-008/009/010/013 trong Bug Tracker (chưa làm).
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành 14 unit test đầu tiên)

- **Milestone:** Sprint 4 gần xong (còn TD-19 — dọn warning/info). `flutter test` (mobile) lần đầu tiên có test thật ngoài widget test mặc định.
- **Phase hiện tại:** B/C (unit test thuộc Phase C nhưng gộp vào Sprint 4 theo `02_SPRINT.md`).
- **Task Completed:**
  - Viết đủ 14 unit test (UT-01→UT-14) cho các hàm thuần Dart: `Haversine` (`test/core/utils/haversine_test.dart`), `RotationCalculator` (`test/core/utils/rotation_calculator_test.dart`), `CompanySettingsModel.calculateIsLate/calculateEarlyLeave` (`test/features/settings/company_settings_model_test.dart`), `BusinessDateHelper.resolveBusinessDate` (`test/core/utils/business_date_helper_test.dart`, gồm cả 1 test đối chứng thêm ngoài yêu cầu gốc để củng cố UT-14).
  - `flutter test`: 19/19 test mới Pass. Phát hiện phụ: `test/widget_test.dart` (bài test mặc định "Counter increments", chưa từng khớp với app thực tế) đang Fail — lỗi có sẵn từ trước, không liên quan tới thay đổi lần này, **chưa sửa** (ngoài phạm vi UT-01→14, để lại quyết định cho lượt sau: sửa thành smoke test thật hoặc xoá).
  - `docs/testing/01_TEST_PLAN.md` (UT-01→14 → Pass) cập nhật theo.
- **Task Remaining:** `test/widget_test.dart` Fail (mới phát hiện, chưa vào backlog); TD-19 (Sprint 4, dọn warning/info); BUG-014 (Open); TD-06→TD-20, TD-14/17/18/20 (Sprint 6); FEAT-01/02/03 (chờ xác nhận); manual test suite Sprint 5 chưa chạy; sửa lệch BUG-008/009/010/013.
- **Risk nổi bật:** `test/widget_test.dart` Fail có thể khiến CI/`flutter test` báo đỏ toàn bộ nếu sau này thêm CI — nên quyết định sửa/xoá trước Phase E (Release Candidate), vì `01_RELEASE_CHECKLIST.md` yêu cầu `flutter test` pass 100%.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-19 — đóng Sprint 4)

- **Milestone:** **Sprint 4 DONE.** Chưa đạt M2 (Quality & Testing Complete) — còn thiếu Sprint 5 (kiểm thử thủ công có kịch bản).
- **Phase hiện tại:** B/C.
- **Task Completed:**
  - TD-19 hoàn thành: dọn toàn bộ `unused_import` (8), `unused_local_variable` (1), `unnecessary_underscores` (8, đổi `__`/`___` → `_`), `deprecated_member_use` (2, `DropdownButtonFormField.value` → `initialValue` ở `employee_screen.dart` — có rủi ro lý thuyết hẹp với `departmentsStreamProvider`, đã báo bạn trước khi commit), `use_build_context_synchronously` (3, đổi `mounted` → `context.mounted` đúng ngữ cảnh dialog builder ở `profile_info_list.dart`); thêm `ignore_for_file: avoid_print` cho 3 script dev (in ra console là chủ đích, không phải thiếu logging framework). Cố ý bỏ qua `checkin_screen.dart` (dead code, để dành TD-14).
  - `flutter analyze`: mobile 23→1, admin 13→0. `flutter test`: 19/19 vẫn Pass, không hồi quy. Commit `00fd541`.
  - `01_BACKLOG.md` (TD-19 → Done), `02_SPRINT.md` (Sprint 4 → DONE, kèm Sprint Review ngắn) cập nhật theo.

### Sprint Review — Sprint 4

| Task | Trạng thái | Bug/rủi ro mới phát sinh? |
|---|---|---|
| TD-05 — Xoá `.toUpperCase()` thừa | Done (`bf64a9e`) | Không |
| TD-04 — Logging tối thiểu (`AppLogger`) | Done (`a3c6d4c`) | Không |
| UT-01→UT-14 — 14 unit test | Done (`137d124`) | Phát hiện phụ: `widget_test.dart` mặc định Fail, tiền tồn tại, chưa sửa (để sau) |
| TD-19 — Dọn `flutter analyze` | Done (`00fd541`) | Rủi ro lý thuyết hẹp ở `DropdownButtonFormField.initialValue` (StreamProvider timing) — đã báo minh bạch, chấp nhận |

**Tổng kết:** 4/4 task Done, đúng phạm vi từng task. Không có bug mới thật sự phát sinh, chỉ 2 điểm cần theo dõi (không chặn gì): `widget_test.dart` Fail và rủi ro lý thuyết ở dropdown nói trên.
- **Task Remaining:** Sprint 5 (kiểm thử thủ công có kịch bản, tận dụng Demo Time System); `widget_test.dart` Fail; BUG-014; TD-06→TD-20 trừ TD-19 (Sprint 6); FEAT-01/02/03 (chờ xác nhận ưu tiên); sửa lệch BUG-008/009/010/013 trong Bug Tracker.
- **Risk nổi bật:** không có rủi ro mới ngoài 2 điểm đã nêu ở trên.

## 2026-07-20 (cùng ngày) — Sprint 5 giao cho bạn tự chạy; bắt đầu Sprint 6

- **Milestone:** Sprint 5 đang chờ bạn tự thực hiện kiểm thử thủ công trên thiết bị thật (đã gửi checklist tổng hợp từ `01_TEST_PLAN.md` mục B/C/D + test tồn đọng TD01-02/03/04/08), báo kết quả sau. Song song, bắt đầu Sprint 6 (Code Quality mở rộng, không bắt buộc).
- **Phase hiện tại:** B (Sprint 6) song song C (Sprint 5, chờ bạn).
- **Task Completed:**
  - TD-14 hoàn thành: xoá 4 file dead code thật sự tồn tại (`checkin_screen.dart`, `gps_test_screen.dart`, `gps_provider.dart`, `admin_model.dart` rỗng ở admin) — đã xác minh bằng grep không còn import/tham chiếu nào trước khi xoá. `auth_gate.dart` (mục 5 trong backlog gốc) hoá ra đã không còn tồn tại từ trước, không cần xoá.
  - `flutter analyze`: mobile 1→0 (đóng nốt issue còn sót từ TD-19), admin vẫn 0. `flutter test` (mobile) 19/19 vẫn Pass. `flutter build web` (admin) build thành công — có 1 sai sót nhỏ tự phát hiện: lần build đầu tiên chạy nhầm thư mục `attendance_mobile` do thư mục làm việc của shell còn giữ từ lệnh trước, đã tự nhận ra và chạy lại đúng `attendance_admin`.
  - Commit `bcaa2c0`. `01_BACKLOG.md` (TD-14 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06→TD-13, TD-15→TD-18, TD-20 (Sprint 6, còn lại); `widget_test.dart` Fail; BUG-014; FEAT-01/02/03; sửa lệch BUG-008/009/010/013.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-07)

- **Milestone:** Sprint 6 tiếp tục (không bắt buộc, dừng được bất kỳ lúc nào).
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-07 hoàn thành: `_getWeeklyAttendance()` (Dashboard admin) đổi từ vòng `for` + `await` tuần tự (7 query/ngày, nối tiếp nhau) sang `Future.wait()` chạy đồng thời, giữ đúng thứ tự ngày cũ→mới khi ghép kết quả.
  - `flutter analyze` (admin) 0 issue; `flutter build web` (admin) build thành công, đúng thư mục lần này (rút kinh nghiệm từ sai sót cwd ở TD-14).
  - Commit `690aa48`. `01_BACKLOG.md` (TD-07 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08→TD-13, TD-15→TD-18, TD-20 (Sprint 6, còn lại); `widget_test.dart` Fail; BUG-014; FEAT-01/02/03; sửa lệch BUG-008/009/010/013.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-12/TD-13)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-12 hoàn thành: đồng bộ nhãn ca — admin đổi `'Ca sáng'` → `'Ca ngày'` (`attendance_model.dart`) khớp với mobile.
  - TD-13 hoàn thành: rà toàn bộ `Color(0xFF...)` hardcode ở cả 2 app, chỉ tìm thấy đúng 2 chỗ trùng khớp chính xác với `AppColors` có sẵn (mobile: `home_skeleton.dart` → `AppColors.primary`, `checkin_card.dart` → `AppColors.background`, đơn giản hoá luôn 1 ternary thừa cùng chỗ). Phát hiện phụ: admin có `0xFFB91C1C` lặp 6 lần (`sidebar.dart`, `main_layout.dart`, `leave_screen.dart`) — khác `AppColors.primary` (`0xFFC8102E`), có thể là màu UI cố ý riêng cho sidebar chứ không phải hardcode nhầm — cố ý chưa đụng, cần bạn xác nhận có muốn thống nhất lại không (sẽ đổi giao diện thấy được nếu làm).
  - `flutter analyze` cả 2 app: 0 issue. Commit `6f34a9e`. `01_BACKLOG.md` (TD-12, TD-13 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08→TD-11, TD-15→TD-18, TD-20 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin (phát hiện phụ, chưa vào backlog riêng); `widget_test.dart` Fail; BUG-014; FEAT-01/02/03; sửa lệch BUG-008/009/010/013.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-16/TD-17)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-16: phát hiện tiền đề backlog sai trước khi code — `LeaveRequestModel.startDate` thực sự là `DateTime?`, không phải "không nullable" như `REVIEW.md`/`01_BACKLOG.md` ghi. Xoá `?.` như mô tả gốc sẽ vỡ build. Đóng dưới dạng **Won't Fix** thay vì Done, cập nhật `01_BACKLOG.md` và `02_BUG_TRACKER.md` (BUG-012) kèm lý do, không đụng code.
  - TD-17 hoàn thành: `attendance_mobile/lib/shared/widgets/custom_button.dart` — set `color: Colors.white` tường minh cho `CircularProgressIndicator` (trước đó dùng màu mặc định theme). Admin's `CustomButton` đã tự làm đúng từ trước, không cần sửa.
  - `flutter analyze` (mobile) 0 issue. Commit `73ce3bb`.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08→TD-11, TD-15, TD-18, TD-20 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới. Bài học quy trình: đáng giá lại tiền đề của backlog item trước khi code, không phải mọi ghi chú cũ đều còn đúng khi source đã thay đổi qua thời gian.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-20)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-20 hoàn thành: gỡ `firebase_storage` khỏi `pubspec.yaml` cả 2 app (xác nhận trước bằng grep — 0 file trong `lib/` import) + `flutter pub get`. Phát hiện phụ tự sửa: `flutter build web` lần đầu báo lỗi do `web_plugin_registrant.dart` cũ (cache) còn tham chiếu `firebase_storage_web` — không phải lỗi thật, chạy `flutter clean` rồi build lại là hết. Cũng tự phát hiện 2 lần chạy nhầm lệnh kiểm tra `attendance_admin` khi thư mục làm việc của shell còn đang ở `attendance_mobile` (do 2 lệnh Bash trong cùng 1 lượt chia sẻ chung trạng thái thư mục) — đã sửa lại bằng `cd` tường minh trong từng lệnh.
  - `flutter analyze` cả 2 app: 0 issue. `flutter test` (mobile): 19/19 vẫn Pass. `flutter build web` cả 2 app: thành công sau `flutter clean`. Commit `4cbfe08` (gồm cả `GeneratedPluginRegistrant.swift`/`generated_plugin_registrant.cc`/`generated_plugins.cmake` tự regenerate, đã review diff chỉ gỡ đúng phần `firebase_storage`).
  - `01_BACKLOG.md` (TD-20 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08→TD-11, TD-15, TD-18 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-10)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-10 hoàn thành, phạm vi rộng hơn dự tính ban đầu sau khi khảo sát: `login_screen.dart` (validator email tự viết yếu hơn `Validators.email` — chỉ kiểm tra `contains('@')`) và `employee_screen.dart` (ô Email chỉ kiểm tra không rỗng, chưa từng validate định dạng dù là email đăng nhập thật của nhân viên) đều đổi sang `Validators.email`. Số điện thoại (`employee_screen.dart`) được giao cho tôi tự quyết định phạm vi — chọn giữ **tuỳ chọn** (không bắt buộc nhập), chỉ validate định dạng bằng `Validators.phone` khi có nhập, để không đổi hành vi hiện tại (admin có thể thêm nhân viên mà chưa có SĐT).
  - `flutter analyze` (admin) 0 issue; `flutter build web` thành công. Commit `311ede8`.
  - `01_BACKLOG.md` (TD-10 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08, TD-09, TD-11, TD-15, TD-18 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-09)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-09 hoàn thành: `ConfirmDialog.show()` (admin) trước đó có 0 call site nào — rà 4 chỗ `AlertDialog` tự dựng, chỉ đúng 1 chỗ khớp hình dạng (title+message+confirm/cancel tĩnh): dialog "Xác nhận xóa nhân viên" (`employee_screen.dart`), đổi sang `ConfirmDialog.show(isDanger: true)`. 3 chỗ còn lại không đụng vì không hợp: form thêm/sửa nhân viên (là form nhập liệu, không phải confirm đơn giản), dialog "Không thể xoá" (chỉ 1 nút Đóng, `ConfirmDialog` luôn có 2 nút), dialog duyệt/từ chối nghỉ phép (có `TextField` nhúng, `ConfirmDialog.message` chỉ nhận `String` tĩnh).
  - Tự phát hiện và sửa 1 lỗi cú pháp phát sinh khi edit (dấu `);` thừa sót lại từ cấu trúc `AlertDialog` cũ) — bắt được ngay qua `flutter analyze` trước khi commit.
  - `flutter analyze` (admin) 0 issue; `flutter build web` thành công. Commit `0ea3030`.
  - `01_BACKLOG.md` (TD-09 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08, TD-11, TD-15, TD-18 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-11)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-11 hoàn thành: 7 chỗ hiển thị lỗi kỹ thuật thô (`'Lỗi: $err'`/`'Lỗi: ${e.toString()}'`) đổi sang thông điệp thân thiện theo ngữ cảnh — admin: tải cấu hình/đơn nghỉ phép/nhật ký chấm công/danh sách nhân viên (4 chỗ `AsyncValue.error`) + lưu nhân viên; mobile: cập nhật số điện thoại + gửi email khôi phục mật khẩu. Thêm `AppLogger.error()` ở 4 chỗ chưa có (không mất chi tiết kỹ thuật, chỉ không hiện cho người dùng).
  - `flutter analyze` cả 2 app: 0 issue. `flutter test` (mobile): 19/19 Pass. `flutter build web` (admin): thành công — lần đầu vô tình build nhầm `attendance_mobile` do thư mục làm việc còn giữ từ lệnh trước (lặp lại đúng lỗi đã gặp ở TD-14/TD-20), tự phát hiện và build lại đúng chỗ.
  - Commit `c6d48bd`. `01_BACKLOG.md` (TD-11 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-08, TD-15, TD-18 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới. Lưu ý thao tác: khi chạy song song 2 lệnh Bash trong cùng 1 lượt, lệnh sau kế thừa thư mục làm việc của lệnh trước — cần `cd` tường minh mỗi lần đổi app, đã lặp lỗi này 3 lần trong Sprint 6 (TD-14, TD-20, TD-11).

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-08)

- **Milestone:** Sprint 6 tiếp tục.
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-08 hoàn thành: `AttendanceHistoryNotifier` (mobile) cache `company_settings`/`shiftGroup` ở cấp instance, chỉ đọc Firestore 1 lần thay vì mỗi lần chuyển tháng; `refresh()` xoá cache trước khi tải lại để không bỏ lỡ thay đổi thật (VD admin đổi cấu hình công ty).
  - Tự phát hiện 1 lỗi kiểu dữ liệu lúc code (`userDoc.data()?['shiftGroup']` trả về `dynamic` dù có `?? 'A'`, không khớp kiểu trả về `String` của hàm) — bắt được ngay qua `flutter analyze`, sửa bằng ép kiểu `as String?` trước khi fallback.
  - Phát hiện phụ về quy trình: 1 lần `flutter analyze` báo "Analyzing attendance-system... No issues found" — hoá ra thư mục làm việc bị lệch (không phải `attendance_mobile` như tưởng), kết quả không đáng tin; đã tự phát hiện qua `pwd`, chạy lại đúng bằng 1 lệnh gộp `cd && flutter analyze` để tránh phụ thuộc trạng thái thư mục giữa các lệnh Bash riêng lẻ.
  - `flutter analyze` (mobile) 0 issue (đã xác nhận đúng thư mục lần 2). `flutter test`: 19/19 Pass. Commit `f819577`.
  - `01_BACKLOG.md` (TD-08 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06, TD-15, TD-18 (Sprint 6, còn lại); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới. Bài học quy trình bổ sung: luôn gộp `cd` + lệnh kiểm tra trong cùng 1 lời gọi Bash, không tách rời và giả định thư mục làm việc còn đúng từ lệnh trước.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-18)

- **Milestone:** Sprint 6 gần xong — chỉ còn TD-06 (phức tạp hơn) và TD-15 (cần xác nhận ưu tiên FEAT-01 trước).
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-18 hoàn thành: thêm `ShiftEndedException` (`attendance/domain/attendance_exceptions.dart`), `attendance_repository.dart` ném đúng kiểu này thay `Exception` thô, `attendance_provider.dart` kiểm tra bằng `e is ShiftEndedException` thay `.toString().contains(...)`. `AuthRepository.reauthenticate()` bắt `FirebaseAuthException` theo `e.code` (giống pattern `login()` đã có), ném sẵn thông điệp thân thiện — `change_password_page.dart` bỏ hẳn việc dò chuỗi `'wrong-password'`.
  - `flutter analyze` (mobile) 0 issue (xác nhận đúng thư mục qua `pwd` trước). `flutter test`: 19/19 Pass. Commit `ab5b04f`.
  - `01_BACKLOG.md` (TD-18 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-06 (giới hạn/lọc `getAttendanceLogs()`, phức tạp hơn — sửa logic query + có thể đụng UI phân trang); TD-15 (cần xác nhận ưu tiên FEAT-01 trước, có thể huỷ nếu FEAT-01 làm trước); quyết định về `0xFFB91C1C` ở admin; `widget_test.dart` Fail; BUG-014; FEAT-01/02/03.
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày, sau khi hoàn thành TD-06 — Sprint 6 gần như đóng)

- **Milestone:** Sprint 6 chỉ còn TD-15 (đang chờ quyết định ưu tiên FEAT-01) — mọi task khác đã Done/Won't Fix. Chưa đạt M2 (còn thiếu Sprint 5).
- **Phase hiện tại:** B.
- **Task Completed:**
  - TD-06 hoàn thành, kèm 1 thay đổi hành vi có chủ đích đã xác nhận trước: `AttendanceRepository.getAttendanceLogs()` (admin) nay bắt buộc `start`/`end`, không còn stream toàn bộ collection `attendance` không giới hạn. `attendanceStreamProvider` đổi thành `StreamProvider.family<..., DateTime?>` theo ngày admin chọn — mặc định **tháng hiện tại** khi chưa chọn ngày (trước đây là toàn bộ lịch sử), chọn 1 ngày cụ thể thì chỉ tải đúng ngày đó. Thêm dòng hint UI báo đang xem tháng nào để tránh admin tưởng mất dữ liệu. Xuất Excel/PDF bị giới hạn theo cùng phạm vi (hệ quả tất yếu, đã báo trước).
  - `flutter analyze` (admin) 0 issue; `flutter build web` thành công. Commit `3ac50c0`.
  - `01_BACKLOG.md` (TD-06 → Done) cập nhật theo.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-15 (chờ quyết định ưu tiên FEAT-01); quyết định về `0xFFB91C1C` ở admin (phát hiện phụ từ TD-13, chưa vào backlog riêng); `widget_test.dart` Fail; BUG-014; FEAT-01/02/03; sửa lệch BUG-008/009/010/013 trong Bug Tracker (phát hiện từ lượt review đầu, vẫn chưa làm).
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày) — Dọn việc nhỏ còn treo

- **Milestone:** Sprint 6 đóng hoàn toàn trừ TD-15. Không có Sprint mới mở.
- **Phase hiện tại:** B.
- **Task Completed:**
  - Sửa lệch trạng thái Bug Tracker: BUG-008/009/010/013 chuyển từ Open → Fixed (đúng thực tế, fix đã Done từ Sprint 1); cập nhật lại bảng tóm tắt ở `01_BACKLOG.md` mục D (Fixed 12/Open 1/Won't Fix 1/Tổng 14). Commit `d5856e2`.
  - Quyết định về màu `0xFFB91C1C` ở admin (giao cho tôi tự chọn): tách thành `AppColors.sidebarAccent` — **không đổi màu hiển thị**, chỉ hết lặp lại hex ở 6 chỗ (`sidebar.dart`, `main_layout.dart`, `leave_screen.dart`). Chọn hướng an toàn nhất vì đây là quyết định thẩm mỹ chủ quan, không phải bug — không tự ý đổi giao diện khi không chắc ý muốn thật sự của bạn. Commit `29223fb`.
  - `flutter analyze` (admin) 0 issue cả 2 lần; `flutter build web` thành công.
- **Task Remaining:** Sprint 5 (chờ bạn báo kết quả); TD-15 (chờ quyết định ưu tiên FEAT-01); `widget_test.dart` Fail; BUG-014 (Open, duy nhất còn lại); FEAT-01/02/03 (chờ xác nhận ưu tiên).
- **Risk nổi bật:** không có rủi ro mới. Toàn bộ Sprint 6 (trừ TD-15) và các việc tồn đọng nhỏ đã dọn xong — điểm quyết định lớn tiếp theo là FEAT-01/02/03 (ảnh hưởng hướng đi toàn bộ phần còn lại của Phase A) và kết quả Sprint 5 từ bạn.

## 2026-07-20 (cùng ngày) — Chốt phạm vi Phase A (D-013)

- **Milestone:** Sprint 2 (Nghỉ phép mobile) và Sprint 3 (Notification UI) sẵn sàng bắt đầu — không còn điều kiện "chờ xác nhận" nào.
- **Phase hiện tại:** A (mở rộng tính năng mới).
- **Task Completed:**
  - Xác nhận với bạn: **làm FEAT-01** (Nghỉ phép mobile), **làm FEAT-02** (Notification UI), **hoãn FEAT-03** (Phòng ban CRUD admin). Ghi thành quyết định D-013 ở `docs/decision/01_DECISION_LOG.md`.
  - `01_BACKLOG.md`: FEAT-01/02 → Ready, FEAT-03 → Deferred, TD-15 → Cancelled (thừa vì FEAT-01 sẽ thay hẳn placeholder, không cần bản "tử tế hơn" tạm).
  - `02_SPRINT.md`: Sprint 2 (chỉ FEAT-01) và Sprint 3 (chỉ FEAT-02, FEAT-03 tách khỏi sprint) bỏ điều kiện tiên quyết "chờ xác nhận".
- **Task Remaining:** Sprint 2 (FEAT-01) — chưa bắt đầu code; Sprint 3 (FEAT-02) sau đó; Sprint 5 (chờ bạn báo kết quả); `widget_test.dart` Fail; BUG-014.
- **Risk nổi bật:** không có rủi ro mới. Phạm vi Phase A giờ đã rõ ràng hoàn toàn — không còn mục nào mơ hồ chờ quyết định.

## 2026-07-20 (cùng ngày) — Sprint 2 DONE (FEAT-01)

- **Milestone:** **Sprint 2 DONE.** Chưa đạt M1 (còn Sprint 3 — FEAT-02).
- **Phase hiện tại:** A.
- **Task Completed:**
  - FEAT-01 hoàn thành: `leave_repository.dart` (tạo đơn + stream đơn của chính mình), `leave_provider.dart` (StreamProvider + Notifier luồng tạo đơn), `leave_screen.dart` (danh sách + badge trạng thái + form tạo đơn qua bottom sheet) — thay hẳn placeholder tĩnh ở route `/leave`. Chỉ có Tạo + Xem, không có Sửa/Huỷ (đúng theo `firestore.rules` — nhân viên không có quyền `update`/`delete` trên `leave_requests`).
  - Phát hiện **BUG-015** ngay trong lúc test tay: query kết hợp `.where('uid',...).orderBy('createdAt',...)` cần composite index chưa khai báo cho `leave_requests`, khiến admin duyệt/từ chối không phản ánh lại mobile. Sửa ngay trong cùng task bằng cách bỏ `orderBy` ở Firestore, sort lại bằng code (đúng pattern đã dùng ở `attendance_history_provider.dart`) — không cần deploy thêm index mới.
  - `flutter analyze` 0 issue, `flutter test` 19/19 Pass, `flutter build web` thành công. Kiểm thử tay end-to-end (tạo đơn mobile → duyệt admin → cập nhật mobile) **Pass** sau khi sửa BUG-015.
  - Commit `b742193`. `01_BACKLOG.md` (FEAT-01 → Done), `02_SPRINT.md` (Sprint 2 → DONE), `02_BUG_TRACKER.md` (BUG-015 → Fixed) cập nhật theo.

### Sprint Review — Sprint 2

| Task | Trạng thái | Bug phát sinh? |
|---|---|---|
| FEAT-01 — Nghỉ phép (mobile) | Done (`b742193`) | BUG-015 (composite index thiếu) — phát hiện và **sửa ngay trong cùng task**, đã đóng |

**Tổng kết:** 1/1 task Done. 1 bug phát hiện-và-sửa-ngay, không có việc tồn đọng nào từ Sprint này.
- **Task Remaining:** Sprint 3 (FEAT-02 — Notification UI); Sprint 5 (chờ bạn báo kết quả); `widget_test.dart` Fail; BUG-014 (Open, duy nhất còn lại).
- **Risk nổi bật:** không có rủi ro mới.

## 2026-07-20 (cùng ngày) — Sprint 3 DONE (FEAT-02) — đạt Milestone M1

- **Milestone:** **Sprint 3 DONE. Đạt Milestone M1 (Core Complete).** Phase A coi như hoàn thành — FEAT-01/02 Done, FEAT-03 Deferred có chủ đích (D-013), không có tính năng nào khác còn "chưa làm" theo `PROJECT_MASTER_PLAN.md` §1.3 ngoài phạm vi đã hoãn.
- **Phase hiện tại:** chuyển tiếp A → B/C (Code Quality mở rộng còn lại + Testing).
- **Task Completed:**
  - FEAT-02 hoàn thành: `notification_repository.dart` (đọc thông báo của chính mình, tránh lại đúng lỗi composite-index như BUG-015 ngay từ đầu), `notification_provider.dart`, `notification_screen.dart`. Nối vào nút chuông có sẵn ở `home_header.dart` (trước đó không làm gì); chấm báo hiệu đổi từ hardcode-luôn-hiện sang có điều kiện (có thông báo mới hiện) — không track được đã đọc/chưa đọc thật vì `firestore.rules` chặn `update` trên `notifications`.
  - Tiện thể dọn 1 dòng "Thông báo" khác cũng chết (`onTap: () {}`) ở Profile > Cài đặt — trùng lặp lối vào với chuông ở Home, không có tính năng cài đặt thông báo nào thật để trỏ tới, nên xoá thay vì nối thêm 1 lối vào giống hệt.
  - `flutter analyze` 0 issue, `flutter test` 19/19 Pass, `flutter build web` thành công. Kiểm thử tay Pass: duyệt/từ chối đơn nghỉ phép ở admin → hiện đúng thông báo ở mobile.
  - Commit `fc0a2b5`. `01_BACKLOG.md` (FEAT-02 → Done), `02_SPRINT.md` (Sprint 3 → DONE, đạt M1) cập nhật theo.

### Sprint Review — Sprint 3

| Task | Trạng thái | Bug/phát sinh? |
|---|---|---|
| FEAT-02 — Notification UI (mobile) | Done (`fc0a2b5`) | Không — rút kinh nghiệm BUG-015 nên tránh được lỗi tương tự ngay từ đầu; tiện thể dọn 1 dead code phụ (dòng "Thông báo" ở Profile) |

**Tổng kết:** 1/1 task Done, không phát sinh bug mới. Milestone M1 đạt được sớm hơn dự kiến nhờ tránh lặp lại lỗi đã học từ Sprint 2.
- **Task Remaining:** Sprint 5 (kiểm thử thủ công, chờ bạn báo kết quả); TD-06→TD-18 hạng Low còn sót (không có, đã xong hết Sprint 6 trừ TD-15 Cancelled); `widget_test.dart` Fail; BUG-014 (Open, duy nhất còn lại); Sprint 7 (Release Candidate) chưa mở.
- **Risk nổi bật:** không có rủi ro mới. Điểm cần chú ý tiếp theo: Phase B (Nên làm/Dọn dẹp, tuỳ chọn) và Phase C (Testing thủ công, Sprint 5) trước khi có thể tiến tới Phase E (Release Candidate).
