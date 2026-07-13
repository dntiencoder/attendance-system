# 02 — Demo Flow

**Bối cảnh:** Báo cáo tiến độ thực tập (không phải bảo vệ tốt nghiệp) — mục tiêu là báo cáo đã hoàn thành gì, chứng minh đúng hướng, demo được chức năng, trình bày kế hoạch tiếp theo.
**Thời lượng tổng:** ~23 phút (có thể co giãn ±5 phút tuỳ thời gian được cấp).

## Mục lục

1. [Timeline tổng quan](#1-timeline-tổng-quan)
2. [Chi tiết từng bước](#2-chi-tiết-từng-bước)
3. [Ghi chú thực hiện](#3-ghi-chú-thực-hiện)

---

## 1. Timeline tổng quan

```
00:00 ─ 02:00   1. Giới thiệu đề tài
02:00 ─ 04:00   2. Kiến trúc & công nghệ
04:00 ─ 05:00   3. Mobile — Đăng nhập
05:00 ─ 07:00   4. Mobile — Home
07:00 ─ 09:00   5. Mobile — Check In (thật)
09:00 ─ 10:00   6. Mobile — Check Out (thật)
10:00 ─ 11:00   7. Mobile — Lịch sử chấm công
11:00 ─ 12:00   8. Admin — Đăng nhập
12:00 ─ 14:00   9. Admin — Dashboard
14:00 ─ 15:00  10. Admin — Nhật Ký Chấm Công
15:00 ─ 17:00  11. Admin — Quản Lý Nhân Viên
17:00 ─ 19:00  12. Admin — Duyệt Nghỉ Phép
19:00 ─ 20:00  13. Admin — Cấu Hình GPS/Settings
20:00 ─ 22:00  14. Kết luận & kế hoạch tiếp theo
```

---

## 2. Chi tiết từng bước

### Bước 1 — Giới thiệu đề tài
- **Thao tác:** Không thao tác trên máy — trình bày bằng lời/slide.
- **Nói gì:** Tên đề tài, bài toán (chấm công GPS theo ca xoay vòng cho doanh nghiệp sản xuất), phạm vi 2 ứng dụng (mobile nhân viên, web admin).
- **Mục tiêu:** Giảng viên hiểu bài toán trước khi xem demo.
- **Thời gian:** 2 phút.

### Bước 2 — Kiến trúc & công nghệ
- **Thao tác:** Slide sơ đồ kiến trúc (feature-first, Riverpod, Firebase).
- **Nói gì:** Flutter cho cả 2 nền tảng, Firebase (Auth + Firestore) làm backend, Riverpod quản lý state, Firestore Security Rules đảm nhiệm việc phân quyền thay vì backend riêng.
- **Mục tiêu:** Cho thấy lựa chọn công nghệ có chủ đích, không tuỳ tiện.
- **Thời gian:** 2 phút.

### Bước 3 — Mobile — Đăng nhập
- **Thao tác:** Mở app mobile, đăng nhập bằng 1 tài khoản nhân viên đã seed sẵn (ví dụ EMP001).
- **Nói gì:** "Đây là tài khoản do admin tạo sẵn, nhân viên chỉ cần đăng nhập bằng email/mật khẩu được cấp."
- **Mục tiêu:** Xác nhận luồng xác thực hoạt động.
- **Thời gian:** 1 phút.

### Bước 4 — Mobile — Home
- **Thao tác:** Chỉ vào phần hiển thị ca làm việc hiện tại trên Home.
- **Nói gì:** Giải thích ngắn gọn cơ chế xoay ca 14 ngày giữa 2 nhóm A/B, nhấn mạnh hệ thống tự xác định ca chứ nhân viên không tự chọn.
- **Mục tiêu:** Giới thiệu tính năng "thông minh" nhất của hệ thống trước khi đi vào thao tác cụ thể.
- **Thời gian:** 2 phút.

### Bước 5 — Mobile — Check In (thật)
- **Thao tác:** Bấm Check In thật, chờ kết quả.
- **Nói gì:** "Hệ thống đang lấy vị trí GPS thật, kiểm tra trong bán kính công ty, kiểm tra đúng khung giờ ca, rồi ghi nhận lên Firestore."
- **Mục tiêu:** Chứng minh tính năng lõi hoạt động thật, không phải giả lập.
- **Thời gian:** 2 phút.

### Bước 6 — Mobile — Check Out (thật)
- **Thao tác:** Bấm Check Out ngay sau đó.
- **Nói gì:** "Trong thực tế nhân viên sẽ Check Out cuối ca làm; ở đây demo Check Out ngay sau để tiết kiệm thời gian trình bày."
- **Mục tiêu:** Khép kín 1 chu trình chấm công đầy đủ để đối chiếu ở phần admin.
- **Thời gian:** 1 phút.

### Bước 7 — Mobile — Lịch sử chấm công
- **Thao tác:** Chuyển tab "Lịch sử", cuộn xem vài bản ghi cũ (dữ liệu thật đã có từ tháng 6).
- **Nói gì:** "Đây là lịch sử chấm công thật trong hơn 1 tháng qua, đã có đầy đủ tình huống: đúng giờ, đi muộn, về sớm, đổi ca."
- **Mục tiêu:** Cho thấy hệ thống đã chạy thật, có dữ liệu tích luỹ, không phải demo dữ liệu giả dựng tạm.
- **Thời gian:** 1 phút.

### Bước 8 — Admin — Đăng nhập
- **Thao tác:** Mở web admin, đăng nhập tài khoản admin.
- **Nói gì:** "Admin quản lý toàn bộ nhân viên, chấm công, nghỉ phép, cấu hình công ty."
- **Mục tiêu:** Chuyển góc nhìn sang phía quản trị.
- **Thời gian:** 1 phút.

### Bước 9 — Admin — Dashboard
- **Thao tác:** Mở Dashboard, chỉ vào biểu đồ và số liệu tổng quan.
- **Nói gì:** Giải thích số liệu tổng hợp (tổng nhân viên, đã check-in hôm nay, biểu đồ tuần).
- **Mục tiêu:** Tạo ấn tượng trực quan đầu tiên cho phía admin.
- **Thời gian:** 2 phút.

### Bước 10 — Admin — Nhật Ký Chấm Công
- **Thao tác:** Mở màn Nhật ký chấm công, lọc/tìm đúng bản ghi Check In/Out vừa tạo ở Bước 5-6.
- **Nói gì:** "Đây chính là bản ghi vừa tạo từ điện thoại — dữ liệu đi thẳng từ mobile lên Firestore, admin thấy ngay lập tức."
- **Mục tiêu:** Chứng minh trực quan luồng dữ liệu mobile → Firestore → admin theo thời gian thực.
- **Thời gian:** 1 phút.

### Bước 11 — Admin — Quản Lý Nhân Viên
- **Thao tác:** Mở màn Nhân viên, bấm "Thêm Nhân Viên Mới", điền thông tin, chỉ vào ô mật khẩu đã tự sinh ngẫu nhiên.
- **Nói gì:** "Hệ thống tự sinh mật khẩu ngẫu nhiên đủ mạnh cho tài khoản mới thay vì dùng mật khẩu mặc định dễ đoán — đây là 1 cải tiến bảo mật đã thực hiện gần đây."
- **Mục tiêu:** Trình bày tính năng quản trị + điểm cộng bảo mật.
- **Thời gian:** 2 phút.

### Bước 12 — Admin — Duyệt Nghỉ Phép
- **Thao tác:** Mở màn Duyệt Nghỉ Phép, xử lý 1 đơn đang "pending" (đã seed sẵn ở `01_DEMO_DATA.md`).
- **Nói gì:** "Đơn nghỉ phép được nhân viên gửi lên (hiện đang seed dữ liệu mẫu để demo phần duyệt admin), admin duyệt/từ chối kèm ghi chú, hệ thống tự gửi thông báo lại cho nhân viên."
- **Mục tiêu:** Trình bày tính năng đã có, đồng thời là điểm tự nhiên để nói về phần "đang làm dở" (tạo đơn từ mobile) mà không cần né tránh.
- **Thời gian:** 2 phút.

### Bước 13 — Admin — Cấu Hình GPS/Settings
- **Thao tác:** Mở màn Settings, chỉ vào các trường toạ độ, bán kính, giờ ca, chu kỳ xoay ca.
- **Nói gì:** "Toàn bộ tham số nghiệp vụ đều cấu hình được qua đây, không hardcode trong code."
- **Mục tiêu:** Cho thấy hệ thống có khả năng cấu hình linh hoạt theo từng doanh nghiệp.
- **Thời gian:** 1 phút.

### Bước 14 — Kết luận & kế hoạch tiếp theo
- **Thao tác:** Không thao tác trên máy — quay lại slide.
- **Nói gì:** Tóm tắt đã hoàn thành gì (Phase 1: bảo mật + ổn định dữ liệu), đang làm gì (Business Date/rotation), kế hoạch tiếp theo (Phase 2: nghỉ phép phía mobile, thông báo, quản lý phòng ban).
- **Mục tiêu:** Kết thúc đúng với mục tiêu buổi báo cáo — chứng minh đúng hướng + có kế hoạch rõ ràng.
- **Thời gian:** 2 phút.

---

## 3. Ghi chú thực hiện

- Nếu thời gian bị rút ngắn, có thể bỏ Bước 6 (Check Out) và Bước 13 (Settings) — không ảnh hưởng mạch câu chuyện chính.
- Bước 5 (Check In thật) là bước rủi ro cao nhất về mặt kỹ thuật (phụ thuộc GPS/mạng) — xem `06_DEMO_RISK.md` để có phương án dự phòng.
- Thứ tự Bước 9→10 (Dashboard trước, Nhật ký sau) cố ý đặt để đối chiếu bản ghi vừa tạo — nên giữ đúng thứ tự này, không đảo ngược.
