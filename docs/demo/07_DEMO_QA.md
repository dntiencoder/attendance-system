# 07 — Câu hỏi & Trả lời dự kiến

33 câu hỏi, mỗi câu có **trả lời ngắn** (dùng khi cần trả lời nhanh) và **trả lời chi tiết** (dùng khi giảng viên hỏi sâu thêm).

## Mục lục

1. [Flutter](#1-flutter)
2. [Firebase](#2-firebase)
3. [Firestore](#3-firestore)
4. [Riverpod](#4-riverpod)
5. [GPS](#5-gps)
6. [Business Date](#6-business-date)
7. [Rotation](#7-rotation)
8. [Security Rules](#8-security-rules)
9. [Database](#9-database)
10. [Architecture](#10-architecture)

---

## 1. Flutter

**Q1. Vì sao chọn Flutter cho cả mobile lẫn web thay vì công nghệ riêng cho từng nền tảng?**
- *Ngắn:* Một ngôn ngữ (Dart), một người phát triển, triển khai song song 2 ứng dụng trong thời gian thực tập có giới hạn.
- *Chi tiết:* Flutter cho phép dùng chung tư duy kiến trúc (feature-first, Riverpod) và một phần logic nghiệp vụ giữa 2 app dù không dùng chung package code. Đánh đổi là phải chấp nhận trùng lặp model giữa 2 app (đã ghi nhận trong `ROADMAP.md`), nhưng đổi lại tốc độ phát triển nhanh hơn nhiều so với việc dùng 2 công nghệ khác nhau cho mobile và web.

**Q2. `StatefulShellRoute` (mobile) khác `ShellRoute` (admin) thế nào, vì sao dùng khác nhau?**
- *Ngắn:* Mobile cần giữ trạng thái riêng cho từng tab (bottom nav), admin chỉ cần 1 layout bao quanh nội dung.
- *Chi tiết:* `StatefulShellRoute.indexedStack` giữ nguyên state của từng tab khi chuyển qua lại (ví dụ cuộn trang lịch sử không bị reset khi chuyển sang tab khác rồi quay lại) — phù hợp bottom nav trên mobile. Admin dùng sidebar điều hướng, không cần giữ state riêng theo kiểu "tab" nên `ShellRoute` đơn giản là đủ.

**Q3. Ứng dụng xử lý dữ liệu Firestore bị thiếu/lỗi field như thế nào?**
- *Ngắn:* Có null-safety và try-catch ở tầng đọc dữ liệu — 1 document lỗi không làm crash toàn bộ danh sách.
- *Chi tiết:* Ví dụ `AttendanceModel.fromFirestore` kiểm tra kiểu dữ liệu (`is Timestamp`) trước khi ép kiểu thay vì ép kiểu cứng; khi tải danh sách nhiều bản ghi, mỗi document được đọc trong 1 khối try-catch riêng — nếu 1 bản ghi hỏng, chỉ bản ghi đó bị bỏ qua (có log), không crash cả màn hình.

## 2. Firebase

**Q4. Vì sao chọn Firebase thay vì tự viết backend riêng?**
- *Ngắn:* Không cần quản lý server, có sẵn Auth + Database + Rules, phù hợp quy mô và thời gian thực tập.
- *Chi tiết:* Firebase cung cấp Authentication, Firestore (database thời gian thực), và Security Rules để tự enforce phân quyền ngay ở tầng dữ liệu — nghĩa là không cần viết API riêng để kiểm tra quyền, giảm đáng kể khối lượng công việc so với tự dựng backend + database + tầng xác thực.

**Q5. Vì sao không dùng Cloud Functions?**
- *Ngắn:* Cloud Functions cần gói Blaze (có billing) và nằm ngoài phạm vi ổn định hoá đã đặt ra cho giai đoạn này.
- *Chi tiết:* Cloud Functions sẽ cần thiết nếu muốn xác thực lại dữ liệu GPS phía server (chống client tự gửi toạ độ giả) — đây là giới hạn đã biết, ghi rõ trong `ROADMAP.md` phần "Ngoài phạm vi", dự định cân nhắc ở giai đoạn sau khi hệ thống cần mức độ tin cậy cao hơn.

**Q6. Vai trò (`role`) của người dùng được xác định dựa vào đâu?**
- *Ngắn:* Dựa vào field `role` trong document `users/{uid}` trên Firestore, không dùng Custom Claims của Firebase Auth.
- *Chi tiết:* Sau khi đăng nhập bằng Firebase Auth, ứng dụng và cả Security Rules đều đọc thêm document `users/{uid}` để biết `role` (`admin`/`employee`) và `isActive`. Đây là lý do rules có hàm `isAdmin()` phải gọi `get()` sang collection `users` thay vì đọc thẳng từ token đăng nhập.

## 3. Firestore

**Q7. Vì sao chọn Firestore (NoSQL) thay vì SQL truyền thống?**
- *Ngắn:* Đồng bộ thời gian thực có sẵn, tích hợp thẳng với Firebase Auth và Security Rules.
- *Chi tiết:* Firestore cho phép mobile/admin lắng nghe thay đổi dữ liệu theo thời gian thực (`StreamProvider`) mà không cần tự dựng WebSocket hay polling, đồng thời Security Rules gắn liền với cùng hệ sinh thái Auth — giảm khối lượng hạ tầng cần tự xây.

**Q8. `docId` của collection `attendance` được thiết kế thế nào, vì sao?**
- *Ngắn:* `"<yyyy-MM-dd>_<uid>"` — đảm bảo đúng 1 bản ghi mỗi người mỗi ngày làm việc, và Security Rules kiểm tra được quyền ghi ngay từ tên document.
- *Chi tiết:* Vì mỗi nhân viên chỉ có đúng 1 bản ghi chấm công mỗi ngày làm việc (Business Date), dùng `docId` có cấu trúc cố định giúp: (1) tránh tạo trùng bản ghi cho cùng 1 ngày, (2) Security Rules kiểm tra quyền tạo/đọc bằng cách so khớp `docId` với `request.auth.uid`, không cần đọc dữ liệu bên trong document — quan trọng cho trường hợp document *chưa tồn tại* (xem Q26).

**Q9. Dự án có đánh index cho Firestore không? Vì sao cần?**
- *Ngắn:* Có, khai báo trong `firestore.indexes.json`, cần cho truy vấn nhiều điều kiện (ví dụ lọc theo `uid` và khoảng ngày).
- *Chi tiết:* Các truy vấn như "lấy lịch sử chấm công của 1 nhân viên trong 1 khoảng ngày" cần lọc đồng thời trên 2 field (`uid` + `attendanceDate`) — Firestore yêu cầu composite index cho việc này, nếu không sẽ báo lỗi `FAILED_PRECONDITION` khi deploy lên project mới.

**Q10. Dự án có dùng subcollection không?**
- *Ngắn:* Không — toàn bộ dữ liệu nghiệp vụ nằm ở các collection gốc (`users`, `attendance`, `departments`, `leave_requests`, `notifications`, `company_settings`).
- *Chi tiết:* Cấu trúc phẳng này đơn giản hoá việc viết Security Rules và truy vấn, phù hợp quy mô dữ liệu hiện tại; nếu sau này cần lưu dữ liệu con gắn chặt với 1 document cha (ví dụ lịch sử sửa đổi từng bản ghi chấm công), subcollection sẽ là lựa chọn tự nhiên.

## 4. Riverpod

**Q11. Vì sao chọn Riverpod thay vì Provider/Bloc/GetX?**
- *Ngắn:* Kiểm tra kiểu dữ liệu tại thời điểm biên dịch tốt hơn Provider, ít boilerplate hơn Bloc.
- *Chi tiết:* Riverpod không phụ thuộc `BuildContext` để đọc provider (khác `Provider` package cũ), giảm lỗi runtime phổ biến kiểu "provider not found"; so với Bloc, Riverpod gọn hơn cho quy mô dự án vừa và nhỏ như đồ án này.

**Q12. `StateNotifierProvider` và `StreamProvider` dùng khi nào?**
- *Ngắn:* `StreamProvider` cho dữ liệu cần cập nhật thời gian thực từ Firestore (`.snapshots()`); `StateNotifierProvider` cho state có thao tác phức tạp (loading, error, nhiều hành động) như Check In/Out.
- *Chi tiết:* Ví dụ danh sách nhân viên (`employeesStreamProvider`) dùng `StreamProvider` vì chỉ cần phản ánh đúng dữ liệu Firestore; trong khi `AttendanceNotifier` dùng `StateNotifierProvider` vì cần quản lý nhiều trạng thái con (`isLoading`, `error`, `successMessage`, `isShiftEnded`) qua nhiều hành động khác nhau.

**Q13. Ứng dụng có tránh rebuild thừa không?**
- *Ngắn:* Có ở mức cơ bản qua cách chia nhỏ widget và `ref.watch` đúng phạm vi cần thiết; chưa tối ưu ở mức `select` toàn diện.
- *Chi tiết:* Đây là điểm đã ghi nhận trong `ROADMAP.md` (Phase 3) — có thể tối ưu thêm bằng `ref.watch(provider.select(...))` để chỉ rebuild đúng phần dữ liệu thay đổi, nhưng chưa cấp thiết ở quy mô dữ liệu hiện tại.

## 5. GPS

**Q14. Cách tính khoảng cách GPS hoạt động thế nào?**
- *Ngắn:* Dùng công thức Haversine tính khoảng cách giữa 2 toạ độ (vị trí hiện tại và vị trí công ty).
- *Chi tiết:* Haversine tính khoảng cách đường chim bay giữa 2 điểm trên mặt cầu (Trái Đất) dựa trên kinh độ/vĩ độ — kết quả trả về đơn vị mét, so sánh với `radius` cấu hình trong `company_settings` để quyết định có cho phép chấm công hay không.

**Q15. Làm sao chống giả mạo vị trí (fake GPS)?**
- *Ngắn:* Dùng cờ `isMocked` của gói `geolocator` — phát hiện vị trí đến từ app giả lập vị trí thì từ chối chấm công.
- *Chi tiết:* Đây là kiểm tra ở tầng thiết bị (client), không phải xác thực phía server — nếu người dùng có kỹ thuật can thiệp sâu hơn (ví dụ sửa OS), lớp bảo vệ này có thể bị vượt qua; xác thực triệt để hơn cần tính toán lại phía server (Cloud Functions), hiện nằm ngoài phạm vi giai đoạn này (xem Q5).

**Q16. Nếu thiết bị không bắt được GPS (trong nhà, tầng hầm...) thì sao?**
- *Ngắn:* App báo lỗi rõ ràng "GPS chưa được bật" hoặc time-out sau 15 giây, không bị treo vô thời hạn.
- *Chi tiết:* `GpsService.getCurrentPosition()` đặt `timeLimit: Duration(seconds: 15)` khi gọi `Geolocator.getCurrentPosition()`, đảm bảo luôn có phản hồi (thành công hoặc lỗi rõ ràng) trong thời gian hợp lý.

## 6. Business Date

**Q17. "Business Date" là gì?**
- *Ngắn:* Ngày làm việc thực tế mà 1 sự kiện (check-in/out) thuộc về — khác với ngày theo lịch/đồng hồ hệ thống.
- *Chi tiết:* Với ca ngày, Business Date luôn trùng ngày lịch. Với ca đêm (xuyên qua nửa đêm), mọi thời điểm từ 00:00 đến giờ kết thúc ca đêm đều thuộc về Business Date của *ngày hôm trước* — ngày ca đó thực sự bắt đầu.

**Q18. Vì sao cần khái niệm này, không dùng thẳng ngày theo đồng hồ?**
- *Ngắn:* Vì ca đêm xuyên qua nửa đêm — dùng thẳng ngày đồng hồ sẽ tính sai ca, sai giờ đi trễ, sai luôn cả docId của bản ghi chấm công.
- *Chi tiết:* Đây chính là nguyên nhân gốc của một bug thực tế đã gặp: nhân viên check-in lúc 0h18 sáng bị hệ thống hiển thị nhầm sang ca ngày và tính sai giờ đi trễ, vì lúc đó code dùng thẳng `DateTime.now()`'s ngày lịch thay vì hiểu rằng đây vẫn là ca đêm bắt đầu từ tối hôm trước.

**Q19. Thuật toán giải quyết vòng lặp phụ thuộc (cần biết ca để biết ngày, cần biết ngày để tính ca) thế nào?**
- *Ngắn:* Không hỏi "ca hiện tại là gì", mà hỏi "hôm qua (một ngày cụ thể, không mơ hồ) nhóm ca này có làm đêm không" — câu hỏi này luôn trả lời được dứt khoát.
- *Chi tiết:* Nếu đang trong khung giờ sáng sớm (trước giờ kết thúc ca đêm) và nhóm ca của nhân viên làm đêm vào *ngày hôm qua*, Business Date = hôm qua. Ngược lại, Business Date = hôm nay như bình thường. Vì luôn tra cứu "hôm qua" (một mốc cố định), thuật toán không bao giờ rơi vào vòng lặp cần biết trước kết quả để tính kết quả.

**Q20. Vì sao cho phép Check In sớm 60 phút, không phải mốc khác?**
- *Ngắn:* Đây là quyết định nghiệp vụ nhằm cân bằng giữa việc cho nhân viên đến sớm chuẩn bị và việc chặn check-in quá sớm khi ca còn chưa bắt đầu.
- *Chi tiết:* Trước khi có quy tắc này, hệ thống từng cho phép check-in bất kỳ lúc nào trong ngày kể cả nhiều giờ trước khi ca bắt đầu — đây là 1 bug đã sửa. 60 phút là mốc được thống nhất trong quá trình rà soát, có thể điều chỉnh nếu thực tế vận hành cho thấy cần thay đổi.

## 7. Rotation

**Q21. Cơ chế xoay ca hoạt động thế nào?**
- *Ngắn:* Nhân viên chia 2 nhóm A/B, đổi ca ngày/đêm cho nhau mỗi `rotationDays` (hiện là 14) ngày, tính từ 1 mốc ngày gốc cố định.
- *Chi tiết:* Số ngày trôi qua kể từ mốc gốc được chia thành các khối `rotationDays` ngày; khối chẵn/lẻ quyết định nhóm nào làm ca gì. Toàn bộ phép tính này nằm trong 1 hàm thuần (`RotationCalculator`), tách riêng để dễ kiểm thử độc lập.

**Q22. Nếu đổi `rotationDays` giữa chừng, dữ liệu chấm công cũ có bị tính sai lại không?**
- *Ngắn:* Dữ liệu cũ đã lưu (`shift` đã ghi vào từng bản ghi chấm công) không bị tính lại — chỉ ảnh hưởng cách tính ca cho các ngày *sau* khi đổi cấu hình.
- *Chi tiết:* `shift` được xác định và lưu chết vào document tại thời điểm check-in, không tính lại mỗi lần đọc — nên lịch sử chấm công không bị "viết lại" nếu sau này đổi `rotationDays`; chỉ có phần "ca dự kiến hiển thị trên Home" (cho ngày chưa check-in) mới phản ánh cấu hình mới ngay lập tức.

**Q23. Có bằng chứng nào cho thấy thuật toán rotation đúng không?**
- *Ngắn:* Có — dữ liệu chấm công thật trong hệ thống cho thấy đúng 1 lần đổi ca giữa 2 nhóm, đúng ngày dự kiến theo chu kỳ 14 ngày.
- *Chi tiết:* Xem `01_DEMO_DATA.md` mục 4 — từ 16/06 đến 27/06 nhóm A làm ca ngày, nhóm B làm ca đêm; đúng từ 29/06 (ngày đầu tiên của khối rotation kế tiếp) 2 nhóm đổi ca cho nhau — khớp chính xác với công thức `floor(daysPassed / rotationDays)`.

## 8. Security Rules

**Q24. Firestore Security Rules trong dự án bảo vệ những gì?**
- *Ngắn:* Đảm bảo mỗi người chỉ đọc/ghi đúng dữ liệu được phép theo vai trò (`admin`/`employee`) và theo quyền sở hữu dữ liệu (chỉ tự chấm công cho chính mình).
- *Chi tiết:* Ví dụ nhân viên chỉ tạo được bản ghi `attendance` với `uid` trùng chính họ và `docId` đúng quy ước ngày; admin có thêm quyền đọc/ghi mở rộng dựa trên kiểm tra `role`/`isActive` của chính tài khoản đang đăng nhập.

**Q25. Vì sao không dùng Firebase Auth Custom Claims để lưu vai trò?**
- *Ngắn:* Custom Claims cần thao tác qua Admin SDK (thường là Cloud Functions) để gán — nằm ngoài phạm vi đã loại trừ (không Cloud Functions).
- *Chi tiết:* Thay vào đó, vai trò được lưu trực tiếp trong document `users/{uid}` trên Firestore, và Security Rules dùng `get()` để đọc lại chính document đó khi cần kiểm tra quyền — đánh đổi là tốn thêm 1 lượt đọc mỗi lần kiểm tra quyền admin, nhưng không cần hạ tầng phía server.

**Q26. Rule `get` và `list` khác nhau thế nào trong Firestore Rules?**
- *Ngắn:* `get` đọc 1 document cụ thể, `list` đọc nhiều document qua truy vấn — Firestore yêu cầu 2 loại này phải được "chứng minh" theo cách khác nhau khi rule tham chiếu tới dữ liệu của document.
- *Chi tiết:* Đây là 1 bug thực tế đã gặp và sửa: rule đọc dữ liệu chấm công ban đầu gộp chung `get`/`list`, khiến việc đọc 1 document *chưa tồn tại* (ví dụ kiểm tra "hôm nay đã check-in chưa") bị từ chối do `resource` là `null`. Giải pháp là tách riêng `allow get` (dựa vào cấu trúc `docId`, không phụ thuộc dữ liệu document) và `allow list` (dựa vào field dữ liệu, áp dụng đúng cho truy vấn).

**Q27. Nếu không có Firestore Rules thì sao?**
- *Ngắn:* Bất kỳ ai có thông tin cấu hình Firebase (vốn không phải bí mật) đều có thể đọc/ghi trực tiếp toàn bộ dữ liệu Firestore mà không qua bất kỳ kiểm tra nào.
- *Chi tiết:* Đây chính là tình trạng ban đầu của dự án trước khi rà soát (ghi nhận ở `REVIEW.md`/`ROADMAP.md` mục P1-05) — vì không có backend riêng, Security Rules là lớp bảo vệ *duy nhất* giữa client và dữ liệu, nên đây là hạng mục được ưu tiên xử lý đầu tiên trong quá trình ổn định hoá.

## 9. Database

**Q28. Vì sao 2 ứng dụng dùng 2 bộ model riêng cho cùng 1 dữ liệu Firestore?**
- *Ngắn:* Đây là đánh đổi có chủ đích để tránh phải tách package Dart dùng chung — nằm ngoài phạm vi đã thống nhất cho giai đoạn ổn định hoá.
- *Chi tiết:* Việc tách package dùng chung là một thay đổi kiến trúc lớn hơn cần thiết ở giai đoạn này; thay vào đó, các bug *cụ thể* phát sinh từ việc trùng lặp (ví dụ lệch nullability giữa 2 model, mất dữ liệu khi lưu) được xử lý riêng lẻ từng trường hợp — đã ghi rõ trong `ROADMAP.md`.

**Q29. Dữ liệu GPS (toạ độ, khoảng cách) do client gửi lên có tin được tuyệt đối không?**
- *Ngắn:* Không — đây là giới hạn đã biết. Firestore Rules hiện tại chỉ kiểm tra *ai* được ghi, không kiểm tra *giá trị* GPS có trung thực không.
- *Chi tiết:* Xác minh triệt để cần tính toán lại khoảng cách phía server (Cloud Functions), nằm ngoài phạm vi hiện tại. Lớp bảo vệ hiện có (`isMocked`) chỉ chống được các công cụ giả lập vị trí phổ biến, không chống được việc sửa đổi sâu hơn ở tầng hệ điều hành.

**Q30. Dự án có cơ chế backup dữ liệu không?**
- *Ngắn:* Có — một công cụ tự viết (`tools/firestore_backup`) đọc toàn bộ dữ liệu qua Firestore REST API, không cần Cloud Storage hay Billing.
- *Chi tiết:* Công cụ tự quét source code tìm mọi collection đang được dùng (không hardcode danh sách), đọc dữ liệu bằng chính tài khoản admin đã có (không dùng Service Account để tránh thêm 1 loại secret cần bảo vệ), rồi xuất ra file JSON kèm báo cáo tổng hợp.

## 10. Architecture

**Q31. Vì sao không tách interface cho Repository (Dependency Inversion)?**
- *Ngắn:* Là quyết định phạm vi có chủ đích cho giai đoạn ổn định hoá — không đổi kiến trúc, không refactor lớn.
- *Chi tiết:* Việc thêm interface (`abstract class`) cho Repository là bước chuẩn bị cho kiểm thử (mock) hoặc thay đổi nguồn dữ liệu dễ dàng hơn — có giá trị nhưng không cấp thiết ở quy mô và giai đoạn hiện tại của dự án, đã ghi nhận là việc "có thể làm sau" trong `ROADMAP.md`.

**Q32. Business logic (tính giờ, tính ca, kiểm tra bán kính) hiện nằm ở đâu?**
- *Ngắn:* Chủ yếu trong tầng Repository và trong các model domain (ví dụ `CompanySettingsModel`), không tách riêng lớp use-case.
- *Chi tiết:* Đây cũng là đánh đổi có chủ đích — tách use-case là một lớp kiến trúc bổ sung, phù hợp khi dự án phức tạp hơn; ở quy mô hiện tại, việc này được đánh giá là chưa cấp thiết so với việc ưu tiên sửa đúng các bug nghiệp vụ thực tế trước.

**Q33. Nếu hệ thống phải mở rộng lên quy mô hàng nghìn nhân viên, điểm nghẽn đầu tiên là gì?**
- *Ngắn:* Nhiều khả năng là các truy vấn tải toàn bộ collection không giới hạn (ví dụ Nhật ký chấm công phía admin hiện tải toàn bộ `attendance`), và việc xử lý 7 truy vấn tuần tự cho biểu đồ Dashboard.
- *Chi tiết:* Cả 2 điểm này đã được ghi nhận trong `ROADMAP.md` Phase 3 (giới hạn/lọc truy vấn, chạy song song truy vấn tuần) — chưa xử lý vì chưa cấp thiết ở quy mô dữ liệu hiện tại (vài chục bản ghi), nhưng là việc đầu tiên cần làm trước khi mở rộng quy mô thật.
