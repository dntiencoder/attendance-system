# 05 — Demo Checklist

Checklist thực hiện trước và trong buổi báo cáo. Dùng cùng lúc với `01_DEMO_DATA.md` (dữ liệu), `02_DEMO_FLOW.md` (thứ tự thao tác), `06_DEMO_RISK.md` (xử lý sự cố).

## Mục lục

1. [Chuẩn bị trước 1 ngày](#1-chuẩn-bị-trước-1-ngày)
2. [Chuẩn bị ngay trước giờ báo cáo](#2-chuẩn-bị-ngay-trước-giờ-báo-cáo)
3. [Trong lúc demo](#3-trong-lúc-demo)

---

## 1. Chuẩn bị trước 1 ngày

```
☐ Đã thêm 3 document mẫu vào leave_requests (xem 01_DEMO_DATA.md mục 5)
☐ Đã quyết định giữ hay đổi company_settings.radius (xem 01_DEMO_DATA.md mục 7)
☐ Đã sửa lại departmentId của tài khoản admin cho khớp 1 phòng ban thật
☐ Đã kiểm thử tay Check In/Check Out trên đúng thiết bị sẽ dùng để demo
☐ Đã kiểm thử đăng nhập cả 2 app bằng đúng tài khoản sẽ dùng khi demo
☐ Đã chạy flutter analyze cho cả 2 app, không còn lỗi mới
☐ Đã sạc đầy pin điện thoại demo + laptop
☐ Đã chuẩn bị phương án mạng dự phòng (hotspot 4G) — xem 06_DEMO_RISK.md
☐ Đã in/mở sẵn 03_DEMO_SCRIPT.md và 07_DEMO_QA.md để tham khảo nhanh khi cần
```

## 2. Chuẩn bị ngay trước giờ báo cáo

```
☐ Mobile Login — đã đăng nhập sẵn hoặc xác nhận đăng nhập nhanh được
☐ Admin Login — đã đăng nhập sẵn hoặc xác nhận đăng nhập nhanh được
☐ GPS trên điện thoại demo đã bật, không ở chế độ vị trí giả (mock location)
☐ Internet ổn định — đã thử tải Dashboard admin ít nhất 1 lần thành công
☐ Firebase Console đã mở sẵn 1 tab (phòng khi cần đối chiếu dữ liệu trực tiếp)
☐ Dashboard admin đã tải thử, không còn lỗi quyền truy cập
☐ Attendance (Nhật ký chấm công) đã mở thử, hiển thị đúng dữ liệu
☐ Employee (Quản lý nhân viên) đã mở thử, dropdown phòng ban hiển thị đủ 13 phòng ban
☐ Leave (Duyệt nghỉ phép) đã mở thử, thấy đủ 3 đơn mẫu (pending/approved/rejected)
☐ Settings đã mở thử, số liệu hiển thị đúng
☐ Firestore attendance đã sẵn sàng nhận dữ liệu mới (không có lỗi ghi từ lần test trước)
☐ Đã chuẩn bị sẵn hotspot 4G, đã thử chuyển mạng 1 lần để chắc chắn hoạt động
☐ Đã tắt thông báo/tin nhắn cá nhân trên điện thoại + laptop dùng demo
```

## 3. Trong lúc demo

```
☐ Mở đầu đúng kịch bản (02_DEMO_FLOW.md bước 1-2)
☐ Mobile Login thành công
☐ Home hiển thị đúng ca dự kiến
☐ Check In thành công (GPS thật)
☐ Check Out thành công
☐ Lịch sử chấm công hiển thị đúng bản ghi cũ + bản ghi vừa tạo
☐ Admin Login thành công
☐ Dashboard tải được, không lỗi
☐ Nhật ký chấm công hiển thị đúng bản ghi Check In/Out vừa demo ở mobile
☐ Thêm nhân viên mới thành công, mật khẩu ngẫu nhiên hiển thị đúng
☐ Duyệt/từ chối 1 đơn nghỉ phép mẫu thành công
☐ Settings mở được, không lỗi
☐ Kết luận đúng trọng tâm: đã làm gì — đang làm gì — kế hoạch tiếp theo
```
