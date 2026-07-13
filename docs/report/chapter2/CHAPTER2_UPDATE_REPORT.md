# Báo cáo cập nhật CHAPTER2.md

**Nguồn đối chiếu:** `VIETNAM_RESEARCH_REVIEW.md` (tài liệu khảo cứu nội bộ, không phải nội dung báo cáo).
**Mục tiêu cập nhật:** Bổ sung nội dung học thuật cho mục 2.3.2 (Nghiên cứu trong nước) — mục tương ứng với "2.3.1 Kết quả nghiên cứu trong nước có liên quan" theo cách đánh số trong bản thảo báo cáo của bạn — dựa trên 5 tài liệu trong nước đã khảo cứu được, đồng thời không đưa nguyên tài liệu khảo cứu vào báo cáo.

---

## 1. Những đoạn đã chỉnh sửa

Chỉ hai vị trí trong `CHAPTER2.md` được chỉnh sửa, không có mục nào khác bị đụng đến, không đổi cấu trúc/đánh số Chương 2:

1. **Mục 2.3.2 "Nghiên cứu trong nước"** — thay toàn bộ 2 đoạn văn ngắn cũ (chỉ nêu "chưa tìm thấy khoá luận trùng phạm vi" + 1 đoạn nói về thư viện số/nền tảng luận văn chung chung) bằng nội dung mới gồm 7 đoạn văn phân tích theo đúng cấu trúc học thuật: mở đầu → xu hướng nghiên cứu trong nước → công trình tiêu biểu → điểm mạnh/điểm hạn chế → bảng so sánh (Bảng 2.7, mới) → đoạn phân tích "liên hệ với đề tài" (kế thừa/khác biệt/cải tiến) → khoảng trống nghiên cứu → kết luận.
2. **Mục "Tài liệu tham khảo"** — bổ sung hai mục trích dẫn mới, [15] và [16], nối tiếp đúng thứ tự đánh số hiện có (không đánh số lại từ đầu); cập nhật lại câu "Ghi chú" ở cuối danh mục cho khớp với nội dung mới.

Không mục 2.1, 2.2, hay 2.3.1/2.3.3 nào bị chỉnh sửa.

## 2. Thông tin nào được bổ sung

Từ 5 tài liệu trong nước tìm được ở `VIETNAM_RESEARCH_REVIEW.md`, các thông tin sau được đưa vào báo cáo dưới hình thức phân tích học thuật (không copy nguyên bảng khảo cứu):

- **Nhận định xu hướng:** sự tách biệt giữa nghiên cứu định vị GPS thuần túy (trắc địa) và nghiên cứu quản lý nhân sự trong nước; xu hướng các đồ án chấm công trong nước chọn công nghệ định vị khác GPS (Wi-Fi) khi gặp hạn chế trong nhà; sự xuất hiện của Firebase trong các đồ án di động trong nước nhưng ở lĩnh vực khác (mạng xã hội).
- **Hai trích dẫn chính thức mới** [15] (Sơn & Khởi, 2021, Tạp chí Khoa học Công nghệ Xây dựng — GPS giám sát an toàn lao động) và [16] (Trần, 2024, khóa luận tốt nghiệp Đại học Kinh tế Quốc dân — phần mềm quản lý nhân sự), đưa vào cả phần phân tích lẫn danh mục tham khảo.
- **Bảng 2.7** — bảng so sánh đề tài với các tài liệu trong nước theo 4 tiêu chí kỹ thuật cốt lõi (GPS, Flutter, Firebase, Xoay ca), đúng định dạng bảng báo cáo (không phải bảng khảo cứu nội bộ dạng checklist).
- **Đoạn phân tích "liên hệ với đề tài"** — giải thích cụ thể đề tài kế thừa gì (nguyên lý GPS giám sát vị trí từ [15]; bài học về hạn chế GPS trong nhà từ đồ án Wi-Fi), khác gì (tích hợp đồng thời nhiều công nghệ thay vì từng mảnh rời rạc), cải tiến gì (chứng minh khả thi của tổ hợp công nghệ chưa từng ghi nhận cùng lúc trong nước), và giải quyết khoảng trống nào.
- **Ba tài liệu còn lại** (đồ án chấm công Wi-Fi, khảo sát định vị GPS của một tạp chí đại học vùng, công bố Firebase+React Native) được nhắc đến mô tả trong đoạn phân tích, không gán số trích dẫn — đúng theo yêu cầu chỉ đưa nguồn đủ tin cậy vào danh mục chính thức.

## 3. Thông tin nào bị loại bỏ (không đưa vào báo cáo)

Toàn bộ nội dung mang tính chất tài liệu khảo cứu nội bộ trong `VIETNAM_RESEARCH_REVIEW.md` **không** được đưa vào `CHAPTER2.md`, cụ thể:

- Bảng khảo cứu 10 trường thông tin cho từng tài liệu (tên đầy đủ/tác giả/năm/đơn vị/link/tóm tắt/công nghệ/điểm mạnh/điểm hạn chế/mức liên quan kèm số sao ★).
- Toàn bộ ghi chú mang tính kỹ thuật rà soát nguồn: ghi chú về HTTP 403 khi crawl ResearchGate, ghi chú "trang chặn crawler", ghi chú ngày thực hiện khảo cứu, ghi chú "cần đối chiếu tài khoản ResearchGate cá nhân".
- Phần "Đề xuất nội dung đưa vào mục 2.3.1" và mục "Ghi chú về độ tin cậy nguồn" của tài liệu khảo cứu — đây là hướng dẫn nội bộ cho chính việc cập nhật này, không phải nội dung báo cáo.
- Quan sát về thị trường phần mềm chấm công thương mại trong nước (MISA AMIS, ACheckin, Tanca...) — giữ nguyên như đã xác định trong tài liệu khảo cứu là **không phải nguồn học thuật**, không đưa vào Chương 2 dưới bất kỳ hình thức trích dẫn nào.
- Hai tài liệu **[D1] (khảo sát định vị GPS, Tạp chí KH ĐH Cần Thơ, 2015)** và **[E2] (Firebase + React Native, ResearchGate, 2023)** — không đưa vào danh mục tài liệu tham khảo chính thức do chưa xác minh được tên tác giả qua nguồn công khai; chỉ nhắc đến mô tả ngắn gọn trong đoạn phân tích, không gán số trích dẫn.
- Tài liệu **[A1] (đồ án chấm công qua Wi-Fi, Đại học Duy Tân)** — không đưa vào danh mục tham khảo chính thức vì đây là đồ án môn học công khai trên nền tảng chia sẻ tài liệu, không phải khóa luận được bảo vệ hội đồng, và không xác định được tên sinh viên thực hiện; chỉ nhắc đến mô tả trong bảng so sánh và đoạn phân tích, không gán số trích dẫn.

## 4. Lý do

- **Không copy nguyên văn:** Tài liệu khảo cứu được viết ở văn phong "báo cáo rà soát nội bộ" (checklist 10 trường thông tin, bảng nội bộ, ghi chú kỹ thuật) — hoàn toàn khác văn phong học thuật liền mạch đã dùng xuyên suốt Chương 2 (đoạn văn phân tích, không liệt kê). Đưa nguyên bảng khảo cứu vào sẽ biến Chương 2 thành "tài liệu tổng hợp" đúng như điều bạn yêu cầu tránh.
- **Chỉ giữ 2 trích dẫn chính thức:** Áp dụng đúng quy tắc bạn đặt ra — tài liệu chưa xác minh đủ tác giả/thông tin APA thì không đưa vào danh mục tham khảo chính thức, kể cả khi bản thân công trình đó là có thật (đã xác minh có tồn tại qua tìm kiếm, chỉ là thiếu tên tác giả). Ưu tiên độ chính xác học thuật hơn số lượng trích dẫn.
- **Không dùng bảng nội bộ, tạo Bảng 2.7 riêng:** Giữ đúng phong cách các bảng đã có trong Chương 2 (Bảng 2.1–2.6: tiêu đề đánh số tiếp nối, chú thích in nghiêng phía trên/dưới bảng, không dùng ký hiệu sao ★ hay các cột đánh giá chủ quan như trong tài liệu khảo cứu).
- **Thêm đoạn "liên hệ với đề tài" riêng biệt, phân tích thay vì liệt kê:** Theo đúng yêu cầu — không chỉ liệt kê ✓/✗ mà giải thích rõ ràng mối quan hệ kế thừa/khác biệt/cải tiến bằng lập luận, nối lại với các mục 2.2.11 (GPS/Geofencing) đã viết trước đó để tăng tính liên kết nội bộ của chương, không phải một đoạn cô lập.
- **Không thêm nội dung chỉ để tăng số trang:** Không đưa mục 2.3.3 (So sánh và khoảng trống nghiên cứu quốc tế) vào diện chỉnh sửa, dù về lý thuyết có thể mở rộng Bảng 2.6 để gộp cả nghiên cứu trong nước — việc này được cân nhắc nhưng quyết định không thực hiện vì mục 2.3.2 (sau khi cập nhật) đã tự có đủ bảng so sánh và đoạn khoảng trống nghiên cứu riêng, gộp thêm vào 2.3.3 sẽ là trùng lặp nội dung không cần thiết.

## 5. Đánh giá chất lượng sau khi cập nhật

**Trước cập nhật:** Mục 2.3.2 chỉ có 2 đoạn ngắn (~150 từ), nêu duy nhất kết luận "chưa tìm thấy" mà không có bất kỳ dẫn chứng khảo sát cụ thể nào — về mặt học thuật, đây là một khẳng định thiếu minh chứng (unsubstantiated claim), dễ bị giảng viên hỏi "đã tìm ở đâu, tìm như thế nào".

**Sau cập nhật:** Mục 2.3.2 hiện có đầy đủ minh chứng cụ thể cho khẳng định khoảng trống nghiên cứu (5 tài liệu thật, 2 trích dẫn chính thức đủ chuẩn APA, 3 tài liệu được ghi nhận thận trọng mà không gán số), một bảng so sánh định lượng theo đúng 4 tiêu chí kỹ thuật đã dùng xuyên suốt chương, và một đoạn phân tích kế thừa/khác biệt/cải tiến nối kết trực tiếp với mục 2.2.11 đã có — khẳng định khoảng trống nghiên cứu giờ đây có căn cứ, không còn là một tuyên bố suông.

**Về tính nhất quán:** Văn phong, cách đặt tên bảng (Bảng 2.7 nối tiếp Bảng 2.6), và cách trích dẫn ([15], [16] nối tiếp [14]) đều khớp với phần còn lại của Chương 2 — không tạo ra một "đảo phong cách" giữa các mục.

**Cập nhật xác minh tác giả [15] (06/07/2026):** Đã thực hiện thêm một vòng tra cứu chéo để xác nhận tên tác giả trước khi nộp. Kết quả:

- Nhiều truy vấn độc lập (khác từ khóa, khác thời điểm) đều hội tụ về cùng một cách viết tên tác giả: **Sơn, P. V. H.** và **Khởi, N. V. T.** — không có kết quả nào mâu thuẫn.
- Tìm được địa chỉ email liên hệ tác giả gắn với bài báo: `pvhson@hcmut.edu.vn` (tên miền Trường Đại học Bách Khoa – Đại học Quốc gia TP.HCM). Tiền tố email "pvhson" khớp trực tiếp với initials "P. V. H. Sơn", củng cố độc lập cho tên và đơn vị công tác của tác giả thứ nhất.
- **Chưa đạt được xác minh ở mức cao nhất** (đọc trực tiếp trang bìa/thông tin tác giả của bản PDF gốc), do ResearchGate tiếp tục chặn truy cập toàn văn qua công cụ tự động (HTTP 403), và không tìm thấy bài báo này trong kho lưu trữ trực tuyến của tạp chí `Tạp chí Khoa học Công nghệ Xây dựng` mà tôi tra cứu được (`stce.huce.edu.vn`) — có khả năng bài đăng trên một ấn phẩm cùng tên nhưng do đơn vị khác chủ quản (nhiều khả năng liên kết với Trường Đại học Bách Khoa TP.HCM/ĐHQG-HCM dựa theo địa chỉ email tác giả), chứ không phải tạp chí cùng tên của Trường Đại học Xây dựng Hà Nội.

**Khuyến nghị cuối cùng:** Tên tác giả dạng viết tắt "Sơn, P. V. H., & Khởi, N. V. T." hiện đang dùng trong danh mục tham khảo của `CHAPTER2.md` có độ tin cậy khá cao (hội tụ nhiều nguồn độc lập + bằng chứng email) và **có thể giữ nguyên**. Tuy nhiên, trước khi nộp bản cuối, bạn nên tự đăng nhập ResearchGate hoặc Google Scholar để xác nhận: (a) tên đầy đủ chính xác (không suy đoán thành "Phạm Vũ Hồng Sơn"/"Nguyễn Văn Tiến Khởi" nếu chưa đọc thấy trực tiếp — hai tên đầy đủ này từng xuất hiện trong một kết quả tìm kiếm nhưng KHÔNG được xác nhận qua nguồn sơ cấp, nên không được đưa vào citation), và (b) tên chính xác của đơn vị chủ quản tạp chí, vì có khả năng đây không phải tạp chí của Trường Đại học Xây dựng Hà Nội như tên gọi dễ gây nhầm lẫn.
