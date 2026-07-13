# 04_DATA_FREEZE_PLAN.md

**Mục tiêu:** Quy định rõ khi nào dữ liệu demo (Firestore) được sửa tự do, khi nào phải đóng băng, và khi nào được chụp màn hình dùng cho báo cáo — một trục quản lý hoàn toàn khác với "Source Freeze" (`PROJECT_MASTER_PLAN.md` Phase F, quản lý code). Dữ liệu và code đóng băng ở các thời điểm khác nhau, vì lý do khác nhau.

**Phạm vi:** Các collection Firestore (`attendance`, `leave_requests`, `notifications`, `departments`, `users`/employee, `company_settings`), trạng thái Demo Time (`ClockService`), và thời điểm chụp screenshot cho báo cáo.

**Khi nào dùng:** Trước mỗi lần demo (D.1, D.2), trước khi chụp screenshot cho Chương 3/4 (Phase G), trước Release (Phase E).

**Liên kết:** Rủi ro liên quan đã ghi ở `PROJECT_MASTER_PLAN.md` §7 (rủi ro #6, #7, #8, #9); dữ liệu thật hiện có mô tả chi tiết ở `docs/demo/01_DEMO_DATA.md`.

---

## Vì sao cần tài liệu riêng cho dữ liệu (khác Source Freeze)

Source Freeze (Phase F) đóng băng **code**. Nhưng dữ liệu Firestore thay đổi theo **thời gian thực** kể cả khi code không đổi một dòng nào:

- Rotation tự động đổi ca theo ngày thực (`rotationStartDate` + `rotationDays`) — trạng thái "nhóm nào đang làm ca gì" mô tả trong tài liệu demo hôm nay **sẽ sai** nếu dùng lại nguyên văn vài tuần/tháng sau (ví dụ lúc bảo vệ tốt nghiệp).
- `main_dev.dart` xoá và tạo lại toàn bộ dữ liệu demo mỗi lần chạy — có thể vô tình phá huỷ 38+ bản ghi chấm công thật đã tích luỹ hơn 1 tháng chỉ bằng 1 lệnh chạy nhầm entrypoint.
- Demo Time System (`ClockService`) cho phép ghi dữ liệu vào bất kỳ "ngày làm việc" nào — luyện tập demo nhiều lần ở đúng ngày sẽ dùng thật có thể gây xung đột ("đã Check In hôm nay rồi") ngay trước buổi demo thật.

## Các mức đóng băng dữ liệu

### Level 0 — Tự do chỉnh sửa (mặc định, hiện tại)

Áp dụng trong lúc phát triển Phase A/B/C. Được phép: seed/xoá/sửa bất kỳ collection nào để phục vụ test, kể cả qua `main_dev.dart` — **miễn là biết rõ mình đang làm gì** (xem cảnh báo dưới).

⚠️ **Luôn dùng `flutter run` (main.dart), không dùng `flutter run -t lib/main_dev.dart`** trừ khi thực sự có ý định xoá sạch và tạo lại dữ liệu demo — `main_dev.dart` wipe + reseed **mỗi lần khởi động**, không hỏi xác nhận.

### Level 1 — Soft Freeze cho Demo báo cáo tiến độ (D.1)

Kích hoạt: ngay khi checklist D.1 (`PROJECT_MASTER_PLAN.md`) bắt đầu hoàn thành (seed `leave_requests`, quyết định `radius`, sửa `departmentId` admin).

Quy định:
- Từ thời điểm này tới hết buổi báo cáo tiến độ: **không chạy `main_dev.dart`**.
- Được phép Check In/Check Out thật để dry-run (MT-01 → MT-10 ở `docs/testing/01_TEST_PLAN.md`), nhưng **ưu tiên dry-run ở "ngày làm việc" khác** với ngày dự kiến demo thật (dùng Demo Time để dịch chuyển, không dùng đúng ngày thật) — tránh việc bị chặn "đã Check In hôm nay rồi" ngay trước mặt giảng viên.
- `departments`, `users`/employee: coi như ổn định, không thêm/xoá tài khoản test lẫn vào danh sách thật trừ khi dọn ngay sau đó.

### Level 2 — Report Data Freeze (chụp ảnh cho Chương 3/4)

Kích hoạt: ngay sau khi Level 1 hoàn thành tốt (D.1 xong) — **không cần đợi Source Freeze (Phase F)** để bắt đầu chụp ảnh cho phần tính năng lõi (Check In/Out, Rotation, Dashboard, Employee, Settings) vì các phần này đã ổn định và có dữ liệu thật chất lượng cao ngay bây giờ.

Quy định:
- Chụp ảnh **theo đợt**, ghi rõ **ngày chụp** kèm mỗi ảnh (hoặc trong 1 file mapping riêng khi viết Chương 3/4) — vì trạng thái rotation (nhóm nào đang ca gì) sẽ khác đi ở lần chụp sau.
- Ảnh liên quan tính năng **mới** (Leave mobile, Notification UI, Department UI — nếu làm ở Phase A) chỉ chụp **sau khi tính năng đó hoàn thành và qua Phase C**, không chụp bản dở dang.
- Không chụp lại nếu không cần — tránh tình trạng ảnh trong báo cáo đến từ nhiều thời điểm rotation khác nhau gây mâu thuẫn khi trình bày (ví dụ 1 ảnh nói nhóm A làm ca ngày, ảnh khác lại nói nhóm A làm ca đêm mà không giải thích).

### Level 3 — Release Data Freeze

Kích hoạt: ngay trước Sprint 7 / `docs/release/01_RELEASE_CHECKLIST.md`.

Quy định:
- Dọn sạch mọi document rác từ quá trình test (tài khoản test tạm, đơn nghỉ phép test tạm, bản ghi chấm công tạo bởi Demo Time ở "ngày ảo" không có ý nghĩa trình diễn).
- Xác nhận lại `company_settings.radius` ở giá trị **thật** (không phải giá trị nới lỏng dùng lúc test, nếu quyết định thay đổi).
- Từ thời điểm này tới hết Release: áp dụng lại quy tắc Level 1 (không `main_dev.dart`, cẩn trọng Check In/Out thật).

### Level 4 — Pre-Defense Freeze (D.2)

Kích hoạt: trước buổi bảo vệ tốt nghiệp (Phase H), sau khi Phase G ổn định.

Quy định:
- Tính lại trạng thái rotation hiện tại (nhóm nào đang ca gì) — **không copy nguyên số liệu từ D.1** vì đã cách nhau nhiều tuần/tháng.
- Nếu Leave (mobile)/Notification/Department UI đã hoàn thành ở Phase A sau D.1, cần seed lại dữ liệu minh hoạ tương ứng cho các màn hình mới này.
- Áp dụng lại toàn bộ quy tắc Level 1 trong ngày bảo vệ.

---

## Bảng tóm tắt theo collection

| Collection | Level 0 (hiện tại) | Trước D.1 | Trước chụp báo cáo | Trước Release | Trước D.2 |
|---|---|---|---|---|---|
| `attendance` | Tự do | Không `main_dev.dart`; dry-run ở ngày ảo | Chụp kèm ngày | Dọn rác test | Tính lại rotation |
| `leave_requests` | Tự do | Seed 3 đơn mẫu (pending/approved/rejected) | Chụp sau khi ổn định | Dọn đơn test tạm | Cập nhật nếu FEAT-01 xong |
| `notifications` | Tự do | Không bắt buộc (theo Demo Guide) | Chụp nếu FEAT-02 xong | Dọn rác test | Cập nhật nếu FEAT-02 xong |
| `departments` | Tự do | Ổn định (13 phòng ban thật) | Chụp trực tiếp | Không đổi | Cập nhật nếu FEAT-03 xong |
| `users` (employee) | Tự do | Không thêm tài khoản test lẫn vào danh sách thật | Chụp trực tiếp | Dọn tài khoản test | Không đổi trừ khi cần |
| `company_settings` | Tự do | Quyết định `radius` | Chụp trực tiếp | Đặt giá trị thật cuối cùng | Không đổi |
| Demo Time (`ClockService`) | Tự do | Reset về Real Time trước khi rời Demo Center | Reset về Real Time trước khi chụp (trừ khi chủ đích minh hoạ Demo Mode) | Không dùng trong bản Release thật (bị chặn `kDebugMode`) | Reset về Real Time trước khi rời Demo Center |
| Screenshot | — | — | Ghi ngày chụp | Có thể cần chụp lại nếu UI đổi ở Phase B | Chụp lại nếu tính năng mới xong |
