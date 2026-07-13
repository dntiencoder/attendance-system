# Báo cáo Đánh giá Mức độ Sẵn sàng — Báo cáo Tiến độ Thực tập

**Ngày đánh giá:** 2026-07-05
**Phạm vi:** `attendance_mobile/` (ứng dụng nhân viên) + `attendance_admin/` (ứng dụng quản trị) + `firestore.rules`
**Bối cảnh đánh giá:** Đây là bản đánh giá lại, thay thế hoàn toàn bản đánh giá trước đó cùng tên. Bản gốc dùng chuẩn "sản phẩm sẵn sàng bảo vệ tốt nghiệp/production", không phù hợp với mục tiêu thực tế của buổi báo cáo sắp tới — **báo cáo tiến độ thực tập giữa kỳ**, không phải bảo vệ tốt nghiệp, không đánh giá theo chuẩn sản phẩm thương mại.
**Mục tiêu buổi báo cáo (theo đúng bối cảnh thực tế):**
- Báo cáo những gì đã hoàn thành.
- Chứng minh dự án đang đi đúng hướng.
- Demo các chức năng đã triển khai.
- Trình bày kế hoạch giai đoạn tiếp theo.

**Phương pháp:** Đọc trực tiếp mã nguồn hiện tại của cả hai ứng dụng, `firestore.rules`, cấu hình routing, đối chiếu lịch sử sửa lỗi trong quá trình ổn định hoá dự án (Phase 1 của `ROADMAP.md`), sau đó đánh giá lại từng phát hiện theo đúng câu hỏi: *"Điều này có ảnh hưởng tới buổi báo cáo tiến độ không, hay chỉ là việc để dành cho giai đoạn sau?"*
**Ràng buộc:** Báo cáo mang tính đánh giá thuần tuý — không sửa code, không cập nhật `ROADMAP.md`, không đề xuất refactor lớn hay kiến trúc mới.

---

## Mục lục

1. [Đánh giá lại từng hạng mục ❌ / 🟡](#1-đánh-giá-lại-từng-hạng-mục---)
2. [Phân loại theo 3 nhóm ưu tiên](#2-phân-loại-theo-3-nhóm-ưu-tiên)
3. [Điểm số theo tiêu chí báo cáo tiến độ](#3-điểm-số-theo-tiêu-chí-báo-cáo-tiến-độ)
4. [Dự đoán phản ứng của giảng viên](#4-dự-đoán-phản-ứng-của-giảng-viên)
5. [Checklist chuẩn bị trước buổi báo cáo](#5-checklist-chuẩn-bị-trước-buổi-báo-cáo)
6. [5 việc giá trị cao nhất cần làm](#6-5-việc-giá-trị-cao-nhất-cần-làm)
7. [Kết luận](#7-kết-luận)

---

## 1. Đánh giá lại từng hạng mục ❌ / 🟡

Các mục sau từng bị đánh giá ❌/🟡 theo chuẩn "sản phẩm hoàn chỉnh". Bảng dưới đánh giá lại đúng theo mức độ ảnh hưởng tới **buổi báo cáo tiến độ**.

| Hạng mục | Đánh giá cũ (chuẩn production) | Có thật sự ảnh hưởng buổi báo cáo tiến độ? |
|---|---|---|
| Check In / Check Out | 🟡 Chưa test tay sau khi viết lại | **Có, ảnh hưởng thật.** Đây là phần chắc chắn sẽ demo trực tiếp — lỗi lúc demo sẽ ảnh hưởng ấn tượng về tiến độ dù code có đúng đến đâu. Là rủi ro *vận hành lúc demo*, không phải rủi ro chất lượng code. |
| GPS mock detection | 🟡 Bắt buộc demo đúng vị trí thật | **Có ảnh hưởng, nhưng là vấn đề hậu cần**, không phải lỗi kỹ thuật — chỉ cần biết trước và chọn đúng địa điểm. Có thể trình bày chủ động như một điểm cộng ("đã chống được vị trí giả"). |
| Dashboard chậm (7 query tuần tự) | 🟡 Có thể gây cảm giác tải chậm | **Không ảnh hưởng đáng kể.** Chậm vài trăm ms không phải vấn đề ở một buổi báo cáo tiến độ. |
| Department không có màn quản lý riêng | ❌ Chưa đạt | **Không phải lỗi ở giai đoạn này.** Dữ liệu phòng ban vẫn đúng và vẫn được dùng (qua dropdown Nhân viên) — đây là tính năng *chưa tới lượt trong roadmap*, không phải tính năng *bị hỏng*. |
| Leave Request — mobile chỉ là placeholder | ❌ Chưa đạt | **Ảnh hưởng một phần, nhưng có thể chuyển hoá thành nội dung trình bày kế hoạch.** Nếu phía admin (duyệt/từ chối) đã chạy thật và có dữ liệu mẫu để demo, đây không còn là "tính năng hỏng" mà là "nửa đã xong, nửa đã có kế hoạch" — đúng trọng tâm mục tiêu "trình bày kế hoạch giai đoạn tiếp theo". Chỉ thực sự rủi ro nếu vô tình bấm vào tab đó mà không có sự chuẩn bị để giải thích. |
| Notification — chỉ ghi, không có màn hiển thị | ❌ Chưa đạt | **Gần như không ảnh hưởng**, miễn là không chủ động đưa vào phần demo. Đây là nội dung phù hợp cho phần "kế hoạch tiếp theo" nếu được hỏi tới, không cần chủ động nhắc. |
| Kiến trúc: không có Repository interface, business logic trong Repository, model trùng lặp | — | **Không ảnh hưởng buổi báo cáo tiến độ.** Đây là câu hỏi thuộc tầm phản biện đồ án tốt nghiệp, hiếm khi được hỏi sâu ở một buổi báo cáo giữa kỳ. |
| UI polish (màu hardcode, nhãn trùng "Tap"/"Tap", chưa dùng lại `ConfirmDialog`/`Validators`) | — | **Không ảnh hưởng.** Không ai soi tới mức này trong 15-20 phút báo cáo tiến độ. |
| Xoá nhân viên không kiểm tra `isActive`, chưa có transaction cho Check In, chưa có Crashlytics | — | **Không ảnh hưởng.** Là rủi ro vận hành production dài hạn, không liên quan tới việc chứng minh tiến độ. |

**Kết luận của mục này:** trong toàn bộ các mục từng bị đánh giá ❌/🟡, chỉ có đúng 2 mục thật sự ảnh hưởng trực tiếp tới thành công của buổi báo cáo — **Check In/Out chưa kiểm thử tay**, và **hậu cần vị trí GPS**. Phần còn lại đều là việc để dành cho giai đoạn sau, hoặc thậm chí là nguyên liệu tốt cho phần trình bày kế hoạch tiếp theo.

---

## 2. Phân loại theo 3 nhóm ưu tiên

### Nhóm A — Bắt buộc hoàn thành trước báo cáo tiến độ

| # | Việc cần làm |
|---|---|
| A1 | Kiểm thử tay Check In/Check Out trên thiết bị thật, ít nhất một lượt ca ngày và một lượt ca đêm |
| A2 | Xác nhận địa điểm/cấu hình GPS phù hợp với nơi báo cáo |
| A3 | Seed sẵn 1-2 đơn nghỉ phép mẫu vào Firestore để màn "Duyệt Nghỉ Phép" không trống khi demo |
| A4 | Kiểm thử luồng đăng nhập cả hai ứng dụng bằng đúng tài khoản sẽ dùng khi báo cáo |
| A5 | Chuẩn bị sẵn phần trình bày ngắn "đã làm gì — vì sao phần kia chưa làm — kế hoạch tiếp theo" cho Leave Request (mobile) và Notification |

### Nhóm B — Nên hoàn thành nếu còn thời gian

- Sửa nhãn hiển thị trùng lặp "Tap"/"Tap" trong `checkin_card.dart`.
- Seed sẵn danh sách phòng ban mẫu để dropdown không trống khi demo màn Nhân viên.
- Xác nhận lại một lần Dashboard tải bình thường, không còn lỗi quyền truy cập.
- Chạy `flutter analyze` lần cuối trên cả hai ứng dụng trước ngày báo cáo.

### Nhóm C — Có thể để sau (Phase 2/3 hoặc trước khi bảo vệ tốt nghiệp)

- Hoàn thiện tính năng Nghỉ phép phía mobile (tạo đơn thật từ ứng dụng nhân viên).
- Xây màn quản lý Phòng ban độc lập cho admin.
- Xây màn hiển thị Notification thật ở cả hai ứng dụng.
- Tối ưu Dashboard (song song hoá 7 truy vấn tuần bằng `Future.wait`).
- Giới hạn/lọc theo ngày cho truy vấn `attendance` (P3-01); cache `company_settings`/`users` trong màn lịch sử chấm công (P3-03).
- Đồng bộ nhãn hiển thị ca làm giữa hai ứng dụng; thay hex màu hardcode bằng `AppColors`; dùng lại `ConfirmDialog`/`Validators` thay code inline.
- Bọc Check In trong `runTransaction()`; thêm Crashlytics/logging; ràng buộc xoá nhân viên theo `isActive`.
- Tách interface cho Repository, tách lớp use-case riêng, gộp package model dùng chung giữa hai ứng dụng — dành cho giai đoạn chuẩn bị bảo vệ tốt nghiệp, không cần cho báo cáo tiến độ.

---

## 3. Điểm số theo tiêu chí báo cáo tiến độ

| Tiêu chí | Điểm | Ghi chú |
|---|---|---|
| Tiến độ thực hiện | 9 / 10 | Khối lượng công việc thực chất lớn trong giai đoạn này: phát hiện và sửa dứt điểm nhiều bug thật (rotation, Business Date, Firestore permission) — đúng tinh thần "chứng minh đang đi đúng hướng", không phải code cho có. |
| Mức độ hoàn thành chức năng | 7.5 / 10 | Lõi (đăng nhập, chấm công GPS, rotation, dashboard, quản lý nhân viên, cấu hình) hoàn chỉnh và đã qua kiểm chứng logic kỹ; tính năng phụ (nghỉ phép mobile, notification UI, department UI) chưa tới — hợp lý cho giai đoạn giữa kỳ. |
| Kiến trúc | 8 / 10 | Rõ ràng, nhất quán, dễ trình bày trên slide — đủ tốt cho báo cáo tiến độ, không cần soi tới mức Clean Architecture/SOLID. |
| Chất lượng code | 8 / 10 | Có null-safety, có lịch sử sửa lỗi thật, Firestore Rules được đầu tư nghiêm túc — điểm cộng rõ rệt so với mặt bằng chung một dự án thực tập. |
| Khả năng demo | 7.5 / 10 (có điều kiện) | Đủ khả năng demo mượt nếu hoàn thành Nhóm A; nếu bỏ qua kiểm thử tay, điểm này giảm rõ rệt vì rủi ro lỗi trực tiếp trước mặt giảng viên. |
| Khả năng tiếp tục phát triển | 9 / 10 | Có roadmap rõ ràng theo từng Phase, quyết định phạm vi được ghi chép có lý do — dễ tiếp tục ở các đợt sau, dễ trình bày định hướng tiếp theo. |
| **Tổng thể (bối cảnh báo cáo tiến độ)** | **8.2 / 10** | Cao hơn rõ rệt so với mức 7.3/10 khi đánh giá theo chuẩn sản phẩm — đúng bản chất vấn đề: dự án đang trên đà tốt cho một buổi báo cáo tiến độ, khác với việc chưa sẵn sàng cho một sản phẩm hoàn chỉnh. |

---

## 4. Dự đoán phản ứng của giảng viên

**Giảng viên nhiều khả năng sẽ hài lòng ở:**

- Chấm công GPS xử lý đúng logic ca ngày/ca đêm kể cả trường hợp khó (ca xuyên nửa đêm) — chi tiết kỹ thuật vượt mức trung bình một đồ án thực tập.
- Firestore Security Rules được đầu tư thực chất (không mở toang, không copy mẫu có sẵn) — hiếm thực tập sinh làm tới mức này.
- Có tài liệu roadmap/phase rõ ràng — thể hiện tư duy quản lý tiến độ có hệ thống.
- Có bằng chứng tự phát hiện và sửa bug thật trong quá trình làm việc, không chỉ nộp bài "chạy được là xong".

**Có khả năng bị hỏi:**

- Vì sao Nghỉ phép/Notification chưa hoàn thiện ở mobile — đã có câu trả lời sẵn: quyết định ưu tiên có chủ đích, đã lên kế hoạch cho phase sau.
- Cách xử lý ca đêm xuyên nửa đêm (Business Date) — nên chủ động kể, đây là điểm mạnh nên khai thác chứ không phải điểm yếu cần né tránh.
- Kế hoạch 2-4 tuần tới sẽ triển khai gì — cần câu trả lời rõ ràng, có thể lấy trực tiếp từ Phase 2 của `ROADMAP.md`.

**Nguy cơ bị yêu cầu làm lại:** **Thấp**, với điều kiện hoàn thành Nhóm A. Không có dấu hiệu nào trong toàn bộ đánh giá cho thấy phải làm lại từ đầu — dự án đang đúng hướng, chỉ cần đảm bảo phần demo trực tiếp chạy mượt và không để lộ một tab hoàn toàn trống mà không có lời giải thích chuẩn bị trước.

---

## 5. Checklist chuẩn bị trước buổi báo cáo

```
☐ Đăng nhập mobile bằng đúng tài khoản sẽ dùng khi báo cáo
☐ Home hiển thị đúng ca (ngày/đêm) theo tài khoản đang test
☐ Check In tại đúng vị trí GPS thật — đã thử tay ít nhất 1 lần trước buổi báo cáo
☐ Check Out — đã thử tay ít nhất 1 lần trước buổi báo cáo
☐ Lịch sử chấm công hiển thị đúng bản ghi vừa tạo
☐ Đăng nhập admin bằng đúng tài khoản sẽ dùng khi báo cáo
☐ Dashboard tải được, không còn lỗi quyền truy cập
☐ Quản Lý Nhân Viên — xem danh sách, thử thêm 1 nhân viên (xác nhận sinh mật khẩu ngẫu nhiên)
☐ Nhật Ký Chấm Công — thấy đúng bản ghi Check In/Out vừa demo
☐ Duyệt Nghỉ Phép — đã seed sẵn đơn mẫu, thử duyệt/từ chối 1 đơn
☐ Cấu Hình Vị Trí GPS (Settings) — xem/sửa thử 1 giá trị
☐ Đã chuẩn bị sẵn phần trình bày ngắn về Nghỉ phép (mobile)/Notification như "kế hoạch giai đoạn tiếp theo"
☐ Đã chuẩn bị sẵn nội dung "kế hoạch 2-4 tuần tới" để trả lời khi được hỏi
```

---

## 6. 5 việc giá trị cao nhất cần làm

1. Kiểm thử tay Check In/Check Out trên thiết bị thật (ít nhất 1 lượt ca ngày, 1 lượt ca đêm) tại đúng địa điểm sẽ báo cáo.
2. Seed sẵn 1-2 đơn nghỉ phép mẫu để màn Duyệt Nghỉ Phép không trống.
3. Chuẩn bị sẵn phần trình bày ngắn "đã làm gì — vì sao chưa làm phần kia — kế hoạch tiếp theo" cho Leave Request (mobile) và Notification.
4. Kiểm thử đăng nhập cả hai ứng dụng bằng đúng tài khoản sẽ dùng khi báo cáo.
5. Seed sẵn danh sách phòng ban mẫu và chạy `flutter analyze` lần cuối cho cả hai ứng dụng.

*(Không đề xuất refactor lớn, không đề xuất kiến trúc mới, không đánh giá theo chuẩn production — đúng theo ràng buộc của bối cảnh báo cáo tiến độ thực tập.)*

---

## 7. Kết luận

**Nếu hôm nay mang dự án đi báo cáo tiến độ: nên đi, với điều kiện hoàn thành Nhóm A ở Mục 2.**

Xét theo đúng mục tiêu của một buổi báo cáo tiến độ thực tập (báo cáo đã hoàn thành gì, chứng minh đúng hướng, demo được chức năng đã có, trình bày kế hoạch tiếp theo) — dự án đang ở trạng thái tốt. Phần lõi hệ thống (đăng nhập, chấm công GPS, xoay ca, Firestore Security Rules) có chiều sâu kỹ thuật thực sự và đã trải qua nhiều vòng sửa lỗi có bằng chứng cụ thể — đây chính là câu chuyện nên kể để "chứng minh dự án đang đi đúng hướng".

Các khoảng trống còn lại (Nghỉ phép chưa hoàn thiện ở mobile, chưa có màn Notification, chưa có màn quản lý Phòng ban riêng) **không phải là thất bại** trong bối cảnh báo cáo tiến độ — đây chính xác là nội dung phù hợp cho phần "trình bày kế hoạch giai đoạn tiếp theo" mà buổi báo cáo yêu cầu, miễn là được chủ động trình bày thay vì để giảng viên tự phát hiện.

**Hai việc duy nhất thực sự cần thiết trước khi báo cáo:** (1) kiểm thử tay Check In/Check Out trên thiết bị thật, và (2) chuẩn bị dữ liệu mẫu để không có màn hình nào trống một cách bất ngờ khi demo trực tiếp. Ngoài hai việc này, dự án không cần thêm bất kỳ thay đổi mã nguồn nào để sẵn sàng cho một buổi báo cáo tiến độ.

---

*Báo cáo này chỉ mang tính đánh giá — không có thay đổi nào được thực hiện trên mã nguồn hoặc trên `ROADMAP.md` trong quá trình lập báo cáo. Bản đánh giá này thay thế hoàn toàn bản đánh giá theo chuẩn "sẵn sàng sản phẩm" trước đó tại cùng đường dẫn.*
