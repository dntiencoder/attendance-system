_# CHƯƠNG 2. TỔNG QUAN VỀ CƠ SỞ LÝ THUYẾT

**Trạng thái:** Nội dung đầy đủ, hợp nhất từ ba mục 2.1, 2.2, 2.3 đã được duyệt theo `CHAPTER2_PLAN.md` (đã cập nhật theo `CHAPTER2_PLAN_REVIEW_RESPONSE.md`).

## Mục lục

- [2.1 Lược khảo tài liệu](#21-lược-khảo-tài-liệu)
- [2.2 Cơ sở lý thuyết](#22-cơ-sở-lý-thuyết)
  - [2.2.1 Tổng quan về hệ thống chấm công điện tử](#221-tổng-quan-về-hệ-thống-chấm-công-điện-tử)
  - [2.2.2 Ngôn ngữ mô hình hoá UML](#222-ngôn-ngữ-mô-hình-hoá-uml)
  - [2.2.3 Nền tảng phát triển ứng dụng đa nền tảng: Flutter](#223-nền-tảng-phát-triển-ứng-dụng-đa-nền-tảng-flutter)
  - [2.2.4 Kiến trúc phần mềm: Mô hình phân lớp theo tính năng và Repository Pattern](#224-kiến-trúc-phần-mềm-mô-hình-phân-lớp-theo-tính-năng-và-repository-pattern)
  - [2.2.5 Quản lý trạng thái ứng dụng: Riverpod](#225-quản-lý-trạng-thái-ứng-dụng-riverpod)
  - [2.2.6 Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase](#226-kiến-trúc-clientserver-và-nền-tảng-backend-as-a-service-firebase)
  - [2.2.7 Firebase Authentication](#227-firebase-authentication)
  - [2.2.8 Mô hình dữ liệu NoSQL](#228-mô-hình-dữ-liệu-nosql)
  - [2.2.9 Cơ sở dữ liệu tài liệu: Cloud Firestore](#229-cơ-sở-dữ-liệu-tài-liệu-cloud-firestore)
  - [2.2.10 Cơ chế phân quyền khai báo: Firestore Security Rules](#2210-cơ-chế-phân-quyền-khai-báo-firestore-security-rules)
  - [2.2.11 Định vị GPS và Geofencing](#2211-định-vị-gps-và-geofencing)
  - [2.2.12 Lý thuyết lập lịch ca làm việc xoay vòng](#2212-lý-thuyết-lập-lịch-ca-làm-việc-xoay-vòng)
- [2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan](#23-kết-quả-nghiên-cứu-trong-và-ngoài-nước-có-liên-quan)
  - [2.3.1 Nghiên cứu quốc tế](#231-nghiên-cứu-quốc-tế)
  - [2.3.2 Nghiên cứu trong nước](#232-nghiên-cứu-trong-nước)
  - [2.3.3 So sánh và khoảng trống nghiên cứu](#233-so-sánh-và-khoảng-trống-nghiên-cứu)
- [Tài liệu tham khảo](#tài-liệu-tham-khảo)

---

## 2.1 Lược khảo tài liệu

Việc xây dựng cơ sở lý thuyết cho một hệ thống chấm công dựa trên định vị đòi hỏi tham khảo tài liệu thuộc nhiều nhóm khác nhau, do đề tài kết hợp đồng thời một bài toán nghiệp vụ (chấm công, lập lịch ca làm việc) với một tổ hợp công nghệ cụ thể (Flutter, Firebase). Sáu nhóm tài liệu được lược khảo dưới đây phản ánh đúng cấu trúc đó, đi từ tài liệu kỹ thuật chính thức của nền tảng, đến các công bố khoa học quốc tế về nghiệp vụ và công nghệ liên quan, và cuối cùng là hiện trạng tài liệu trong nước.

Nhóm thứ nhất gồm tài liệu kỹ thuật chính thức do chính nhà phát triển nền tảng công bố: Flutter Documentation [1], Firebase Documentation [2], và Riverpod Documentation [3]. Đây là nhóm tài liệu có độ tin cậy cao nhất về mặt kỹ thuật do được duy trì trực tiếp bởi đơn vị phát triển nền tảng, tuy nhiên có đặc điểm là tập trung mô tả cách sử dụng công nghệ hơn là phân tích học thuật về nguyên lý — vai trò chính của nhóm tài liệu này trong chương là làm căn cứ mô tả chính xác cơ chế hoạt động của từng công nghệ ở mục 2.2.

Nhóm thứ hai gồm các công bố khoa học quốc tế về hệ thống chấm công dựa trên định vị và geofencing, là nhóm tài liệu gần nhất với bài toán nghiệp vụ cốt lõi của đề tài: hai công bố trên IEEE Xplore là "A GPS-based Face Attendance Register System using Android Applications stored in the Cloud" [4] và "Attendance Management System Using Geofencing Technology" [5]; một nghiên cứu tổng quan hệ thống trên Cambridge Core, Journal of Management & Organization [6]; cùng hai công bố trên ResearchGate là "Mobile Based Student Attendance System Using Geo-Fencing With Timing And Face Recognition" [7] và "Enhancing Employee Attendance Systems Through Integrated Monitoring And Automation" [8]. Nhóm tài liệu này được khảo sát chi tiết hơn, kèm so sánh trực tiếp với đề tài, ở mục 2.3.1.

Nhóm thứ ba gồm các nghiên cứu về việc ứng dụng Flutter và Firebase trong phát triển phần mềm thực tế, đóng vai trò minh chứng cho tính khả thi của tổ hợp công nghệ được lựa chọn: "Improving the Tourists Experiences: Application of Firebase and Flutter Technologies in Mobile Applications Development Process" (IEEE) [9], "The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test" (ScienceDirect) [10], và "Application of Firebase in Android App Development – A Study" (ResearchGate) [11]. Trong đó, công bố [10] có giá trị riêng biệt vì cung cấp bằng chứng định lượng, không chỉ mô tả định tính, cho việc so sánh cơ sở dữ liệu NoSQL với cơ sở dữ liệu quan hệ truyền thống.

Nhóm thứ tư gồm nghiên cứu về lập lịch ca làm việc xoay vòng, phục vụ trực tiếp cho việc phân tích cơ chế xoay ca hai nhóm của đề tài ở mục 2.2.12: "Task assignments with rotations and flexible shift starts to improve demand coverage and staff satisfaction in healthcare" (Journal of Scheduling, Springer) [12]. Đây là nhóm tài liệu duy nhất thuộc lĩnh vực nghiên cứu vận trù học (operations research) được đưa vào chương, nhằm cung cấp nền tảng lý thuyết về độ phức tạp của bài toán lập lịch ca, làm căn cứ giải thích vì sao đề tài lựa chọn một quy tắc xoay ca đơn giản thay vì một thuật toán tối ưu hoá đầy đủ.

Nhóm thứ năm gồm tài liệu phương pháp luận về kiến trúc phần mềm và mô hình hoá hệ thống: đặc tả Unified Modeling Language của Object Management Group [13], và tác phẩm kinh điển về kiến trúc ứng dụng doanh nghiệp của Fowler, *Patterns of Enterprise Application Architecture* [14]. Nhóm tài liệu này không mô tả một công nghệ cụ thể mà cung cấp khung khái niệm và ký hiệu chuẩn hoá được dùng để trình bày kiến trúc của đề tài, cả ở Chương 2 lẫn Chương 3.

Nhóm thứ sáu, khác với năm nhóm trên, không phải một tập hợp tài liệu được sử dụng mà là kết quả của một quá trình tìm kiếm chưa cho kết quả phù hợp: khoá luận và đồ án tốt nghiệp trong nước có phạm vi trùng khớp với đề tài. Qua tra cứu các công cụ tìm kiếm học thuật công khai, chưa xác định được công trình trong nước nào kết hợp trực tiếp chấm công định vị GPS với lập lịch ca xoay vòng. Khoảng trống này được trình bày chi tiết, kèm hướng xử lý cụ thể, ở mục 2.3.2, thay vì được lấp đầy bằng một nguồn không đúng phạm vi.

Sáu nhóm tài liệu trên được sử dụng theo phân công rõ ràng trong phần còn lại của chương: nhóm một và nhóm năm cung cấp nền tảng khái niệm cho mục 2.2; nhóm hai, ba và bốn cung cấp minh chứng ứng dụng thực tế xuyên suốt mục 2.2 và là đối tượng so sánh trực tiếp ở mục 2.3; nhóm sáu định hình phạm vi và giới hạn của việc đối chiếu trong nước ở mục 2.3.2.

---

## 2.2 Cơ sở lý thuyết

### 2.2.1 Tổng quan về hệ thống chấm công điện tử

Chấm công điện tử là hình thức ghi nhận thời gian làm việc của người lao động bằng phương tiện điện tử, thay thế cho phương pháp thủ công dựa trên sổ sách hoặc chữ ký tay. Mục tiêu chung của mọi hệ thống chấm công điện tử là xác định chính xác hai yếu tố tại thời điểm ghi nhận: danh tính người lao động và thời điểm thực hiện hành vi vào/ra ca làm việc.

Các hệ thống chấm công điện tử hiện có được phân loại theo phương thức xác thực danh tính sử dụng: chấm công bằng thẻ từ hoặc thẻ RFID, chấm công bằng đặc điểm sinh trắc học (vân tay, khuôn mặt), chấm công bằng mã QR hoặc mã vạch, và chấm công dựa trên định vị vệ tinh kết hợp giới hạn địa lý ảo (geofencing) [4], [5]. Mỗi phương pháp gồm ba thành phần chung: thiết bị hoặc cảm biến thu nhận dữ liệu xác thực, cơ chế đối chiếu danh tính, và hệ thống lưu trữ để tổng hợp dữ liệu phục vụ tính công/lương.

Bốn_ nhóm phương pháp trên có đặc điểm đánh đổi khác nhau. Chấm công bằng thẻ từ có chi phí triển khai thấp nhưng không ngăn được việc một người mang thẻ chấm công hộ người khác. Chấm công sinh trắc học có độ tin cậy xác thực danh tính cao nhất nhưng đòi hỏi đầu tư thiết bị chuyên dụng tại từng điểm chấm công. Chấm công bằng mã QR triển khai nhanh và chi phí thấp nhưng dễ bị vô hiệu hoá bằng cách chụp ảnh mã và chia sẻ. Chấm công dựa trên định vị không đòi hỏi thiết bị phần cứng chuyên dụng tại nơi làm việc — thiết bị di động của người lao động đảm nhiệm vai trò cảm biến — nhưng độ chính xác phụ thuộc vào chất lượng tín hiệu định vị của thiết bị và có thể bị vô hiệu hoá bằng phần mềm giả lập vị trí nếu không có cơ chế phát hiện bổ sung.

*(Hình 2.1 — Phân loại các phương pháp chấm công điện tử phổ biến, minh hoạ bốn nhóm phương pháp và đặc điểm đánh đổi tương ứng. Nguồn: tổng hợp từ [6].)*

**Liên hệ với đề tài:** Hệ thống của đề tài không có hạ tầng phần cứng chấm công chuyên dụng (máy chấm công vân tay, đầu đọc thẻ từ) tại địa điểm làm việc, trong khi mỗi người lao động đã sẵn có thiết bị di động cá nhân — điều kiện này phù hợp trực tiếp với nhóm phương pháp chấm công dựa trên định vị. Hệ thống được xây dựng thuộc đúng nhóm này: ứng dụng `attendance_mobile` sử dụng vị trí GPS của thiết bị (thông qua lớp `GpsService`) làm cơ chế xác thực vị trí duy nhất, không kết hợp thêm sinh trắc học hay mã QR. Việc xác định rõ vị trí của đề tài trong bức tranh phân loại này là căn cứ để lựa chọn các công nghệ trình bày ở các mục tiếp theo của chương.

### 2.2.2 Ngôn ngữ mô hình hoá UML

Unified Modeling Language (UML) [13] là ngôn ngữ mô hình hoá thống nhất do Object Management Group chuẩn hoá, dùng để đặc tả, trực quan hoá và tài liệu hoá các thành phần của một hệ thống phần mềm trước và trong quá trình xây dựng. UML không mô tả một công nghệ triển khai cụ thể mà cung cấp một tập ký hiệu quy ước để biểu diễn hệ thống dưới nhiều góc nhìn độc lập nhưng nhất quán với nhau: góc nhìn chức năng (hệ thống làm gì, cho ai), góc nhìn cấu trúc (hệ thống gồm những thành phần nào, quan hệ ra sao), và góc nhìn hành vi (các thành phần tương tác với nhau theo trình tự nào).

Bốn loại biểu đồ UML được sử dụng phổ biến nhất trong phân tích thiết kế hệ thống là: biểu đồ Use Case, mô tả chức năng hệ thống theo góc nhìn của từng tác nhân (actor); biểu đồ lớp (Class Diagram), mô tả cấu trúc tĩnh gồm các lớp, thuộc tính, phương thức và quan hệ giữa chúng; biểu đồ trình tự (Sequence Diagram), mô tả thứ tự trao đổi thông điệp giữa các đối tượng theo trục thời gian; và biểu đồ hoạt động (Activity Diagram), mô tả luồng xử lý của một quy trình nghiệp vụ. Mỗi loại biểu đồ dùng một tập ký hiệu chuẩn hoá riêng, cho phép biểu diễn chính xác một khía cạnh của hệ thống mà không cần lặp lại thông tin đã thể hiện ở biểu đồ khác.

*(Hình 2.2 — Các loại biểu đồ UML chính và mục đích sử dụng tương ứng. Nguồn: [13].)*

Ưu điểm chính của UML là tính trực quan và mức độ công nhận rộng rãi trong ngành phần mềm, cho phép giao tiếp hiệu quả giữa các bên liên quan không nhất thiết có chuyên môn lập trình sâu. Nhược điểm là việc áp dụng đầy đủ mọi loại biểu đồ UML cho một hệ thống có quy mô nhỏ có thể tạo ra khối lượng tài liệu không tương xứng với độ phức tạp thực tế của hệ thống, đồng thời bản thân UML không thay thế được đặc tả chi tiết ở mức mã nguồn.

**Liên hệ với đề tài:** UML được sử dụng làm công cụ trình bày thiết kế ở Chương 3 của báo cáo, không phải một công nghệ được cài đặt trong mã nguồn của hệ thống. Cụ thể: biểu đồ Use Case mô tả hai tác nhân của hệ thống — Nhân viên và Quản trị viên — cùng các chức năng tương ứng (chấm công, xem lịch sử, duyệt nghỉ phép, cấu hình hệ thống); biểu đồ lớp mô tả cấu trúc các Model và Repository thực tế của dự án (`AttendanceModel`, `AttendanceRepository`, `CompanySettingsModel`...); biểu đồ trình tự mô tả luồng tương tác cụ thể của thao tác Check-in/Check-out giữa ứng dụng di động, dịch vụ định vị và Cloud Firestore.

### 2.2.3 Nền tảng phát triển ứng dụng đa nền tảng: Flutter

Flutter [1] là bộ công cụ phát triển giao diện người dùng đa nền tảng do Google phát triển, sử dụng ngôn ngữ lập trình Dart, cho phép biên dịch mã nguồn thành mã máy gốc (native) cho nhiều nền tảng đích (Android, iOS, Web, Windows, macOS, Linux) từ một cơ sở mã nguồn duy nhất, không thông qua lớp trung gian WebView như một số giải pháp lai (hybrid) khác. Tính khả thi của việc dùng Flutter để phát triển ứng dụng thực tế, không chỉ ở mức thử nghiệm, đã được ghi nhận trong nghiên cứu [9].

Nguyên lý cốt lõi của Flutter là mô hình "mọi thành phần giao diện đều là widget" (everything is a widget) — mỗi phần tử hiển thị, từ một dòng văn bản đến toàn bộ màn hình, đều được biểu diễn dưới dạng một đối tượng widget trong một cây phân cấp (widget tree). Flutter không sử dụng thành phần giao diện gốc của hệ điều hành mà tự đảm nhiệm việc vẽ (rendering) thông qua engine đồ hoạ riêng (Skia, và Impeller ở các phiên bản gần đây), cho phép giao diện hiển thị nhất quán trên mọi nền tảng. Về cấu trúc, một ứng dụng Flutter gồm ba cây song song: cây widget (mô tả cấu hình giao diện ở dạng bất biến), cây phần tử (element tree, quản lý vòng đời), và cây render (render tree, đảm nhiệm việc đo đạc và vẽ thực tế). Cơ chế hot reload cho phép cập nhật giao diện gần như tức thời trong quá trình phát triển mà không cần khởi động lại toàn bộ ứng dụng, trong khi bản phát hành được biên dịch trước (ahead-of-time compilation) thành mã máy để tối ưu hiệu năng thực thi.

Ưu điểm của Flutter là khả năng dùng một cơ sở mã nguồn cho nhiều nền tảng, hiệu năng hiển thị gần với ứng dụng native do không phụ thuộc thành phần giao diện của hệ điều hành, và hệ sinh thái thư viện mở (pub.dev) tương đối phong phú. Nhược điểm là kích thước gói cài đặt thường lớn hơn ứng dụng native thuần do phải đóng gói kèm engine đồ hoạ riêng, và một số chức năng đặc thù của từng nền tảng (ví dụ dịch vụ chạy nền phức tạp) đòi hỏi phải tích hợp thêm plugin viết riêng cho từng nền tảng thay vì có sẵn trong Flutter SDK.

*(Hình 2.3 — Kiến trúc tổng quan Flutter, minh hoạ quan hệ giữa Widget Tree, Element Tree và Render Tree. Nguồn: [1].)*

**Liên hệ với đề tài:** Đề tài triển khai hai ứng dụng độc lập — `attendance_mobile` (dành cho nhân viên, chạy trên Android/iOS) và `attendance_admin` (dành cho quản trị viên, chạy trên nền Web) — cùng sử dụng Flutter SDK phiên bản `^3.12.1`. Việc lựa chọn Flutter cho phép một người phát triển duy nhất triển khai đồng thời hai ứng dụng có nền tảng đích khác nhau trong cùng một ngôn ngữ lập trình, phù hợp với điều kiện thời gian và nhân lực của một đợt thực tập. Đánh đổi đi kèm là hai ứng dụng không chia sẻ mã nguồn dùng chung (không có package Dart dùng chung giữa hai dự án) — mọi model dữ liệu, hàm tiện ích và giao diện được định nghĩa độc lập ở mỗi ứng dụng, được phân tích chi tiết hơn ở mục kiến trúc phần mềm tiếp theo.

### 2.2.4 Kiến trúc phần mềm: Mô hình phân lớp theo tính năng và Repository Pattern

Kiến trúc phân lớp (layered architecture) là cách tổ chức mã nguồn thành các lớp có trách nhiệm tách biệt, trong đó mỗi lớp chỉ được phép phụ thuộc vào lớp nằm bên dưới nó, không phụ thuộc ngược lại — nguyên lý này được gọi là phân tách mối quan tâm (separation of concerns). Repository Pattern là một mẫu thiết kế cụ thể hoá nguyên lý trên cho tầng truy xuất dữ liệu, được mô tả trong [14]: một lớp Repository đóng vai trò trung gian, trừu tượng hoá nguồn dữ liệu thực tế (cơ sở dữ liệu, dịch vụ mạng) khỏi phần còn lại của ứng dụng, sao cho tầng giao diện và tầng nghiệp vụ không cần biết dữ liệu đến từ đâu hay được lưu trữ như thế nào.

Kiến trúc được áp dụng trong đề tài tổ chức mã nguồn theo tính năng (feature-first), trong đó mỗi tính năng nghiệp vụ (ví dụ chấm công, xác thực, quản lý nhân viên) được đặt trong một thư mục riêng, bên trong chia thành ba lớp con: lớp miền (`domain/`) chứa các model dữ liệu thuần tuý; lớp dữ liệu (`data/`) chứa các lớp Repository, là nơi duy nhất được phép gọi trực tiếp đến dịch vụ Firebase; và lớp trình diễn (`presentation/`) chứa các Provider quản lý trạng thái cùng các màn hình giao diện. Luồng xử lý một yêu cầu điển hình đi theo chiều: giao diện gọi Provider, Provider gọi Repository, Repository gọi Firebase SDK, kết quả được ánh xạ qua model rồi trả ngược lên để cập nhật giao diện.

*(Hình 2.4 — Sơ đồ ba lớp domain/data/presentation của một tính năng trong kiến trúc phân lớp theo tính năng.)*

Ưu điểm của cách tổ chức này là dễ định vị mã nguồn liên quan đến một tính năng cụ thể, đồng thời giới hạn rõ ràng vị trí duy nhất trong toàn bộ ứng dụng được phép thao tác trực tiếp với Firestore. Nhược điểm là các lớp Repository trong đề tài không được định nghĩa thông qua interface trừu tượng, khiến việc kiểm thử độc lập (dùng đối tượng giả lập thay thế) khó thực hiện hơn so với kiến trúc có áp dụng nguyên lý đảo ngược phụ thuộc (dependency inversion) đầy đủ; đồng thời không có một lớp use-case tách biệt, khiến một phần logic nghiệp vụ (như tính toán ca làm việc) nằm trực tiếp trong lớp Repository hoặc trong model thay vì được cô lập hoàn toàn.

*(Bảng 2.1 — Danh sách các lớp Repository thực tế theo từng tính năng, đối chiếu giữa hai ứng dụng.)*

**Liên hệ với đề tài:** Cấu trúc `lib/features/<tên tính năng>/{domain, data, presentation}` là cấu trúc thư mục thực tế được dùng nhất quán ở cả hai ứng dụng. Cụ thể, lớp `AttendanceRepository` (ứng dụng di động) chứa các phương thức `checkIn()`, `checkOut()`, `getTodayAttendance()`, là nơi duy nhất trong ứng dụng thực hiện đọc/ghi collection `attendance` trên Firestore; lớp `EmployeeRepository` (ứng dụng quản trị) đảm nhiệm toàn bộ thao tác tạo/sửa/khoá/xoá tài khoản nhân viên. Việc không interface hoá Repository là một đánh đổi có chủ đích nhằm giữ độ phức tạp kiến trúc tương xứng với quy mô của đề tài, thay vì áp dụng đầy đủ Clean Architecture — đánh đổi này được ghi nhận rõ ràng trong tài liệu quản lý tiến độ nội bộ của dự án.

### 2.2.5 Quản lý trạng thái ứng dụng: Riverpod

Riverpod [3] là thư viện quản lý trạng thái cho Flutter, xây dựng trên khái niệm Provider — một đối tượng cung cấp dữ liệu có thể được nhiều widget khác nhau lắng nghe (observe) đồng thời mà không cần truyền dữ liệu qua nhiều tầng constructor trung gian. Nguyên lý vận hành của Riverpod thuộc mô hình lập trình phản ứng (reactive programming): khi dữ liệu bên trong một provider thay đổi, mọi widget đang lắng nghe provider đó sẽ tự động được xây dựng lại (rebuild) để phản ánh dữ liệu mới, mà không cần lập trình viên chủ động gọi lệnh cập nhật giao diện. Khác với thư viện `provider` là tiền thân của nó, Riverpod không phụ thuộc vào `BuildContext` để truy cập dữ liệu, giúp giảm một lớp lỗi runtime phổ biến liên quan đến việc truy cập provider sai vị trí trong cây widget.

Bốn loại provider chính được sử dụng gồm: `Provider`, cung cấp một giá trị hoặc đối tượng không đổi; `StateNotifierProvider`, quản lý một đối tượng trạng thái có thể thay đổi qua các phương thức xác định; `FutureProvider`, bao bọc một thao tác bất đồng bộ trả về kết quả một lần; và `StreamProvider`, bao bọc một luồng dữ liệu liên tục cập nhật theo thời gian. Widget tiêu thụ dữ liệu thông qua `ConsumerWidget` hoặc `ConsumerStatefulWidget`, dùng phương thức `ref.watch()` để lắng nghe thay đổi và `ref.read()` để đọc giá trị một lần mà không đăng ký lắng nghe.

*(Hình 2.5 — Luồng dữ liệu từ Provider đến Consumer trong mô hình Riverpod. Nguồn: [3].)*

Ưu điểm của Riverpod là tính an toàn kiểu dữ liệu được kiểm tra tại thời điểm biên dịch và khả năng kiểm thử dễ dàng hơn so với cách quản lý trạng thái dựa trên `InheritedWidget` thuần tuý. Nhược điểm là đường cong học tập ban đầu đối với người mới tiếp cận, và nguy cơ xây dựng lại giao diện không cần thiết (rebuild thừa) nếu không sử dụng đúng cơ chế `select` để giới hạn phạm vi lắng nghe.

**Liên hệ với đề tài:** Cả hai ứng dụng sử dụng Riverpod xuyên suốt tầng trình diễn. `StreamProvider` được dùng cho dữ liệu cần cập nhật thời gian thực trực tiếp từ Firestore, ví dụ `employeesStreamProvider` và `departmentsStreamProvider` ở ứng dụng quản trị. `StateNotifierProvider` được dùng cho các luồng nghiệp vụ có nhiều trạng thái con cần quản lý đồng thời (đang tải, lỗi, thành công), ví dụ `AttendanceNotifier` quản lý toàn bộ trạng thái của thao tác chấm công, `HomeNotifier` tổng hợp dữ liệu hiển thị trên màn hình chính, và `AuthNotifier` quản lý trạng thái đăng nhập/đăng xuất.

### 2.2.6 Kiến trúc Client–Server và nền tảng Backend-as-a-Service: Firebase

Mô hình Client–Server là mô hình kiến trúc phần mềm phân chia rõ vai trò giữa bên yêu cầu dịch vụ (client) và bên cung cấp, xử lý và lưu trữ dữ liệu (server). Trong mô hình truyền thống, đội ngũ phát triển ứng dụng đồng thời phải thiết kế, triển khai và vận hành phần server — bao gồm cả hạ tầng máy chủ, cơ sở dữ liệu và các quy tắc xử lý nghiệp vụ phía server.

Backend-as-a-Service (BaaS) là một hướng phát triển của mô hình Client–Server, trong đó nhà cung cấp nền tảng đã xây dựng sẵn và vận hành các dịch vụ backend phổ biến — xác thực người dùng, cơ sở dữ liệu, lưu trữ tệp — dưới dạng giao diện lập trình (API) để ứng dụng client gọi trực tiếp, không cần đội ngũ phát triển tự viết và vận hành server. Vai trò của client trong mô hình BaaS không thay đổi so với mô hình Client-Server truyền thống — vẫn là bên khởi tạo yêu cầu — nhưng trách nhiệm vận hành server được chuyển giao hoàn toàn cho nhà cung cấp nền tảng, đồng thời cơ chế phân quyền dữ liệu cũng dịch chuyển từ mã nguồn phía server sang một tầng cấu hình khai báo độc lập (trình bày chi tiết ở mục 2.2.10).

Firebase [2] là nền tảng BaaS của Google, cung cấp các dịch vụ Authentication (xác thực người dùng), Firestore (cơ sở dữ liệu thời gian thực) và nhiều dịch vụ khác dưới dạng SDK tích hợp trực tiếp vào ứng dụng client. Tính khả thi và hiệu quả của việc dùng Firebase trong phát triển ứng dụng thực tế được ghi nhận trong các nghiên cứu [9] và [11].

*(Hình 2.6 — Mô hình Client-Server truyền thống đối chiếu với biến thể Backend-as-a-Service.)*

*(Bảng 2.2 — So sánh mô hình Client-Server truyền thống, tự triển khai backend, với mô hình Backend-as-a-Service.)*

Ưu điểm của việc áp dụng BaaS là rút ngắn đáng kể thời gian phát triển do không cần xây dựng hạ tầng server, đồng thời có sẵn cơ chế đồng bộ dữ liệu thời gian thực giữa nhiều client. Nhược điểm là sự phụ thuộc vào một nhà cung cấp nền tảng duy nhất (vendor lock-in) và giới hạn khả năng tuỳ biến logic xử lý phức tạp phía server — các nghiệp vụ đòi hỏi tính toán phía server cần dịch vụ bổ sung (Cloud Functions), hiện chưa được áp dụng trong đề tài.

**Liên hệ với đề tài:** Toàn bộ hệ thống không có bất kỳ máy chủ backend tự viết nào — cả hai ứng dụng kết nối trực tiếp đến cùng một project Firebase (`attendance-management-sy-34105`) thông qua tệp cấu hình `firebase_options.dart` riêng của từng ứng dụng. Các dịch vụ Firebase thực sự được sử dụng trong mã nguồn là Authentication và Firestore; dịch vụ Storage tuy được khai báo trong tệp phụ thuộc của cả hai ứng dụng nhưng không có đoạn mã nào gọi đến trong thực tế — trường lưu ảnh đại diện của người dùng được lưu dưới dạng đường dẫn URL bên ngoài thay vì tệp tải lên qua Storage.

### 2.2.7 Firebase Authentication

Firebase Authentication [2] là dịch vụ xác thực người dùng của Firebase, hỗ trợ nhiều phương thức đăng nhập, trong đó đề tài chỉ sử dụng phương thức xác thực bằng địa chỉ email và mật khẩu. Sau khi xác thực thành công, dịch vụ trả về một mã định danh duy nhất (`uid`) gắn với tài khoản, cùng một token phiên đăng nhập được lưu trữ cục bộ trên thiết bị.

Firebase Authentication không cung cấp sẵn cơ chế phân quyền chi tiết theo vai trò người dùng — dịch vụ chỉ xác nhận danh tính, không xác nhận vai trò hay quyền hạn. Việc phân biệt vai trò trong đề tài (nhân viên hoặc quản trị viên) được thực hiện bằng cách đọc thêm một trường dữ liệu lưu trong Cloud Firestore ngay sau khi xác thực thành công, thay vì sử dụng cơ chế Custom Claims có sẵn của Firebase Authentication — lý do cho lựa chọn này được trình bày ở mục 2.2.10 khi phân tích cơ chế Firestore Security Rules.

*(Hình 2.7 — Luồng đăng nhập bằng email/mật khẩu kết hợp bước kiểm tra vai trò sau xác thực.)*

Ưu điểm của phương thức xác thực này là được tích hợp sẵn trong SDK, không đòi hỏi ứng dụng tự lưu trữ hay mã hoá mật khẩu người dùng. Nhược điểm là việc kiểm tra vai trò phải được lập trình thủ công ở tầng ứng dụng thay vì có sẵn ở tầng xác thực.

**Liên hệ với đề tài:** Hàm `login()` trong lớp `AuthRepository`, hiện diện độc lập ở cả hai ứng dụng, thực hiện `signInWithEmailAndPassword()` rồi ngay sau đó đọc document `users/{uid}` để kiểm tra hai trường `role` và `isActive`. Nếu tài khoản không thoả điều kiện vai trò tương ứng với ứng dụng đang đăng nhập (nhân viên đăng nhập ứng dụng quản trị, hoặc ngược lại) hoặc tài khoản đã bị khoá, ứng dụng chủ động gọi `signOut()` và hiển thị thông báo lỗi tương ứng, thay vì cho phép phiên đăng nhập tiếp tục tồn tại.

### 2.2.8 Mô hình dữ liệu NoSQL

NoSQL (Not Only SQL) là tên gọi chung cho nhóm hệ quản trị cơ sở dữ liệu không tuân theo mô hình quan hệ truyền thống (bảng, hàng, khoá ngoại, ràng buộc toàn vẹn tham chiếu), không yêu cầu một lược đồ (schema) cố định được định nghĩa trước khi ghi dữ liệu. Về mặt lý thuyết phân tán, phần lớn hệ NoSQL được thiết kế theo định lý CAP, phát biểu rằng một hệ thống lưu trữ phân tán chỉ có thể đảm bảo đồng thời tối đa hai trong ba thuộc tính: tính nhất quán (Consistency), tính sẵn sàng (Availability), và khả năng chịu phân vùng mạng (Partition tolerance). Đa số hệ NoSQL lựa chọn ưu tiên tính sẵn sàng và khả năng chịu phân vùng hơn tính nhất quán tuyệt đối, đổi lại khả năng mở rộng theo chiều ngang tốt hơn hệ quản trị cơ sở dữ liệu quan hệ. Bằng chứng thực nghiệm về sự khác biệt hiệu năng giữa cơ sở dữ liệu NoSQL của Firebase và cơ sở dữ liệu quan hệ MySQL được trình bày trong [10].

NoSQL được phân thành bốn nhóm theo mô hình tổ chức dữ liệu: cơ sở dữ liệu khoá-giá trị (key-value, ví dụ Redis), cơ sở dữ liệu hướng tài liệu (document-oriented, ví dụ MongoDB, Cloud Firestore), cơ sở dữ liệu họ cột (column-family, ví dụ Cassandra), và cơ sở dữ liệu đồ thị (graph, ví dụ Neo4j). Điểm chung của cả bốn nhóm là dữ liệu được tổ chức linh hoạt theo nhu cầu truy vấn thực tế thay vì được chuẩn hoá (normalization) triệt để như trong thiết kế cơ sở dữ liệu quan hệ.

*(Hình 2.8 — Phân loại bốn nhóm cơ sở dữ liệu NoSQL theo mô hình tổ chức dữ liệu.)*

Ưu điểm chung của NoSQL là khả năng mở rộng theo chiều ngang và khả năng thích ứng khi cấu trúc dữ liệu thay đổi thường xuyên. Nhược điểm là không hỗ trợ phép kết nối (JOIN) như SQL, đòi hỏi lập trình viên tự đảm bảo tính nhất quán giữa các bản ghi có liên quan về mặt nghiệp vụ nhưng không có ràng buộc tham chiếu ở tầng cơ sở dữ liệu.

**Liên hệ với đề tài:** Dữ liệu nghiệp vụ của hệ thống — hồ sơ nhân viên, bản ghi chấm công theo ngày, cấu hình công ty — có đặc điểm bán cấu trúc và mỗi bản ghi tương đối độc lập với nhau, phù hợp với mô hình hướng tài liệu hơn là mô hình khoá-giá trị (không đủ biểu đạt cho dữ liệu có nhiều trường) hoặc mô hình đồ thị (không cần biểu diễn quan hệ phức tạp giữa các thực thể). Đây là căn cứ cho việc lựa chọn Cloud Firestore — một đại diện cụ thể của nhóm NoSQL hướng tài liệu — được trình bày ở mục tiếp theo.

### 2.2.9 Cơ sở dữ liệu tài liệu: Cloud Firestore

Cloud Firestore [2] là dịch vụ cơ sở dữ liệu NoSQL hướng tài liệu của Firebase, tổ chức dữ liệu theo cấu trúc phân cấp Collection (tập hợp) chứa nhiều Document (tài liệu), mỗi Document chứa nhiều Field (trường dữ liệu). Không giống ràng buộc kiểu dữ liệu cố định theo cột của bảng quan hệ, mỗi trường trong một Document có thể mang một trong nhiều kiểu dữ liệu — chuỗi ký tự, số, giá trị thời gian (Timestamp), toạ độ địa lý (GeoPoint), tham chiếu đến Document khác (Reference), hoặc cấu trúc lồng nhau dạng Map và Array.

*(Hình 2.9 — So sánh mô hình dữ liệu quan hệ và mô hình dữ liệu tài liệu của Cloud Firestore.)*

Firestore không đòi hỏi khai báo lược đồ trước khi ghi dữ liệu, và cung cấp cơ chế đồng bộ thời gian thực thông qua việc client đăng ký lắng nghe (listener) trên một Document hoặc kết quả truy vấn — mọi thay đổi dữ liệu được đẩy đến các client đang lắng nghe gần như tức thời, không cần client chủ động truy vấn lại. Với các truy vấn kết hợp nhiều điều kiện lọc trên nhiều trường khác nhau, Firestore yêu cầu phải khai báo trước một chỉ mục kết hợp (composite index) tương ứng, nếu không truy vấn sẽ bị từ chối thực thi.

Ưu điểm của Firestore trong bối cảnh đề tài là khả năng tích hợp liền mạch với Firebase Authentication và Firestore Security Rules trong cùng một hệ sinh thái, cùng khả năng đồng bộ thời gian thực giữa nhiều thiết bị mà không cần xây dựng cơ chế polling hay WebSocket riêng. Nhược điểm là chi phí sử dụng được tính theo số lượt đọc/ghi thực tế, và việc thiết kế chỉ mục kết hợp cho các truy vấn phức tạp phải được thực hiện thủ công.

**Liên hệ với đề tài:** Toàn bộ nghiệp vụ của hệ thống được lưu trữ trong sáu collection: `users` (hồ sơ nhân viên và quản trị viên, định danh bằng chính `uid` của Firebase Authentication), `attendance` (bản ghi chấm công, định danh theo quy ước `"<năm-tháng-ngày>_<uid>"` để đảm bảo mỗi người chỉ có tối đa một bản ghi cho mỗi ngày làm việc), `company_settings` (một Document cấu hình duy nhất, định danh cố định là `"main"`), `departments`, `leave_requests`, và `notifications`.

*(Bảng 2.3 — Danh sách sáu collection thực tế của hệ thống, quy ước Document ID, và vai trò đọc/ghi của từng ứng dụng.)*

### 2.2.10 Cơ chế phân quyền khai báo: Firestore Security Rules

Firestore Security Rules [2] là một ngôn ngữ khai báo (declarative), độc lập với mã nguồn ứng dụng client, chạy trên hạ tầng của Firebase để đánh giá và quyết định cho phép hay từ chối từng yêu cầu đọc/ghi dữ liệu. Nguyên tắc vận hành mặc định là từ chối toàn bộ (deny-by-default): một thao tác chỉ được thực hiện nếu tồn tại một quy tắc khai báo tường minh cho phép thao tác đó, dựa trên các biến ngữ cảnh có sẵn tại thời điểm đánh giá — danh tính người gọi (`request.auth`), dữ liệu hiện có của tài liệu đang được truy cập (`resource.data`), và dữ liệu sắp được ghi (`request.resource.data`).

Về cấu trúc, quy tắc được khai báo theo từng đường dẫn `match /{collection}/{document}`, mỗi khối quy tắc quy định riêng biệt các hành vi `read`/`write`, hoặc chi tiết hơn theo `get`/`list`/`create`/`update`/`delete`. Một điểm cần lưu ý về cơ chế hoạt động là sự khác biệt giữa `get` (đọc một tài liệu xác định) và `list` (đọc nhiều tài liệu thông qua một truy vấn): đối với thao tác `list`, Firestore không đọc dữ liệu thực tế của từng kết quả trả về để quyết định quyền truy cập, mà yêu cầu điều kiện phân quyền phải được "chứng minh" chỉ dựa vào cấu trúc của bản thân truy vấn (các điều kiện lọc mà truy vấn đã khai báo).

*(Hình 2.10 — Sơ đồ luồng đánh giá một yêu cầu đọc/ghi thông qua Firestore Security Rules.)*

*(Bảng 2.4 — Ma trận quyền get/list/create/update/delete theo từng collection và vai trò người dùng.)*

Ưu điểm của cơ chế này là cho phép kiểm soát truy cập dữ liệu ở tầng cơ sở dữ liệu mà không cần xây dựng một tầng backend riêng để thực hiện việc kiểm tra quyền. Nhược điểm gồm hai điểm: cơ chế này không có khả năng xác thực tính trung thực của giá trị dữ liệu nghiệp vụ do client tự tính toán rồi gửi lên (ví dụ toạ độ định vị), vì bản chất quy tắc chỉ kiểm tra "ai được ghi", không kiểm tra "giá trị được ghi có đúng thực tế hay không"; đồng thời một số hành vi của ngôn ngữ này dễ gây lỗi nếu không được hiểu đúng — cụ thể, biến `resource` mang giá trị rỗng (null) khi tài liệu đang truy cập chưa tồn tại, và việc truy cập trường dữ liệu trên một `resource` rỗng sẽ khiến toàn bộ điều kiện bị đánh giá là từ chối, kể cả khi ý định của quy tắc là cho phép trong trường hợp đó.

**Liên hệ với đề tài:** Việc không lựa chọn xây dựng backend riêng (mục 2.2.6) đặt Firestore Security Rules vào vị trí lớp bảo vệ dữ liệu duy nhất giữa ứng dụng client và cơ sở dữ liệu. Tệp `firestore.rules` của hệ thống định nghĩa hai hàm điều kiện dùng chung, `isOwner()` (kiểm tra người gọi có phải chủ sở hữu tài liệu) và `isAdmin()` (kiểm tra vai trò quản trị dựa trên việc đọc lại chính document `users/{uid}` của người gọi, do hệ thống không sử dụng Custom Claims như đã nêu ở mục 2.2.7). Đối với collection `attendance`, quy tắc `get` và `list` được khai báo tách biệt nhau: quy tắc `get` kiểm tra quyền dựa trên cấu trúc của Document ID thay vì dữ liệu bên trong tài liệu, nhằm tránh chính xác tình huống `resource` rỗng khi kiểm tra một bản ghi chấm công chưa được tạo trong ngày.

### 2.2.11 Định vị GPS và Geofencing

Geofencing là kỹ thuật xác định một vị trí địa lý cụ thể có nằm trong một ranh giới ảo được định nghĩa trước hay không — ranh giới này thường được biểu diễn dưới dạng một hình tròn (xác định bởi toạ độ tâm và bán kính) hoặc một đa giác [5]. Trong bài toán chấm công, geofencing được dùng để xác định người lao động có đang hiện diện trong phạm vi cho phép quanh địa điểm làm việc hay không tại thời điểm thực hiện hành vi chấm công [4], [7].

Việc xác định một điểm có nằm trong ranh giới hình tròn hay không đòi hỏi tính được khoảng cách giữa hai toạ độ địa lý. Công thức Haversine là công thức lượng giác dùng để tính khoảng cách theo đường cung lớn (great-circle distance) giữa hai điểm trên một mặt cầu, dựa trên kinh độ và vĩ độ của chúng:

```
a = sin²(Δφ/2) + cos(φ₁) · cos(φ₂) · sin²(Δλ/2)
c = 2 · atan2(√a, √(1−a))
d = R · c
```

trong đó φ₁, φ₂ lần lượt là vĩ độ của điểm thứ nhất và điểm thứ hai (tính bằng radian), Δφ và Δλ lần lượt là hiệu vĩ độ và hiệu kinh độ giữa hai điểm, R là bán kính xấp xỉ của Trái Đất (khoảng 6371 km), và d là khoảng cách kết quả giữa hai điểm.

*(Hình 2.11 — Biểu diễn hình học của công thức Haversine trên mặt cầu Trái Đất.)*

*(Hình 2.12 — Khái niệm Geofencing dưới dạng vòng tròn bán kính quanh một điểm mốc cố định.)*

Cơ chế xác định chấm công hợp lệ theo geofencing gồm ba bước: lấy toạ độ hiện tại từ cảm biến định vị của thiết bị, tính khoảng cách từ toạ độ đó đến toạ độ cố định của địa điểm làm việc bằng công thức Haversine, rồi so sánh khoảng cách tính được với bán kính cho phép đã cấu hình để quyết định chấp nhận hay từ chối thao tác chấm công.

Ưu điểm của phương pháp này là không đòi hỏi đầu tư hạ tầng phần cứng bổ sung tại địa điểm làm việc (thiết bị phát tín hiệu định vị trong nhà, thiết bị Bluetooth beacon), và độ chính xác đạt được (thường trong khoảng vài mét đến vài chục mét với định vị vệ tinh tiêu chuẩn) đủ dùng cho bài toán xác định phạm vi công ty ở quy mô hàng chục đến hàng trăm mét. Nhược điểm là độ chính xác định vị phụ thuộc vào điều kiện thiết bị và môi trường xung quanh (tín hiệu suy giảm đáng kể trong nhà cao tầng hoặc không gian kín), và về bản chất giá trị toạ độ được gửi lên từ phía client, nên có thể bị làm giả bằng phần mềm giả lập vị trí nếu không có cơ chế phát hiện bổ sung ở tầng ứng dụng, đồng thời không có cơ chế xác thực độc lập ở tầng server.

**Liên hệ với đề tài:** Công thức Haversine được cài đặt thành hàm thuần tuý trong tệp `core/utils/haversine.dart` của ứng dụng di động, không gọi dịch vụ định vị bên ngoài nào. Lớp `GpsService` chịu trách nhiệm lấy toạ độ hiện tại từ thiết bị và bổ sung một bước kiểm tra không có trong công thức lý thuyết: kiểm tra cờ `isMocked` do hệ điều hành cung cấp để phát hiện toạ độ có đến từ một ứng dụng giả lập vị trí hay không, nhằm giảm thiểu rủi ro giả mạo đã nêu ở phần nhược điểm. Lớp `AttendanceRepository` gọi các hàm này ở cả hai thao tác Check-in và Check-out, so sánh khoảng cách tính được với trường `radius` được cấu hình trong document `company_settings`.

### 2.2.12 Lý thuyết lập lịch ca làm việc xoay vòng

Rotating Workforce Scheduling (lập lịch nhân sự theo ca xoay vòng) là bài toán phân bổ một tập hợp nhân viên vào các ca làm việc luân phiên theo chu kỳ thời gian, sao cho đảm bảo tính công bằng về khối lượng công việc giữa các nhân viên và tuân thủ các ràng buộc về thời gian nghỉ ngơi tối thiểu giữa hai ca liên tiếp [12]. Về mặt lý thuyết độ phức tạp tính toán, bài toán phân ca nhân sự ở dạng tổng quát — cho phép tối ưu hoá đồng thời nhiều mục tiêu và ràng buộc — đã được chứng minh thuộc lớp bài toán NP-hard, thông qua phép quy giản từ bài toán thoả mãn công thức Boolean dạng chuẩn tắc hội có ba biến mỗi mệnh đề (3-SAT).

Do độ phức tạp tính toán của dạng tổng quát, các hệ thống lập lịch ca xoay vòng trong thực tế thường không tìm cách giải bài toán tối ưu hoá đầy đủ mà áp dụng một quy tắc chu kỳ cố định (fixed rotation): nhân viên được chia thành các nhóm cố định, mỗi nhóm đảm nhiệm một loại ca trong một khoảng thời gian xác định trước, sau đó các nhóm hoán đổi ca cho nhau theo đúng chu kỳ đã định. Cơ chế xác định nhóm nào đảm nhiệm ca nào tại một thời điểm bất kỳ dựa trên việc tính số ngày đã trôi qua kể từ một mốc thời gian gốc, chia cho độ dài chu kỳ để xác định "khối" hiện tại đang ở, từ đó suy ra sự phân công ca tương ứng.

*(Hình 2.13 — Ví dụ minh hoạ lịch xoay ca giữa hai nhóm nhân viên theo chu kỳ cố định qua nhiều chu kỳ liên tiếp.)*

*(Bảng 2.5 — Ví dụ cụ thể phân công ca giữa hai nhóm qua bốn chu kỳ liên tiếp.)*

Ưu điểm của phương pháp chu kỳ cố định là tính dễ hiểu và khả năng dự đoán trước cho nhân viên, cùng độ đơn giản khi triển khai so với các phương pháp tối ưu hoá đầy đủ (quy hoạch nguyên, thuật toán heuristic chuyên biệt). Nhược điểm là phương pháp này không thích ứng với biến động nhu cầu nhân sự thực tế theo thời gian, và không tự xử lý được các ràng buộc phát sinh ngoài quy tắc chu kỳ (nhân viên xin nghỉ phép, thiếu hụt nhân sự đột xuất) — các ràng buộc này cần được xử lý bằng logic bổ sung nằm ngoài quy tắc xoay ca cố định.

**Liên hệ với đề tài:** Ở mức khái niệm, hệ thống áp dụng đúng mô hình chu kỳ cố định vừa trình bày: nhân viên được chia thành hai nhóm (gọi là nhóm A và nhóm B), luân phiên đảm nhiệm ca ngày và ca đêm theo một chu kỳ có độ dài cấu hình được (mặc định 14 ngày), tính từ một mốc ngày gốc cấu hình được. Thuật toán cụ thể xác định ca hiện tại của một nhóm tại một ngày làm việc xác định, cùng với khái niệm "ngày làm việc" (Business Date) được thiết kế riêng để xử lý đúng trường hợp ca đêm kéo dài qua nửa đêm sang ngày lịch kế tiếp, là đóng góp thiết kế cụ thể của đề tài và được trình bày đầy đủ ở Chương 3.

---

## 2.3 Kết quả nghiên cứu trong và ngoài nước có liên quan

### 2.3.1 Nghiên cứu quốc tế

Hệ thống chấm công dựa trên định vị đã được nghiên cứu dưới nhiều biến thể kỹ thuật khác nhau trong các công bố quốc tế gần đây. Một nhóm nghiên cứu tập trung vào việc kết hợp định vị vệ tinh với một lớp xác thực sinh trắc học bổ sung nhằm khắc phục điểm yếu cố hữu của chấm công thuần định vị — việc chỉ xác nhận được vị trí thiết bị chứ không xác nhận được danh tính người mang thiết bị đó. Nghiên cứu "A GPS-based Face Attendance Register System using Android Applications stored in the Cloud" [4] đề xuất kết hợp GPS với nhận diện khuôn mặt, lưu trữ trên nền tảng đám mây, áp dụng trong phạm vi cơ sở giáo dục. Theo hướng tiếp cận thuần geofencing hơn, không kết hợp sinh trắc học, nghiên cứu "Attendance Management System Using Geofencing Technology" [5] trình bày một hệ thống xác định phạm vi hợp lệ bằng ranh giới ảo quanh một điểm mốc, hướng đến cải thiện tính di động của quy trình chấm công so với thiết bị chấm công cố định.

Ở lớp tổng hợp tài liệu rộng hơn, nghiên cứu tổng quan hệ thống "A comprehensive and systematic literature review on the employee attendance management systems based on cloud computing" [6] khảo sát và phân loại một số lượng lớn công bố về hệ thống chấm công nền tảng đám mây, cho thấy xu hướng chung của lĩnh vực là dịch chuyển từ hạ tầng chấm công tại chỗ (on-premise) sang mô hình lưu trữ và xử lý trên đám mây — phù hợp với hướng tiếp cận Backend-as-a-Service đã trình bày ở mục 2.2.6. Bên cạnh nhóm nghiên cứu đặt trong bối cảnh giáo dục — cụ thể là "Mobile Based Student Attendance System Using Geo-Fencing With Timing And Face Recognition" [7], khảo sát việc điểm danh sinh viên bằng geofencing kết hợp khung giờ và nhận diện khuôn mặt — có một nhóm nghiên cứu đặt trực tiếp trong bối cảnh doanh nghiệp, gần với phạm vi của đề tài hơn: "Enhancing Employee Attendance Systems Through Integrated Monitoring And Automation" [8] phân tích việc tích hợp giám sát và tự động hoá vào quy trình chấm công nhân sự tại doanh nghiệp, không giới hạn ở môi trường giáo dục.

Song song với các nghiên cứu về nghiệp vụ chấm công, một nhóm công bố khác cung cấp bằng chứng thực nghiệm cho việc lựa chọn công nghệ nền tảng của đề tài. Nghiên cứu "The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test" [10] so sánh định lượng hiệu năng giữa một cơ sở dữ liệu NoSQL của Firebase và một hệ quản trị cơ sở dữ liệu quan hệ truyền thống, cung cấp căn cứ thực nghiệm — thay vì chỉ lý thuyết — cho phân tích đánh đổi NoSQL đối lập quan hệ đã trình bày ở mục 2.2.8. Ở khía cạnh nền tảng phát triển ứng dụng, nghiên cứu "Improving the Tourists Experiences: Application of Firebase and Flutter Technologies in Mobile Applications Development Process" [9] và "Application of Firebase in Android App Development – A Study" [11] đều ghi nhận Flutter kết hợp Firebase là một tổ hợp công nghệ khả thi và đã được kiểm chứng trong thực tế phát triển ứng dụng di động, không phải một lựa chọn công nghệ mang tính thử nghiệm.

Cuối cùng, ở khía cạnh lập lịch ca làm việc, nghiên cứu "Task assignments with rotations and flexible shift starts to improve demand coverage and staff satisfaction in healthcare" [12] khảo sát bài toán phân ca xoay vòng trong lĩnh vực y tế — một lĩnh vực có đặc điểm chung với bối cảnh sản xuất/vận hành liên tục là nhu cầu duy trì nhân sự trực ca ngày lẫn ca đêm không gián đoạn. Điểm đáng chú ý khi đối chiếu nghiên cứu này với đề tài là hướng tiếp cận khác biệt về mục tiêu: nghiên cứu [12] đặt trọng tâm vào bài toán tối ưu hoá phân công (tối đa hoá mức độ hài lòng của nhân sự và mức độ đáp ứng nhu cầu ca trực), thuộc lớp bài toán NP-hard đã nêu ở mục 2.2.12; trong khi đề tài không giải bài toán tối ưu hoá đó mà áp dụng trực tiếp quy tắc chu kỳ cố định — một lựa chọn có chủ đích nhằm giữ độ phức tạp tương xứng với quy mô một hệ thống chấm công của một đợt thực tập, không phải một công cụ lập lịch nhân sự toàn diện.

Nhìn chung, năm công bố quốc tế khảo sát được cho thấy từng thành phần kỹ thuật cấu thành đề tài — xác thực vị trí bằng geofencing, kiến trúc Backend-as-a-Service, và lập lịch ca xoay vòng — đều đã được nghiên cứu trong tài liệu quốc tế, nhưng luôn ở dạng tách rời theo từng khía cạnh: nghiên cứu về geofencing không đề cập đến xoay ca, nghiên cứu về xoay ca không đề cập đến định vị, và không công bố nào khảo sát đồng thời từ ba thành phần trở lên. Đây là tiền đề để mục 2.3.2 mở rộng khảo sát sang bối cảnh trong nước, trước khi tổng hợp toàn diện cả hai nguồn quốc tế và trong nước ở mục 2.3.3.

### 2.3.2 Nghiên cứu trong nước

Song song với việc khảo sát các công bố quốc tế ở mục 2.3.1, tài liệu trong nước liên quan đến chấm công, định vị GPS, và phát triển ứng dụng di động bằng Firebase cũng được tra cứu một cách có hệ thống qua Google Scholar, ResearchGate (bản công khai), tạp chí khoa học chuyên ngành trong nước, và thư viện số của một số trường đại học kỹ thuật. Mục tiêu của việc khảo sát này không chỉ nhằm bổ sung tài liệu tham khảo, mà còn nhằm xác định vị trí cụ thể của đề tài trong bối cảnh nghiên cứu học thuật trong nước.

Xu hướng nổi bật nhất rút ra được là **sự tách biệt giữa nghiên cứu về công nghệ định vị và nghiên cứu về nghiệp vụ nhân sự**. Các công bố trong nước có đề cập đến GPS thường thuộc một trong hai hướng: hướng thứ nhất là nghiên cứu kỹ thuật định vị thuần tuý, đặt trong lĩnh vực trắc địa và đo đạc, không gắn với bất kỳ bài toán quản lý con người nào; hướng thứ hai là ứng dụng GPS vào giám sát nhân sự tại hiện trường, nhưng mục tiêu là an toàn lao động chứ không phải chấm công hành chính. Ở chiều ngược lại, khi bài toán chấm công điện tử được giải quyết trong các đồ án/khóa luận trong nước, công nghệ định danh vị trí được lựa chọn thường không phải GPS mà là các phương án khác (Wi-Fi, mã QR), với lý do kỹ thuật được nêu tường minh là hạn chế của GPS trong môi trường trong nhà. Việc ứng dụng Firebase cho phát triển ứng dụng di động cũng đã xuất hiện trong tài liệu trong nước, nhưng ở các lĩnh vực ứng dụng khác (mạng xã hội, chia sẻ thông tin), chưa gắn với nghiệp vụ nhân sự.

Hai công trình sau đây được xác định đủ thông tin học thuật (tác giả, đơn vị công bố) để trích dẫn chính thức trong báo cáo. Sơn và Khởi [15] trình bày một ứng dụng kết hợp định vị GPS trên smartphone với cảm biến gắn trên thiết bị bảo hộ lao động, cho phép giám sát vị trí công nhân theo thời gian thực và cảnh báo tự động khi phát sinh rủi ro an toàn tại công trường xây dựng — đây là công bố học thuật trong nước hiếm hoi kết hợp trực tiếp GPS với bài toán giám sát nhân sự. Trần [16] trình bày việc xây dựng phần mềm quản lý nhân sự cho một doanh nghiệp cụ thể, đại diện cho hướng tiếp cận "số hoá nghiệp vụ nhân sự" phổ biến trong các khóa luận trong nước, không gắn với định vị hay nền tảng di động. Bên cạnh hai công trình này, quá trình khảo sát còn ghi nhận một đồ án môn học công khai về chấm công qua Wi-Fi tại một trường đại học trong nước, cùng một khảo sát kỹ thuật định vị GPS đăng trên một tạp chí khoa học đại học vùng và một công bố về ứng dụng Firebase kết hợp React Native cho ứng dụng mạng xã hội; ba tài liệu này không đủ thông tin tác giả xác minh được qua nguồn công khai nên chỉ được nêu ở đây như bối cảnh tham khảo, không được gán số trích dẫn hay đưa vào danh mục tài liệu tham khảo chính thức.

Điểm mạnh chung của nhóm tài liệu trong nước là cho thấy hai thành phần công nghệ cốt lõi của đề tài — định vị GPS và Firebase — đều đã có tiền lệ ứng dụng thực tế trong nước, không phải công nghệ hoàn toàn xa lạ với môi trường phát triển phần mềm trong nước; công bố [15] cụ thể cho thấy tư duy "dùng GPS để giám sát vị trí nhân sự theo thời gian thực" đã từng được đặt ra và giải quyết ở một bài toán liền kề (an toàn lao động). Điểm hạn chế chung là không có công trình nào trong số khảo sát được kết hợp đồng thời từ hai thành phần công nghệ cốt lõi trở lên của đề tài trong cùng một hệ thống, và số lượng công bố học thuật được bình duyệt (so với số lượng đồ án môn học và sản phẩm thương mại) về chấm công điện tử nói riêng còn tương đối hạn chế.

*(Bảng 2.7 — So sánh đề tài với các tài liệu trong nước đã khảo sát.)*

| Tài liệu | Lĩnh vực | GPS | Flutter | Firebase | Xoay ca | Ghi chú |
|---|---|---|---|---|---|---|
| Sơn & Khởi (2021) [15] | Giám sát an toàn lao động xây dựng | ✓ | ✗ | ✗ | ✗ | Công bố tạp chí khoa học |
| Trần (2024) [16] | Phần mềm quản lý nhân sự | ✗ | ✗ | ✗ | ✗ | Khóa luận tốt nghiệp |
| Đồ án chấm công qua Wi-Fi (không trích dẫn số hiệu) | Chấm công điện tử | ✗ (dùng Wi-Fi) | ✗ | ✗ | ✗ | Đồ án môn học, chưa xác minh tác giả |
| **Đề tài** | **Chấm công điện tử** | **✓** | **✓** | **✓** | **✓** | — |

Xét về mức độ kế thừa và khác biệt, đề tài kế thừa từ tài liệu trong nước chủ yếu ở mức nguyên lý kỹ thuật: cách tiếp cận "định vị theo thời gian thực để xác nhận sự hiện diện của người lao động" trong [15] củng cố thêm cơ sở cho việc lựa chọn GPS làm cơ chế xác thực vị trí ở mục 2.2.11, còn lý do kỹ thuật khiến đồ án chấm công qua Wi-Fi từ bỏ GPS (tín hiệu suy giảm trong không gian kín) là một đối chứng hữu ích, giúp làm rõ giới hạn áp dụng của GPS mà đề tài cũng đã thừa nhận là nhược điểm ở cùng mục đó. Điểm khác biệt cốt lõi nằm ở việc đề tài không dừng ở một thành phần công nghệ đơn lẻ như các tài liệu trong nước đã khảo sát, mà tích hợp đồng thời định vị GPS, nền tảng Flutter, dịch vụ Firebase, và cơ chế xoay ca hai nhóm trong cùng một hệ thống vận hành thực tế. Sự cải tiến so với tài liệu trong nước không nằm ở việc đề xuất một thuật toán định vị hay lập lịch mới, mà ở việc chứng minh tính khả thi của một tổ hợp kỹ thuật chưa từng được ghi nhận cùng lúc trong các công bố trong nước tìm được, thông qua một hệ thống có dữ liệu vận hành thật (xem `docs/demo/01_DEMO_DATA.md`).

Qua quá trình khảo cứu các cơ sở dữ liệu học thuật trong nước, chưa tìm thấy công trình công bố có phạm vi hoàn toàn tương đồng với đề tài. Các nghiên cứu hiện có chủ yếu tập trung vào từng khía cạnh riêng như định vị GPS, quản lý nhân sự hoặc ứng dụng di động. Đây chính là khoảng trống nghiên cứu mà đề tài hướng đến — cụ thể là sự thiếu vắng một công trình trong nước kết hợp đồng thời định vị GPS/geofencing, tổ hợp công nghệ Flutter–Firebase, và cơ chế lập lịch ca xoay vòng nhiều nhóm trong cùng một hệ thống chấm công.

Tóm lại, tài liệu trong nước hiện có cung cấp các mảnh ghép rời rạc — định vị GPS, quản lý nhân sự, phát triển ứng dụng di động bằng Firebase — nhưng không có công trình nào ghép các mảnh đó lại thành một hệ thống chấm công hoàn chỉnh như đề tài đã thực hiện. Đây là căn cứ để khẳng định đóng góp cụ thể, dù ở quy mô một báo cáo thực tập, của đề tài đối với bức tranh nghiên cứu trong nước về chủ đề này.

### 2.3.3 So sánh và khoảng trống nghiên cứu

Mục này tổng hợp kết quả khảo sát từ cả hai nguồn đã trình bày — công bố quốc tế ở mục 2.3.1 và tài liệu trong nước ở mục 2.3.2 — thành một nhận định thống nhất về vị trí của đề tài trong bức tranh nghiên cứu hiện có. Bảng 2.6 trước hết so sánh đề tài với năm công bố quốc tế, theo bốn tiêu chí: phạm vi bài toán hướng đến, công nghệ nền tảng sử dụng, khả năng xử lý ca làm việc xuyên nửa đêm, và cơ chế phân quyền dữ liệu ở tầng lưu trữ; phần so sánh tương ứng với ba tài liệu trong nước tiêu biểu đã được trình bày riêng ở Bảng 2.7 (mục 2.3.2), theo bốn tiêu chí kỹ thuật cốt lõi của đề tài (GPS, Flutter, Firebase, xoay ca) — không lặp lại ở đây.

*(Bảng 2.6 — So sánh đề tài với các nghiên cứu/hệ thống quốc tế đã khảo sát, theo bốn tiêu chí: phạm vi bài toán, công nghệ nền, xử lý ca đêm xuyên nửa đêm, cơ chế phân quyền dữ liệu.)*

| Nghiên cứu / Hệ thống | Phạm vi bài toán | Công nghệ nền | Xử lý ca đêm xuyên nửa đêm | Phân quyền dữ liệu tầng lưu trữ |
|---|---|---|---|---|
| [4] GPS + Face Attendance | Giáo dục | Android, Cloud | Không đề cập | Không đề cập |
| [5] Geofencing Attendance | Không xác định cụ thể | Không xác định cụ thể | Không đề cập | Không đề cập |
| [7] Geo-Fencing sinh viên | Giáo dục | Mobile, Face recognition | Không | Không đề cập |
| [8] Enhancing Employee Attendance | Doanh nghiệp | Không xác định cụ thể | Không đề cập | Không đề cập |
| [12] Task assignments with rotations | Y tế (lập lịch nhân sự) | Không áp dụng (bài toán tối ưu hoá) | Có xử lý ca, không xử lý geofencing | Không áp dụng |
| [15] GPS an toàn lao động xây dựng | Xây dựng (an toàn lao động) | Android, cảm biến | Không đề cập | Không đề cập |
| **Đề tài (hệ thống chấm công GPS xoay ca)** | **Doanh nghiệp, ca xoay vòng ngày/đêm** | **Flutter, Firebase (Firestore, Authentication)** | **Có (Business Date, `BusinessDateHelper`)** | **Có (Firestore Security Rules, `isAdmin()`/`isOwner()`)** |

Từ hai bảng so sánh (Bảng 2.6 và Bảng 2.7), khoảng trống nghiên cứu của đề tài thể hiện nhất quán ở cả hai nguồn tài liệu, dù với biểu hiện khác nhau. Ở tài liệu quốc tế, phần lớn nghiên cứu về chấm công dựa trên định vị/geofencing đặt trong bối cảnh giáo dục (điểm danh sinh viên), không phải bối cảnh doanh nghiệp vận hành liên tục nhiều ca; nghiên cứu về geofencing không đề cập đến xoay ca, còn nghiên cứu về xoay ca ([12]) không đề cập đến định vị. Ở tài liệu trong nước, khoảng trống thể hiện theo cách khác: từng thành phần công nghệ riêng lẻ (GPS giám sát nhân sự ở [15], phần mềm quản lý nhân sự ở [16], chấm công di động theo vị trí ở đồ án Wi-Fi đã nêu tại mục 2.3.2) đều đã có tiền lệ, nhưng không công trình nào trong nước tích hợp chúng lại với nhau, và không công trình nào — cả quốc tế lẫn trong nước — sử dụng đúng tổ hợp GPS + Flutter + Firebase.

Đề tài, thông qua việc kết hợp `GpsService`/công thức Haversine với `RotationCalculator` và khái niệm Business Date, đứng ở giao điểm của hai nhánh nghiên cứu quốc tế vốn được khảo sát tách biệt (geofencing và lập lịch ca xoay vòng), đồng thời là công trình duy nhất trong số tài liệu trong nước khảo sát được tích hợp đồng thời định vị GPS, nền tảng Flutter và dịch vụ Firebase trong một hệ thống chấm công vận hành thực tế. Đề tài cũng bổ sung một khía cạnh không được bất kỳ nghiên cứu nào — quốc tế hay trong nước — đề cập cụ thể: cơ chế phân quyền dữ liệu khai báo ở tầng lưu trữ (Firestore Security Rules), hệ quả trực tiếp của việc không sử dụng máy chủ backend tự viết đã phân tích ở mục 2.2.6 và 2.2.10. Đây là cơ sở để khẳng định: đóng góp của đề tài, ở quy mô một báo cáo thực tập, không nằm ở việc đề xuất một thuật toán hay công nghệ hoàn toàn mới, mà nằm ở việc tích hợp và chứng minh tính khả thi trong thực tế vận hành của một tổ hợp kỹ thuật mà cho đến thời điểm khảo sát, chưa được ghi nhận đồng thời trong bất kỳ công bố nào — quốc tế hay trong nước.

---

## Tài liệu tham khảo

[1] Flutter Documentation, Google, "Flutter architectural overview," https://docs.flutter.dev

[2] Firebase Documentation, Google, https://firebase.google.com/docs

[3] Riverpod Documentation, https://riverpod.dev

[4] "A GPS-based Face Attendance Register System using Android Applications stored in the Cloud," IEEE Xplore, 2024, doc. 10498447.

[5] "Attendance Management System Using Geofencing Technology," IEEE Xplore, 2024, doc. 10696345.

[6] "A comprehensive and systematic literature review on the employee attendance management systems based on cloud computing," Journal of Management & Organization, Cambridge Core.

[7] "Mobile Based Student Attendance System Using Geo-Fencing With Timing And Face Recognition," ResearchGate.

[8] "Enhancing Employee Attendance Systems Through Integrated Monitoring And Automation," ResearchGate.

[9] "Improving the Tourists Experiences: Application of Firebase and Flutter Technologies in Mobile Applications Development Process," IEEE Xplore, 2021, doc. 9623025.

[10] "The Comparison Firebase Realtime Database and MySQL Database Performance using Wilcoxon Signed-Rank Test," ScienceDirect (Elsevier).

[11] "Application of Firebase in Android App Development – A Study," ResearchGate.

[12] "Task assignments with rotations and flexible shift starts to improve demand coverage and staff satisfaction in healthcare," Journal of Scheduling, Springer.

[13] Object Management Group (OMG), "Unified Modeling Language Specification," https://www.omg.org/spec/UML

[14] Fowler, M., *Patterns of Enterprise Application Architecture*, Addison-Wesley, 2002.

[15] Sơn, P. V. H., & Khởi, N. V. T. (2021). Ứng dụng công nghệ định vị GPS trên smart phone để quản lý an toàn lao động trong quản lý xây dựng. *Tạp chí Khoa học Công nghệ Xây dựng*.

[16] Trần, Đ. N. M. (2024). *Xây dựng phần mềm quản lý nhân sự của công ty TNHH* [Khóa luận tốt nghiệp, Đại học Kinh tế Quốc dân].

**Ghi chú:** Ngoài [15] và [16], không có khoá luận/đồ án trong nước nào khác được trích dẫn chính thức trong danh mục trên. Ba tài liệu trong nước còn lại được nêu ở mục 2.3.2 (đồ án chấm công qua Wi-Fi, khảo sát kỹ thuật định vị GPS của một tạp chí đại học vùng, công bố Firebase kết hợp React Native) không đủ thông tin tác giả xác minh được qua nguồn công khai tại thời điểm khảo sát, nên chỉ được nhắc đến trong phần phân tích, không được gán số trích dẫn hay đưa vào danh mục tham khảo chính thức.
