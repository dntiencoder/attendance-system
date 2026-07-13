# 08 — Demo Summary

Tổng hợp cuối cùng, dựa trên dữ liệu thật (`01_DEMO_DATA.md`) và toàn bộ phân tích ở các file `02`-`07`. Đọc file này sau cùng, dùng như bảng tóm tắt trước khi bước vào phòng báo cáo.

## Mục lục

1. [Những điểm nên chủ động nhấn mạnh](#1-những-điểm-nên-chủ-động-nhấn-mạnh)
2. [Những điểm không cần chủ động nhắc](#2-những-điểm-không-cần-chủ-động-nhắc)
3. [Những điểm chỉ giải thích nếu được hỏi](#3-những-điểm-chỉ-giải-thích-nếu-được-hỏi)
4. [Kết luận](#4-kết-luận)

---

## 1. Những điểm nên chủ động nhấn mạnh

- **Cơ chế xoay ca + Business Date** — đây là phần kỹ thuật sâu nhất, có bằng chứng thực nghiệm rõ ràng trong dữ liệu thật (xem `01_DEMO_DATA.md` mục 4: đúng 1 lần đổi ca giữa 2 nhóm, đúng ngày dự kiến theo chu kỳ 14 ngày).
- **Firestore Security Rules** — đã được rà soát và vá kỹ (owner-or-admin, phân biệt `get`/`list`, xử lý `resource` null khi document chưa tồn tại) — là phần thể hiện rõ nhất tư duy kỹ thuật vượt mức trung bình một đồ án thực tập.
- **Câu chuyện sửa bug thật** — bug Business Date (check-in 0h18 hiển thị sai ca) là câu chuyện tốt để kể: phát hiện → phân tích nguyên nhân → thiết kế lại → có bằng chứng dữ liệu xác nhận đã sửa đúng.
- **Công cụ backup Firestore tự viết** — một điểm cộng phụ, cho thấy có tư duy vận hành/DevOps, không chỉ dừng ở mức code tính năng.

## 2. Những điểm không cần chủ động nhắc

- Việc chưa tách interface cho Repository, chưa tách use-case layer — đây là câu hỏi tầm phản biện đồ án tốt nghiệp, không phải trọng tâm 1 buổi báo cáo tiến độ.
- Các code smell nhỏ (so khớp lỗi bằng chuỗi, màu hardcode, nhãn hiển thị lệch giữa 2 app) — không ảnh hưởng demo, không cần nhắc tới.
- Bản ghi chấm công `2026-07-02_CDjUg...` (dữ liệu cũ từ trước khi sửa bug, cách công ty 46.6km) — không chủ động mở bản ghi này ra xem trong lúc demo Nhật ký chấm công; nếu vô tình lướt qua và bị hỏi, xem cách trả lời ở mục 3.

## 3. Những điểm chỉ giải thích nếu được hỏi

- **Vì sao `company_settings.radius` đang rất lớn (9999999999m)?** — Trả lời thẳng: đây là giá trị đang dùng để thuận tiện kiểm thử trong giai đoạn phát triển, sẽ đặt lại giá trị thực tế (ví dụ 500m) khi triển khai chính thức cho công ty. Không cần né tránh câu hỏi này.
- **Vì sao Nghỉ phép/Notification chưa hoàn thiện ở mobile?** — Trả lời: ưu tiên hoàn thiện lõi chấm công GPS trước, đây là quyết định phạm vi có chủ đích, đã có kế hoạch cho giai đoạn tiếp theo (xem `ROADMAP.md` Phase 2).
- **Vì sao 2 app dùng 2 model riêng, không dùng chung package?** — Xem câu trả lời chi tiết ở `07_DEMO_QA.md` Q28.
- **Vì sao không dùng Cloud Functions để xác thực GPS phía server?** — Xem `07_DEMO_QA.md` Q5, Q29.

---

## 4. Kết luận

**Nếu hôm nay mang dự án đi báo cáo tiến độ: nên đi.**

Dữ liệu thật hiện có (38 bản ghi chấm công trải dài hơn 1 tháng, đủ biến thể đúng giờ/đi muộn/về sớm/chưa checkout/ca ngày/ca đêm/2 nhóm rotation, cùng bằng chứng đổi ca đúng chu kỳ) cho thấy hệ thống **đã chạy thật, không phải dữ liệu dựng tạm cho buổi demo** — đây là lợi thế lớn nhất khi trình bày.

### Còn thiếu gì

1. `leave_requests` đang trống hoàn toàn — cần bổ sung 3 document mẫu (pending/approved/rejected) trước demo, xem `01_DEMO_DATA.md` mục 5.
2. Chưa quyết định giữ hay đổi `company_settings.radius` — cần quyết định trước, không bắt buộc phải đổi.
3. `departmentId` của tài khoản admin đang trỏ tới 1 phòng ban không tồn tại — nên sửa lại cho gọn.
4. Chưa có bằng chứng Check In/Check Out **mới nhất** (sau các lần sửa bug gần đây) từng chạy thật trên thiết bị — nên thử tay ít nhất 1 lần trước ngày báo cáo, không để lần đầu là ngay trước mặt giảng viên.

### Điều nên chuẩn bị ngay

Theo đúng thứ tự ưu tiên — xem chi tiết đầy đủ ở `05_DEMO_CHECKLIST.md`:

1. Seed 3 document `leave_requests` mẫu.
2. Kiểm thử tay Check In/Check Out trên đúng thiết bị sẽ dùng để demo.
3. Quyết định và (nếu cần) chỉnh lại `company_settings.radius`.
4. Sửa `departmentId` của tài khoản admin.
5. Đọc qua `03_DEMO_SCRIPT.md` và `07_DEMO_QA.md` ít nhất 1 lượt trước ngày báo cáo.

Không có việc nào trong danh sách trên là sửa code hay đổi kiến trúc — toàn bộ là chuẩn bị dữ liệu và kiểm thử tay, đúng phạm vi đã thống nhất cho giai đoạn báo cáo tiến độ này.
