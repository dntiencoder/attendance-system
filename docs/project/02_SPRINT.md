# 02_SPRINT.md

**Mục tiêu:** Chia toàn bộ công việc còn lại trong `01_BACKLOG.md` thành các đợt thực hiện có thời hạn (sprint), để biết "tuần này làm gì" thay vì chỉ có một danh sách Phase trừu tượng.

**Phạm vi:** Chỉ Phase A, B, C, E, F (công việc code/kiểm thử/release). Phase D.1 được tách thành Sprint 0 vì có thể làm ngay, không phụ thuộc các sprint khác. Phase G, D.2, H **không chia sprint ở đây** — đó là công việc viết lách/thuyết trình, không có "task kỹ thuật" rời rạc để đóng gói theo sprint theo cùng cách; kế hoạch cho các phase đó nằm nguyên ở `PROJECT_MASTER_PLAN.md` §3.

**Khi nào dùng:** Đầu mỗi đợt làm việc, để biết đang ở sprint nào và task tiếp theo là gì; cập nhật `07_PROGRESS.md` khi đóng một sprint.

**Liên kết:** Task ID tham chiếu `01_BACKLOG.md`; Phase tham chiếu `PROJECT_MASTER_PLAN.md` §3; Definition of Done từng sprint là tập con của Definition of Done cấp Phase ở `PROJECT_MASTER_PLAN.md` §5, không định nghĩa lại. Đóng sprint → ghi 1 dòng vào `docs/project/03_PROGRESS.md`.

> **Lưu ý về đơn vị thời gian:** đây là dự án cá nhân làm bán thời gian — "Sprint" ở đây là một **cụm công việc liên quan**, không phải khung thời gian cố định theo lịch (không có ngày bắt đầu/kết thúc ép buộc, không có "velocity"). Estimate tính bằng ngày công (man-day) thực tế ngồi làm, không phải ngày lịch. Thứ tự sprint là thứ tự đề xuất, có thể đảo nếu có lý do.

---

## Sprint 0 — Demo báo cáo tiến độ sẵn sàng (M0)

**Mục tiêu:** Đạt Demo Ready cho buổi báo cáo tiến độ — không phụ thuộc bất kỳ sprint nào khác, làm ngay.

**Task:** checklist D.1 của `PROJECT_MASTER_PLAN.md` (không lặp lại ở đây — xem nguyên văn tại đó): seed `leave_requests` mẫu, quyết định `company_settings.radius`, sửa `departmentId` admin, kiểm thử tay Check In/Out, dry-run Demo Center.

**Estimate:** ~1 ngày công.
**Deliverable:** Buổi báo cáo tiến độ có thể diễn ra bất kỳ lúc nào sau sprint này.
**Definition of Done:** toàn bộ checklist D.1 + `docs/demo/05_DEMO_CHECKLIST.md` đã tick.

---

## Sprint 1 — Nợ kỹ thuật lõi + an toàn Demo Time System — ✅ DONE (2026-07-13)

**Mục tiêu:** Loại bỏ rủi ro mất công sức (Demo Time chưa commit) và các bug/nợ kỹ thuật ảnh hưởng trực tiếp tới tính đúng của nghiệp vụ chấm công/rotation.

**Task:** FEAT-04, TD-01, TD-02 (đã đổi tên/thiết kế lại 2026-07-13 — "Chặn xoá nhân viên đã phát sinh dữ liệu nghiệp vụ", xem `docs/design/EMPLOYEE_LIFECYCLE.md` và `01_BACKLOG.md`), TD-03.
**Estimate:** ~3-4 ngày công.
**Deliverable:** Demo Time System đã commit; `checkIn()` an toàn với transaction; xoá nhân viên có ràng buộc `isActive`; rotation dùng 1 nguồn mốc ngày duy nhất.
**Ghi lại:** mỗi task hoàn thành → cập nhật Status ở `01_BACKLOG.md` sang `Done`.
**Definition of Done:** `flutter analyze` không phát sinh issue mới; đã kiểm thử tay từng thay đổi (Check In liên tiếp nhanh, xoá nhân viên đang active, đổi `rotationStartDate` và xác nhận `WorkScheduleHelper` phản ánh đúng).

**Đã đóng 2026-07-13** — cả 4 task hoàn thành: FEAT-04 (`9a2623e`), TD-01 (`2da7827`), TD-02 (`7f17397`, đổi tên/thiết kế lại theo `docs/design/EMPLOYEE_LIFECYCLE.md`), TD-03 (`5d829ae`). Xem Sprint Review đầy đủ ở `docs/project/03_PROGRESS.md`.

---

## Sprint 2 — Nghỉ phép (mobile) — ✅ DONE (2026-07-20)

**Điều kiện tiên quyết:** đã xác nhận 2026-07-20 (D-013, `docs/decision/01_DECISION_LOG.md`) — không còn chờ gì thêm.

**Mục tiêu:** Nhân viên tự tạo và xem đơn nghỉ phép từ app mobile.
**Task:** FEAT-01. TD-15 (thay placeholder) đã Cancelled — FEAT-01 tự thay thế hẳn màn placeholder, không cần làm riêng.
**Estimate:** ~2-3 ngày công.
**Deliverable:** `LeaveRepository`/`leave_provider.dart`/UI tạo đơn + danh sách đơn ở mobile.
**Definition of Done:** tạo đơn từ mobile → hiện đúng ở màn Duyệt Nghỉ Phép (admin) → duyệt/từ chối → trạng thái cập nhật lại đúng ở mobile.

**Đã đóng 2026-07-20** — FEAT-01 hoàn thành, commit `b742193`. Phát hiện + sửa 1 bug ngay trong lúc test tay: query `.where('uid',...).orderBy('createdAt',...)` cần composite index chưa khai báo cho `leave_requests` trong `firestore.indexes.json`, khiến cập nhật trạng thái từ admin không phản ánh lại mobile — sửa bằng cách bỏ `orderBy` ở Firestore, sort lại bằng code (giống pattern đã dùng ở `attendance_history_provider.dart`). Kiểm thử tay end-to-end Pass sau khi sửa. Xem Sprint Review đầy đủ ở `docs/project/03_PROGRESS.md`.

---

## Sprint 3 — Notification UI — ✅ DONE (2026-07-20)

**Điều kiện tiên quyết:** đã xác nhận 2026-07-20 (D-013) — FEAT-02 làm, FEAT-03 hoãn (không nằm trong sprint này nữa).

**Mục tiêu:** Có màn hiển thị thông báo cho nhân viên (tối thiểu 1 app).
**Task:** FEAT-02. (FEAT-03 chuyển sang Deferred ở `01_BACKLOG.md` mục C, không thuộc sprint nào.)
**Estimate:** ~1-2 ngày công.
**Deliverable:** màn hiển thị thông báo (tối thiểu 1 app).
**Definition of Done:** Phase A của `PROJECT_MASTER_PLAN.md` — checklist đã tick (trừ FEAT-03 hoãn có chủ đích) → đạt **Milestone M1**.

**Đã đóng 2026-07-20** — FEAT-02 hoàn thành, commit `fc0a2b5`. Nối vào nút chuông có sẵn ở `home_header.dart` (trước đó `onPressed: () {}` chết); tiện thể xoá 1 dòng "Thông báo" khác cũng chết ở Profile > Cài đặt (trùng lặp lối vào). Kiểm thử tay Pass: duyệt/từ chối đơn nghỉ phép ở admin → hiện đúng thông báo ở mobile. **→ Đạt Milestone M1 (Core Complete)** — Phase A coi như xong (FEAT-03 hoãn có chủ đích, không chặn M1). Xem Sprint Review đầy đủ ở `docs/project/03_PROGRESS.md`.

---

## Sprint 4 — Code Quality bắt buộc + Unit Test — ✅ DONE (2026-07-20)

**Mục tiêu:** Đóng các mục High-priority còn lại của Phase B, bắt đầu Phase C phần tự động hoá được.
**Task:** TD-04, TD-05, TD-19; + 5 unit test đầu của `docs/testing/01_TEST_PLAN.md` (Haversine, `getCurrentShift`, `calculateIsLate`, `calculateEarlyLeave`, `BusinessDateHelper`).
**Estimate:** ~3-4 ngày công.
**Deliverable:** logging/crash tối thiểu đã có; `flutter analyze` giảm về gần 0; `flutter test` chạy xanh với bộ unit test mới.
**Definition of Done:** `flutter test` pass 100%; không còn issue High trong `REVIEW.md`/`01_BACKLOG.md` mục B.

**Đã đóng 2026-07-20** — cả 4 task hoàn thành: TD-05 (`bf64a9e`), TD-04 (`a3c6d4c`), 14 unit test UT-01→UT-14 (`137d124`), TD-19 (`00fd541`). `flutter analyze`: mobile 23→1 (1 còn lại cố ý ở `checkin_screen.dart`, dead code chờ TD-14), admin 13→0. `flutter test`: 19/19 test mới Pass; 1 fail tiền tồn tại không liên quan (`widget_test.dart` mặc định, để lại quyết định sau). Xem Sprint Review đầy đủ ở `docs/project/03_PROGRESS.md`.
**Lưu ý DoD:** `flutter test` chưa pass 100% tuyệt đối (do `widget_test.dart` fail, không phải do bộ unit test mới) — coi Sprint 4 là Done vì mục tiêu thực chất (unit test cho business logic + dọn code quality) đã đạt; `widget_test.dart` là việc tồn đọng riêng, không thuộc phạm vi task nào của Sprint 4.

---

## Sprint 5 — Kiểm thử thủ công có kịch bản

**Mục tiêu:** Chạy hết phần "Manual" của `docs/testing/01_TEST_PLAN.md`, tận dụng Demo Time System (đã commit từ Sprint 1) để tạo nhanh các mốc giờ biên.
**Task:** toàn bộ test case Manual trong `docs/testing/01_TEST_PLAN.md`.
**Estimate:** ~3-4 ngày công (rải ra vài đợt, không nhất thiết liên tục).
**Deliverable:** `docs/testing/01_TEST_PLAN.md` được điền đầy đủ cột Status/Kết quả; mọi bug phát hiện được ghi vào `docs/testing/02_BUG_TRACKER.md`.
**Definition of Done:** không còn test case nào ở trạng thái "Chưa chạy"; các bug phát hiện (nếu có) đã được xử lý hoặc chuyển thành task mới trong `01_BACKLOG.md` → đạt **Milestone M2** (cùng Sprint 4).

---

## Sprint 6 — Code Quality mở rộng (tuỳ thời gian còn lại)

**Mục tiêu:** Dọn nốt các mục Medium/Low nếu còn thời gian trước khi cần chuyển sang Release.
**Task:** TD-06 đến TD-18, TD-20.
**Estimate:** ~6-8 ngày công — **không bắt buộc**, có thể dừng ở bất kỳ điểm nào trong sprint này nếu thời gian eo hẹp, ưu tiên chuyển sang Sprint 7.
**Deliverable:** `flutter analyze` về 0 issue; UI nhất quán hơn giữa 2 app.
**Definition of Done:** tuỳ chọn — coi là "Done" khi bạn quyết định dừng, không cần làm hết 100% mục này.

---

## Sprint 7 — Release Candidate + Source Freeze

**Mục tiêu:** Có bản build cụ thể, gắn tag, và tuyên bố đóng băng source.
**Task:** checklist đầy đủ tại `docs/release/01_RELEASE_CHECKLIST.md` (không lặp lại ở đây).
**Estimate:** ~1-2 ngày công.
**Deliverable:** APK + Web build từ 1 commit cụ thể, git tag, `docs/project/04_DATA_FREEZE_PLAN.md` chuyển sang mức đóng băng phù hợp.
**Definition of Done:** `docs/release/01_RELEASE_CHECKLIST.md` tick hết → đạt **Milestone M3**; tuyên bố freeze → **Milestone M4**.

---

## Ghi chú: Phase G, D.2, H không nằm trong sprint

Viết Chương 3/4 (Phase G) là công việc soạn thảo, không phải task kỹ thuật rời rạc — bắt đầu được **ngay từ sau Sprint 0** cho phần "viết nháp" (song song các sprint trên), chỉ phần "chốt số liệu" cần đợi sau Sprint 7 (Source Freeze). D.2 và Phase H (chuẩn bị bảo vệ) chỉ bắt đầu sau khi Phase G có bản thảo ổn định — xem `PROJECT_MASTER_PLAN.md` §3 Phase G/H để biết chi tiết, không lặp lại ở đây.
