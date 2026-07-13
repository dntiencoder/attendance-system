# EMPLOYEE_LIFECYCLE.md

> Tài liệu thiết kế nghiệp vụ — **không phải tài liệu kỹ thuật**. Không có dòng code, không có schema, không có tên hàm/collection nào bị coi là ràng buộc thiết kế ở đây; các khái niệm dưới đây (Attendance, Leave Request, Notification...) chỉ được nhắc tới ở mức "loại dữ liệu nghiệp vụ nào", không mô tả cách chúng được lưu trữ hiện tại. Mục tiêu: chốt đúng bản chất nghiệp vụ của vòng đời một nhân viên trong hệ thống, trước khi quay lại implementation cho TD-02.
>
> **Trạng thái:** **Đã duyệt (2026-07-13)** — tài liệu thiết kế chính thức của dự án. Mọi thay đổi sau này liên quan tới vòng đời nhân viên (Active/Inactive/Delete) phải tham chiếu tài liệu này.

---

## 1. Vấn đề với thiết kế cũ

Thiết kế ban đầu của TD-02 (bắt buộc `isActive = false` rồi mới cho xoá) dùng sai tiêu chí. `isActive` trả lời câu hỏi **"người này có được phép dùng hệ thống không"** — một câu hỏi về **quyền truy cập**. Việc xoá hồ sơ lại là câu hỏi **"xoá cái này có phá dữ liệu nghiệp vụ nào không"** — một câu hỏi về **tính toàn vẹn dữ liệu**. Hai câu hỏi độc lập với nhau:

- Một nhân viên làm việc nhiều năm, bị khoá truy cập sau khi nghỉ việc (`isActive = false`) — theo thiết kế cũ, giờ lại **đủ điều kiện xoá**, đúng lúc dữ liệu của họ quan trọng nhất.
- Một hồ sơ tạo nhầm, chưa từng phát sinh gì (`isActive = true` mặc định) — theo thiết kế cũ, **chưa đủ điều kiện xoá** dù không có gì để mất.

Tài liệu này thiết kế lại toàn bộ vòng đời nhân viên để tách đúng hai trục: **quyền truy cập** (Active/Inactive) và **khả năng xoá** (dựa trên Business Data), không trộn lẫn.

---

## 2. Employee Lifecycle — các trạng thái

### Quyết định: chỉ 2 trạng thái lưu trữ (Active, Inactive), không thêm Archived

Đã cân nhắc thêm trạng thái `Archived` (như ví dụ bạn đưa ra) nhưng **quyết định không thêm** ở giai đoạn này — lý do và điều kiện để thêm lại được nêu ở mục 6.

### 2.1 Active

| Câu hỏi | Trả lời |
|---|---|
| Ý nghĩa nghiệp vụ | Nhân viên đang làm việc, được phép dùng hệ thống bình thường |
| Khi nào chuyển sang | Mặc định khi tạo hồ sơ mới; hoặc khi Admin **mở lại** quyền truy cập cho một người trước đó Inactive (quay lại làm việc, hoặc khoá nhầm) |
| Ai được chuyển | Admin |
| Đăng nhập | Có |
| Check In | Có (theo đúng lịch làm việc/ca hiện hành) |
| Xin nghỉ phép | Có |
| Xuất hiện trên Dashboard | Có — tính vào các số liệu "hiện tại" (tổng nhân viên đang làm, phân bổ theo ca/phòng ban...) |
| Tính vào thống kê | Có |
| Chỉnh sửa | Có, đầy đủ |
| Xoá | Chỉ khi **chưa từng phát sinh Business Data** (xem mục 4) — không phụ thuộc việc đang Active |

### 2.2 Inactive

| Câu hỏi | Trả lời |
|---|---|
| Ý nghĩa nghiệp vụ | Không còn được phép dùng hệ thống. Có thể vì đã nghỉ việc, hoặc Admin tạm khoá vì lý do khác. Hồ sơ và toàn bộ lịch sử **giữ nguyên** |
| Khi nào chuyển sang | Admin chủ động khoá — thường ngay khi nhân viên nghỉ việc, hoặc bất kỳ lúc nào cần tạm ngưng quyền truy cập |
| Ai được chuyển | Admin |
| Đăng nhập | Không — bị từ chối ngay cả khi xác thực đúng |
| Check In | Không (hệ quả của không đăng nhập được) |
| Xin nghỉ phép | Không |
| Xuất hiện trên Dashboard | **Loại khỏi** số liệu "hiện tại/đang hoạt động"; **vẫn giữ nguyên** trong báo cáo của các khoảng thời gian trong quá khứ khi họ còn Active (báo cáo tháng 3 không được đổi chỉ vì người đó nghỉ việc ở tháng 6) |
| Tính vào thống kê | Loại khỏi thống kê hiện tại/tương lai; giữ nguyên trong thống kê lịch sử |
| Chỉnh sửa | Nên hạn chế ở mức thông tin liên hệ cơ bản — không có lý do nghiệp vụ để sửa ca làm/phòng ban của người không còn làm việc. Chi tiết UX cụ thể để dành cho lúc implementation, không chốt cứng ở đây |
| Xoá | Chỉ khi chưa từng phát sinh Business Data — cùng điều kiện như Active, trong thực tế hiếm khi xảy ra vì Inactive thường đi kèm đã từng làm việc |

**Điểm quan trọng nhất của mục này:** Active và Inactive là **hai chiều, chuyển đổi tự do**, không phải một chiều đi xuống. Admin có thể bật lại bất kỳ lúc nào (nhân viên quay lại làm việc, hoặc khoá nhầm). Không có khái niệm "Inactive là bước đệm trước khi xoá" trong thiết kế mới — Inactive chỉ đơn thuần là công tắc quyền truy cập.

### 2.3 Deleted — là một hành động, không phải một trạng thái lưu trữ

Khác với Active/Inactive (hồ sơ vẫn tồn tại, chỉ đổi cờ), Deleted nghĩa là **hồ sơ không còn tồn tại nữa** — không có "trạng thái Deleted" để truy vấn, vì sau khi xoá thì không còn gì để hỏi các câu hỏi "đăng nhập được không/check-in được không" nữa.

| Câu hỏi | Trả lời |
|---|---|
| Ý nghĩa nghiệp vụ | Dọn dẹp hồ sơ **tạo nhầm/trùng/test** — không dùng cho nhân viên thật đã từng làm việc |
| Khi nào cho phép | Bất kỳ lúc nào, **miễn là chưa từng phát sinh Business Data** — không phụ thuộc Active hay Inactive |
| Ai được thực hiện | Admin |
| Có hoàn tác được không | Không — một chiều, vĩnh viễn |

---

## 3. Flow vòng đời

```
                    Employee Created
                    (Active, chưa có Business Data)
                            │
                            │
              ┌─────────────┴─────────────┐
              │                           │
         Active  ⇄⇄⇄ (Admin bật/tắt tự do) ⇄⇄⇄  Inactive
              │                           │
              │   (chỉ khi CHƯA có Business Data — từ Active hoặc Inactive đều được)
              └─────────────┬─────────────┘
                            ▼
                        Deleted
                     (vĩnh viễn, không hoàn tác)


  Ngay khi Business Data đầu tiên phát sinh (1 lần Check In / 1 đơn nghỉ phép /
  1 thông báo) → nhánh "Deleted" ở trên bị khoá vĩnh viễn, bất kể sau đó Active
  hay Inactive bao nhiêu lần. Đây không phải một trạng thái hiển thị, mà là một
  mốc không thể đảo ngược ảnh hưởng tới việc nút Xoá còn dùng được hay không.
```

**Vì sao KHÔNG dùng flow tuyến tính "Active → Inactive → Archive → Delete" như ví dụ gợi ý ban đầu:** flow tuyến tính ngụ ý xoá là **đích đến cuối cùng** của mọi nhân viên, kể cả người đã làm việc nhiều năm — điều này sai về bản chất nghiệp vụ (xem mục 5, đối chiếu thực tế doanh nghiệp: không hệ thống nghiêm túc nào coi "xoá" là bước cuối của một nhân viên thật). Flow đúng phải tách Xoá thành một **nhánh riêng, có điều kiện**, không phải một bước tiếp theo của Inactive.

---

## 4. Business Data là gì trong dự án này?

**Định nghĩa:** Business Data là bất kỳ dữ liệu nào **do chính hoạt động của nhân viên đó tạo ra** (hoặc trực tiếp nhắm tới họ), mà nếu mất đi sẽ để lại một khoảng trống không thể khôi phục trong lịch sử vận hành/lương/tuân thủ của công ty.

| Loại dữ liệu | Có tính là Business Data không? | Vì sao |
|---|---|---|
| **Attendance (Chấm công)** | **Có** | Bằng chứng trực tiếp cho việc tính lương, đi muộn/về sớm, ngày công — mất đi là mất bằng chứng lương |
| **Leave Request (Nghỉ phép)** | **Có** | Hồ sơ chính thức về việc vắng mặt có/không lương — liên quan trực tiếp tới lương và có thể cần tra cứu khi có tranh chấp/kiểm toán |
| **Notification (Thông báo)** | **Không** | Là log giao tiếp một chiều (Admin → nhân viên), không phải "giao dịch" do nhân viên tạo ra, không có giá trị pháp lý/lương/kiểm toán lâu dài — mất một thông báo cũ không để lại khoảng trống nghiệp vụ nào. Loại khỏi điều kiện chặn Delete (xem lại từ bản nháp trước — ban đầu đề xuất tính vào để đơn giản hoá quy tắc, nhưng cân nhắc lại thấy không tương xứng bản chất, đã loại bỏ theo góp ý duyệt tài liệu) |
| **Department** | **Không** | Đây là thực thể mà nhân viên *thuộc về* (tham chiếu tới), không phải dữ liệu *do* nhân viên tạo ra. Xoá nhân viên không ảnh hưởng Department, nên không liên quan tới quy tắc này |
| **Company Settings** | **Không** | Cấu hình toàn công ty, không gắn với một nhân viên cụ thể nào |

**Tóm gọn quy tắc:** *Business Data = Attendance + Leave Request.* Chỉ cần **một bản ghi duy nhất** ở một trong hai loại này từng tồn tại (kể cả sau đó đơn nghỉ phép bị từ chối) → hồ sơ nhân viên đó **không bao giờ được xoá nữa**, chỉ còn Inactive là lựa chọn hợp lệ. Notification **không** nằm trong điều kiện chặn — một nhân viên chỉ từng nhận thông báo nhưng chưa từng chấm công/xin nghỉ phép vẫn được phép xoá thẳng.

---

## 5. Delete Rule — đánh giá các phương án

### Phương án A (đề xuất) — Cấm Delete vĩnh viễn khi đã có Business Data, không thêm trạng thái mới

| Tiêu chí | Đánh giá |
|---|---|
| An toàn dữ liệu | Cao nhất — không có cách nào vô tình phá dữ liệu lương/kiểm toán, vì điều kiện chặn dựa thẳng vào sự tồn tại của dữ liệu, không dựa vào một cờ trung gian có thể bị set sai |
| Trải nghiệm người dùng | Đơn giản, dễ giải thích: "hồ sơ chưa từng dùng thì xoá được, đã dùng rồi thì không" — không cần nhớ quy trình nhiều bước |
| Độ phức tạp | Thấp — không thêm trạng thái, không thêm màn hình, chỉ thêm 1 điều kiện kiểm tra trước khi cho xoá |
| Phù hợp quy mô đồ án | Rất phù hợp |

### Phương án B — Thêm trạng thái Archived riêng biệt

| Tiêu chí | Đánh giá |
|---|---|
| An toàn dữ liệu | Tương đương phương án A |
| Trải nghiệm người dùng | Rõ ràng hơn về mặt khái niệm ("tạm khoá" khác "nghỉ hẳn") nhưng đòi hỏi người dùng học thêm 1 khái niệm |
| Độ phức tạp | Cao hơn hẳn — cần màn hình/bộ lọc riêng cho danh sách đã Archive để không làm rối danh sách chính, cần luồng chuyển Inactive → Archived (ai chuyển, khi nào, có tự động không) |
| Phù hợp quy mô đồ án | **Không phù hợp ở giai đoạn hiện tại** — chưa có nhu cầu nghiệp vụ cụ thể nào đòi hỏi phân biệt "tạm khoá" khỏi "nghỉ hẳn" ngoài mục đích tổ chức màn hình — xem điều kiện để thêm lại ở mục 6 |

### Phương án C — Xoá mềm có thời hạn ân hạn (kiểu Google Workspace/Entra ID: đánh dấu xoá, xoá thật sau N ngày)

| Tiêu chí | Đánh giá |
|---|---|
| An toàn dữ liệu | Cao, có thêm lớp "hối lại được trong N ngày" |
| Trải nghiệm người dùng | Tốt cho trường hợp xoá nhầm |
| Độ phức tạp | Cao — cần cơ chế theo dõi thời gian, tác vụ dọn dẹp định kỳ |
| Phù hợp quy mô đồ án | Không phù hợp bây giờ — không có yêu cầu nghiệp vụ nào đặt ra khung thời gian ân hạn cụ thể, thêm vào sẽ là over-engineering |

### Phương án D — Xoá tự động sau N năm theo quy định lưu trữ hồ sơ lao động

| Tiêu chí | Đánh giá |
|---|---|
| An toàn dữ liệu | Khớp đúng tinh thần luật lao động (hồ sơ lương thường phải lưu tối thiểu vài năm) |
| Trải nghiệm người dùng | Không cần thao tác tay |
| Độ phức tạp | Cao nhất trong các phương án — cần tác vụ tự động, cần biết chính xác quy định lưu trữ áp dụng |
| Phù hợp quy mô đồ án | Không phù hợp — chưa có yêu cầu tuân thủ pháp lý cụ thể nào cho đồ án tốt nghiệp |

**Kết luận: chọn Phương án A.** Đơn giản nhất, an toàn nhất, khớp đúng tiền lệ các hệ thống nghiêm túc (mục 6), không thêm gì thừa cho quy mô hiện tại.

---

## 6. Đối chiếu thực tế doanh nghiệp

| Hệ thống | Cách xử lý khi nhân viên nghỉ việc | Có gần với dự án này không |
|---|---|---|
| **SAP SuccessFactors / Workday** | Chuyển trạng thái "Terminated", khoá truy cập ngay, **không có khái niệm xoá** hồ sơ đã có giao dịch — hồ sơ tồn tại vĩnh viễn. Có nhiều trạng thái trung gian (Leave of Absence, Retired, Terminated...) | Đúng nguyên tắc cốt lõi ("không xoá dữ liệu đã giao dịch"), nhưng **quá nhiều trạng thái** so với nhu cầu hiện tại |
| **Odoo / ERPNext** | Nút "Archive" là hành động chính khi nhân viên nghỉ việc; nút Delete bị ẩn/hạn chế khi đã có bản ghi liên quan (chấm công, bảng lương...) | **Gần nhất với quy mô dự án này** — chỉ 1-2 trạng thái đơn giản + 1 hành động xoá có điều kiện |
| **Oracle HCM** | Tương tự SAP/Workday, nhiều trạng thái, quy trình phê duyệt phức tạp | Quá phức tạp so với nhu cầu |
| **Microsoft Entra ID / Google Workspace** | "Disable account" (giữ dữ liệu) và "Delete" có **thời gian ân hạn ~30 ngày** trước khi xoá thật | Ý tưởng hay (xoá mềm có ân hạn) nhưng là hệ thống định danh, không phải HRM — và thêm cơ chế theo thời gian là over-engineering ở giai đoạn này (ghi nhận là hướng phát triển tương lai, xem mục 8) |

**Mô hình gần nhất và phù hợp nhất để tham chiếu: Odoo/ERPNext** — 2 trạng thái đơn giản (Active/Archived hoặc tương đương Active/Inactive ở đây) cộng với 1 quy tắc chặn Delete dựa trên sự tồn tại của dữ liệu liên quan, không có quy trình nhiều bước.

---

## 7. Đánh giá riêng cho quy mô đồ án hiện tại

Với quy mô một đồ án tốt nghiệp (không phải sản phẩm thương mại vận hành thật), **Phương án A** là lựa chọn hợp lý nhất vì:

- Không thêm khái niệm mới nào ngoài những gì đã có (Active/Inactive) — người dùng không cần học thêm quy trình.
- Giải quyết đúng rủi ro thật đã xác định (phá dữ liệu Attendance/Leave Request), không chỉ giải quyết rủi ro phụ (tài khoản đăng nhập mồ côi — vẫn còn tồn tại nhưng không còn là trọng tâm bảo vệ chính).
- Không xây thêm màn hình, bộ lọc, hay cơ chế tự động nào — đúng tinh thần "không over-engineering" đã đặt ra từ đầu cho toàn bộ `ROADMAP.md`.

---

## 8. Hướng phát triển tương lai (không làm bây giờ)

Ghi nhận lại để không quên, không đưa vào phạm vi hiện tại:

- **Trạng thái Archived riêng biệt** — nên cân nhắc thêm lại nếu sau này có nhu cầu thật: ví dụ cần một màn hình "Nhân viên đã nghỉ việc" tách khỏi danh sách đang làm việc, hoặc cần phân biệt "tạm nghỉ có thời hạn" (thai sản, nghỉ không lương dài hạn) khỏi "nghỉ việc hẳn".
- **Xoá mềm có thời gian ân hạn** (kiểu Entra ID/Google Workspace) — nếu sau này cần một lớp bảo vệ chống xoá nhầm ngay cả với hồ sơ chưa có Business Data.
- **Xoá tự động theo quy định lưu trữ hồ sơ lao động** — chỉ cần thiết nếu dự án tiến tới giai đoạn triển khai thật cho một doanh nghiệp cụ thể, lúc đó cần xác nhận quy định lưu trữ hồ sơ lương/chấm công áp dụng.

---

## 9. Đề xuất đổi tên TD-02

Tên cũ **"Ràng buộc xoá nhân viên: chỉ cho phép khi `isActive == false`"** không còn phản ánh đúng bản chất — thiết kế mới không dùng `isActive` làm điều kiện xoá nữa.

**Đề xuất tên mới:** *"Chặn xoá nhân viên đã phát sinh dữ liệu nghiệp vụ (Chấm công/Nghỉ phép) — tách rời hoàn toàn khỏi trạng thái `isActive`"* (tiếng Anh nếu cần: *"Prevent deleting employees with business records (Attendance/Leave Request), decoupled from isActive"*).

---

## 10. Đề xuất cập nhật tài liệu khác (CHƯA thực hiện — chỉ đề xuất)

| Tài liệu | Có cần cập nhật không | Nội dung đề xuất |
|---|---|---|
| `docs/project/01_BACKLOG.md` | **Có** | Đổi tên + mô tả TD-02 theo mục 9 ở trên; cập nhật lại phần "Giải pháp" trong mô tả task để phản ánh quy tắc Business Data thay vì `isActive` |
| `docs/project/02_SPRINT.md` | **Có** | Sprint 1 đang liệt kê TD-02 với mô tả cũ — cần cập nhật câu mô tả task cho khớp tên/nội dung mới |
| `docs/decision/01_DECISION_LOG.md` | **Có, nên thêm 1 entry mới** | Đây đúng là loại quyết định Decision Log được tạo ra để lưu lại: có bối cảnh rõ ràng (thiết kế cũ sai tiêu chí), có lý do (tách bạch quyền truy cập khỏi khả năng xoá), có phương án so sánh (mục 5), có ảnh hưởng lâu dài (định nghĩa lại toàn bộ vòng đời nhân viên). Nội dung đề xuất: tóm tắt quyết định "Delete Rule dựa trên Business Data, không dựa trên isActive" + tham chiếu tới tài liệu này |

Ba cập nhật trên đã được thực hiện sau khi tài liệu này được duyệt — xem `docs/decision/01_DECISION_LOG.md`, `docs/project/01_BACKLOG.md`, `docs/project/02_SPRINT.md`.

---

## 11. Non-goals — cố ý không giải quyết trong phạm vi đồ án

Ghi rõ để không ai (kể cả người đọc sau này) hiểu nhầm đây là thiếu sót — đây là ranh giới phạm vi có chủ đích:

- **Không xây trạng thái Archived riêng biệt** — xem lý do ở mục 5/6, điều kiện để thêm lại ở mục 8.
- **Không xây cơ chế xoá mềm có thời gian ân hạn** (kiểu Google Workspace/Entra ID) — không có yêu cầu nghiệp vụ cụ thể nào cần "hối lại trong N ngày".
- **Không xây cơ chế xoá/lưu trữ tự động theo quy định pháp luật lao động** — dự án không nhắm tới triển khai thật cho một doanh nghiệp cụ thể nên không có quy định lưu trữ hồ sơ nào cần tuân thủ chính xác.
- **Không giải quyết vấn đề tài khoản đăng nhập (Firebase Auth) mồ côi** — việc không xoá được tài khoản đăng nhập tương ứng khi xoá hồ sơ vẫn tồn tại như một giới hạn đã biết (cần Admin SDK/Cloud Function, ngoài phạm vi kiến trúc hiện tại — xem `OOS-07` ở `docs/project/01_BACKLOG.md`). Thiết kế trong tài liệu này giảm được rủi ro *phá dữ liệu nghiệp vụ*, nhưng **không** giải quyết rủi ro tài khoản mồ côi.
- **Không thêm nhiều trạng thái trung gian kiểu SAP/Workday** (Leave of Absence, Retired, On Probation...) — không có nhu cầu nghiệp vụ nào trong phạm vi đồ án đòi hỏi phân biệt các loại "không hoạt động" khác nhau.
- **Không thiết kế lại quyền hạn ai được chuyển trạng thái** — mặc định toàn bộ hành động (Active ⇄ Inactive, Delete) chỉ do Admin thực hiện, không có khái niệm phân quyền nhiều cấp (ví dụ HR-only vs Admin-only) trong phạm vi hiện tại.
- **Không định nghĩa lại Notification hay xây màn hình hiển thị Notification** — tài liệu này chỉ kết luận Notification không thuộc Business Data cho mục đích chặn Delete, không đánh giá lại toàn bộ tính năng Notification (việc đó thuộc phạm vi Phase A khác — xem `FEAT-02` ở `docs/project/01_BACKLOG.md`).
