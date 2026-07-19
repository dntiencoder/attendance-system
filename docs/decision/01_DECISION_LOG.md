# 01_DECISION_LOG.md

**Mục tiêu:** Ghi lại các quyết định kỹ thuật/quản lý quan trọng kèm bối cảnh và lý do — thứ mà `ARCHITECTURE.md` (chỉ mô tả trạng thái hiện tại, không giải thích "vì sao") và `ROADMAP.md` (chỉ có 1 bảng ngắn "Ngoài phạm vi", không đủ chi tiết bối cảnh/ưu-nhược điểm) không đóng vai trò này.

**Phạm vi:** Toàn bộ quyết định có ảnh hưởng lâu dài tới kiến trúc, nghiệp vụ, hoặc phạm vi dự án — không ghi các quyết định vụn vặt (đặt tên biến, thứ tự import...).

**Khi nào dùng:** Tra cứu "tại sao lại làm thế này" khi quay lại code sau một thời gian dài, hoặc khi cần trả lời câu hỏi phản biện lúc bảo vệ tốt nghiệp về các lựa chọn thiết kế. Thêm entry mới ngay khi có quyết định quan trọng mới — **thêm vào cuối file này, không tạo file riêng cho từng quyết định** (chỉ tách file khi số lượng entry vượt quá ~30 mục).

**Liên kết:** Nhiều quyết định dưới đây là căn cứ trực tiếp cho các mục "Deferred"/"Out-of-Scope" ở `docs/project/01_BACKLOG.md` mục C.

---

## Chú giải

Mỗi entry gồm: **Ngày**, **Bối cảnh**, **Lý do**, **Ưu điểm**, **Nhược điểm**, **Ảnh hưởng**.

---

### D-001 — Business Date resolution qua tham chiếu "hôm qua" cố định

**Ngày:** 2026-07 (commit `d2be986`, "fix night-shift attendance bugs via unified Business Date resolution")
**Bối cảnh:** Ca đêm xuyên nửa đêm gây bug: check-in lúc 00:18 hiển thị sai ca vì hệ thống dùng ngày theo đồng hồ thay vì "ngày làm việc" thực tế.
**Lý do:** Cần xác định nhân viên đang thuộc "ngày làm việc" nào mà không rơi vào phụ thuộc vòng tròn (muốn biết hôm nay làm ca gì → cần biết có làm đêm hôm qua không → biến chuỗi suy luận thành vòng lặp nếu không cố định điểm tham chiếu).
**Ưu điểm:** Loại bỏ hoàn toàn lớp bug thuộc nhóm "ca đêm qua nửa đêm" — nhóm bug phức tạp và dễ tái phát nhất trong hệ thống chấm công theo ca.
**Nhược điểm:** Thêm 1 khái niệm mới ("Business Date") mà người đọc code lần đầu cần học riêng, khác với ngày theo lịch thông thường.
**Ảnh hưởng:** `BusinessDateHelper` (mobile), toàn bộ luồng check-in/check-out/lịch sử chấm công. Xem thêm `docs/design/BUSINESS_DATE_DESIGN.md`.

### D-002 — Shift Rotation dựa trên `floor(daysPassed / rotationDays)` chẵn/lẻ

**Ngày:** giai đoạn đầu dự án (trước Phase 1 ROADMAP)
**Bối cảnh:** Cần một công thức xác định nhóm A/B đang làm ca gì tại bất kỳ ngày nào, có thể cấu hình lại chu kỳ mà không sửa code.
**Lý do:** Công thức thuần toán học (không cần lưu trạng thái từng ngày trong Firestore) — chỉ cần 2 tham số (`rotationStartDate`, `rotationDays`) là suy ra được ca của bất kỳ ngày nào trong quá khứ/tương lai.
**Ưu điểm:** Đơn giản, không cần cron job/Cloud Function để "advance" trạng thái theo thời gian; dễ kiểm chứng bằng dữ liệu thật (đã có bằng chứng đổi ca đúng chu kỳ 14 ngày).
**Nhược điểm:** Đổi `rotationStartDate` sai (như BUG-001) làm lệch toàn bộ lịch sử diễn giải — không có cơ chế "khoá" giá trị này khỏi bị ghi đè ngoài ý muốn ở tầng dữ liệu (chỉ có ở tầng UI sau khi fix).
**Ảnh hưởng:** `CompanySettingsModel.getCurrentShift()`, trùng lặp độc lập ở cả 2 app (xem D-007).

### D-003 — Firestore Security Rules tự viết dựa trên `get()`, không dùng Custom Claims

**Ngày:** 2026-07-05 (commit `55da6da`)
**Bối cảnh:** Trước đó không có `firestore.rules` nào trong repo (REVIEW.md 4.2, Critical) — phân quyền chỉ kiểm tra ở tầng client.
**Lý do:** Hệ thống không dùng Firebase Custom Claims (không có Cloud Function để set claim khi tạo/sửa user) — cách duy nhất để rules biết `role`/`isActive` của người gọi là `get(/databases/.../users/$(request.auth.uid))` ngay trong rules.
**Ưu điểm:** Không cần Cloud Function (giữ đúng cam kết "không thêm Cloud Functions"); rules phản ánh đúng dữ liệu `users` hiện có, không cần đồng bộ thêm 1 nguồn dữ liệu song song (claims).
**Nhược điểm:** Mỗi request cần thêm 1 lượt đọc Firestore (`get()`) để kiểm tra quyền — tốn thêm 1 read quota so với Custom Claims (đọc từ token, miễn phí); nếu `users/{uid}` bị xoá/lỗi, toàn bộ quyền của user đó gãy theo.
**Ảnh hưởng:** `firestore.rules` — đặc biệt phải phân biệt rõ `get` (đọc 1 doc, `resource` có thể null nếu doc chưa tồn tại) và `list` (đọc nhiều doc) khi viết rule cho `attendance`.

### D-004 — Sinh mật khẩu ngẫu nhiên thay vì mặc định `123456`

**Ngày:** gần đây nhất (commit `f6cb032`)
**Bối cảnh:** REVIEW.md 13.4 (High) — mật khẩu mặc định `123456` gợi ý sẵn cho mọi nhân viên mới, không ép đổi lần đầu.
**Lý do:** Có 2 phương án: (A) ép đổi mật khẩu lần đầu đăng nhập (`mustChangePassword` flag + điều hướng bắt buộc), hoặc (B) sinh mật khẩu ngẫu nhiên đủ mạnh ngay lúc tạo, hiển thị 1 lần cho admin copy. Chọn phương án B.
**Ưu điểm:** Không cần thêm field/logic điều hướng bắt buộc (giữ tối thiểu thay đổi); loại bỏ hoàn toàn rủi ro "mọi tài khoản mới đều đoán được mật khẩu".
**Nhược điểm:** Nếu admin quên copy/lưu mật khẩu hiển thị, phải tự reset lại qua "Quên mật khẩu"; không ép nhân viên đổi mật khẩu lần đầu (rủi ro thấp hơn nhưng vẫn còn lý thuyết nếu mật khẩu ngẫu nhiên bị lộ qua kênh khác).
**Ảnh hưởng:** `employee_screen.dart` (admin), dialog tạo nhân viên mới.

### D-005 — `ClockService`: static class + `ValueNotifier` (không dùng singleton thuần hay Riverpod provider)

**Ngày:** theo `docs/design/DEMO_TIME_DESIGN_v2.md`
**Bối cảnh:** Cần một "single source of time" để mọi nơi dùng `DateTime.now()` có thể chuyển sang giờ giả lập khi bật Demo Mode, mà không refactor lớn.
**Lý do:** So sánh 3 lựa chọn — (1) static class thuần: đơn giản nhất nhưng không tự động rebuild UI khi giờ demo đổi; (2) Riverpod `StateNotifierProvider`: đúng convention của dự án nhưng buộc phải truyền `Ref` vào các class thuần Dart (`BusinessDateHelper`, Repository) vốn không có khái niệm Riverpod — vi phạm "ít thay đổi nhất"; (3) **hybrid static + `ValueNotifier`** — giữ API tĩnh đơn giản (`ClockService.now()`) cho logic nghiệp vụ, đồng thời `ValueListenableBuilder` cho phần UI cần tự cập nhật (banner). Chọn (3).
**Ưu điểm:** Không cần sửa chữ ký hàm ở bất kỳ Repository/Helper nào (chỉ đổi `DateTime.now()` → `ClockService.now()`); UI vẫn reactive qua `ValueNotifier` không cần Riverpod.
**Nhược điểm:** Thêm 1 pattern reactivity thứ hai (`ValueNotifier`) song song với Riverpod đang dùng khắp nơi — không nhất quán 100% nhưng có lý do rõ ràng (xem trên).
**Ảnh hưởng:** `core/services/clock_service.dart`, toàn bộ nơi từng gọi `DateTime.now()` trong business logic (mobile).

### D-006 — Không dùng Cloud Function để xác thực GPS phía server

**Ngày:** từ đầu `ROADMAP.md` (ràng buộc phạm vi gốc)
**Bối cảnh:** REVIEW.md 4.1 (Critical) — toàn vẹn dữ liệu GPS hoàn toàn dựa client, `Position.isMocked` không chống được mọi cách giả lập vị trí (đặc biệt máy đã root/app bị sửa).
**Lý do:** Khắc phục triệt để cần Cloud Function (Callable Function) tính lại `distance`/`isLate`/`status` bằng Admin SDK — nhưng bị loại khỏi phạm vi vì (a) tăng độ phức tạp hạ tầng (cần Cloud Functions, có thể phát sinh chi phí/độ trễ), (b) không cần thiết cho mục tiêu báo cáo tiến độ/bảo vệ tốt nghiệp ở quy mô hiện tại.
**Ưu điểm:** Giữ kiến trúc đơn giản (client-only, không backend riêng); không phát sinh chi phí Cloud Functions.
**Nhược điểm:** Rủi ro gian lận chấm công vẫn tồn tại về lý thuyết nếu ai đó sửa client hoặc gọi thẳng Firestore SDK với dữ liệu tuỳ ý — **chấp nhận rủi ro này** cho giai đoạn hiện tại, không phải đã khắc phục.
**Ảnh hưởng:** `attendance_repository.dart` (mobile), `gps_service.dart`. Ghi vào Kết luận/hướng phát triển của báo cáo (Phase G) như một hạn chế đã biết, không phải điểm yếu bị che giấu.

### D-007 — Không tách package Dart dùng chung giữa 2 app

**Ngày:** từ đầu `ROADMAP.md`
**Bối cảnh:** REVIEW.md 1.5/12 — model/helper/theme bị copy-paste độc lập giữa `attendance_mobile` và `attendance_admin` (7+ file trùng lặp), là nguyên nhân gốc của nhiều bug lệch dữ liệu (BUG-001, nhãn hiển thị ca khác nhau...).
**Lý do:** Tách package (`attendance_core` qua `path:` dependency, hoặc melos workspace) là thay đổi cấu trúc dự án xuyên suốt — rủi ro cao hơn lợi ích trong giai đoạn ổn định hoá, và không có yêu cầu vận hành thực tế nào (2 app không được deploy/version độc lập theo lịch khác nhau) buộc phải tách ngay.
**Ưu điểm:** Không phải học/setup thêm công cụ quản lý monorepo; mỗi app vẫn hoàn toàn độc lập, dễ hiểu cho người đọc mới.
**Nhược điểm:** Rủi ro lệch schema/logic giữa 2 app tiếp tục tồn tại về lâu dài — các bug cụ thể phát sinh từ đây được xử lý riêng lẻ (P1-02, P1-04, P3-07) thay vì xử lý tận gốc.
**Ảnh hưởng:** toàn bộ `*/domain/*.dart`, `*/core/utils/*.dart` ở cả 2 app — xem OOS-03 ở `docs/project/01_BACKLOG.md`.

### D-008 — Không thêm interface cho Repository / không chuyển Clean Architecture

**Ngày:** từ đầu `ROADMAP.md`, tái xác nhận trong `CLAUDE.md`
**Bối cảnh:** REVIEW.md 1.1/1.2 (Medium) — không có `abstract class IXRepository`, business logic nằm lẫn trong Repository, không mock/test được qua `ProviderScope(overrides:...)`.
**Lý do:** Đổi kiến trúc giữa chừng một dự án đang chạy, do 1 người phát triển, cho mục tiêu báo cáo tiến độ/bảo vệ tốt nghiệp — chi phí (refactor lan rộng toàn bộ `*/data/*_repository.dart` và `*/presentation/*_provider.dart`) không tương xứng lợi ích (test coverage tốt hơn) ở giai đoạn này.
**Ưu điểm:** Tránh refactor lớn, rủi ro phá vỡ tính năng đang chạy đúng; giữ đúng cam kết "không đổi kiến trúc" đã thống nhất từ đầu.
**Nhược điểm:** Không thể viết automated test cho phần lớn business logic gắn Firestore — Phase C (`docs/testing/01_TEST_PLAN.md`) phải dựa chủ yếu vào kiểm thử thủ công thay vì tự động.
**Ảnh hưởng:** Toàn bộ `*Provider`/`*Repository` — xem OOS-01, OOS-02 ở `docs/project/01_BACKLOG.md`. Có thể là quyết định cần trả lời trực tiếp trong buổi bảo vệ tốt nghiệp (Phase H) nếu bị hỏi.

### D-009 — Dùng `kDebugMode` để ẩn công cụ dev/demo, không tách build flavor riêng

**Ngày:** xuyên suốt dự án (route seed departments, Demo Center)
**Bối cảnh:** Cần ẩn các route/tính năng chỉ dùng lúc phát triển (seed dữ liệu, Demo Time System) khỏi bản production, nhưng không muốn setup build flavor (`--flavor dev/prod`) — tăng độ phức ttạp cấu hình build.
**Lý do:** `kDebugMode` là cờ có sẵn của Flutter, tự động `false` khi build `--release`, không cần cấu hình thêm gì.
**Ưu điểm:** Không cần sửa `pubspec.yaml`/CI/cấu hình build; áp dụng nhất quán được ở nhiều nơi (route dev, Demo Center) bằng 1 pattern duy nhất.
**Nhược điểm:** Không phân biệt được "debug nhưng đang test trên thiết bị thật của khách hàng" — `kDebugMode` chỉ phân biệt debug/release build, không phân biệt môi trường (dev/staging/production Firebase project). Chấp nhận được vì cả dự án chỉ dùng 1 Firebase project duy nhất.
**Ảnh hưởng:** `/dev/seed-departments` (admin), `/demo-center` (mobile).

### D-010 — Đánh giá lại tiêu chuẩn "sẵn sàng" theo đúng bối cảnh báo cáo tiến độ, không theo chuẩn sản phẩm hoàn chỉnh

**Ngày:** 2026-07-05 (`docs/review/DEMO_READINESS_REVIEW.md`)
**Bối cảnh:** Đánh giá đầu tiên chấm điểm dự án theo chuẩn "sẵn sàng bảo vệ tốt nghiệp/production" (7.3/10) — không phù hợp vì buổi báo cáo sắp tới chỉ là báo cáo tiến độ giữa kỳ.
**Lý do:** Một hệ thống chấm công thật có nhiều khoảng trống hoàn toàn hợp lý ở giai đoạn giữa kỳ (Nghỉ phép mobile, Notification UI chưa xong) — đánh giá đúng bối cảnh giúp phân biệt "chưa tới lượt trong roadmap" với "bị lỗi/thất bại".
**Ưu điểm:** Tránh lãng phí thời gian sửa những thứ không ảnh hưởng buổi báo cáo sắp tới; tập trung đúng 2 việc thực sự cần (kiểm thử tay Check In/Out, chuẩn bị dữ liệu mẫu).
**Nhược điểm:** Cần nhớ đánh giá lại theo chuẩn cao hơn khi tới gần Phase H (bảo vệ tốt nghiệp) — không được dùng mãi điểm số 8.2/10 này làm chuẩn cho buổi bảo vệ cuối cùng.
**Ảnh hưởng:** Toàn bộ cách ưu tiên công việc trong `docs/project/PROJECT_MASTER_PLAN.md` — Phase D được tách D.1/D.2 chính vì lý do này.

### D-011 — Master Plan tách Phase D thành D.1 (báo cáo tiến độ) và D.2 (bảo vệ tốt nghiệp)

**Ngày:** 2026-07-13
**Bối cảnh:** Bản nháp đầu tiên của `PROJECT_MASTER_PLAN.md` liệt kê "Demo Preparation" như 1 phase tuyến tính giữa Testing và Release — không khớp thực tế vì đã có 1 đợt demo gần như sẵn sàng ngay từ bây giờ.
**Lý do:** Tự rà soát (technical lead review) phát hiện việc gộp chung gây hiểu lầm về thứ tự phụ thuộc.
**Ưu điểm:** Phản ánh đúng thực tế có 2 sự kiện demo độc lập; tránh trì hoãn demo báo cáo tiến độ chỉ vì đang chờ Phase A-C xong.
**Nhược điểm:** Thêm 1 khái niệm (D.1/D.2) cần nhớ khi đọc kế hoạch.
**Ảnh hưởng:** `docs/project/PROJECT_MASTER_PLAN.md` §3 Phase D, Milestone M0.

### D-012 — Quy tắc chặn xoá nhân viên dựa trên Business Data, không dựa trên `isActive`

**Ngày:** 2026-07-13
**Bối cảnh:** Thiết kế ban đầu của TD-02 (bắt buộc `isActive = false` rồi mới cho xoá hồ sơ nhân viên) dùng sai tiêu chí — `isActive` chỉ phản ánh quyền truy cập, không phản ánh việc xoá có phá dữ liệu nghiệp vụ (Attendance, Leave Request) hay không. Một nhân viên đã làm việc nhiều năm, sau khi bị khoá truy cập (`isActive = false`), theo thiết kế cũ lại đủ điều kiện xoá — đúng lúc dữ liệu của họ quan trọng nhất. Phân tích đầy đủ ở `docs/design/EMPLOYEE_LIFECYCLE.md`.
**Lý do:** Tách bạch hai trục độc lập — quyền truy cập (Active/Inactive, hai chiều, Admin bật/tắt tự do) và khả năng xoá (một chiều, chỉ cho phép khi hồ sơ **chưa từng phát sinh Business Data** = Attendance hoặc Leave Request; Notification không tính vào vì chỉ là log giao tiếp một chiều, không có giá trị pháp lý/lương lâu dài). So sánh 4 phương án (cấm Delete khi có Business Data / thêm trạng thái Archived / xoá mềm có ân hạn / xoá tự động theo thời hạn pháp lý) — chọn phương án đầu vì đơn giản nhất, an toàn nhất, khớp tiền lệ Odoo/ERPNext (không phải SAP/Workday — quá nhiều trạng thái so với nhu cầu).
**Ưu điểm:** Bảo vệ đúng rủi ro thật (mất dữ liệu lương/chấm công/nghỉ phép) thay vì rủi ro phụ; không thêm trạng thái/màn hình mới; quy tắc dễ giải thích cho người dùng không rành kỹ thuật ("chưa dùng thì xoá được, đã dùng rồi thì không").
**Nhược điểm:** Không giải quyết vấn đề tài khoản Firebase Auth mồ côi (vẫn cần Admin SDK/Cloud Function, ngoài phạm vi — xem OOS-07); hồ sơ nhân viên đã có dữ liệu sẽ tồn tại vĩnh viễn trong hệ thống, không có cách dọn dẹp (chấp nhận được, đây là hành vi đúng theo tiền lệ ERP và quy định lưu trữ hồ sơ lao động).
**Ảnh hưởng:** `docs/design/EMPLOYEE_LIFECYCLE.md` (tài liệu thiết kế chính thức); TD-02 đổi tên và thiết kế lại theo quy tắc mới — xem `docs/project/01_BACKLOG.md`, `docs/project/02_SPRINT.md`.

### D-013 — Xác nhận phạm vi mở rộng Phase A: làm FEAT-01/FEAT-02, hoãn FEAT-03

**Ngày:** 2026-07-20
**Bối cảnh:** `PROJECT_MASTER_PLAN.md` Phase A liệt kê 3 tính năng mới (Nghỉ phép mobile, Notification UI, Phòng ban CRUD admin) nằm ngoài phạm vi `ROADMAP.md` gốc, đã gắn cờ cảnh báo yêu cầu xác nhận rõ ràng trước khi bắt đầu vì đây là phần tốn thời gian nhất còn lại của Phase A. Sau khi Sprint 4 (Code Quality) và phần lớn Sprint 6 (dọn dẹp) đã đóng, cần chốt hướng đi trước khi tiếp tục.
**Lý do:** Hỏi trực tiếp từng mục — FEAT-01 (Nghỉ phép mobile) và FEAT-02 (Notification UI) được xác nhận làm; FEAT-03 (Phòng ban CRUD admin) bị từ chối vì 13 phòng ban đã có sẵn qua dropdown, màn quản lý riêng không ảnh hưởng vận hành/demo hiện tại.
**Ưu điểm:** Phạm vi Phase A giờ rõ ràng, không còn mục nào "chờ xác nhận" treo lơ lửng; TD-15 (thay placeholder Nghỉ phép tạm thời) trở thành thừa và được Cancelled thay vì làm 2 lần (làm tạm rồi làm lại thật).
**Nhược điểm:** Thêm ~3-5 ngày công trước khi có thể chuyển sang Phase B/C/E — trì hoãn mốc Release Candidate/Source Freeze so với kịch bản bỏ qua cả 3.
**Ảnh hưởng:** `docs/project/01_BACKLOG.md` (FEAT-01/02 → Ready, FEAT-03 → Deferred, TD-15 → Cancelled), `docs/project/02_SPRINT.md` (Sprint 2/3 sẵn sàng bắt đầu, bỏ điều kiện "chờ xác nhận").

---

## Mẫu thêm quyết định mới

```
### D-0XX — <tên quyết định ngắn gọn>

**Ngày:** <ngày quyết định>
**Bối cảnh:** <vấn đề gì dẫn tới cần quyết định>
**Lý do:** <vì sao chọn phương án này, có so sánh phương án khác nếu có>
**Ưu điểm:** <...>
**Nhược điểm:** <...>
**Ảnh hưởng:** <file/module bị ảnh hưởng, liên kết backlog/risk liên quan nếu có>
```
