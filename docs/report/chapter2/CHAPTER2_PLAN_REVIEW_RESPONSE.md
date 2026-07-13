# Phản hồi góp ý & Cập nhật CHAPTER2_PLAN.md

**Trạng thái:** Phản hồi + cập nhật kế hoạch. **Chưa viết nội dung Chương 2.**
**Căn cứ đối chiếu:** `CHAPTER2_PLAN.md` (bản trước cập nhật), `ARCHITECTURE.md`, `PROJECT_OVERVIEW.md`, source code thực tế 2 app.

---

## Mục lục

1. [Phản hồi góp ý #1 — Bổ sung tổng quan hệ thống chấm công điện tử](#1-phản-hồi-góp-ý-1--bổ-sung-tổng-quan-hệ-thống-chấm-công-điện-tử)
2. [Phản hồi góp ý #2 — Bổ sung UML, Client–Server, mô hình dữ liệu NoSQL](#2-phản-hồi-góp-ý-2--bổ-sung-uml-clientserver-mô-hình-dữ-liệu-nosql)
3. [Phản hồi góp ý #3 — Tăng số lượng nghiên cứu ở mục 2.3](#3-phản-hồi-góp-ý-3--tăng-số-lượng-nghiên-cứu-ở-mục-23)
4. [Bảng tổng hợp](#4-bảng-tổng-hợp)
5. [Danh sách thay đổi sẽ thực hiện](#5-danh-sách-thay-đổi-sẽ-thực-hiện)
6. [Danh sách giữ nguyên](#6-danh-sách-giữ-nguyên)
7. [Đề cương Chương 2 sau khi cập nhật](#7-đề-cương-chương-2-sau-khi-cập-nhật)
8. [Đánh giá lại](#8-đánh-giá-lại)
9. [Kết luận](#9-kết-luận)

---

## 1. Phản hồi góp ý #1 — Bổ sung tổng quan hệ thống chấm công điện tử

> *"Chương 2.2 hiện quá thiên về công nghệ, nên bổ sung phần tổng quan hệ thống chấm công điện tử trước khi đi vào Flutter."*

**Quyết định: ĐỒNG Ý.**

**Lý do:** Bản kế hoạch trước bắt đầu ngay ở "Flutter là gì" mà chưa trả lời câu hỏi nền tảng hơn: "chấm công điện tử là gì, có những phương pháp nào, hệ thống này thuộc nhóm nào". Đây là lỗi cấu trúc thật — một Chương 2 đúng chuẩn học thuật cần đi từ **bài toán/lĩnh vực** (domain) trước khi vào **công cụ giải quyết bài toán** (technology). Thiếu bước này khiến phần Flutter/Firebase đọc như liệt kê công nghệ đã chọn sẵn, không cho thấy quá trình lập luận "vì sao chọn hướng GPS-based mobile".

**Đối chiếu:**
- *Source code:* Toàn bộ hệ thống (cả `attendance_mobile` lẫn `attendance_admin`) chỉ hiện thực **một** phương pháp chấm công (GPS + xác thực tài khoản) — nhưng báo cáo cần đặt phương pháp này trong bối cảnh các phương pháp khác (thẻ từ, vân tay, mã QR) để lý giải lựa chọn, không phải vì code có cài đặt các phương pháp đó.
- *Kiến trúc dự án:* Không ảnh hưởng — đây là bổ sung ở tầng trình bày lý thuyết, không đụng tới cấu trúc code.
- *Mục tiêu báo cáo thực tập:* Phù hợp — phần "tổng quan chấm công điện tử" là kiến thức nền độc lập với công nghệ cụ thể, đúng tinh thần "Cơ sở lý thuyết" thay vì "hướng dẫn dùng Flutter/Firebase".
- *Chương 3:* Tạo tiền đề tốt — Chương 3 khi trình bày "Phân tích yêu cầu hệ thống" có thể tham chiếu ngược lại đúng phần phân loại này để lý giải bài toán cụ thể.

**Hành động:** Thêm mục mới **2.2.1 — Tổng quan về hệ thống chấm công điện tử**, đặt trước toàn bộ các mục công nghệ hiện có. Nội dung dự kiến: khái niệm chấm công điện tử; phân loại theo phương thức xác thực (thẻ từ/RFID, vân tay/sinh trắc học, mã QR/vạch, định vị GPS); so sánh ưu-nhược điểm từng nhóm; xu hướng dịch chuyển sang giải pháp di động; kết luận định vị hệ thống của đề tài thuộc nhóm "chấm công di động dựa trên định vị (mobile GPS-based attendance)". Độ dài ước tính: 2–3 trang. **Ảnh hưởng:** toàn bộ 9 mục công nghệ cũ (2.2.1 → 2.2.9) dịch số xuống 1 bậc — chi tiết ở mục 7.

---

## 2. Phản hồi góp ý #2 — Bổ sung UML, Client–Server, mô hình dữ liệu NoSQL

> *"Nên bổ sung phần UML, Client–Server và mô hình dữ liệu NoSQL."*

Đây là 3 ý gộp chung, tôi tách riêng để phân tích chính xác.

### 2a. UML (Unified Modeling Language)

**Quyết định: ĐỒNG Ý.**

**Lý do:** Chương 3 (Phân tích & Thiết kế hệ thống) chắc chắn sẽ cần trình bày sơ đồ (use case, class diagram, sequence diagram) để mô tả thiết kế — nếu Chương 2 không đặt nền lý thuyết cho UML, các sơ đồ ở Chương 3 sẽ xuất hiện mà không có cơ sở phương pháp luận được giải thích trước, vi phạm đúng nguyên tắc "Chương 2 làm nền cho Chương 3" mà chính kế hoạch ban đầu đã đặt ra ở mục A.6.

**Đối chiếu:**
- *Source code:* Không có UML trong code (đúng bản chất — UML là công cụ mô hình hoá, không phải công nghệ triển khai), nhưng cấu trúc thật của dự án (feature-first, Repository, Provider) hoàn toàn mô tả được bằng class diagram — đây chính là nội dung sẽ dùng UML để vẽ ở Chương 3.
- *Kiến trúc dự án:* Không ảnh hưởng code, chỉ ảnh hưởng phần trình bày lý thuyết.
- *Mục tiêu báo cáo:* Phù hợp — UML là kiến thức nền bắt buộc của học phần Phân tích thiết kế hệ thống, được kỳ vọng xuất hiện ở Chương 2 của hầu hết báo cáo CNTT.
- *Chương 3:* Liên kết trực tiếp và cần thiết — không có mục này, Chương 3 dùng sơ đồ mà không có căn cứ lý thuyết được trích dẫn.

**Hành động:** Thêm mục mới **2.2.2 — Ngôn ngữ mô hình hoá UML**, đặt ngay sau mục tổng quan chấm công điện tử, trước các mục công nghệ. Nội dung dự kiến: khái niệm UML; các loại biểu đồ chính (use case, class, sequence, activity) và mục đích từng loại; vai trò UML trong quy trình phân tích thiết kế phần mềm. Độ dài ước tính: 1.5–2 trang. Không cần "liên hệ trực tiếp với project" bằng code (vì UML không phải công nghệ triển khai) — phần liên hệ sẽ là: "Chương 3 của báo cáo này sử dụng use case diagram để mô tả tác nhân Nhân viên/Quản trị viên, class diagram để mô tả các Model/Repository, sequence diagram để mô tả luồng Check-in/Check-out."

### 2b. Client–Server

**Quyết định: ĐỒNG Ý — nhưng tích hợp vào mục Firebase hiện có, không tách mục riêng.**

**Lý do:** Client–Server là nền tảng lý thuyết chung mà Backend-as-a-Service (mục 2.2.4 cũ) chính là một **biến thể cụ thể**. Tách thành 2 mục riêng biệt (Client-Server tổng quát + Firebase BaaS) sẽ tạo lặp ý — vì phần "ưu/nhược điểm", "cơ chế hoạt động" của Client-Server và BaaS có nội dung chồng lấn đáng kể (cả hai đều nói về việc client giao tiếp với server để lấy/ghi dữ liệu). Cách xử lý đúng học thuật hơn là trình bày Client-Server như **bối cảnh lý thuyết mở đầu**, rồi dẫn vào BaaS như một hướng triển khai cụ thể của mô hình đó — tránh lặp mà vẫn đủ ý.

**Đối chiếu:**
- *Source code:* Dự án không có server tự viết (`PROJECT_OVERVIEW.md` xác nhận rõ "Không có server backend tự viết") — đây chính xác là điểm cần Client-Server tổng quát làm nền để giải thích "vì sao vẫn có server (của Firebase) dù không tự viết code server".
- *Kiến trúc dự án:* Không ảnh hưởng cấu trúc code.
- *Mục tiêu báo cáo:* Phù hợp, tăng chiều sâu lý thuyết mà không phình to số mục.
- *Chương 3:* Không ảnh hưởng trực tiếp (Chương 3 sẽ mô tả kiến trúc triển khai cụ thể, không cần lặp lại lý thuyết Client-Server).

**Hành động:** Đổi tên và mở rộng mục cũ **2.2.4 (Firebase BaaS)** thành **"Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase"**. Thêm phần mở đầu ngắn (khoảng 1 trang) trình bày mô hình Client-Server tổng quát (2 tầng, 3 tầng) trước khi giới thiệu BaaS như một hướng phát triển hiện đại của mô hình đó. Độ dài mục này tăng từ 2 trang → khoảng 3 trang. **Không tạo mục ToC mới.**

### 2c. Mô hình dữ liệu NoSQL

**Quyết định: ĐỒNG Ý — tách thành mục riêng, độc lập với mục Cloud Firestore.**

**Lý do:** Bản kế hoạch trước gộp lý thuyết NoSQL chung vào ngay trong mục "Cloud Firestore" (2.2.6 cũ), khiến ranh giới giữa "lý thuyết NoSQL nói chung" và "Firestore là một triển khai cụ thể" bị mờ — vi phạm đúng nguyên tắc phân lớp lý thuyết/ứng dụng mà tôi tự đặt ra ở mục A.6 của kế hoạch gốc (lý thuyết chung ở Chương 2, cụ thể hoá ở phần sau). Tách riêng giúp trình bày rõ: NoSQL là một **họ** mô hình dữ liệu (key-value, document, column-family, graph), Firestore chỉ là **một đại diện** thuộc nhóm document-oriented.

**Đối chiếu:**
- *Source code:* Toàn bộ 6 collection (`users`, `attendance`, `company_settings`, `departments`, `leave_requests`, `notifications`) là ví dụ thật của mô hình document-oriented — tách mục giúp phần "liên hệ project" của mục NoSQL tổng quát và mục Firestore cụ thể không bị trùng nội dung.
- *Kiến trúc dự án:* Không ảnh hưởng.
- *Mục tiêu báo cáo:* Phù hợp, tăng độ chính xác học thuật (không đánh đồng "NoSQL" với "Firestore").
- *Chương 3:* Chương 3 khi thiết kế schema 6 collection sẽ tham chiếu lại đúng phân loại "document-oriented" đã lập luận ở đây.

**Hành động:** Thêm mục mới **"Mô hình dữ liệu NoSQL"**, đặt ngay trước mục Cloud Firestore, sau mục Firebase Authentication. Nội dung: khái niệm NoSQL; 4 nhóm chính (key-value, document, column-family, graph) kèm ví dụ mỗi nhóm; định lý CAP (Consistency/Availability/Partition tolerance) làm cơ sở lý giải đánh đổi của NoSQL so với SQL; kết luận Firestore thuộc nhóm document-oriented. Mục "Cloud Firestore" cũ được **thu hẹp phạm vi** — chỉ còn tập trung đặc tả riêng Firestore (không lặp lại lý thuyết NoSQL chung nữa). Độ dài: mục mới ~1.5–2 trang; mục Firestore cũ giảm từ 3 trang → khoảng 2–2.5 trang (vì phần lý thuyết chung đã chuyển sang mục mới).

---

## 3. Phản hồi góp ý #3 — Tăng số lượng nghiên cứu ở mục 2.3

> *"Tăng số lượng nghiên cứu trong và ngoài nước ở mục 2.3."*

**Quyết định: ĐỒNG Ý.**

**Lý do:** Bản kế hoạch trước chỉ có 3–4 nghiên cứu quốc tế và **0 nghiên cứu trong nước xác nhận được** — quá mỏng cho một mục có tên "Kết quả nghiên cứu trong và ngoài nước có liên quan". Tôi đã tìm kiếm bổ sung thật (không fabricate) và xác nhận thêm được các nguồn sau:

**Nghiên cứu quốc tế bổ sung (đã xác nhận tồn tại thật qua tìm kiếm):**

| # | Nguồn | Loại | Nội dung liên quan |
|---|---|---|---|
| 5 | *"A comprehensive and systematic literature review on the employee attendance management systems based on cloud computing"*, Journal of Management & Organization, **Cambridge Core** | Systematic Literature Review | Tổng hợp nhiều nghiên cứu về hệ thống chấm công dựa trên cloud — nguồn mạnh để dẫn nhập mục 2.3, vì bản thân nó đã là một review tổng hợp |
| 6 | *"Mobile Based Student Attendance System Using Geo-Fencing With Timing And Face Recognition"*, ResearchGate | Bài báo ứng dụng | Bổ sung góc nhìn giáo dục, đối trọng với hệ thống hiện tại (doanh nghiệp) |
| 7 | *"Enhancing Employee Attendance Systems Through Integrated Monitoring And Automation"*, ResearchGate | Bài báo ứng dụng | Bối cảnh doanh nghiệp, gần với đề tài hơn các nghiên cứu giáo dục |
| 8 | *"The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test"*, **ScienceDirect (Elsevier)** | Nghiên cứu định lượng | Nguồn Elsevier thật — dùng làm dẫn chứng định lượng cho lựa chọn NoSQL/Firebase ở mục 2.2.8/2.2.9 (mới), đồng thời liên hệ mục 2.3 |
| 9 | *"Application of Firebase in Android App Development – A Study"*, ResearchGate | Bài báo khảo sát | Bổ sung góc nhìn tổng quan ứng dụng Firebase trong phát triển Android |

**Nghiên cứu trong nước:** Vẫn **chưa xác nhận được** khoá luận đúng phạm vi "chấm công GPS + xoay ca" qua tìm kiếm web công khai — đây là kết quả thật, không phải tôi chưa cố gắng tìm. Tôi đề xuất xử lý minh bạch thay vì fabricate: nêu rõ trong mục 2.3.2 rằng đây là khoảng trống, kèm **hướng dẫn cụ thể để bạn tự bổ sung** — ví dụ thư viện số `thuvienso.hcmute.edu.vn` (xác nhận có tồn tại, chuyên đề tài GPS) là loại nguồn nên tra cứu, và quan trọng nhất: **thư viện số của chính trường bạn đang thực tập/bảo vệ** — nơi tôi không có quyền truy cập.

**Đối chiếu mục tiêu báo cáo:** Việc thừa nhận khoảng trống nghiên cứu trong nước, thay vì bịa một nguồn không kiểm chứng được, **là hành vi học thuật đúng đắn** — một hội đồng chấm sẽ đánh giá cao việc chỉ ra khoảng trống thật hơn là phát hiện một trích dẫn không tồn tại.

**Hành động:** Cập nhật mục 2.3.1 (quốc tế) từ 3-4 nguồn lên **9 nguồn**; giữ nguyên cấu trúc 2.3.2 (trong nước) nhưng viết cụ thể hơn hướng tra cứu tiếp theo thay vì chỉ nói "chưa tìm được". Độ dài mục 2.3 tăng từ 5–7 trang → khoảng **6–8 trang** (do bảng so sánh giờ có nhiều dòng hơn).

---

## 4. Bảng tổng hợp

| Góp ý | Đồng ý | Không đồng ý | Lý do | Hành động |
|---|---|---|---|---|
| #1 — Bổ sung tổng quan hệ thống chấm công điện tử | ✅ | | Thiếu bước domain-overview trước khi vào công nghệ — lỗi cấu trúc thật | Thêm mục mới 2.2.1, các mục sau dịch số |
| #2a — Bổ sung UML | ✅ | | Cần làm nền phương pháp luận cho sơ đồ ở Chương 3 | Thêm mục mới 2.2.2 |
| #2b — Bổ sung Client–Server | ✅ | | Đúng nhưng nên tích hợp vào mục Firebase để tránh lặp ý, không tách riêng | Mở rộng mục Firebase BaaS cũ, đổi tên |
| #2c — Bổ sung mô hình dữ liệu NoSQL | ✅ | | Cần tách khỏi mục Firestore để phân biệt lý thuyết chung / triển khai cụ thể | Thêm mục mới, thu hẹp phạm vi mục Firestore cũ |
| #3 — Tăng số lượng nghiên cứu 2.3 | ✅ | | Bản cũ quá mỏng (3-4 nguồn, 0 trong nước) | Bổ sung 5 nguồn quốc tế xác nhận thật; làm rõ hướng tra cứu trong nước |

Không có góp ý nào bị từ chối — cả 5 điểm đều có căn cứ học thuật vững và đối chiếu đúng với mục tiêu "làm nền cho Chương 3".

---

## 5. Danh sách thay đổi sẽ thực hiện

1. Thêm mục **2.2.1 — Tổng quan về hệ thống chấm công điện tử** (mới).
2. Thêm mục **2.2.2 — Ngôn ngữ mô hình hoá UML** (mới).
3. Đổi tên + mở rộng mục Firebase: **"Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase"**.
4. Thêm mục **"Mô hình dữ liệu NoSQL"** (mới), tách riêng khỏi mục Cloud Firestore.
5. Thu hẹp phạm vi mục Cloud Firestore (bỏ phần lý thuyết NoSQL chung đã chuyển sang mục 4).
6. Toàn bộ mục 2.2.x cũ dịch số xuống theo đúng vị trí mới (chi tiết mục 7).
7. Toàn bộ danh mục Hình/Bảng ở Phần C đánh số lại.
8. Bổ sung 5 nguồn nghiên cứu quốc tế thật vào mục 2.3.1.
9. Viết rõ hơn hướng tra cứu nghiên cứu trong nước ở mục 2.3.2 (không fabricate).
10. Cập nhật lại tổng độ dài ước tính Chương 2.

## 6. Danh sách giữ nguyên

- Cấu trúc 3 mục lớn 2.1/2.2/2.3 (đúng khung đã yêu cầu ban đầu).
- Toàn bộ nội dung chi tiết (Mục tiêu/Khái niệm/Nguyên lý/.../Liên hệ project) của 9 mục công nghệ đã lập ở bản kế hoạch trước — chỉ đổi **vị trí/số thứ tự**, không đổi nội dung.
- Nguyên tắc phân định "lý thuyết chung ở Chương 2, thiết kế cụ thể ở Chương 3" (mục A.6 bản gốc) — góp ý lần này càng củng cố nguyên tắc đó, không mâu thuẫn.
- Mục 2.1 (Lược khảo tài liệu) — không có góp ý nào nhắm vào mục này.
- Phần D (Đánh giá kiến thức còn thiếu) — vẫn giữ, bổ sung thêm 1 điểm mới (xem mục 7).

## 7. Đề cương Chương 2 sau khi cập nhật

```
CHƯƠNG 2. TỔNG QUAN VỀ CƠ SỞ LÝ THUYẾT

2.1 Lược khảo tài liệu                                              (2–3 trang, không đổi)

2.2 Cơ sở lý thuyết
  2.2.1  Tổng quan về hệ thống chấm công điện tử                    (MỚI, 2–3 trang)
  2.2.2  Ngôn ngữ mô hình hoá UML                                   (MỚI, 1.5–2 trang)
  2.2.3  Nền tảng phát triển đa nền tảng: Flutter                   (cũ 2.2.1, không đổi nội dung, 2–3 trang)
  2.2.4  Kiến trúc phần mềm: Layered Architecture & Repository Pattern (cũ 2.2.2, 3–4 trang)
  2.2.5  Quản lý trạng thái ứng dụng: Riverpod                      (cũ 2.2.3, 2–3 trang)
  2.2.6  Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase
                                                                     (cũ 2.2.4, MỞ RỘNG, 2 → 3 trang)
  2.2.7  Firebase Authentication                                   (cũ 2.2.5, 1.5–2 trang)
  2.2.8  Mô hình dữ liệu NoSQL                                      (MỚI — tách từ cũ 2.2.6, 1.5–2 trang)
  2.2.9  Cơ sở dữ liệu tài liệu: Cloud Firestore                    (cũ 2.2.6, THU HẸP, 3 → 2–2.5 trang)
  2.2.10 Firestore Security Rules                                  (cũ 2.2.7, 2.5–3 trang)
  2.2.11 Định vị GPS và Geofencing                                  (cũ 2.2.8, 3 trang)
  2.2.12 Lý thuyết lập lịch ca làm việc xoay vòng                   (cũ 2.2.9, 2–3 trang)

2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan
  2.3.1  Nghiên cứu quốc tế (9 nguồn, TĂNG từ 3–4)                  (~4–5 trang)
  2.3.2  Nghiên cứu trong nước (khoảng trống + hướng tra cứu cụ thể) (~1 trang)
  2.3.3  So sánh và khoảng trống nghiên cứu                         (~1–2 trang)
                                                                     Tổng 2.3: 6–8 trang (tăng từ 5–7)

TỔNG CHƯƠNG 2 ƯỚC TÍNH: ~40–48 trang (tăng từ ~30–36 trang)
```

**Danh mục Hình cập nhật (13 hình, tăng từ 10):** thêm Hình 2.1 (phân loại phương pháp chấm công điện tử — mục 2.2.1), Hình 2.2 (các loại biểu đồ UML — mục 2.2.2), Hình mới (phân loại 4 nhóm NoSQL — mục 2.2.8); toàn bộ hình cũ dịch số theo đúng vị trí mục mới.

**Danh mục Bảng cập nhật (6 bảng, tăng từ 5):** thêm 1 bảng so sánh Client-Server truyền thống và BaaS (mục 2.2.6).

**Phần D (kiến thức còn thiếu) bổ sung thêm:** cần xác nhận quy ước ký hiệu UML theo đúng chuẩn được dạy tại học phần Phân tích thiết kế hệ thống của trường (một số trường dùng UML 2.x chuẩn OMG, một số dùng biến thể đơn giản hoá) trước khi vẽ sơ đồ ở Chương 3.

---

## 8. Đánh giá lại

- **Tính học thuật:** Tăng rõ rệt — bổ sung UML và Client-Server lấp đúng 2 khoảng trống lý thuyết nền tảng mà bản trước thiếu; tách bạch NoSQL/Firestore tăng độ chính xác khái niệm.
- **Tính liên kết với source code:** Không suy giảm — mọi mục mới đều có phần liên hệ project cụ thể (trừ UML, vốn đúng bản chất là công cụ mô hình hoá, phần liên hệ của nó là dẫn hướng sang Chương 3, không phải dẫn tới 1 dòng code).
- **Tính phù hợp với báo cáo thực tập:** Phù hợp — độ dài tăng nhưng vẫn nằm trong biên độ hợp lý của Chương 2 một báo cáo/khoá luận CNTT (thường 25–45 trang); nếu cần rút gọn, ưu tiên cắt mục 2.2.1 và 2.2.2 xuống còn 1–1.5 trang mỗi mục.
- **Khả năng làm nền cho Chương 3:** Tăng đáng kể — trước đây Chương 3 sẽ phải tự đưa ra UML và mô hình Client-Server mà không có cơ sở đã trích dẫn trước; nay đã có đủ nền để Chương 3 chỉ cần "áp dụng" thay vì phải giải thích lại từ đầu.

---

## 9. Kết luận

Toàn bộ 3 góp ý (5 ý chi tiết) đều được chấp nhận và đã cập nhật vào cấu trúc mới ở mục 7. `CHAPTER2_PLAN.md` sẽ được cập nhật đồng bộ theo đúng cấu trúc này ngay sau tài liệu phản hồi này.

**Đề cương đã sẵn sàng để triển khai viết Chương 2.**

Vẫn chờ xác nhận của bạn trước khi bắt đầu viết — theo đúng thứ tự đã thống nhất: **2.1 → 2.2 → 2.3**, không viết toàn bộ trong một lần.
