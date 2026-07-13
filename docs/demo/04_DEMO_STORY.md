# 04 — Demo Story

Câu chuyện nghiệp vụ đằng sau buổi demo — dùng để dẫn dắt mạch trình bày, không chỉ là hướng dẫn bấm nút. Mỗi bước gắn với dữ liệu thật đang có trong hệ thống (xem `01_DEMO_DATA.md`).

## Mục lục

1. [Câu chuyện đầy đủ](#1-câu-chuyện-đầy-đủ)
2. [Sơ đồ luồng](#2-sơ-đồ-luồng)
3. [Vì sao kể theo thứ tự này](#3-vì-sao-kể-theo-thứ-tự-này)

---

## 1. Câu chuyện đầy đủ

**"Công ty UMC Việt Nam vận hành theo ca xoay vòng — nhân viên chia làm 2 nhóm, ngày A đêm B, rồi đổi ngược lại mỗi 14 ngày."**

↓

**"Khi có nhân viên mới, admin tạo tài khoản ngay trên web quản trị — chọn phòng ban, nhóm ca, hệ thống tự sinh mật khẩu ngẫu nhiên."**
*(Minh hoạ bằng: tạo thử 1 nhân viên mới, dữ liệu thật đã có sẵn EMP004 — Tạ Đình Trí — được thêm gần đây theo đúng cách này.)*

↓

**"Nhân viên nhận tài khoản, cài app, đăng nhập lần đầu."**
*(Minh hoạ bằng: đăng nhập tài khoản EMP001 — Trần Văn Ab, nhóm A.)*

↓

**"Mở app, nhân viên thấy ngay ca làm việc hôm nay — không cần tự nhớ lịch xoay ca, hệ thống tự tính theo đúng chu kỳ 14 ngày kể từ ngày công ty bắt đầu áp dụng."**

↓

**"Đến đúng giờ ca, nhân viên đến công ty, bấm Check In."**

↓

**"Điện thoại lấy vị trí GPS thật, hệ thống kiểm tra: đúng trong bán kính công ty chưa, đúng đã tới giờ vào ca chưa, có phải vị trí giả không — rồi mới ghi nhận."**

↓

**"Dữ liệu chấm công được gửi thẳng lên Firestore — không qua máy chủ trung gian nào của công ty, vì kiến trúc hệ thống không có backend riêng."**

↓

**"Cuối ca, nhân viên bấm Check Out — hệ thống tính lại đúng ca đó đã kéo dài bao lâu, có về sớm không."**

↓

**"Admin, ở phía web quản trị, mở Dashboard và thấy ngay số liệu chấm công hôm nay được cập nhật — không cần đợi đồng bộ, không cần thao tác gì thêm."**

↓

**"Admin mở Nhật ký chấm công, tìm thấy đúng bản ghi nhân viên vừa tạo — xác nhận đúng giờ, đúng vị trí, đúng ca."**

↓

**"Một hôm, nhân viên cần nghỉ phép — gửi đơn (hiện dùng dữ liệu mẫu vì phần này ở mobile còn dang dở), admin xem đơn trên web, duyệt hoặc từ chối kèm lý do."**

↓

**"Hệ thống tự gửi thông báo lại cho nhân viên biết đơn đã được xử lý."**

↓

**"Nếu công ty cần đổi giờ ca, đổi bán kính cho phép chấm công, hay đổi chu kỳ xoay ca — admin chỉ cần vào màn Cấu hình, không cần sửa code, không cần build lại ứng dụng."**

↓

**"Kết thúc: một vòng đời chấm công đầy đủ, từ lúc tạo tài khoản tới lúc dữ liệu được admin giám sát và công ty cấu hình theo nhu cầu riêng."**

---

## 2. Sơ đồ luồng

```
Admin tạo nhân viên
        │
        ▼
Nhân viên nhận tài khoản, đăng nhập
        │
        ▼
Home hiển thị đúng ca (rotation tự động)
        │
        ▼
Check In (GPS thật + kiểm tra giờ ca)
        │
        ▼
Dữ liệu ghi thẳng lên Firestore
        │
        ├──────────────────────────┐
        ▼                          ▼
Check Out (cuối ca)      Admin thấy ngay trên Dashboard/Nhật ký
        │
        ▼
Nhân viên xin nghỉ phép ──► Admin duyệt/từ chối ──► Thông báo gửi lại nhân viên
        │
        ▼
Admin điều chỉnh cấu hình khi cần (GPS, giờ ca, chu kỳ xoay ca)
```

## 3. Vì sao kể theo thứ tự này

Thứ tự trên đi theo đúng **vòng đời thật của 1 nhân viên trong hệ thống** (được tạo → đăng nhập → làm việc hằng ngày → có nhu cầu phát sinh như nghỉ phép → công ty điều chỉnh cấu hình khi cần), thay vì liệt kê tính năng rời rạc theo màn hình. Cách kể này giúp giảng viên thấy được **một hệ thống hoàn chỉnh phục vụ đúng 1 bài toán thật**, thay vì một danh sách chức năng không liên kết với nhau.
