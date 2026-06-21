# HỆ THỐNG QUẢN LÝ CHẤM CÔNG - SCHEMA DỮ LIỆU (FIRESTORE)

Tài liệu này tổng hợp cấu trúc dữ liệu được sử dụng đồng bộ giữa **Web Admin**, **Mobile App** và **Cloud Firestore**.

---

## 1. Collection: `users`
Lưu trữ thông tin chi tiết về nhân sự và tài khoản đăng nhập.

| Trường (Field) | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | `String` | ID tự động của Firestore (Dùng làm `uid` cho Auth) |
| `employeeCode` | `String` | Mã số nhân viên (Ví dụ: NV001, NV002) |
| `name` | `String` | Họ và tên đầy đủ |
| `email` | `String` | Địa chỉ email (Dùng để đăng nhập) |
| `role` | `String` | Phân quyền: `admin` hoặc `employee` |
| `phone` | `String` | Số điện thoại liên lạc |
| `departmentId` | `String` | ID của phòng ban thuộc về |
| `shiftGroup` | `String` | Nhóm ca làm việc (Ví dụ: A, B, C) |
| `avatarUrl` | `String` | Đường dẫn ảnh đại diện (Firebase Storage) |
| `isActive` | `Boolean` | Trạng thái hoạt động (`true`: Đang làm, `false`: Nghỉ việc) |
| `createdAt` | `Timestamp` | Thời điểm tạo hồ sơ nhân viên |

---

## 2. Collection: `attendance`
Lưu trữ nhật ký chấm công hàng ngày của nhân viên.

| Trường (Field) | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `uid` | `String` | ID của nhân viên (Link với `users.id`) |
| `employeeName` | `String` | Tên nhân viên (Để hiển thị nhanh trên bảng công) |
| `date` | `String` | Ngày chấm công định dạng `YYYY-MM-DD` (Dùng để filter) |
| `checkIn` | `Timestamp` | Thời gian quét vân tay/nhấn nút vào |
| `checkOut` | `Timestamp` | Thời gian quét vân tay/nhấn nút ra |
| `status` | `String` | Trạng thái: `ontime`, `late`, `early_leave`, `absent` |
| `location` | `GeoPoint` | Tọa độ GPS thực tế lúc chấm công |
| `isWithinRadius`| `Boolean` | Xác nhận chấm công có nằm trong bán kính cho phép |

---

## 3. Collection: `leave_requests`
Lưu trữ các đơn xin nghỉ phép từ nhân viên gửi lên.

| Trường (Field) | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `uid` | `String` | ID của nhân viên gửi đơn |
| `employeeCode` | `String` | Mã nhân viên |
| `startDate` | `Timestamp` | Ngày bắt đầu nghỉ |
| `endDate` | `Timestamp` | Ngày kết thúc nghỉ |
| `reason` | `String` | Lý do xin nghỉ |
| `status` | `String` | Trạng thái: `pending` (chờ), `approved` (duyệt), `rejected` (từ chối) |
| `adminNote` | `String` | Phản hồi từ Admin khi duyệt đơn |
| `createdAt` | `Timestamp` | Thời điểm gửi đơn |

---

## 4. Collection: `settings`
Lưu trữ cấu hình GPS và quy tắc của công ty.

| Trường (Field) | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `officeName` | `String` | Tên trụ sở/văn phòng |
| `latitude` | `Double` | Vĩ độ của văn phòng |
| `longitude` | `Double` | Kinh độ của văn phòng |
| `radius` | `Number` | Bán kính cho phép chấm công (tính bằng mét) |
| `workStartTime` | `String` | Giờ bắt đầu làm việc (Ví dụ: "08:00") |
| `workEndTime` | `String` | Giờ kết thúc làm việc (Ví dụ: "17:00") |

---

## Lưu ý quan trọng cho nhà phát triển:
1. **Case-sensitive**: Tất cả các giá trị chuỗi định danh như `role`, `status` nên thống nhất viết **chữ thường** để tránh lỗi so sánh.
2. **Date storage**: Luôn ưu tiên dùng kiểu `Timestamp` của Firebase thay vì `String` để tối ưu việc truy vấn và sắp xếp dữ liệu.
3. **Security Rules**: Đảm bảo các Rules đã được cập nhật tương ứng với các trường dữ liệu trên để tránh lỗi `Permission Denied`.
