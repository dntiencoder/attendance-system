# CHAPTER2_PLAN.md — Đề cương chi tiết Chương 2: Tổng quan về Cơ sở lý thuyết

**Trạng thái:** Kế hoạch (đã cập nhật theo `CHAPTER2_PLAN_REVIEW_RESPONSE.md`) — CHƯA viết nội dung Chương 2. Tài liệu này là nền để duyệt trước khi viết từng mục theo đúng thứ tự 2.1 → 2.2 → 2.3.
**Phạm vi phân tích:** Toàn bộ source code `attendance_mobile/`, `attendance_admin/`, `PROJECT_OVERVIEW.md`, `ARCHITECTURE.md`, `FOLDER_STRUCTURE.md`, `CLAUDE.md`, `ROADMAP.md`, `REVIEW.md`, `pubspec.yaml` của cả 2 app, `firestore.rules`.
**Lịch sử cập nhật:** Bản gốc → phản hồi góp ý (bổ sung tổng quan chấm công điện tử, UML, Client-Server, mô hình dữ liệu NoSQL, tăng số nghiên cứu 2.3) → bản này.

---

## Mục lục tài liệu này

- [Phần A — Phân tích trước khi lập đề cương](#phần-a--phân-tích-trước-khi-lập-đề-cương)
  - [A.1 Toàn bộ công nghệ đang dùng trong dự án](#a1-toàn-bộ-công-nghệ-đang-dùng-trong-dự-án)
  - [A.2 Công nghệ/khái niệm đủ quan trọng để đưa vào Chương 2](#a2-công-nghệkhái-niệm-đủ-quan-trọng-để-đưa-vào-chương-2)
  - [A.3 Công nghệ KHÔNG nên đưa vào Chương 2](#a3-công-nghệ-không-nên-đưa-vào-chương-2)
  - [A.4 Đề xuất cấu trúc Chương 2 và lý do](#a4-đề-xuất-cấu-trúc-chương-2-và-lý-do)
  - [A.5 Đánh giá độ dài từng mục](#a5-đánh-giá-độ-dài-từng-mục)
  - [A.6 Liên kết giữa Chương 2 và Chương 3](#a6-liên-kết-giữa-chương-2-và-chương-3)
- [Phần B — Đề cương chi tiết từng mục](#phần-b--đề-cương-chi-tiết-từng-mục)
  - [2.1 Lược khảo tài liệu](#21-lược-khảo-tài-liệu)
  - [2.2 Cơ sở lý thuyết](#22-cơ-sở-lý-thuyết)
  - [2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan](#23-kết-quả-nghiên-cứu-trong-và-ngoài-nước-có-liên-quan)
- [Phần C — Danh mục Hình, Bảng, Công thức](#phần-c--danh-mục-hình-bảng-công-thức)
- [Phần D — Đánh giá kiến thức còn thiếu cần bổ sung](#phần-d--đánh-giá-kiến-thức-còn-thiếu-cần-bổ-sung)

---

## Phần A — Phân tích trước khi lập đề cương

### A.1 Toàn bộ công nghệ đang dùng trong dự án

Xác nhận trực tiếp từ `pubspec.yaml` của cả 2 app và source code (không suy đoán):

| Nhóm | Công nghệ/Package | Version | Dùng ở app | Xác nhận dùng thật trong code? |
|---|---|---|---|---|
| Ngôn ngữ & Framework | Flutter/Dart SDK | `^3.12.1` | Cả 2 | Có — toàn bộ codebase |
| Backend | Firebase (`firebase_core`) | `^3.6.0` (mobile) / `^4.6.0` (admin) | Cả 2 | Có — `main.dart` |
| Xác thực | `firebase_auth` | `^5.3.1` / `^6.5.0` | Cả 2 | Có — `AuthRepository` cả 2 app |
| Cơ sở dữ liệu | `cloud_firestore` | `^5.4.4` / `^6.1.1` | Cả 2 | Có — mọi `*Repository` |
| Lưu trữ file | `firebase_storage` | `^12.3.2` / `^13.4.2` | Cả 2 | **Khai báo nhưng KHÔNG thấy code nào gọi thật** — avatar dùng field `avatarUrl` dạng chuỗi URL ngoài, không upload qua Storage |
| Quản lý trạng thái | `flutter_riverpod` | `^2.5.1` | Cả 2 | Có — toàn bộ `*_provider.dart` |
| Điều hướng | `go_router` | `^14.3.0` | Cả 2 | Có — `app_router.dart` mỗi app |
| Định vị | `geolocator` | `^13.0.1` | Mobile | Có — `GpsService` |
| Quyền truy cập | `permission_handler` | `^11.3.1` | Mobile | Có, gián tiếp qua `geolocator` |
| Biểu đồ | `fl_chart` | `^0.69.0` | Admin | Có — `DashboardScreen` |
| Xuất báo cáo | `excel`, `pdf`, `printing` | `^4.0.3` / `^3.11.1` / `^5.13.1` | Admin | Có — `ExportService` |
| Định dạng | `intl` | `^0.19.0` | Cả 2 | Có — `DateHelper` |
| Khác | `uuid`, `google_fonts`, `cupertino_icons` | — | Tuỳ app | Có, nhưng thuần tiện ích/thẩm mỹ |
| Cơ chế bảo mật tầng dữ liệu | **Firestore Security Rules** | — | Backend chung | Có — `firestore.rules`, viết tay, không dùng template mặc định |
| Thuật toán tự viết | Haversine (tính khoảng cách GPS) | — | Mobile | Có — `core/utils/haversine.dart` |
| Thuật toán tự viết | Rotation ca làm việc (`getCurrentShift`) | — | Cả 2 (trùng lặp độc lập) | Có — `CompanySettingsModel`/`RotationCalculator` |
| Kiến trúc | Feature-first layered architecture (domain/data/presentation) | — | Cả 2 | Có — toàn bộ `lib/features/` |
| Kiến trúc | Repository Pattern (giản lược, không interface) | — | Cả 2 | Có — mọi `*Repository` |
| Mô hình hoá | UML (dùng ở tầng tài liệu/thiết kế, không phải code) | — | Chương 3 | Sẽ dùng để vẽ sơ đồ thiết kế hệ thống |

### A.2 Công nghệ/khái niệm đủ quan trọng để đưa vào Chương 2

Tiêu chí chọn: (1) định hình kiến trúc hệ thống, (2) có nền tảng lý thuyết học thuật thật sự, (3) gắn trực tiếp với bài toán chấm công GPS, (4) làm nền phương pháp luận cần thiết cho Chương 3.

1. **Tổng quan hệ thống chấm công điện tử** (bối cảnh bài toán, trước khi vào công nghệ cụ thể — *bổ sung theo góp ý*).
2. **UML** (ngôn ngữ mô hình hoá — nền phương pháp luận cho sơ đồ ở Chương 3 — *bổ sung theo góp ý*).
3. **Flutter** (nền tảng phát triển đa nền tảng).
4. **Kiến trúc phần mềm: Feature-first Layered Architecture & Repository Pattern.**
5. **Riverpod** (quản lý trạng thái).
6. **Kiến trúc Client–Server & Backend-as-a-Service: Firebase** (*mở rộng theo góp ý — thêm nền Client-Server tổng quát*).
7. **Firebase Authentication.**
8. **Mô hình dữ liệu NoSQL** (*tách riêng theo góp ý — lý thuyết chung, độc lập với Firestore cụ thể*).
9. **Cloud Firestore** (triển khai NoSQL dạng tài liệu cụ thể của dự án).
10. **Firestore Security Rules.**
11. **Định vị GPS & Geofencing (công thức Haversine).**
12. **Lý thuyết lập lịch ca làm việc xoay vòng (Rotating Workforce Scheduling)** — chỉ lý thuyết tổng quát, thuật toán cụ thể để dành Chương 3 (xem mục A.6).

### A.3 Công nghệ KHÔNG nên đưa vào Chương 2

| Công nghệ | Vì sao không đưa vào |
|---|---|
| `go_router` (như một mục lý thuyết riêng) | Không có "lý thuyết" độc lập đáng trình bày — chỉ nhắc ngắn trong phần liên hệ của mục Kiến trúc phần mềm. |
| `fl_chart` | Thuần công cụ hiển thị biểu đồ, không có nền tảng lý thuyết cần thiết. |
| `excel`, `pdf`, `printing` | Công cụ xuất file, thuộc tầng triển khai — phù hợp Chương 3 hơn. |
| `intl`, `uuid`, `google_fonts`, `cupertino_icons` | Tiện ích/thẩm mỹ, không ảnh hưởng kiến trúc/nghiệp vụ cốt lõi. |
| `firebase_storage` | **Không dùng thật trong code** — đưa vào sẽ vi phạm yêu cầu "liên hệ trực tiếp với project". |
| `permission_handler` | Phụ thuộc gián tiếp của `geolocator`, gộp vào phần liên hệ của mục GPS. |

### A.4 Đề xuất cấu trúc Chương 2 và lý do

- **2.1 Lược khảo tài liệu** — mô tả các NHÓM tài liệu đã tham khảo (phương pháp luận thu thập tài liệu), chưa đi vào nội dung lý thuyết cụ thể.
- **2.2 Cơ sở lý thuyết** — nội dung chính, **12 mục con** (2.2.1 → 2.2.12), sắp xếp theo trình tự: bối cảnh bài toán → phương pháp luận mô hình hoá → nền tảng phát triển → kiến trúc tổ chức code → quản lý trạng thái → nền tảng backend (Client-Server/BaaS) → xác thực → mô hình dữ liệu → cơ sở dữ liệu cụ thể → bảo mật dữ liệu → nghiệp vụ định vị → nghiệp vụ lập lịch ca. Thứ tự này đi từ **bài toán** → **phương pháp luận** → **hạ tầng** → **nghiệp vụ cốt lõi**.
- **2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan** — so sánh cụ thể với hệ thống/nghiên cứu đã tồn tại, kết thúc bằng khoảng trống nghiên cứu.

### A.5 Đánh giá độ dài từng mục

| Mục | Số trang ước tính | Ghi chú |
|---|---|---|
| 2.1 Lược khảo tài liệu | 2–3 trang | Không đổi |
| 2.2.1 Tổng quan hệ thống chấm công điện tử | 2–3 trang | **Mới** |
| 2.2.2 Ngôn ngữ mô hình hoá UML | 1.5–2 trang | **Mới** |
| 2.2.3 Flutter | 2–3 trang | Không đổi nội dung, đổi số thứ tự |
| 2.2.4 Kiến trúc phần mềm (Layered + Repository Pattern) | 3–4 trang | Không đổi nội dung |
| 2.2.5 Riverpod | 2–3 trang | Không đổi nội dung |
| 2.2.6 Kiến trúc Client–Server & BaaS: Firebase | 3 trang | **Mở rộng** (từ 2 trang, thêm phần Client-Server tổng quát) |
| 2.2.7 Firebase Authentication | 1.5–2 trang | Không đổi nội dung |
| 2.2.8 Mô hình dữ liệu NoSQL | 1.5–2 trang | **Mới** (tách từ mục Firestore cũ) |
| 2.2.9 Cloud Firestore | 2–2.5 trang | **Thu hẹp** (từ 3 trang, bớt phần lý thuyết NoSQL chung) |
| 2.2.10 Firestore Security Rules | 2.5–3 trang | Không đổi nội dung |
| 2.2.11 GPS & Geofencing (Haversine) | 3 trang | Không đổi nội dung |
| 2.2.12 Lập lịch ca làm việc xoay vòng | 2–3 trang | Không đổi nội dung |
| 2.3 Kết quả nghiên cứu liên quan (3 mục con) | 6–8 trang | **Tăng** (từ 5–7 trang, do tăng số nghiên cứu quốc tế) |
| **Tổng cộng** | **≈ 40–48 trang** | Tăng từ ~30–36 trang |

Nếu cần rút gọn, ưu tiên cắt: 2.2.1 và 2.2.2 xuống 1–1.5 trang mỗi mục (là 2 mục mới bổ sung, có thể viết súc tích hơn); gộp phần Client-Server tổng quát trong 2.2.6 xuống còn nửa trang thay vì 1 trang đầy đủ.

### A.6 Liên kết giữa Chương 2 và Chương 3

- **Chương 2 trình bày LÝ THUYẾT TỔNG QUÁT** của từng công nghệ/khái niệm.
- **Chương 3 trình bày THIẾT KẾ CỤ THỂ CỦA TÁC GIẢ** dựa trên nền lý thuyết đó.

| Chương 2 (lý thuyết chung) | Chương 3 (thiết kế cụ thể của dự án) |
|---|---|
| 2.2.2 UML — các loại biểu đồ và mục đích | Use case diagram (tác nhân Nhân viên/Quản trị), class diagram (Model/Repository), sequence diagram (luồng Check-in/Check-out) cụ thể của dự án |
| 2.2.4 Repository Pattern là gì, ưu/nhược điểm | Sơ đồ lớp cụ thể `AttendanceRepository`, `EmployeeRepository`... + lý do không dùng interface |
| 2.2.6 Client-Server & BaaS tổng quát | Sơ đồ triển khai cụ thể: 2 app Flutter ↔ 1 project Firebase `attendance-management-sy-34105` |
| 2.2.8 Mô hình dữ liệu NoSQL tổng quát | Thiết kế chi tiết schema 6 collection, mối quan hệ ngầm giữa chúng (ERD dạng NoSQL) |
| 2.2.10 Cơ chế đánh giá Firestore Rules (`get`/`list`, `allow`/`deny`) | Toàn văn `firestore.rules` của dự án, giải thích từng rule cụ thể |
| 2.2.11 Công thức Haversine, khái niệm Geofencing | Lưu đồ thuật toán Check-in/Check-out thực tế (`GpsService`, `AttendanceRepository`), ngưỡng bán kính cấu hình |
| 2.2.12 Lý thuyết tổng quát lập lịch ca xoay vòng, tính chất NP-hard | Thuật toán cụ thể `RotationCalculator.getCurrentShift()`, khái niệm **Business Date** tự thiết kế để xử lý ca đêm xuyên nửa đêm — đóng góp kỹ thuật riêng của đề tài |

→ Mục 2.2.12 ở Chương 2 **chỉ dừng ở lý thuyết lập lịch ca xoay vòng nói chung**, không trình bày thuật toán `Business Date`/`RotationCalculator` cụ thể — đúng vị trí thuộc Chương 3.

---

## Phần B — Đề cương chi tiết từng mục

### 2.1 Lược khảo tài liệu

**Độ dài:** 2–3 trang. **Không cần hình/bảng/công thức.**

1. Tài liệu chính thức từ nhà cung cấp công nghệ: Flutter Documentation, Firebase Documentation, Riverpod Documentation.
2. Bài báo khoa học quốc tế về hệ thống chấm công dựa trên định vị/geofencing (IEEE, Cambridge, ResearchGate) — dùng cho mục 2.2.11 và mục 2.3.
3. Bài báo/nghiên cứu về Firebase/Flutter trong phát triển ứng dụng di động (IEEE, ResearchGate, ScienceDirect) — dùng cho mục 2.2.3, 2.2.6, 2.2.8, 2.2.9.
4. Nghiên cứu học thuật về lập lịch ca làm việc xoay vòng (Springer, ResearchGate — lĩnh vực Operations Research) — dùng cho mục 2.2.12.
5. Giáo trình/sách kỹ thuật phần mềm về Design Pattern và UML — dùng cho mục 2.2.2, 2.2.4.
6. Khoá luận/đồ án trong nước có chủ đề liên quan — dùng đối chiếu bối cảnh trong nước ở mục 2.3. **Lưu ý (xem Phần D):** chưa tìm được khoá luận trong nước đúng chủ đề qua tìm kiếm web thông thường — cần tra cứu trực tiếp thư viện số của trường.

**Liên hệ với source code:** Không áp dụng trực tiếp (mục này mang tính phương pháp luận).

---

### 2.2 Cơ sở lý thuyết

#### 2.2.1 Tổng quan về hệ thống chấm công điện tử

- **Mục tiêu:** Đặt bài toán của đề tài trong bối cảnh chung của các phương pháp chấm công điện tử, trước khi đi vào công nghệ triển khai cụ thể.
- **Khái niệm:** Chấm công điện tử (electronic attendance/time-tracking) — hình thức ghi nhận thời gian làm việc của nhân viên bằng phương tiện điện tử thay cho phương pháp thủ công (sổ sách, chữ ký).
- **Nguyên lý/Phân loại:** Theo phương thức xác thực: (1) thẻ từ/RFID, (2) sinh trắc học (vân tay, khuôn mặt), (3) mã QR/vạch, (4) định vị GPS/geofencing.
- **Cấu trúc:** Mỗi phương pháp có 3 thành phần chung: thiết bị/cảm biến thu nhận, cơ chế xác thực danh tính, hệ thống lưu trữ/tổng hợp dữ liệu.
- **Cơ chế hoạt động:** Khái quát chu trình chung: nhân viên thực hiện hành động xác thực → hệ thống ghi nhận thời điểm + danh tính → dữ liệu được tổng hợp cho mục đích tính công/lương.
- **Ưu điểm/Nhược điểm (so sánh giữa các nhóm phương pháp):** Thẻ từ/RFID — chi phí thấp nhưng dễ mượn thẻ hộ; sinh trắc học — độ tin cậy cao nhưng chi phí thiết bị lớn; mã QR — triển khai nhanh nhưng dễ chụp ảnh chia sẻ; GPS/geofencing — không cần thiết bị phần cứng riêng, phù hợp nhân viên làm việc ngoài văn phòng cố định, nhưng phụ thuộc độ chính xác định vị và có thể bị giả mạo vị trí nếu không kiểm soát.
- **Lý do lựa chọn hướng GPS-based cho đề tài:** Nhân viên chấm công tại một địa điểm công ty cố định nhưng không có hạ tầng phần cứng chấm công (máy chấm công vân tay/thẻ từ) sẵn có; giải pháp di động dùng chính điện thoại nhân viên giảm chi phí đầu tư hạ tầng.
- **Liên hệ trực tiếp với project:** Hệ thống thuộc nhóm "chấm công di động dựa trên định vị" (mobile GPS-based attendance) — `attendance_mobile` dùng GPS thiết bị (`GpsService`) làm cơ chế xác thực vị trí duy nhất, không kết hợp sinh trắc học hay mã QR.
- **Hình minh hoạ:** *Hình 2.1 — Phân loại các phương pháp chấm công điện tử phổ biến.* Nguồn: tổng hợp từ các nghiên cứu khảo sát hệ thống chấm công (xem mục 2.3.1).
- **Nguồn tham khảo:** Cambridge Core — *"A comprehensive and systematic literature review on the employee attendance management systems based on cloud computing"*, Journal of Management & Organization; các bài IEEE về hệ thống chấm công (liệt kê đầy đủ ở mục 2.3.1).

#### 2.2.2 Ngôn ngữ mô hình hoá UML

- **Mục tiêu:** Giới thiệu công cụ mô hình hoá sẽ dùng để trình bày thiết kế hệ thống ở Chương 3.
- **Khái niệm:** UML (Unified Modeling Language) — ngôn ngữ mô hình hoá thống nhất, chuẩn hoá bởi Object Management Group (OMG), dùng để đặc tả, trực quan hoá và tài liệu hoá các thành phần của hệ thống phần mềm.
- **Nguyên lý:** Biểu diễn hệ thống qua nhiều góc nhìn (view) độc lập nhưng nhất quán — góc nhìn chức năng, góc nhìn cấu trúc, góc nhìn hành vi.
- **Cấu trúc:** Các loại biểu đồ chính — Use Case Diagram (chức năng theo tác nhân), Class Diagram (cấu trúc lớp/đối tượng), Sequence Diagram (trình tự tương tác theo thời gian), Activity Diagram (luồng xử lý nghiệp vụ).
- **Cơ chế hoạt động:** Mỗi loại biểu đồ dùng ký hiệu chuẩn hoá riêng (actor, use case, class box, lifeline, message...) để mô tả một khía cạnh cụ thể của hệ thống.
- **Ưu điểm:** Ngôn ngữ trực quan, được công nhận rộng rãi, hỗ trợ giao tiếp giữa các bên liên quan không chuyên sâu kỹ thuật.
- **Nhược điểm:** Có thể trở nên phức tạp nếu áp dụng đầy đủ mọi loại biểu đồ cho hệ thống quy mô nhỏ; không thay thế được đặc tả chi tiết ở mức code.
- **Lý do lựa chọn:** Là công cụ mô hình hoá tiêu chuẩn được giảng dạy và yêu cầu trong báo cáo phân tích thiết kế hệ thống.
- **Liên hệ trực tiếp với project:** Chương 3 của báo cáo sẽ dùng Use Case Diagram để mô tả 2 tác nhân (Nhân viên, Quản trị viên) và các chức năng tương ứng; Class Diagram để mô tả các Model/Repository thực tế (`AttendanceModel`, `AttendanceRepository`...); Sequence Diagram để mô tả luồng Check-in/Check-out.
- **Hình minh hoạ:** *Hình 2.2 — Các loại biểu đồ UML chính và mục đích sử dụng.* Nguồn: tài liệu chuẩn UML (OMG Specification hoặc giáo trình Phân tích thiết kế hệ thống).
- **Nguồn tham khảo:** Object Management Group — *UML Specification*; giáo trình Phân tích và Thiết kế Hệ thống hướng đối tượng (theo tài liệu bộ môn).

#### 2.2.3 Nền tảng phát triển ứng dụng đa nền tảng: Flutter

- **Mục tiêu:** Giải thích vì sao có thể xây dựng đồng thời ứng dụng di động (nhân viên) và ứng dụng web (quản trị) từ cùng một nền tảng.
- **Khái niệm:** Flutter là SDK phát triển giao diện đa nền tảng của Google, dùng ngôn ngữ Dart, biên dịch native (không qua WebView).
- **Nguyên lý:** Kiến trúc "everything is a widget", cơ chế render riêng (Skia/Impeller) không phụ thuộc thành phần UI gốc của hệ điều hành.
- **Cấu trúc:** Widget tree, Element tree, Render tree.
- **Cơ chế hoạt động:** Hot reload, build pipeline, biên dịch AOT cho production.
- **Ưu điểm:** Một codebase nhiều nền tảng, hiệu năng gần native, hệ sinh thái package phong phú (`pub.dev`).
- **Nhược điểm:** Kích thước ứng dụng lớn hơn native thuần, một số API nền tảng đặc thù cần plugin bên thứ ba.
- **Lý do lựa chọn cho dự án:** Một người phát triển, cần triển khai song song 2 ứng dụng (mobile + web) trong thời gian giới hạn của đợt thực tập.
- **Liên hệ trực tiếp với project:** `attendance_mobile` (Android/iOS) và `attendance_admin` (Web) là 2 project Flutter độc lập, cùng SDK `^3.12.1`, không dùng chung package (đánh đổi, dẫn sang phần kiến trúc 2.2.4).
- **Hình minh hoạ:** *Hình 2.3 — Kiến trúc tổng quan Flutter (Widget/Element/Render Tree).* Nguồn: Flutter Documentation — Flutter architectural overview.
- **Nguồn tham khảo:** Flutter Documentation (docs.flutter.dev); IEEE — *"Improving the Tourists Experiences: Application of Firebase and Flutter Technologies"*, 2021.

#### 2.2.4 Kiến trúc phần mềm: Mô hình phân lớp theo tính năng (Feature-first Layered Architecture) và Repository Pattern

- **Mục tiêu:** Giải thích cách tổ chức mã nguồn để tách biệt dữ liệu, nghiệp vụ và giao diện.
- **Khái niệm:** Kiến trúc phân lớp (layered architecture); Repository Pattern — lớp trung gian trừu tượng hoá nguồn dữ liệu.
- **Nguyên lý:** Separation of Concerns; mỗi lớp chỉ phụ thuộc lớp bên dưới.
- **Cấu trúc:** 3 lớp `domain/` (model thuần), `data/` (Repository), `presentation/` (Provider + UI).
- **Cơ chế hoạt động:** UI gọi Provider → Provider gọi Repository → Repository gọi Firestore SDK → dữ liệu trả ngược qua model → cập nhật UI.
- **Ưu điểm:** Dễ định vị code theo tính năng, giới hạn rõ nơi được phép gọi Firestore trực tiếp.
- **Nhược điểm:** Không có interface cho Repository nên khó kiểm thử độc lập; không có lớp use-case riêng.
- **Lý do lựa chọn:** Đơn giản, đủ dùng cho quy mô 2 ứng dụng độc lập, không cần độ phức tạp của Clean Architecture đầy đủ.
- **Liên hệ trực tiếp với project:** Cấu trúc thật `lib/features/attendance/{domain,data,presentation}` — `AttendanceRepository` (mobile) chứa `checkIn()`, `checkOut()`, `getTodayAttendance()`; `EmployeeRepository` (admin) chứa CRUD nhân viên. Hạn chế đã ghi nhận trong `ROADMAP.md`: không interface hoá Repository, là đánh đổi có chủ đích.
- **Hình minh hoạ:** *Hình 2.4 — Sơ đồ 3 lớp domain/data/presentation của một feature.* Nguồn: tự vẽ dựa trên `ARCHITECTURE.md`.
- **Bảng minh hoạ:** *Bảng 2.1 — Danh sách Repository thực tế theo từng feature, 2 ứng dụng.*
- **Nguồn tham khảo:** Fowler, M., *Patterns of Enterprise Application Architecture*, Addison-Wesley; Flutter Documentation — Architecting Flutter apps.

#### 2.2.5 Quản lý trạng thái ứng dụng: Riverpod

- **Mục tiêu:** Giải thích cách dữ liệu được chia sẻ và đồng bộ giữa các màn hình.
- **Khái niệm:** Riverpod — thư viện quản lý trạng thái dựa trên khái niệm Provider.
- **Nguyên lý:** Reactive programming — widget tự động rebuild khi provider thay đổi; không phụ thuộc `BuildContext`.
- **Cấu trúc:** `Provider`, `StateNotifierProvider`, `FutureProvider`, `StreamProvider`.
- **Cơ chế hoạt động:** `ConsumerWidget`/`ConsumerStatefulWidget` dùng `ref.watch()`/`ref.read()`.
- **Ưu điểm:** An toàn kiểu dữ liệu tại thời điểm biên dịch, dễ kiểm thử hơn `InheritedWidget` thuần.
- **Nhược điểm:** Đường cong học tập ban đầu, dễ rebuild thừa nếu không dùng `select` đúng cách.
- **Lý do lựa chọn:** Phù hợp quy mô vừa, không cần độ phức tạp của BLoC.
- **Liên hệ trực tiếp với project:** `StreamProvider` cho dữ liệu thời gian thực (`employeesStreamProvider`, `departmentsStreamProvider`); `StateNotifierProvider` cho luồng nghiệp vụ nhiều trạng thái (`AttendanceNotifier`, `HomeNotifier`, `AuthNotifier`).
- **Hình minh hoạ:** *Hình 2.5 — Luồng dữ liệu Provider → Consumer trong Riverpod.* Nguồn: Riverpod Documentation.
- **Nguồn tham khảo:** Riverpod Documentation (riverpod.dev); Flutter Documentation — State management approaches.

#### 2.2.6 Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase

- **Mục tiêu:** Giải thích mô hình giao tiếp giữa ứng dụng và nơi lưu trữ dữ liệu, vì sao dự án không cần xây dựng máy chủ backend riêng.
- **Khái niệm:** Client–Server — mô hình phân chia vai trò giữa bên yêu cầu dịch vụ (client) và bên cung cấp dịch vụ (server); Backend-as-a-Service (BaaS) — mô hình cung cấp sẵn các dịch vụ backend dưới dạng API.
- **Nguyên lý:** Mô hình Client-Server cổ điển (2 tầng, 3 tầng) yêu cầu bên phát triển tự triển khai và vận hành server; BaaS dịch chuyển trách nhiệm vận hành server sang nhà cung cấp nền tảng, trong khi client vẫn giữ vai trò gọi dịch vụ như mô hình Client-Server truyền thống — phân quyền dịch chuyển từ tầng server sang tầng cấu hình khai báo (Security Rules).
- **Cấu trúc:** Client (mobile/web) ↔ Firebase SDK ↔ Dịch vụ Firebase (Authentication, Firestore).
- **Cơ chế hoạt động:** Client gọi trực tiếp API của dịch vụ backend qua SDK, không qua tầng trung gian tự viết.
- **Ưu điểm:** Giảm thời gian phát triển, không cần vận hành server, có sẵn đồng bộ thời gian thực.
- **Nhược điểm:** Phụ thuộc nhà cung cấp (vendor lock-in), giới hạn tuỳ biến logic phía server (cần Cloud Functions cho logic phức tạp — dự án hiện chưa dùng).
- **Lý do lựa chọn:** Phù hợp quy mô đồ án/thực tập, một người phát triển, không có hạ tầng server sẵn có.
- **Liên hệ trực tiếp với project:** Project Firebase `attendance-management-sy-34105`, dùng chung bởi cả 2 app qua `firebase_options.dart` riêng từng app; dịch vụ thực sự dùng: `firebase_auth`, `cloud_firestore` (`firebase_storage` khai báo nhưng không dùng thật — xem mục A.3); không có server tự viết nào (xác nhận ở `PROJECT_OVERVIEW.md`).
- **Hình minh hoạ:** *Hình 2.6 — Mô hình Client-Server truyền thống và biến thể Backend-as-a-Service.* Nguồn: Firebase Documentation — Firebase overview.
- **Bảng minh hoạ:** *Bảng 2.2 — So sánh mô hình Client-Server truyền thống (tự viết backend) và BaaS (Firebase).*
- **Nguồn tham khảo:** Firebase Documentation (firebase.google.com/docs); ResearchGate — *"A Review on Firebase (Backend as A Service) for Mobile Application Development"*, 2022.

#### 2.2.7 Firebase Authentication

- **Mục tiêu:** Giải thích cơ chế xác thực người dùng và phân biệt vai trò (nhân viên/quản trị).
- **Khái niệm:** Dịch vụ xác thực dựa trên email/mật khẩu.
- **Nguyên lý:** Xác thực trả về token định danh (`uid`) duy nhất; phân quyền chi tiết không mặc định có sẵn.
- **Cấu trúc:** `FirebaseAuth` instance, `User` object, token phiên đăng nhập.
- **Cơ chế hoạt động:** `signInWithEmailAndPassword()` → trả `uid` → ứng dụng tự đọc thêm dữ liệu vai trò từ cơ sở dữ liệu.
- **Ưu điểm:** Tích hợp sẵn, không cần tự lưu trữ mật khẩu.
- **Nhược điểm:** Không có sẵn cơ chế phân quyền chi tiết (role-based) nếu không dùng thêm Custom Claims.
- **Lý do lựa chọn:** Đơn giản, đủ cho 2 vai trò cố định của hệ thống.
- **Liên hệ trực tiếp với project:** `AuthRepository.login()` (mobile, admin) đọc thêm `users/{uid}` để kiểm tra `role`/`isActive` sau khi xác thực thành công — không dùng Custom Claims (lý do ở 2.2.10).
- **Hình minh hoạ:** *Hình 2.7 — Luồng đăng nhập email/mật khẩu kết hợp kiểm tra vai trò.* Nguồn: tự vẽ dựa trên `AuthRepository`.
- **Nguồn tham khảo:** Firebase Documentation — Authenticate with Firebase using Password-Based Accounts.

#### 2.2.8 Mô hình dữ liệu NoSQL

- **Mục tiêu:** Giới thiệu lý thuyết tổng quát về cơ sở dữ liệu NoSQL trước khi trình bày Cloud Firestore như một triển khai cụ thể.
- **Khái niệm:** NoSQL (Not Only SQL) — nhóm cơ sở dữ liệu không dùng mô hình quan hệ truyền thống, không yêu cầu schema cố định.
- **Nguyên lý:** Đánh đổi theo định lý CAP (Consistency, Availability, Partition tolerance) — hầu hết hệ NoSQL ưu tiên Availability và Partition tolerance hơn Consistency tuyệt đối so với hệ quan hệ truyền thống.
- **Cấu trúc/Phân loại:** 4 nhóm chính — Key-Value (ví dụ Redis), Document-oriented (ví dụ MongoDB, Firestore), Column-family (ví dụ Cassandra), Graph (ví dụ Neo4j).
- **Cơ chế hoạt động:** Không có cấu trúc bảng/hàng cố định; dữ liệu tổ chức linh hoạt theo nhu cầu truy vấn thay vì chuẩn hoá (normalization) như SQL.
- **Ưu điểm:** Linh hoạt mở rộng theo chiều ngang, phù hợp dữ liệu thay đổi cấu trúc thường xuyên, hiệu năng đọc/ghi cao ở quy mô lớn.
- **Nhược điểm:** Không hỗ trợ JOIN như SQL, khó đảm bảo tính nhất quán chặt chẽ giữa nhiều bản ghi liên quan, dễ phát sinh dữ liệu trùng lặp nếu thiết kế không cẩn thận.
- **Lý do lựa chọn nhóm document-oriented cho dự án:** Dữ liệu nghiệp vụ (hồ sơ nhân viên, bản ghi chấm công) có cấu trúc bán ổn định, mỗi bản ghi tương đối độc lập — phù hợp mô hình tài liệu hơn là mô hình khoá-giá trị hay đồ thị.
- **Liên hệ trực tiếp với project:** Dự án chọn Cloud Firestore — một đại diện của nhóm NoSQL document-oriented (trình bày chi tiết ở mục 2.2.9).
- **Hình minh hoạ:** *Hình 2.8 — Phân loại 4 nhóm cơ sở dữ liệu NoSQL.* Nguồn: tổng hợp tài liệu học thuật về NoSQL.
- **Nguồn tham khảo:** ScienceDirect (Elsevier) — *"The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test"*; tài liệu học thuật tổng quan NoSQL (giáo trình Cơ sở dữ liệu nâng cao, nếu có trong chương trình đào tạo).

#### 2.2.9 Cơ sở dữ liệu tài liệu: Cloud Firestore

- **Mục tiêu:** Giải thích mô hình lưu trữ dữ liệu cụ thể của toàn bộ nghiệp vụ hệ thống.
- **Khái niệm:** Cloud Firestore — cơ sở dữ liệu NoSQL dạng tài liệu của Firebase, tổ chức theo Collection → Document → Field.
- **Nguyên lý:** Không có ràng buộc schema cứng; đồng bộ thời gian thực qua cơ chế lắng nghe (listener).
- **Cấu trúc:** Collection, Document (định danh bằng ID), Field (string, number, Timestamp, GeoPoint, Map, Array, Reference).
- **Cơ chế hoạt động:** Truy vấn theo field, cần composite index cho truy vấn nhiều điều kiện; ghi dữ liệu qua `set`/`update` (có tuỳ chọn `merge`).
- **Ưu điểm:** Tích hợp sẵn với Authentication/Security Rules, đồng bộ thời gian thực tức thời giữa các client.
- **Nhược điểm:** Chi phí tính theo số lượt đọc/ghi, cần thiết kế composite index thủ công cho truy vấn phức tạp.
- **Lý do lựa chọn:** Tích hợp liền mạch với Firebase Authentication và Security Rules đã chọn ở các mục trước, phù hợp dữ liệu bán cấu trúc của hệ thống chấm công.
- **Liên hệ trực tiếp với project:** 6 collection nghiệp vụ thực tế: `users`, `attendance` (docId `"<yyyy-MM-dd>_<uid>"`), `company_settings` (document đơn `"main"`), `departments`, `leave_requests`, `notifications`.
- **Hình minh hoạ:** *Hình 2.9 — So sánh mô hình dữ liệu quan hệ (SQL) và mô hình tài liệu (Firestore).* Nguồn: Firebase Documentation — Cloud Firestore Data model.
- **Bảng minh hoạ:** *Bảng 2.3 — Danh sách 6 collection thực tế, Document ID, vai trò đọc/ghi.*
- **Nguồn tham khảo:** Firebase Documentation — Cloud Firestore Data model.

#### 2.2.10 Cơ chế phân quyền khai báo: Firestore Security Rules

- **Mục tiêu:** Giải thích cách hệ thống kiểm soát ai được đọc/ghi dữ liệu nào khi không có backend riêng.
- **Khái niệm:** Security Rules — ngôn ngữ khai báo chạy trên hạ tầng Firebase, đánh giá độc lập với client.
- **Nguyên lý:** Mặc định từ chối (deny-by-default); mỗi request đánh giá qua biểu thức boolean dựa trên `request.auth`, `resource.data`, `request.resource.data`.
- **Cấu trúc:** `match /{collection}/{document}`, mỗi khối có `allow read/write/get/list/create/update/delete`.
- **Cơ chế hoạt động:** Phân biệt `get` (đọc 1 document) và `list` (đọc nhiều qua truy vấn) — `list` chỉ được chấp nhận nếu điều kiện "chứng minh" được qua cấu trúc truy vấn.
- **Ưu điểm:** Không cần backend riêng vẫn kiểm soát được truy cập ở tầng dữ liệu.
- **Nhược điểm:** Không xác thực được tính trung thực của dữ liệu nghiệp vụ do client tự tính rồi gửi lên; hành vi `resource == null` khi document chưa tồn tại dễ gây lỗi nếu không lường trước.
- **Lý do lựa chọn:** Bắt buộc phải có vì không dùng backend riêng.
- **Liên hệ trực tiếp với project:** `firestore.rules` thực tế — hàm `isAdmin()`, `isOwner()`; rule tách riêng `allow get`/`allow list` cho collection `attendance`.
- **Hình minh hoạ:** *Hình 2.10 — Sơ đồ luồng đánh giá một request qua Firestore Security Rules.* Nguồn: Firebase Documentation.
- **Bảng minh hoạ:** *Bảng 2.4 — Ma trận quyền get/list/create/update/delete theo collection và vai trò.*
- **Nguồn tham khảo:** Firebase Documentation — Firestore Security Rules structure & conditions.

#### 2.2.11 Định vị GPS và Geofencing

- **Mục tiêu:** Giải thích cách hệ thống xác định nhân viên có đang ở đúng vị trí công ty hay không.
- **Khái niệm:** Geofencing — xác định vị trí có nằm trong ranh giới địa lý ảo hay không; công thức Haversine — tính khoảng cách cung tròn lớn giữa 2 điểm trên mặt cầu.
- **Nguyên lý — Công thức Haversine:**

  ```
  a = sin²(Δφ/2) + cos(φ₁) · cos(φ₂) · sin²(Δλ/2)
  c = 2 · atan2(√a, √(1−a))
  d = R · c
  ```

  φ₁, φ₂: vĩ độ 2 điểm (radian); Δφ, Δλ: hiệu vĩ độ/kinh độ; R ≈ 6371 km; d: khoảng cách kết quả.
- **Cấu trúc/Cơ chế hoạt động:** Lấy toạ độ hiện tại → tính khoảng cách tới toạ độ công ty bằng Haversine → so sánh với bán kính cho phép → quyết định cho phép/từ chối chấm công.
- **Ưu điểm:** Không cần hạ tầng phần cứng bổ sung, đủ chính xác cho phạm vi vài chục–vài trăm mét.
- **Nhược điểm:** Độ chính xác phụ thuộc thiết bị/môi trường; có thể bị giả mạo bằng mock-location nếu không kiểm tra bổ sung; không xác thực được tại tầng server.
- **Lý do lựa chọn:** Đơn giản, không tốn chi phí hạ tầng, đủ chính xác cho bài toán chấm công phạm vi công ty.
- **Liên hệ trực tiếp với project:** `core/utils/haversine.dart`; `GpsService.getCurrentPosition()` kiểm tra `position.isMocked`; `AttendanceRepository.checkIn()/checkOut()` gọi các hàm này trước khi ghi nhận.
- **Hình minh hoạ:** *Hình 2.11 — Hình học công thức Haversine trên mặt cầu Trái Đất.* Nguồn: tài liệu toán học địa lý. *Hình 2.12 — Khái niệm Geofencing.* Nguồn: tự vẽ.
- **Nguồn tham khảo:** IEEE — *"Attendance Management System Using Geofencing Technology"*, 2024; IEEE — *"A GPS-based Face Attendance Register System using Android Applications stored in the Cloud"*, 2024.

#### 2.2.12 Lý thuyết lập lịch ca làm việc xoay vòng (Rotating Workforce Scheduling)

- **Mục tiêu:** Giải thích nền tảng lý thuyết của bài toán phân ca luân phiên.
- **Khái niệm:** Rotating Workforce Scheduling — bài toán phân bổ nhân viên vào các ca luân phiên theo chu kỳ.
- **Nguyên lý:** Bài toán phân ca nhân sự tổng quát thuộc lớp NP-hard (quy giản từ 3-SAT); hệ thống thực tế thường dùng chu kỳ cố định (fixed rotation) thay vì tối ưu hoá đầy đủ.
- **Cấu trúc:** Nhóm nhân viên, chu kỳ xoay ca, mốc thời gian gốc.
- **Cơ chế hoạt động (tổng quát):** Xác định số ngày trôi qua kể từ mốc gốc, chia theo độ dài chu kỳ để xác định "khối" hiện tại, suy ra nhóm nào đảm nhận ca nào.
- **Ưu điểm:** Chu kỳ cố định dễ hiểu, dễ dự đoán; triển khai đơn giản.
- **Nhược điểm:** Không tối ưu theo nhu cầu biến động; không tự xử lý ràng buộc phức tạp (nghỉ phép, thiếu nhân sự đột xuất).
- **Lý do lựa chọn (mức lý thuyết chung):** Phù hợp mô hình 2 nhóm ca đơn giản, quy mô nhân sự vừa và nhỏ.
- **Liên hệ trực tiếp với project (mức khái niệm — chi tiết thuật toán ở Chương 3):** Dự án áp dụng mô hình 2 nhóm (A/B) xoay ca ngày/đêm theo chu kỳ cố định (`rotationDays`, mặc định 14 ngày) từ mốc gốc (`rotationStartDate`).
- **Hình minh hoạ:** *Hình 2.13 — Ví dụ lịch xoay ca 2 nhóm theo chu kỳ cố định.* Nguồn: tự vẽ.
- **Bảng minh hoạ:** *Bảng 2.5 — Ví dụ phân ca 2 nhóm qua 4 chu kỳ liên tiếp.*
- **Nguồn tham khảo:** Springer — *"Task assignments with rotations and flexible shift starts..."*, Journal of Scheduling; ResearchGate — *"Efficient Generation of Rotating Workforce Schedules"*; ResearchGate — *"Rota: A Research Project on Algorithms for Workforce Scheduling and Shift Design Optimization"* (TU Wien).

---

### 2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan

**Độ dài:** 6–8 trang.

#### 2.3.1 Nghiên cứu quốc tế (9 nguồn)

1. IEEE — *"A GPS-based Face Attendance Register System using Android Applications stored in the Cloud"* (2024) — GPS + nhận diện khuôn mặt, phạm vi giáo dục.
2. IEEE — *"Attendance Management System Using Geofencing Technology"* (2024) — GPS + Geofencing, cải thiện tính di động.
3. IEEE — *"Improving the Tourists Experiences: Application of Firebase and Flutter Technologies"* (2021) — minh chứng Flutter + Firebase khả thi cho ứng dụng thực tế.
4. Springer — nghiên cứu lập lịch ca xoay vòng trong y tế/sản xuất.
5. Cambridge Core — *"A comprehensive and systematic literature review on the employee attendance management systems based on cloud computing"*, Journal of Management & Organization — tổng hợp nhiều nghiên cứu hệ thống chấm công dựa trên cloud.
6. ResearchGate — *"Mobile Based Student Attendance System Using Geo-Fencing With Timing And Face Recognition"* — góc nhìn giáo dục, đối trọng với bối cảnh doanh nghiệp của đề tài.
7. ResearchGate — *"Enhancing Employee Attendance Systems Through Integrated Monitoring And Automation"* — bối cảnh doanh nghiệp, gần với đề tài hơn nhóm giáo dục.
8. ScienceDirect (Elsevier) — *"The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test"* — dẫn chứng định lượng cho lựa chọn NoSQL/Firebase.
9. ResearchGate — *"Application of Firebase in Android App Development – A Study"* — tổng quan ứng dụng Firebase trong phát triển Android.

#### 2.3.2 Nghiên cứu trong nước

Ghi nhận trung thực: **chưa xác định được khoá luận/đồ án trong nước đúng phạm vi "chấm công GPS + xoay ca"** qua tìm kiếm web công khai. Hướng bổ sung cụ thể: tra cứu thư viện số của trường đang thực hiện đề tài; tham khảo các thư viện số công khai dạng `thuvienso.hcmute.edu.vn` (đã xác nhận có chuyên đề GPS, dù chưa đúng phạm vi chấm công) làm ví dụ loại nguồn cần tìm; các nền tảng tổng hợp luận văn trong nước (`luanvan.net.vn`, `123docz.net`) có thể tham khảo bối cảnh nhưng cần đánh giá cẩn trọng chất lượng học thuật trước khi trích dẫn chính thức.

#### 2.3.3 So sánh và khoảng trống nghiên cứu

- **Bảng 2.6 — So sánh dự án với các nghiên cứu/hệ thống đã khảo sát**, tiêu chí: phạm vi bài toán, công nghệ nền, có xử lý ca đêm xuyên nửa đêm hay không, có cơ chế phân quyền dữ liệu tầng backend hay không, có xử lý xoay ca hay không.
- **Khoảng trống nghiên cứu:** Phần lớn nghiên cứu GPS attendance khảo sát được tập trung vào bối cảnh giáo dục, không phải doanh nghiệp sản xuất có ca xoay vòng ngày/đêm; không nghiên cứu nào kết hợp trực tiếp geofencing với lập lịch ca xoay vòng nhiều nhóm trong cùng hệ thống.

**Liên hệ trực tiếp với project:** Toàn bộ mục 2.3 dẫn chiếu ngược lại đặc điểm cụ thể của hệ thống (2 nhóm A/B, ca ngày/đêm, docId `"<date>_<uid>"`, Firestore Security Rules) khi so sánh.

---

## Phần C — Danh mục Hình, Bảng, Công thức

### Danh mục Hình (13 hình)

| Hình | Tên | Vị trí chèn | Nguồn |
|---|---|---|---|
| 2.1 | Phân loại các phương pháp chấm công điện tử | Mục 2.2.1 | Tổng hợp từ nghiên cứu (mục 2.3.1) |
| 2.2 | Các loại biểu đồ UML chính và mục đích sử dụng | Mục 2.2.2 | OMG UML Specification |
| 2.3 | Kiến trúc tổng quan Flutter (Widget/Element/Render Tree) | Mục 2.2.3 | Flutter Documentation |
| 2.4 | Sơ đồ 3 lớp domain/data/presentation | Mục 2.2.4 | Tự vẽ (`ARCHITECTURE.md`) |
| 2.5 | Luồng dữ liệu Provider → Consumer (Riverpod) | Mục 2.2.5 | Riverpod Documentation |
| 2.6 | Mô hình Client-Server và biến thể Backend-as-a-Service | Mục 2.2.6 | Firebase Documentation |
| 2.7 | Luồng đăng nhập email/mật khẩu kết hợp kiểm tra vai trò | Mục 2.2.7 | Tự vẽ |
| 2.8 | Phân loại 4 nhóm cơ sở dữ liệu NoSQL | Mục 2.2.8 | Tổng hợp tài liệu học thuật |
| 2.9 | So sánh mô hình dữ liệu quan hệ (SQL) và tài liệu (Firestore) | Mục 2.2.9 | Firebase Documentation |
| 2.10 | Luồng đánh giá request qua Firestore Security Rules | Mục 2.2.10 | Firebase Documentation |
| 2.11 | Hình học công thức Haversine trên mặt cầu | Mục 2.2.11 | Tài liệu toán học địa lý |
| 2.12 | Khái niệm Geofencing (bán kính quanh 1 điểm mốc) | Mục 2.2.11 | Tự vẽ |
| 2.13 | Ví dụ lịch xoay ca 2 nhóm theo chu kỳ cố định | Mục 2.2.12 | Tự vẽ |

### Danh mục Bảng (6 bảng)

| Bảng | Tên | Vị trí chèn |
|---|---|---|
| 2.1 | Danh sách Repository thực tế theo từng feature, 2 ứng dụng | Mục 2.2.4 |
| 2.2 | So sánh Client-Server truyền thống và BaaS | Mục 2.2.6 |
| 2.3 | Danh sách 6 collection Firestore thực tế, Document ID, vai trò đọc/ghi | Mục 2.2.9 |
| 2.4 | Ma trận quyền get/list/create/update/delete theo collection và vai trò | Mục 2.2.10 |
| 2.5 | Ví dụ phân ca 2 nhóm qua 4 chu kỳ liên tiếp | Mục 2.2.12 |
| 2.6 | So sánh dự án với các nghiên cứu/hệ thống đã khảo sát | Mục 2.3.3 |

### Danh mục Công thức

| Công thức | Vị trí chèn |
|---|---|
| Công thức Haversine (tính khoảng cách 2 toạ độ GPS) | Mục 2.2.11 |

---

## Phần D — Đánh giá kiến thức còn thiếu cần bổ sung

1. **Nghiên cứu trong nước cụ thể:** Chưa xác định được khoá luận/đồ án tiếng Việt đúng phạm vi "chấm công GPS + xoay ca". Cần tra cứu trực tiếp thư viện số của trường đang thực hiện đề tài.
2. **Kiểm tra khả năng truy cập toàn văn:** Một số bài báo IEEE/Springer/ScienceDirect chỉ xác nhận tồn tại qua tóm tắt công khai — cần xác minh khả năng truy cập bản đầy đủ trước khi trích dẫn chi tiết số liệu.
3. **Độ sâu học thuật cho mục Geofencing:** Nguồn hiện tại chủ yếu là bài báo ứng dụng — nên bổ sung 1 nguồn thuần lý thuyết định vị/địa lý học (geodesy) cho công thức Haversine.
4. **Xác nhận thuật ngữ tiếng Việt chuẩn:** Thống nhất bản dịch ("Backend-as-a-Service", "Rotating Workforce Scheduling"...) theo quy ước của bộ môn/trường.
5. **Số liệu Bảng 2.6 (so sánh nghiên cứu):** Cần đọc kỹ nội dung đầy đủ các bài báo đã liệt kê để điền chính xác các cột so sánh.
6. **Quy ước ký hiệu UML:** Cần xác nhận chuẩn UML (2.x đầy đủ hay biến thể đơn giản hoá) theo đúng học phần Phân tích thiết kế hệ thống của trường trước khi vẽ sơ đồ ở Chương 3.

---

## Bước tiếp theo

Tài liệu này **chưa viết bất kỳ nội dung Chương 2 nào** — chỉ là đề cương kế hoạch, đã cập nhật theo góp ý. Chờ xác nhận trước khi bắt đầu viết, theo đúng thứ tự: **2.1 → 2.2 → 2.3**, không viết toàn bộ trong một lần.
