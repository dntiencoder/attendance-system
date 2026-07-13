# 03 — Demo Script (Lời thuyết trình)

Viết theo phong cách nói tự nhiên, có thể đọc trực tiếp hoặc dùng làm gợi ý ứng biến. Khớp với thứ tự các bước ở `02_DEMO_FLOW.md`.

## Mục lục

1. [Mở đầu — Giới thiệu đề tài](#1-mở-đầu--giới-thiệu-đề-tài)
2. [Kiến trúc & công nghệ](#2-kiến-trúc--công-nghệ)
3. [Phần Mobile](#3-phần-mobile)
4. [Phần Admin](#4-phần-admin)
5. [Kết luận](#5-kết-luận)

---

## 1. Mở đầu — Giới thiệu đề tài

> Em xin phép báo cáo tiến độ đồ án thực tập: hệ thống chấm công bằng GPS cho nhân viên làm việc theo ca xoay vòng.
>
> Bài toán thực tế là: công ty có nhân viên làm ca ngày và ca đêm, luân phiên đổi ca theo chu kỳ, và cần xác nhận nhân viên chấm công đúng tại vị trí công ty — không thể chấm công hộ hay chấm công từ xa.
>
> Em xây dựng 2 ứng dụng: một app di động cho nhân viên để chấm công, và một web quản trị cho admin để theo dõi, quản lý nhân viên, duyệt nghỉ phép và cấu hình hệ thống. Cả 2 dùng chung 1 backend Firebase.

## 2. Kiến trúc & công nghệ

> Về công nghệ, em dùng Flutter cho cả 2 ứng dụng — vì Flutter cho phép build cả mobile lẫn web từ cùng 1 ngôn ngữ Dart, phù hợp để 1 mình em phát triển song song 2 app trong thời gian thực tập.
>
> Backend em dùng Firebase — cụ thể là Firebase Authentication để đăng nhập, và Cloud Firestore để lưu toàn bộ dữ liệu nghiệp vụ: hồ sơ nhân viên, bản ghi chấm công, cấu hình công ty, đơn nghỉ phép.
>
> Về quản lý state trong Flutter, em dùng Riverpod — mỗi tính năng có Repository lo việc đọc/ghi Firestore, và Provider expose dữ liệu ra cho UI, tách biệt rõ giữa tầng dữ liệu và tầng giao diện.
>
> Một điểm em muốn nhấn mạnh: vì không dùng backend server riêng, toàn bộ việc phân quyền — ai được đọc, ai được ghi dữ liệu nào — nằm ở Firestore Security Rules. Em sẽ quay lại điểm này ở phần sau, vì đây là phần em đầu tư khá kỹ.

## 3. Phần Mobile

### Đăng nhập

> Đây là app dành cho nhân viên. Tài khoản đăng nhập do admin tạo sẵn — nhân viên không tự đăng ký, chỉ nhận email và mật khẩu từ công ty rồi đăng nhập.

### Home — Ca làm việc

> Sau khi đăng nhập, màn Home hiển thị ngay ca làm việc hôm nay của nhân viên này.
>
> Ở đây có một bài toán nghiệp vụ khá thú vị: công ty có 2 nhóm nhân viên, gọi là nhóm A và nhóm B, luân phiên đổi ca ngày/ca đêm mỗi 14 ngày. Nhân viên không tự chọn ca — hệ thống tự tính dựa trên nhóm của họ và ngày hiện tại.
>
> Cái khó nằm ở ca đêm — ca đêm bắt đầu 20 giờ tối và kết thúc 8 giờ sáng hôm sau, tức là xuyên qua nửa đêm. Ban đầu hệ thống của em có một lỗi khá tinh vi: nếu nhân viên check-in lúc, ví dụ, 0 giờ 18 phút sáng, hệ thống lại tính theo ngày lịch hiện tại thay vì hiểu rằng đây vẫn là ca đêm bắt đầu từ tối hôm qua — dẫn đến hiển thị sai ca, và tính sai luôn cả việc đi trễ hay đúng giờ.
>
> Em đã giải quyết bằng cách đưa vào khái niệm "Business Date" — tức ngày làm việc thực tế, khác với ngày theo lịch — để mọi tính toán ca, giờ vào ca, giờ ra ca đều neo theo đúng ngày ca đó *bắt đầu*, không phải ngày đồng hồ tại thời điểm thao tác.

### Check In

> Bây giờ em sẽ Check In thật. Hệ thống sẽ: lấy vị trí GPS thật của máy — có kiểm tra chống giả lập vị trí; tính khoảng cách tới toạ độ công ty đã cấu hình; kiểm tra đã tới giờ vào ca chưa — cho phép vào sớm tối đa 60 phút; và cuối cùng ghi nhận lên Firestore kèm đánh dấu đi trễ hay đúng giờ.

*(Chờ kết quả Check In hiện lên)*

> Như các thầy cô thấy, bản ghi đã được tạo — em sẽ đối chiếu lại ở phần admin ngay sau đây.

### Check Out

> Em Check Out luôn để khép kín ví dụ — trong thực tế nhân viên sẽ làm hết ca rồi mới check-out, ở đây demo nhanh nên khoảng cách giữa check-in và check-out chỉ vài phút.

### Lịch sử chấm công

> Đây là lịch sử chấm công — dữ liệu này đã có thật hơn 1 tháng nay, không phải dữ liệu giả dựng cho buổi demo hôm nay. Các thầy cô có thể thấy đủ các trường hợp: đúng giờ, đi trễ, về sớm, và đặc biệt là đúng ngày hệ thống tự đổi ca giữa 2 nhóm theo chu kỳ 14 ngày như em vừa nói.

## 4. Phần Admin

### Đăng nhập & Dashboard

> Chuyển sang phía quản trị. Đây là Dashboard tổng quan — số nhân viên, số người đã chấm công hôm nay, biểu đồ chấm công theo tuần.

### Nhật ký chấm công

> Và đây, bản ghi Check In/Check Out em vừa thực hiện trên điện thoại đã xuất hiện ngay tại đây — dữ liệu đi thẳng từ mobile lên Firestore, admin thấy gần như tức thời, không qua bước đồng bộ trung gian nào.

### Quản lý Nhân viên

> Ở màn quản lý nhân viên, khi tạo tài khoản mới, hệ thống tự sinh một mật khẩu ngẫu nhiên đủ mạnh thay vì đặt sẵn một mật khẩu mặc định — đây là một cải tiến bảo mật em vừa hoàn thành, vì trước đó mọi tài khoản mới đều dùng chung 1 mật khẩu dễ đoán.

### Duyệt nghỉ phép

> Đây là màn duyệt đơn nghỉ phép. Nhân viên gửi đơn, admin duyệt hoặc từ chối kèm ghi chú, hệ thống tự gửi thông báo lại cho nhân viên đó.
>
> Em xin nói thẳng một phần đang còn dang dở: hiện tại phía mobile, màn "Nghỉ phép" chưa cho nhân viên tự tạo đơn — em ưu tiên hoàn thiện phần lõi là chấm công GPS trước, phần tạo đơn nghỉ phép từ mobile nằm trong kế hoạch giai đoạn tiếp theo.

### Cấu hình hệ thống

> Cuối cùng, toàn bộ tham số nghiệp vụ — toạ độ công ty, bán kính cho phép, giờ ca, chu kỳ xoay ca — đều cấu hình được qua đây, không hardcode trong code, nên khi triển khai cho công ty khác chỉ cần đổi cấu hình.

## 5. Kết luận

> Tóm lại, trong giai đoạn vừa qua em đã hoàn thành: luồng chấm công GPS đầy đủ có xử lý đúng ca đêm xuyên nửa đêm, cơ chế xoay ca tự động, và một phần em muốn nhấn mạnh là đã rà soát và vá lại toàn bộ Firestore Security Rules — ban đầu dữ liệu gần như không có lớp bảo vệ nào ở tầng cơ sở dữ liệu, giờ đã kiểm soát chặt theo từng vai trò.
>
> Phần đang làm dở và sẽ hoàn thiện ở giai đoạn tiếp theo: cho nhân viên tự tạo đơn nghỉ phép từ mobile, xây màn hiển thị thông báo, và màn quản lý phòng ban độc lập cho admin.
>
> Em xin dừng phần trình bày ở đây, sẵn sàng nhận câu hỏi từ thầy cô.
