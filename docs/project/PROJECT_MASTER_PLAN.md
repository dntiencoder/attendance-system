# PROJECT_MASTER_PLAN.md

> Tài liệu quản lý trung tâm cho `attendance-system`, từ thời điểm hiện tại (2026-07-13, Phase 1 của `ROADMAP.md` đã xong) cho tới khi bảo vệ tốt nghiệp. Đây **không phải** TODO list và **không phải** roadmap kỹ thuật đơn thuần (đã có `ROADMAP.md` cho việc đó) — đây là kế hoạch quản lý dự án cấp cao, bao trùm cả source code, kiểm thử, demo, release, tài liệu báo cáo và bảo vệ.
>
> Tài liệu này **chỉ lập kế hoạch** — không có dòng code, không có nội dung báo cáo (Chương 3/4) nào được viết trong quá trình tạo tài liệu này. Đã được tự rà soát bởi vai trò Technical Lead trước khi xuất bản bản cuối (xem §0).

---

## Mục lục

0. [Ghi chú tự rà soát (Technical Lead review)](#0-ghi-chú-tự-rà-soát-technical-lead-review)
1. [Tình trạng hiện tại của dự án](#1-tình-trạng-hiện-tại-của-dự-án)
2. [Nguyên tắc quản lý xuyên suốt](#2-nguyên-tắc-quản-lý-xuyên-suốt)
3. [Các Phase](#3-các-phase)
4. [Milestone](#4-milestone)
5. [Definition of Done](#5-definition-of-done)
6. [Tài liệu quản lý đề xuất thêm](#6-tài-liệu-quản-lý-đề-xuất-thêm)
7. [Risk Register tổng thể](#7-risk-register-tổng-thể)
8. [Kết luận & khuyến nghị](#8-kết-luận--khuyến-nghị)

---

## 0. Ghi chú tự rà soát (Technical Lead review)

Bản dưới đây **đã là bản cuối cùng, đã được chỉnh sửa** — các mục sau là những gì bị phát hiện có vấn đề ở bản nháp đầu tiên và đã được sửa trực tiếp vào nội dung chính thức bên dưới, ghi lại ở đây để minh bạch lý do:

1. **Phase D (Demo Preparation) không nằm đúng vị trí tuyến tính C→D→E như liệt kê ban đầu.** Trên thực tế đã có **một đợt demo gần như sẵn sàng ngay bây giờ** — demo cho **báo cáo tiến độ** (không phải bảo vệ tốt nghiệp), dựa trên `docs/demo/DEMO_GUIDE.md` đã hoàn thành và dữ liệu Firestore thật hiện có. Đợt demo này **không phụ thuộc** vào việc Phase A-C hoàn tất trước. → Đã tách rõ **"Demo báo cáo tiến độ" (gần như xong, có thể làm ngay tuần này)** khỏi **"Demo bảo vệ tốt nghiệp" (ở cuối, sau Phase G)** trong §3 Phase D và bổ sung **Milestone M0** ở §4 để phản ánh đúng thực tế này.
2. **Phase C (Testing) không thể là automated test toàn diện** — `ROADMAP.md` cấm rõ ràng việc thêm interface cho Repository (mục đích chính để mock/test được), nên phần lớn business logic gắn liền Firestore chỉ kiểm thử được thủ công. Đã tách Phase C thành **(a) Unit test tự động cho các hàm thuần tuý** (Haversine, `getCurrentShift`, `calculateIsLate`, `calculateEarlyLeave`, `BusinessDateHelper` — không đụng kiến trúc, hoàn toàn khả thi) và **(b) kiểm thử thủ công có kịch bản** cho phần còn lại — thay vì gộp chung "Testing" mập mờ.
3. **Demo Time System (`ClockService`) không chỉ là công cụ demo — nó là công cụ kiểm thử.** Bản nháp đầu đặt nó riêng ở Phase D. Đã bổ sung ghi chú chéo ở Phase C: dùng Fast Forward/Rewind để kiểm thử biên ca đêm/rotation mà không phải chờ thời gian thực — tận dụng lại công cụ đã xây thay vì đề xuất công cụ mới.
4. **Phase A liệt kê "Nghỉ phép" và "Notification" như module cần hoàn thiện — đây là MỞ RỘNG PHẠM VI so với `ROADMAP.md` hiện tại**, vốn xếp hai việc này vào nhóm "Ngoài phạm vi roadmap ổn định hoá" (tính năng mới, không phải bug). Không tự ý xoá khỏi Phase A vì đây là yêu cầu rõ ràng của bạn ("nếu phát hiện còn thiếu chức năng... đưa vào đúng Phase"), nhưng đã **gắn cờ cảnh báo rõ ràng** trong Phase A để bạn xác nhận có thực sự muốn đầu tư ~4-5 ngày cho việc này trước khi bắt đầu, thay vì để nó âm thầm trôi qua như một quyết định mặc định.
5. **Phase B và Phase C có thể chạy song song, không phải tuần tự** — sửa lỗi phát hiện lúc test (Phase C) chính là công việc của Phase B. Đã gộp hai phase này vào cùng một Milestone (M2) và ghi rõ trong §3 rằng chúng lặp lại xen kẽ (fix → test lại → fix tiếp), không phải "làm xong B rồi mới bắt đầu C".
6. **Phase G (Documentation) không cần đợi Phase F (Source Freeze) mới bắt đầu** — phần lý luận/kiến trúc/khảo sát của Chương 3-4 có thể viết song song với Phase B/C (nội dung không đổi nhiều), chỉ phần **số liệu/kết quả thực nghiệm cụ thể** mới cần chốt sau khi source freeze. Đã tách Phase G thành "viết nháp" (có thể bắt đầu sớm, song song Phase C) và "chốt số liệu" (sau Phase F).
7. **Rủi ro bị bỏ sót ở bản nháp đầu — đã bổ sung vào §7:** (a) toàn bộ Demo Time System đang là **thay đổi chưa commit** trong working tree, chưa qua kiểm thử tay trên thiết bị, chưa vào Phase B/F sẽ mất dấu vết nếu không được đưa vào checklist Phase A; (b) `version: 1.0.0+1` chưa từng được bump kể từ khi tạo project — Phase E cần một quyết định versioning rõ ràng; (c) không có CI/CD, không có git tag nào — Phase E/F cần quyết định có cần CI hay không (khuyến nghị: không bắt buộc, xem §3 Phase E); (d) tài liệu demo hiện đã có **5 nguồn chồng lấn** (`docs/demo/01-08`, `DEMO_GUIDE.md`, `DEMO_TIME_DESIGN.md`/`v2`, `DEMO_READINESS_REVIEW.md`) — không đề xuất xoá (ngoài phạm vi tài liệu này) nhưng cảnh báo rủi ro đọc nhầm bản cũ, xem §7.
8. **Không phát hiện Phase nào thừa cần loại bỏ** — cả 8 Phase A-H đều có vai trò rõ ràng, không chồng chéo mục tiêu sau khi đã tách D thành hai nhánh (báo cáo tiến độ vs. bảo vệ) và gộp B+C vào một milestone.

---

## 1. Tình trạng hiện tại của dự án

### 1.1 Giai đoạn hiện tại

Dự án đang ở cuối **giai đoạn ổn định hoá** (Phase 1 của `ROADMAP.md`, 7/7 hạng mục Critical đã xong và đã commit), chuẩn bị bước vào **giai đoạn hoàn thiện tính năng + kiểm thử** trước khi có thể tiến tới release/report/defense. Một nhánh công việc phụ (Demo Time System) đã được **thiết kế và code xong nhưng chưa commit, chưa kiểm thử tay** — xem chi tiết ở Phase A.

### 1.2 Bức tranh hoàn thành theo từng Phase (không phải một con số duy nhất)

Một con số % tổng duy nhất sẽ gây hiểu lầm vì các Phase có bản chất khác hẳn nhau (code vs. viết báo cáo vs. chuẩn bị thuyết trình). Bảng dưới đánh giá riêng từng Phase:

| Phase | Ước tính hoàn thành | Căn cứ |
|---|---|---|
| A — Hoàn thiện Source Code | ~75% | Lõi chấm công/GPS/rotation/Business Date/Settings/Employee đã chạy đúng, có bằng chứng dữ liệu thật; còn thiếu Leave (mobile), Notification (UI), Department (màn quản lý riêng), và việc commit+test Demo Time System |
| B — Code Quality | ~20% | Phase 1 (Critical) đã dọn xong; P2-03 (`firestore.indexes.json`) vô tình đã xong; toàn bộ P2 còn lại + P3 + P4 của `ROADMAP.md` (≈17 hạng mục) chưa đụng tới |
| C — Testing | ~10% | Chỉ có kiểm thử thủ công rời rạc trong lúc phát triển; 0 automated test thực chất (`test/widget_test.dart` mặc định); Demo Time System hoàn toàn chưa test |
| D — Demo Preparation (báo cáo tiến độ) | ~85% | `docs/demo/DEMO_GUIDE.md` + dữ liệu Firestore thật đã sẵn sàng; còn 4 việc nhỏ (seed leave_requests, quyết định radius, sửa departmentId admin, dry-run 1 lần) |
| D — Demo Preparation (bảo vệ tốt nghiệp) | 0% | Chưa bắt đầu — phụ thuộc vào việc hoàn thiện tính năng đầy đủ hơn ở Phase A |
| E — Release Candidate | 0% | Chưa build release, chưa bump version (đang đứng yên ở `1.0.0+1`), chưa gắn git tag |
| F — Source Freeze | 0% | Chưa tuyên bố, chưa có mốc thời gian |
| G — Documentation | ~25% (tính trên toàn bộ Chương 3+4+Kết luận+Phụ lục) | Chương 1, Chương 2 đã hoàn thành (`docs/report/chapter2/CHAPTER2.md`, 316 dòng); Chương 3/4/Kết luận/Phụ lục/UML/Screenshot: 0% |
| H — Defense Preparation | 0% | Chưa bắt đầu |

### 1.3 Module — trạng thái chi tiết

| Module | Trạng thái | Ghi chú |
|---|---|---|
| Đăng nhập/Phân quyền (Auth) | ✅ Hoàn thành | Email/password, role/isActive check cả client lẫn Firestore Rules |
| Check In / Check Out (GPS) | ✅ Hoàn thành (core) | Đã sửa các bug nghiêm trọng (rotation, Business Date); chưa kiểm thử tay lượt **mới nhất** sau các lần sửa gần đây |
| Business Date / Xoay ca (Rotation) | ✅ Hoàn thành | Có bằng chứng dữ liệu thật xác nhận đổi ca đúng chu kỳ; còn 1 nợ kỹ thuật nhỏ (P2-06 — 2 cơ chế lịch làm việc song song chưa đồng bộ nguồn) |
| Company Settings | ✅ Hoàn thành | Bug mất `rotationStartDate` (Critical) đã sửa; validate số đã sửa |
| Firestore Security Rules | ✅ Hoàn thành (trong phạm vi đã chọn) | Đã deploy, phân biệt get/list đúng; giới hạn đã biết và **chấp nhận**: toàn vẹn GPS vẫn dựa vào client (cần Cloud Function để sửa triệt để — nằm ngoài phạm vi kiến trúc hiện tại theo `ROADMAP.md`) |
| Quản lý Nhân viên (Admin) | ✅ Hoàn thành phần lớn | CRUD + sinh mật khẩu ngẫu nhiên đã xong; thiếu ràng buộc "chỉ xoá khi `isActive == false`" (P2-04) |
| Dashboard (Admin) | ✅ Hoàn thành (chức năng) | Đúng số liệu; chưa tối ưu hiệu năng (7 query tuần tự — P3-02, không chặn demo) |
| Attendance History (cả 2 app) | ✅ Hoàn thành | — |
| Phòng ban (Department) | 🟡 Đang làm / dữ liệu có, UI quản lý chưa có | Có 13 phòng ban thật, dùng qua dropdown; chưa có màn CRUD riêng (chỉ có route dev ẩn để seed) |
| Nghỉ phép (Leave) — phía Admin | 🟡 Đang làm | Duyệt/từ chối đã chạy được, có model đầy đủ |
| Nghỉ phép (Leave) — phía Mobile | ❌ Chưa làm | Chỉ là `Scaffold` placeholder tĩnh trên bottom-nav — nhân viên chưa thể tự tạo đơn |
| Notification | ❌ Chưa làm (UI) | Admin ghi được vào Firestore; **không app nào có màn hiển thị** để đọc |
| Demo Time System (`ClockService` + Demo Center) | 🟡 Code xong, chưa commit, chưa test tay | 12 file mới/sửa, `flutter analyze` sạch, nhưng 0 lần chạy thật trên thiết bị |
| Xuất báo cáo Excel/PDF (Admin) | ✅ Hoàn thành | Không có trong danh sách vấn đề nào ở `REVIEW.md` |
| Automated test suite | ❌ Chưa làm | Chỉ có file mặc định `widget_test.dart` ở cả 2 app |
| CI/CD | ⚪ Chưa cần làm | Không có yêu cầu nào từ bạn; quy mô solo/thực tập không bắt buộc — xem Phase E |
| Repository interface / Clean Architecture / package dùng chung | ⚪ Chưa cần làm | Bị loại khỏi phạm vi tường minh trong `ROADMAP.md` — chỉ phù hợp nếu có câu hỏi phản biện sâu ở buổi bảo vệ |

### 1.4 Sẵn sàng cho từng mục tiêu

| Mục tiêu | Sẵn sàng? | Điều kiện còn thiếu |
|---|---|---|
| **Demo báo cáo tiến độ** (gần nhất) | 🟢 Gần sẵn sàng | 4 việc nhỏ ở `docs/demo/DEMO_GUIDE.md` §1.1/§6 — có thể xong trong 1 ngày |
| **Release** (dùng thật, kể cả nội bộ) | 🔴 Chưa sẵn sàng | Cần hết Phase B (High-priority) + Phase C + Phase E |
| **Viết Chương 3/4** | 🟡 Có thể bắt đầu phần khung/lý luận ngay, chưa chốt được số liệu thực nghiệm | Số liệu kiểm thử (Phase C) và trạng thái cuối cùng của source (Phase F) chưa có |
| **Bảo vệ tốt nghiệp** | 🔴 Còn xa | Cần đi hết Phase A→H — đây chính là lý do tài liệu này tồn tại |

---

## 2. Nguyên tắc quản lý xuyên suốt

Kế thừa nguyên văn các ràng buộc đã thống nhất từ `CLAUDE.md` và `ROADMAP.md`, áp dụng cho **toàn bộ** các Phase dưới đây trừ khi Phase đó tự nêu ngoại lệ:

- Không đổi kiến trúc (không thêm use-case layer, không interface hoá Repository, không đổi state management) — **cho tới Phase F**. Sau source freeze, mọi thay đổi kiến trúc (nếu có, ví dụ để chuẩn bị trả lời phản biện) phải là quyết định riêng, có lý do, không lẫn vào các Phase ổn định hoá.
- Không thêm Cloud Functions, không tách package Dart dùng chung giữa 2 app — trừ khi bạn chủ động quyết định đổi phạm vi (xem §7, rủi ro đã biết và chấp nhận).
- Mỗi task chỉ sửa trong phạm vi tối thiểu file cần thiết, không refactor lan rộng ngoài yêu cầu.
- Trước khi code: phân tích nguyên nhân → đề xuất giải pháp → liệt kê file bị ảnh hưởng → chờ xác nhận (đúng quy trình đã áp dụng nhất quán từ đầu dự án).
- Sau khi code: tóm tắt thay đổi → tác dụng phụ → đề xuất test tay → chờ duyệt trước khi sang việc tiếp theo.
- Tài liệu (`ARCHITECTURE.md`, `PROJECT_OVERVIEW.md`, `ROADMAP.md`, `REVIEW.md`) là **tài liệu chỉ đọc**, không tự sửa khi làm việc khác — chỉ cập nhật khi có yêu cầu tường minh cập nhật chính tài liệu đó.

---

## 3. Các Phase

### Phase A — Hoàn thiện Source Code

**Mục tiêu:** Đưa toàn bộ tính năng nghiệp vụ về trạng thái hoạt động đúng, đầy đủ theo phạm vi đã xác nhận (không thêm tính năng ngoài danh sách dưới).

⚠️ **Cần xác nhận trước khi bắt đầu:** hai mục "Nghỉ phép (mobile)" và "Notification (UI)" trong checklist dưới đây là **tính năng mới**, từng bị `ROADMAP.md` xếp ngoài phạm vi ổn định hoá vì tốn công đáng kể (~3-5 ngày) so với lợi ích cho một buổi báo cáo tiến độ. Đưa vào đây vì bạn yêu cầu "hoàn thiện toàn bộ project" trước khi tiếp tục viết báo cáo — nhưng đây là lựa chọn tốn thời gian nhất trong toàn bộ Phase A, nên xác nhận lại mức ưu tiên trước khi bắt đầu.

**Checklist:**

```
Core (đã hoàn thành, chỉ cần chốt các nợ kỹ thuật nhỏ còn sót)
☐ [P2-01] Bọc checkIn() trong runTransaction() để tránh race condition double check-in
☐ [P2-06] Đồng bộ nguồn mốc ngày giữa WorkScheduleHelper (hardcode 2026-06-01) và CompanySettingsModel.rotationStartDate
☐ [P2-04] Ràng buộc xoá nhân viên: chỉ cho phép khi isActive == false, kèm dialog cảnh báo rõ

Demo Time System (đã code xong, chưa hoàn tất vòng đời)
☐ Review lại diff hiện tại (12 file mới/sửa, chưa commit) — xác nhận đúng ý trước khi commit
☐ Commit thay đổi Demo Time System thành 1 (hoặc vài) commit rõ ràng
☐ Kiểm thử tay Demo Center trên thiết bị thật: Use Demo Time, Fast Forward, Rewind, Reset to Current Time, cả 10 mốc giờ trong docs/demo/DEMO_GUIDE.md §3.2

Tính năng mới — cần xác nhận ưu tiên trước khi làm (xem cảnh báo ở trên)
☐ Nghỉ phép (mobile): repository + provider + UI tạo đơn + xem danh sách đơn của chính mình
☐ Notification: màn hiển thị danh sách thông báo (tối thiểu 1 trong 2 app, lý tưởng cả 2)
☐ Phòng ban (admin): màn quản lý CRUD riêng thay vì chỉ seed qua route dev ẩn
```

**Điều kiện bắt đầu:** Phase 1 của `ROADMAP.md` đã xong (✅ đã đúng hiện tại).
**Điều kiện hoàn thành:** toàn bộ checklist trên được tick; `flutter analyze` không phát sinh lỗi mới (warning/info hiện có được xử lý ở Phase B, không chặn Phase A).
**Kết quả đầu ra:** source code có đầy đủ tính năng đã xác nhận, đã commit sạch, sẵn sàng cho Phase B/C.
**Rủi ro:** mở rộng phạm vi Nghỉ phép/Notification có thể kéo dài hơn ước tính nếu phát sinh yêu cầu UI/UX chưa lường trước (ví dụ: nhân viên cần đính kèm ảnh xin nghỉ, cần soạn nội dung thông báo phức tạp) — nếu xảy ra, nên chốt lại phạm vi tối thiểu (MVP) thay vì làm đầy đủ như ứng dụng thương mại.
**Cách kiểm tra:** `flutter analyze` cả 2 app; tự thao tác thủ công từng luồng mới trên thiết bị/thiết bị ảo thật.

---

### Phase B — Code Quality

**Mục tiêu:** Xử lý nợ kỹ thuật đã biết (`ROADMAP.md` Phase 2 còn lại + Phase 3 + Phase 4), không để lại nợ mới phát sinh trong lúc làm Phase A/C.

**Checklist (tách theo mức bắt buộc — giữ đúng phân loại gốc của `ROADMAP.md`):**

```
Bắt buộc trước khi release (High, còn lại sau khi P2-03 đã vô tình xong)
☐ [P2-02] Thêm logging tối thiểu có cấu trúc (hoặc firebase_crashlytics) vào các nhánh catch quan trọng
☐ [P2-05] Xoá .toUpperCase() thừa khi gửi email đăng nhập (mobile, login_form.dart:32)
☐ (P2-01, P2-04, P2-06 đã liệt kê ở Phase A vì gắn liền tính đúng của tính năng — không lặp lại ở đây)

Nên làm, không chặn release (Medium — Phase 3 của ROADMAP.md, 8 mục)
☐ Giới hạn/lọc theo ngày cho getAttendanceLogs() thay vì tải toàn bộ collection
☐ Song song hoá 7 query tuần tự trong _getWeeklyAttendance() bằng Future.wait
☐ Cache company_settings/users trong AttendanceHistoryNotifier khi chuyển tháng
☐ Thay AlertDialog tự dựng bằng ConfirmDialog.show() có sẵn
☐ Dùng lại Validators.email/phone thay vì validator inline
☐ Thay thông báo lỗi thô ($err) bằng thông điệp thân thiện
☐ Đồng bộ nhãn hiển thị ca làm giữa 2 app ("Ca ngày" vs "Ca sáng")
☐ Thay hex màu hardcode bằng AppColors.primary

Dọn dẹp khi còn thời gian (Low — Phase 4 của ROADMAP.md, 5 mục)
☐ Xoá dead code: auth_gate.dart, admin_model.dart (rỗng), checkin_screen.dart, gps_test_screen.dart, gps_provider.dart
☐ Xoá toán tử ?. thừa trên startDate không nullable (leave_provider.dart)
☐ Set màu tường minh cho CircularProgressIndicator trong CustomButton
☐ Thay so khớp lỗi bằng chuỗi text bằng 1-2 exception class gọn nhẹ

Phát sinh thêm từ lần chạy flutter analyze gần nhất (2026-07-13, chưa có trong ROADMAP.md)
☐ Dọn 23 warning/info còn lại ở attendance_mobile (unused import, unused variable, unnecessary_underscores...)
☐ Dọn 13 warning/info còn lại ở attendance_admin (unused import, deprecated_member_use FormField.value → initialValue...)
☐ Cân nhắc gỡ dependency firebase_storage (khai báo ở cả 2 pubspec.yaml nhưng không có code nào dùng thật)
```

**Điều kiện bắt đầu:** có thể bắt đầu song song với Phase A (không phụ thuộc tính năng mới) và xen kẽ với Phase C.
**Điều kiện hoàn thành:** toàn bộ mục "Bắt buộc" đã xong; mục "Nên làm"/"Dọn dẹp" xong theo mức bạn quyết định còn thời gian hay không.
**Kết quả đầu ra:** `flutter analyze` về 0 issue (hoặc issue còn lại đã được xem xét có chủ đích, ghi chú lý do giữ); không còn mục Critical/High nào trong `REVIEW.md` chưa xử lý.
**Rủi ro:** dễ bị cám dỗ mở rộng thành refactor lớn khi đang "dọn dẹp" — bám sát đúng từng mục đã liệt kê trong `ROADMAP.md`, không tự thêm việc.
**Cách kiểm tra:** `flutter analyze` (cả 2 app) trước/sau, đối chiếu số issue giảm dần theo từng đợt.

---

### Phase C — Testing

**Mục tiêu:** Có bằng chứng kiểm thử đủ tin cậy cho các luồng nghiệp vụ cốt lõi, trong giới hạn thực tế của kiến trúc hiện tại (không interface hoá Repository → phần lớn không mock được).

**Checklist:**

```
Automated — khả thi vì đây là các hàm thuần Dart, không phụ thuộc Firestore/DI
☐ Unit test: Haversine.calculateDistance() — biên bán kính, khoảng cách 0, khoảng cách lớn
☐ Unit test: CompanySettingsModel.getCurrentShift() — biên đổi ca đúng/sai chu kỳ rotationDays
☐ Unit test: calculateIsLate() — đúng giờ / trễ 1 phút / trễ nhiều / ca đêm qua nửa đêm
☐ Unit test: calculateEarlyLeave() — về đúng giờ / về sớm / ca đêm qua nửa đêm
☐ Unit test: BusinessDateHelper.resolveBusinessDate() — biên 23:59/00:00/00:15 cho ca đêm

Thủ công có kịch bản — dùng Demo Time System (Fast Forward/Rewind) để tạo nhanh các mốc giờ biên,
thay vì chờ thời gian thực — tận dụng công cụ đã xây ở Phase A cho mục đích test, không chỉ demo
☐ Check In đúng giờ / trễ / ngoài bán kính GPS / GPS giả (mock location)
☐ Check Out đúng giờ / về sớm / chưa Check In mà Check Out / quá giờ ân hạn
☐ Check In trùng lặp trong cùng ngày làm việc (đã Check In rồi bấm lại)
☐ Rotation: xác nhận đổi ca đúng ngày dự kiến cho cả 2 nhóm A/B
☐ Business Date: check-in/check-out quanh mốc nửa đêm cho ca đêm (00:15, 23:30 — đã có trong DEMO_GUIDE.md §3.2)
☐ Phân quyền: đăng nhập nhầm app (employee vào admin, admin vào mobile), tài khoản isActive=false
☐ Firestore Rules: thử đọc/ghi trái phép qua Firebase Console với tài khoản không đủ quyền → xác nhận bị chặn
☐ Leave (nếu Phase A hoàn thành): tạo đơn, duyệt, từ chối, trạng thái hiển thị đúng cả 2 phía
☐ Regression: chạy lại toàn bộ checklist trên sau mỗi đợt sửa lỗi lớn ở Phase A/B
```

**Điều kiện bắt đầu:** Phase A checklist "Core" đã xong; có thể bắt đầu phần automated test sớm hơn, song song Phase B.
**Điều kiện hoàn thành:** toàn bộ kịch bản thủ công đã chạy ít nhất 1 lần và pass; unit test chạy xanh trong `flutter test`.
**Kết quả đầu ra:** khuyến nghị tạo `TEST_PLAN.md` ghi lại kết quả từng kịch bản (xem §6) — đây sẽ là nguyên liệu trực tiếp cho Chương 4 báo cáo.
**Rủi ro:** kiểm thử ca đêm/rotation cần đúng "ngày làm việc" thật nếu không dùng Demo Time — dễ tốn nhiều ngày thực nếu quên tận dụng `ClockService`; kiểm thử trên Demo Time không thay thế hoàn toàn được ít nhất 1 lần kiểm thử bằng thời gian thực trước khi release/defense (để loại trừ khả năng bug ẩn chỉ xảy ra ngoài môi trường giả lập giờ).
**Cách kiểm tra:** `flutter test` cho phần automated; đối chiếu Firestore Console cho phần thủ công (đúng document được tạo/cập nhật đúng field như kỳ vọng).

---

### Phase D — Demo Preparation

Tách rõ **hai đợt demo khác nhau về thời điểm, mục tiêu và mức độ sẵn sàng** — đây là điều bản kế hoạch gốc gộp chung, đã tách lại ở §0.

#### D.1 — Demo báo cáo tiến độ (gần nhất, không chờ Phase A-C xong)

**Mục tiêu:** Demo trung thực trạng thái hiện tại cho giảng viên hướng dẫn, đúng tinh thần đã thống nhất ở `docs/demo/DEMO_GUIDE.md` (không demo cái chưa xong, không hứa tính năng chưa có).

**Checklist:**
```
☐ Seed 3 document leave_requests mẫu (pending/approved/rejected) — docs/demo/01_DEMO_DATA.md mục 5
☐ Quyết định giữ hay đổi company_settings.radius (đang 9999999999m)
☐ Sửa departmentId của tài khoản admin (đang trỏ dep001 không tồn tại)
☐ Kiểm thử tay Check In/Check Out trên đúng thiết bị sẽ demo, ít nhất 1 lượt ca ngày + 1 lượt ca đêm
☐ Dry-run Demo Center ít nhất 1 lần trên thiết bị thật trước khi tin tưởng dùng live
```
**Điều kiện bắt đầu:** ngay bây giờ — không phụ thuộc Phase A-C.
**Điều kiện hoàn thành:** checklist trên tick hết + checklist đầy đủ ở `docs/demo/05_DEMO_CHECKLIST.md`.
**Kết quả đầu ra:** buổi báo cáo tiến độ diễn ra suôn sẻ.
**Rủi ro:** đã liệt kê đầy đủ ở `docs/demo/06_DEMO_RISK.md` — không lặp lại ở đây.
**Cách kiểm tra:** chính là buổi báo cáo.

#### D.2 — Demo bảo vệ tốt nghiệp (cuối lộ trình, sau Phase G)

**Mục tiêu:** Mở rộng demo báo cáo tiến độ thành demo đầy đủ hơn, phản ánh trạng thái sau khi hoàn thiện Phase A (Leave/Notification/Department nếu đã làm), có chiều sâu kỹ thuật để trả lời phản biện.

**Checklist:**
```
☐ Cập nhật docs/demo/DEMO_GUIDE.md phản ánh tính năng mới hoàn thiện ở Phase A
☐ Chuẩn bị thêm kịch bản demo cho Leave (mobile)/Notification nếu đã hoàn thiện
☐ Chuẩn bị câu trả lời cho câu hỏi kiến trúc sâu hơn (Repository interface, Clean Architecture, package dùng chung) — không cần code, chỉ cần câu trả lời có lý do rõ ràng dựa trên REVIEW.md mục "Ngoài phạm vi"
```
**Điều kiện bắt đầu:** Phase G đã có nội dung Chương 3/4 tương đối ổn định (để demo khớp với những gì được trình bày trong báo cáo).
**Điều kiện hoàn thành:** đã rehearsal ít nhất 1-2 lần theo đúng timeline dự kiến của buổi bảo vệ (xem Phase H).
**Kết quả đầu ra:** kịch bản demo bảo vệ tốt nghiệp, có thể là bản mở rộng của `DEMO_GUIDE.md` hoặc file riêng — quyết định ở Phase H.
**Rủi ro:** nếu Phase A mở rộng (Leave/Notification) không hoàn thành kịp, cần quay lại dùng nguyên bản demo báo cáo tiến độ cho buổi bảo vệ — không phải thất bại, chỉ cần trình bày nhất quán với Chương 3/4.
**Cách kiểm tra:** rehearsal có người ngoài xem thử (bạn học, người hướng dẫn) trước ngày thật nếu có thể.

---

### Phase E — Release Candidate

**Mục tiêu:** Có một bản build cụ thể, có version, có thể tái tạo lại được — đánh dấu "đây là bản dùng để báo cáo/bảo vệ", không phải "code trên máy tôi lúc đó".

**Checklist:**
```
☐ Quyết định chính sách version (hiện đang đứng yên ở 1.0.0+1 từ đầu dự án) — ví dụ bump lên 1.0.0+2 hoặc 1.1.0 tuỳ quy ước bạn chọn
☐ Build Android (APK/AAB) cho attendance_mobile — flutter build apk / appbundle
☐ Build Web cho attendance_admin — flutter build web
☐ Xác nhận firestore.rules đang deploy đúng bản trong repo (git status -- firestore.rules phải sạch)
☐ Xác nhận firestore.indexes.json đã deploy khớp (firebase deploy --only firestore:indexes)
☐ Gắn git tag đánh dấu bản release candidate (ví dụ v1.0.0-rc1)
☐ (Tuỳ chọn, không bắt buộc) — cân nhắc CI đơn giản (GitHub Actions chạy flutter analyze + flutter test) nếu muốn thể hiện quy trình chuyên nghiệp hơn trong báo cáo — không bắt buộc cho quy mô đồ án thực tập solo
```
**Điều kiện bắt đầu:** Phase B (mục Bắt buộc) và Phase C đã hoàn thành.
**Điều kiện hoàn thành:** có build artifact cụ thể (file APK/thư mục web build) + git tag tương ứng.
**Kết quả đầu ra:** 1 bản release candidate có thể cài đặt/deploy lại được từ đúng 1 commit cụ thể.
**Rủi ro:** build lỗi lần đầu do khác biệt môi trường máy build (SDK version, keystore Android chưa cấu hình cho release build) — nên thử build sớm 1 lần ở Phase A/B để phát hiện sớm, không để dồn tới sát Phase E.
**Cách kiểm tra:** cài thử APK trên thiết bị thật; mở thử web build bằng `flutter run -d chrome --release` hoặc serve tĩnh.

---

### Phase F — Source Freeze

**Mục tiêu:** Một mốc quyết định rõ ràng — sau thời điểm này, source code chỉ nhận sửa lỗi, không nhận tính năng mới, để nội dung Chương 3/4 và slide không bị "đuổi theo" code liên tục thay đổi.

**Checklist:**
```
☐ Xác nhận Phase A, B (Bắt buộc), C, D.1, E đã hoàn thành
☐ Tuyên bố Source Freeze (ví dụ: 1 dòng ghi chú trong ROADMAP.md hoặc message của git tag) — không cần file tài liệu riêng
☐ Từ thời điểm này, mọi commit mới phải là "fix:" — nếu phát sinh ý tưởng tính năng mới, ghi lại riêng cho đợt sau, không đưa vào source đang dùng để viết báo cáo
```
**Điều kiện bắt đầu:** Phase E đã có release candidate cụ thể.
**Điều kiện hoàn thành:** tuyên bố freeze đã ghi lại (git tag/commit message là đủ, không cần file mới).
**Kết quả đầu ra:** một điểm neo cố định (commit hash / tag) mà Chương 3/4/Slide/Demo bảo vệ đều tham chiếu tới.
**Rủi ro:** freeze quá sớm khi Phase A còn dang dở (đặc biệt nếu Leave/Notification bị trì hoãn) sẽ buộc phải "un-freeze" — chỉ tuyên bố khi thực sự chắc chắn.
**Cách kiểm tra:** `git log` sau mốc freeze chỉ còn commit dạng sửa lỗi, không có tính năng mới.

---

### Phase G — Documentation

**Mục tiêu:** Hoàn thành phần báo cáo còn lại (Chương 3, Chương 4, Kết luận, Tài liệu tham khảo, Phụ lục, UML, hình ảnh/screenshot), tận dụng tối đa tài liệu kỹ thuật đã có sẵn (`ARCHITECTURE.md`, `PROJECT_OVERVIEW.md`, `REVIEW.md`, `ROADMAP.md`, kết quả Phase C) thay vì viết lại từ đầu.

**Checklist (tách "viết nháp" có thể làm sớm vs "chốt số liệu" cần đợi Phase F):**
```
Có thể bắt đầu sớm, song song Phase B/C (nội dung ít thay đổi theo source)
☐ Chương 3 — khung kiến trúc, công nghệ sử dụng: dựa trực tiếp trên ARCHITECTURE.md + PROJECT_OVERVIEW.md
☐ Chương 3 — mô tả nghiệp vụ (rotation, Business Date, GPS): dựa trên PROJECT_OVERVIEW.md mục 4 + docs/design/BUSINESS_DATE_DESIGN.md
☐ Phụ lục — sơ đồ UML (class diagram model, sequence diagram check-in/out) — vẽ được ngay từ code hiện tại
☐ Tài liệu tham khảo — tổng hợp dần trong lúc viết, không cần đợi

Cần đợi sau Phase F (số liệu/kết quả cụ thể phải khớp với bản đã freeze)
☐ Chương 3 — số liệu/bảng liệt kê tính năng đã hoàn thành (phải khớp đúng bản freeze, không phải bản đang dở)
☐ Chương 4 — kết quả kiểm thử (lấy trực tiếp từ TEST_PLAN.md của Phase C)
☐ Chương 4 — đánh giá/nhận xét (dựa trên REVIEW.md đã có + phát sinh mới nếu có trong Phase B/C)
☐ Kết luận — hướng phát triển tiếp theo (có thể liệt kê thẳng các mục "Ngoài phạm vi" của ROADMAP.md — Cloud Function, Clean Architecture, package dùng chung)
☐ Screenshot — chụp từ bản release candidate (Phase E), không chụp bản đang code dở
```
**Điều kiện bắt đầu:** phần "viết nháp" — bắt đầu được ngay; phần "chốt số liệu" — sau Phase F.
**Điều kiện hoàn thành:** đủ 8 mục theo yêu cầu gốc (Chương 3, Chương 4, Kết luận, Tài liệu tham khảo, Phụ lục, UML, Hình ảnh, Screenshot).
**Kết quả đầu ra:** bản thảo đầy đủ báo cáo (ngoài Chương 1-2 đã có).
**Rủi ro:** đây là công việc viết lách, không phải code — thời gian phụ thuộc hoàn toàn vào tốc độ viết của bạn, không nằm trong khả năng ước lượng kỹ thuật của kế hoạch này (xem ước lượng thời gian mang tính tham khảo ở §8).
**Cách kiểm tra:** đối chiếu từng chương với checklist yêu cầu của giảng viên/bộ môn (ngoài phạm vi tài liệu này).

---

### Phase H — Defense Preparation

**Mục tiêu:** Sẵn sàng trình bày và bảo vệ trước hội đồng.

**Checklist:**
```
☐ Slide PowerPoint — dựa trên cấu trúc Chương 1-4 đã hoàn thành
☐ Kịch bản Demo bảo vệ (D.2) đã rehearsal ít nhất 1-2 lần
☐ Q&A — mở rộng bộ câu hỏi đã có sẵn ở docs/demo/07_DEMO_QA.md (33 câu) + bổ sung câu hỏi riêng cho Chương 3/4 mới viết
☐ Timeline buổi bảo vệ — phân bổ thời gian trình bày/demo/hỏi đáp theo quy định của bộ môn
☐ Checklist thiết bị/hậu cần cho ngày bảo vệ — mở rộng từ docs/demo/05_DEMO_CHECKLIST.md
```
**Điều kiện bắt đầu:** Phase G đã có bản thảo đầy đủ; Phase D.2 đã có kịch bản demo cập nhật.
**Điều kiện hoàn thành:** đã rehearsal toàn bộ (trình bày + demo + trả lời câu hỏi giả định) trong đúng giới hạn thời gian quy định.
**Kết quả đầu ra:** sẵn sàng bước vào buổi bảo vệ.
**Rủi ro:** rehearsal muộn không phát hiện kịp vấn đề về thời lượng hoặc thiết bị — nên rehearsal ít nhất 1 lần đủ sớm để còn thời gian điều chỉnh.
**Cách kiểm tra:** rehearsal có bấm giờ, lý tưởng có người khác quan sát/phản hồi.

---

## 4. Milestone

```
M0 — Progress Report Demo Ready        (D.1 — gần như xong, có thể đạt trong 1 ngày làm việc)
        ↓ (không chặn M1 — chạy song song)
M1 — Core Complete                     (Phase A xong)
        ↓
M2 — Quality & Testing Complete        (Phase B "Bắt buộc" + Phase C xong — hai phase này lặp xen kẽ, không tuần tự cứng)
        ↓
M3 — Release Candidate                 (Phase E xong)
        ↓
M4 — Source Freeze                     (Phase F tuyên bố)
        ↓
M5 — Documentation Complete            (Phase G xong — phần "viết nháp" có thể đã bắt đầu từ trước M2)
        ↓
M6 — Defense Demo Ready                (D.2 xong)
        ↓
M7 — Defense Ready                     (Phase H xong)
```

Lưu ý: M0 được thêm vào so với đề xuất gốc (vốn chỉ có M1-M7) vì đây là một cột mốc thực tế, gần nhất, độc lập với chuỗi M1-M7 còn lại — xem lý do ở §0 mục 1.

---

## 5. Definition of Done

**Demo Ready (báo cáo tiến độ):**
- Checklist D.1 đã tick hết.
- Đã kiểm thử tay Check In/Check Out trên đúng thiết bị, đúng địa điểm sẽ dùng.
- Không có màn hình nào trống dữ liệu một cách bất ngờ khi demo.

**Demo Ready (bảo vệ tốt nghiệp):**
- Tất cả điều kiện của "Demo Ready (báo cáo tiến độ)".
- Checklist D.2 đã tick hết, đã rehearsal ít nhất 1 lần theo đúng nội dung Chương 3/4 đã viết.

**Release Ready:**
- Phase A, B (mục Bắt buộc), C đã hoàn thành.
- Có build artifact cụ thể (APK + Web build) từ 1 commit đã gắn tag.
- `flutter analyze` không còn issue nào chưa được xem xét có chủ đích.
- Firestore Rules + Indexes đã deploy khớp với bản trong repo.

**Report Ready (sẵn sàng nộp báo cáo viết):**
- Phase G đã hoàn thành đủ 8 mục yêu cầu.
- Số liệu/screenshot trong báo cáo khớp với bản đã Source Freeze (Phase F) — không có phần nào mô tả tính năng chưa thực sự chạy được.

**Defense Ready:**
- Phase H đã hoàn thành.
- Đã rehearsal đủ số lần cần thiết để tự tin về thời lượng và nội dung trả lời câu hỏi.

---

## 6. Tài liệu quản lý đề xuất thêm

> **Cập nhật 2026-07-13:** hệ thống tài liệu quản lý chi tiết đã được tách khỏi Master Plan này theo yêu cầu, tổ chức theo thư mục chuyên đề thay vì dồn hết vào `docs/project/`. Xem cấu trúc đầy đủ và bảng liên kết bên dưới. Nội dung phần còn lại của §6 giữ nguyên như bản gốc, chỉ cập nhật cột "Đề xuất?" cho các mục nay đã có file thật.

### Cấu trúc thư mục quản lý dự án

```
docs/
├── project/     — kế hoạch & tiến độ (Backlog, Sprint, Progress, Data Freeze, và chính Master Plan này)
├── testing/     — chất lượng & kiểm thử (Test Plan, Bug Tracker)
├── release/     — vận hành release (Release Checklist)
├── decision/    — lịch sử quyết định kỹ thuật (Decision Log)
├── demo/        — kịch bản & dữ liệu demo (đã có từ trước — DEMO_GUIDE.md, 01-08, DEMO_TIME_DESIGN*)
├── report/      — nội dung báo cáo tốt nghiệp (đã có từ trước — chapter2/)
├── review/      — đánh giá tại một thời điểm, chỉ đọc (đã có từ trước — REVIEW.md tương đương, DEMO_READINESS_REVIEW.md)
└── design/      — thiết kế kỹ thuật chi tiết (đã có từ trước — BUSINESS_DATE_DESIGN.md...)
```

Nguyên tắc phân loại: **project/** = "sắp làm gì, khi nào" (kế hoạch); **testing/** = "có đúng không" (chất lượng); **release/** = "đã sẵn sàng phát hành chưa" (vận hành); **decision/** = "tại sao lại làm thế này" (lịch sử quyết định, không đổi theo thời gian một khi đã ghi); **demo/report/review/design** giữ nguyên vai trò đã có từ trước, không đổi.

| Tài liệu | Đề xuất? | Lý do |
|---|---|---|
| `docs/testing/01_TEST_PLAN.md` | **Đã tạo** (2026-07-13) | Hiện chưa có nơi nào ghi lại kịch bản kiểm thử + kết quả — cần thiết làm bằng chứng cho Chương 4, và bản thân `ROADMAP.md`/`REVIEW.md` không đóng vai trò này (chúng là tài liệu đánh giá code tĩnh, không phải nhật ký kiểm thử) |
| `docs/testing/02_BUG_TRACKER.md` | **Đã tạo** (2026-07-13) | Không có issue tracker nào đang dùng (không thấy GitHub Issues được dùng); Phase B/C chắc chắn sẽ phát sinh phát hiện mới ngoài danh sách đã có trong `REVIEW.md` (vốn là bản chụp tại một thời điểm, không cập nhật tiếp) — cần một nơi nhẹ để ghi nhận, không lẫn vào `REVIEW.md` (tài liệu đó tự khai là "chỉ đọc") |
| `docs/release/01_RELEASE_CHECKLIST.md` | **Đã tạo** (2026-07-13, theo yêu cầu tường minh) | Ban đầu đánh giá "không cần tạo riêng ngay" vì checklist Phase E ở đây đã đủ chi tiết — nay tạo theo yêu cầu tường minh như bản **checklist thao tác thuần tuý** (không giải thích lại lý do, chỉ tham chiếu Phase E), tránh trùng lặp nội dung dù trùng tên file |
| `docs/project/01_BACKLOG.md`, `02_SPRINT.md` | **Đã tạo** (2026-07-13) | Không có trong đề xuất gốc — bổ sung theo yêu cầu tường minh, đóng vai trò "backlog thao tác được" và "lịch thực thi theo sprint" mà bản Phase A-H tĩnh ở đây không có |
| `docs/decision/01_DECISION_LOG.md` | **Đã tạo** (2026-07-13) | Không có trong đề xuất gốc — bổ sung theo yêu cầu tường minh, lấp khoảng trống "tại sao" mà `ARCHITECTURE.md` (chỉ mô tả "cái gì") không có |
| `docs/project/03_PROGRESS.md` | **Đã tạo** (2026-07-13) | Không có trong đề xuất gốc — nhật ký tiến độ theo thời gian, khác bản chất với kế hoạch tĩnh ở Master Plan này |
| `docs/project/04_DATA_FREEZE_PLAN.md` | **Đã tạo** (2026-07-13) | Trục quản lý mới (đóng băng **dữ liệu** Firestore, khác đóng băng **source code** ở Phase F) — không tồn tại ở bất kỳ tài liệu nào trước đó |
| `PROJECT_DEMO_GUIDE.md` | Không cần — **đã tồn tại** | `docs/demo/DEMO_GUIDE.md` đã đúng vai trò này; tạo thêm file trùng tên/mục đích sẽ gây nhầm lẫn nguồn nào là bản mới nhất (xem cảnh báo doc sprawl ở §7) |
| `PROJECT_REPORT_PLAN.md` | Không cần riêng | Phase G ở tài liệu này đã đóng vai trò kế hoạch viết báo cáo; việc lập dàn ý chi tiết từng chương thuộc về công việc viết lách của bạn, không phải kế hoạch quản lý dự án |
| `PROJECT_DEFENSE_PLAN.md` | Không cần tạo bây giờ | Còn quá sớm (Phase H ở cuối lộ trình) — nội dung cụ thể (timeline hội đồng, quy định bộ môn) chưa biết được ở thời điểm hiện tại; nên tạo ngay trước khi bắt đầu Phase H thay vì bây giờ |
| `RISK_REGISTER.md` | Không cần tách riêng | Đã embed trực tiếp ở §7 dưới đây — quy mô rủi ro hiện tại (≈10 mục) chưa đủ lớn để cần một file quản lý vòng đời rủi ro riêng biệt (open/mitigated/closed theo thời gian); nếu số lượng rủi ro tăng đáng kể ở Phase B/C, cân nhắc tách ra sau |

---

## 7. Risk Register tổng thể

| # | Rủi ro | Phase liên quan | Mức độ | Cách giảm thiểu |
|---|---|---|---|---|
| 1 | Demo Time System đang là thay đổi chưa commit trong working tree — có thể mất nếu máy gặp sự cố trước khi commit | A | Cao | Commit sớm, ngay đầu Phase A, tách riêng khỏi các thay đổi khác |
| 2 | Toàn vẹn dữ liệu GPS hoàn toàn dựa client (không có Cloud Function xác thực lại) | Đã biết, chấp nhận | Cao (production), Thấp (báo cáo/bảo vệ) | Không sửa trong phạm vi hiện tại theo `ROADMAP.md`; trình bày chủ động như "hướng phát triển tiếp theo" ở Kết luận (Phase G) |
| 3 | Mở rộng phạm vi Nghỉ phép (mobile)/Notification ở Phase A có thể vượt ước lượng thời gian | A | Trung bình | Chốt phạm vi tối thiểu (MVP) trước khi bắt đầu, không làm đầy đủ như sản phẩm thương mại |
| 4 | Version chưa từng bump (`1.0.0+1` từ đầu dự án) — dễ nhầm giữa các bản build khi cần đối chiếu | E | Thấp | Quyết định chính sách version ngay đầu Phase E, không để tới sát ngày release |
| 5 | Không có CI — lỗi `flutter analyze`/`flutter test` chỉ phát hiện khi chạy tay | B, E | Thấp-Trung bình | Chạy `flutter analyze` + `flutter test` thủ công đều đặn cuối mỗi đợt làm việc; CI là tuỳ chọn, không bắt buộc cho quy mô này |
| 6 | Tài liệu demo chồng lấn (5 nguồn: `01-08`, `DEMO_GUIDE.md`, `DEMO_TIME_DESIGN.md`/`v2`, `DEMO_READINESS_REVIEW.md`) — dễ đọc nhầm bản cũ | D, G, H | Trung bình | Luôn coi `DEMO_GUIDE.md` là nguồn tổng hợp mới nhất khi cần tra cứu nhanh; các file `01-08`/`DEMO_TIME_DESIGN*` là tài liệu nền/lịch sử thiết kế, không phải kịch bản dùng trực tiếp |
| 7 | Kiểm thử ca đêm/rotation chỉ dựa Demo Time, chưa từng xác nhận lại bằng thời gian thực gần ngày release/bảo vệ | C, D.2 | Trung bình | Luôn dành ít nhất 1 lượt kiểm thử bằng thời gian thực trước mỗi cột mốc quan trọng (M3, M6), không chỉ dựa mô phỏng |
| 8 | Rotation hiện tại (`rotationStartDate: 2026-06-01`) sẽ tiếp tục đổi ca theo thời gian — trạng thái "nhóm nào đang làm ca gì" mô tả trong tài liệu demo sẽ lệch nếu dùng lại nhiều tháng sau (ví dụ lúc bảo vệ tốt nghiệp) | D.2 | Trung bình | Luôn tính lại trạng thái rotation hiện tại trước mỗi lần dùng tài liệu demo, không copy nguyên số liệu cũ |
| 9 | Firestore `company_settings.radius` hiện đang đặt cực lớn (9999999999m, thực chất vô hiệu hoá kiểm tra bán kính) — nếu quên đặt lại giá trị thật trước khi trình bày như một tính năng đã hoàn thiện, dễ bị hỏi xoáy | D.1, D.2 | Thấp-Trung bình | Đã có trong checklist D.1; nhắc lại ở đây để không bị bỏ sót khi cập nhật demo bảo vệ (D.2) |
| 10 | `.idea/`, `.agents/skills/` và một số file untracked khác đang lẫn trong `git status` — không liên quan trực tiếp tới kế hoạch này nhưng có thể gây nhiễu khi rà soát "source đã freeze chưa" ở Phase F | F | Thấp | Khi tới Phase F, rà soát `git status` sạch cho riêng phần code (`attendance_mobile/`, `attendance_admin/`, `firestore.rules`, `firestore.indexes.json`) — không cần lo phần `.idea`/tooling |

---

## 8. Kết luận & khuyến nghị

**Đánh giá tổng thể:** Dự án đang ở vị trí tốt để bắt đầu giai đoạn hoàn thiện — phần lõi khó nhất về mặt kỹ thuật (GPS, xoay ca, Business Date qua nửa đêm, Firestore Rules) đã xong và có bằng chứng dữ liệu thật xác nhận đúng. Phần còn thiếu chủ yếu là khối lượng công việc có thể lường trước được (Leave mobile, Notification UI, testing, viết báo cáo), không phải rủi ro kỹ thuật chưa biết.

**Việc quan trọng nhất cần làm ngay (theo thứ tự):**

1. **Commit ngay Demo Time System** (rủi ro #1 ở §7) — việc này chỉ tốn vài phút nhưng đang là rủi ro mất công sức lớn nhất hiện tại.
2. **Hoàn thành D.1 (Demo báo cáo tiến độ)** — gần xong, tận dụng ngay, không phụ thuộc gì khác.
3. **Xác nhận với chính bạn về phạm vi Phase A** — đặc biệt quyết định có thực sự làm Leave (mobile) + Notification hay không, vì đây là điểm quyết định lớn nhất tới tổng thời gian toàn bộ kế hoạch.
4. Sau đó đi theo đúng thứ tự M1 → M7, với Phase B/C chạy xen kẽ và Phase G phần "viết nháp" có thể bắt đầu sớm song song.

**Ước lượng thời gian (mang tính tham khảo, giả định làm bán thời gian, không phải cam kết cứng):**

| Phase | Ước lượng |
|---|---|
| M0 (D.1) | ~1 ngày |
| A (còn lại, gồm cả 2 tính năng mới nếu làm) | ~6-10 ngày làm việc (~2-3 tuần lịch) |
| B (Bắt buộc) + C | ~8-11 ngày làm việc (~3-4 tuần lịch, xen kẽ) |
| B (Nên làm + Dọn dẹp, nếu còn thời gian) | +6-8 ngày làm việc, không bắt buộc |
| E | ~1-2 ngày |
| F | <1 ngày (chỉ là quyết định) |
| G | Phụ thuộc tốc độ viết — không ước lượng kỹ thuật được, tham khảo: các đồ án tương tự thường mất 2-4 tuần cho Chương 3+4+Kết luận+Phụ lục |
| D.2 + H | ~4-6 ngày làm việc |

**Tổng thể:** nếu chỉ làm phần bắt buộc (không làm Phase B "Nên làm"/"Dọn dẹp"), lộ trình từ hôm nay tới sẵn sàng bảo vệ vào khoảng **7-11 tuần lịch** làm bán thời gian — con số này phụ thuộc nhiều nhất vào tốc độ viết Chương 3/4 (Phase G) và quyết định phạm vi Phase A, không phải vào khối lượng code còn lại (khối lượng đó đã tương đối rõ và nhỏ).
