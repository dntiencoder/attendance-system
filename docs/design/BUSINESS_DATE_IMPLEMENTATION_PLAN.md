# Business Date — Phân tích bổ sung & Kế hoạch triển khai

> Tài liệu phân tích + kế hoạch. **Chưa cài đặt, chưa sửa bất kỳ file source nào.**
> Nối tiếp `docs/design/BUSINESS_DATE_DESIGN.md`. Trả lời 2 yêu cầu review trước khi triển khai.

---

## Yêu cầu 1 — `rotationDays` hardcode & RotationCalculator

### 1.1 Có nên tách `RotationCalculator` riêng, hay chỉ sửa `getCurrentShift()` là đủ?

**Việc bắt buộc phải làm dù chọn phương án nào:** thay `(daysPassed / 14).floor()` bằng `(daysPassed / rotationDays).floor()`. Đây là sửa lỗi tối thiểu, 1 dòng, không thể bỏ qua bất kể có tách class hay không.

**Câu hỏi thực sự cần quyết định:** có đáng để tách phần tính rotation (~15 dòng) ra khỏi `CompanySettingsModel` thành một class thuần túy riêng hay không.

So sánh:

| | Sửa tại chỗ trong `getCurrentShift()` | Tách `RotationCalculator` riêng |
|---|---|---|
| Phạm vi thay đổi | 1 dòng trong 1 file đã có | 1 file mới + `getCurrentShift()` trở thành wrapper gọi sang |
| Rủi ro | Thấp nhất — đúng tinh thần "chỉ sửa cái cần" | Thấp — nhưng về hình thức là thêm 1 class mới, đụng nhẹ tới ranh giới "domain = không chứa business logic" mà CLAUDE.md mô tả (ranh giới này thực ra **đã bị vi phạm từ trước** bởi chính `getCurrentShift()`/`calculateIsLate()`/`calculateEarlyLeave()` nằm trong domain model — không phải vi phạm mới do việc tách gây ra, mà là dọn lại một vi phạm đã tồn tại) |
| Test độc lập | Phải dựng cả `CompanySettingsModel` (nhiều field bắt buộc: lat/lng/radius/...) mới test được rotation | Test thuần: `RotationCalculator.getCurrentShift(rotationStartDate, rotationDays, shiftGroup, today)` — không cần field nào khác |
| Liên quan đến `BusinessDateHelper` | `BusinessDateHelper` gọi `settings.getCurrentShift(...)` như thiết kế gốc, không đổi | `BusinessDateHelper` **vẫn gọi `settings.getCurrentShift(...)` y hệt** — vì `CompanySettingsModel.getCurrentShift()` được giữ nguyên chữ ký, chỉ ủy quyền nội bộ sang `RotationCalculator`. **API công khai của `BusinessDateHelper` không đổi ở cả 2 phương án.** |
| Phù hợp convention hiện có | — | Có: `core/utils/` đã có sẵn các static helper cùng dạng (`DateHelper`, `WorkScheduleHelper`) — `RotationCalculator` khớp đúng pattern này |
| Động lực thực tế | — | Đây là hàm đã gây ra **2 bug riêng biệt** trong 2 lượt phân tích gần đây (P1-02: `rotationStartDate` null crash; hiện tại: hardcode 14) — mật độ lỗi cao, xứng đáng được cô lập để review/test kỹ hơn, độc lập khỏi phần parse Firestore của model |

**Đã xác nhận:** tách `RotationCalculator` (static, pure function, đặt tại `core/utils/rotation_calculator.dart`), với `CompanySettingsModel.getCurrentShift()` giữ nguyên chữ ký cũ và chỉ gọi ủy quyền — nhờ vậy **không có call site nào trong 4 nơi đang gọi `getCurrentShift()` hiện tại cần sửa** ở bước này.

### 1.2 Có phát sinh circular dependency giữa `BusinessDateHelper` và `getCurrentShift()` không?

**Về mặt kiến trúc/import (circular dependency đúng nghĩa kỹ thuật): không.** Chiều phụ thuộc chỉ một hướng: `BusinessDateHelper` → gọi → `CompanySettingsModel.getCurrentShift()` (hoặc `RotationCalculator` nếu tách). Không có chiều ngược lại — `CompanySettingsModel`/`RotationCalculator` không biết và không gọi `BusinessDateHelper`. Không file nào import lẫn nhau theo vòng tròn.

**Về mặt logic nghiệp vụ (đã nêu ở `BUSINESS_DATE_DESIGN.md` mục 3.1): có một vòng lặp khái niệm**, nhưng đã được giải quyết bằng thuật toán (không phải bằng kiến trúc): `resolveBusinessDate()` không bao giờ hỏi "hôm nay đang là ca gì" (câu hỏi mơ hồ, cần biết business date để trả lời chính xác) — nó chỉ hỏi "**hôm qua** (một ngày dương lịch cụ thể, luôn xác định rõ ràng) nhóm ca này có làm đêm không". Vì "hôm qua" luôn là một mốc dứt khoát, không cần vòng lặp giải quyết trước, vấn đề tự tiêu biến ở tầng thuật toán.

**Kết luận:** không cần kiến trúc đặc biệt gì để "tránh circular dependency" vì không có circular dependency ở tầng code. Việc tách hay không tách `RotationCalculator` không ảnh hưởng gì tới việc giải quyết vòng lặp logic — vòng lặp đó đã được giải quyết xong trong thiết kế `resolveBusinessDate()`, độc lập với quyết định ở mục 1.1.

---

## Yêu cầu 2 — Nghiệp vụ Check Out ca đêm

Bối cảnh: ca đêm 04/07 20:00 → 05/07 08:00, nhân viên nhóm A (làm đêm ngày 04/07 theo rotation), đã check-in lúc 20:xx ngày 04/07 (document `2026-07-04_uid` đã tồn tại, `checkOut: null`).

### 2.1 Vấn đề: `resolveBusinessDate()` một mình KHÔNG đủ cho Check Out

`resolveBusinessDate(now, settings, shiftGroup)` (thiết kế ở tài liệu trước) chỉ đúng cho **Check In** và **hiển thị Home** — những nơi cần biết "bây giờ đang thuộc ngày làm việc nào để **tạo mới** hoặc **hiển thị**". Check Out khác về bản chất: nó không tạo gì mới, nó cần **tìm đúng document đã tồn tại và đang mở** (`checkOut == null`) để đóng lại. Nếu áp dụng máy móc `resolveBusinessDate(now)` cho check-out, ngay tại **08:01** — chỉ trễ 1 phút so với giờ tan ca — kết quả sẽ nhảy sang `05/07` (ra khỏi "khung nhạy cảm" `[00:00, 08:00]`), khiến hệ thống đi tìm document `2026-07-05_uid` **chưa hề tồn tại**, và báo nhầm "Bạn chưa Check In hôm nay" cho một nhân viên chỉ đơn giản là bấm Check Out hơi trễ 1 phút.

→ **Cần một quy tắc riêng cho Check Out**, có "khung ân hạn" (grace window) sau giờ tan ca, thay vì chỉ dùng đúng 1 lần `resolveBusinessDate()`.

### 2.2 Quy tắc đề xuất cho Check Out

```
resolveCheckoutTarget(now, settings, shiftGroup):
  1. candidate = resolveBusinessDate(now, settings, shiftGroup)
  2. Thử tìm document tại candidate (docId = "<candidate>_<uid>")
     - Nếu tồn tại và checkOut == null -> dùng document này. XONG.
  3. Nếu không tìm thấy ở bước 2, VÀ candidate == hôm nay theo lịch (nghĩa là
     resolveBusinessDate không rollback, tức đang ngoài khung nhạy cảm):
     - Thử tìm document của HÔM QUA (candidate - 1 ngày).
     - Nếu tồn tại, shift == 'night', checkOut == null,
       VÀ (now - nightShiftEnd của document đó) <= 2 giờ (xem 2.3)
       -> dùng document hôm qua. XONG.
  4. Không tìm thấy gì phù hợp -> từ chối, báo lỗi phù hợp (xem bảng 2.4).
```

Đây là một hàm **khác** `resolveBusinessDate()`, dùng riêng cho `checkOut()` — không dùng cho `checkIn()`/Home.

### 2.3 Khung ân hạn Check Out — Đã xác nhận

**Phương án B — ngưỡng giờ cố định: 2 giờ sau giờ tan ca.** Với ca đêm kết thúc 08:00, Check Out muộn được chấp nhận tới **10:00** (bao gồm đúng 10:00); từ sau 10:00 bị từ chối.

Hằng số "2 giờ" là hardcode trong code (không thêm field mới vào `CompanySettingsModel`/Firestore — giữ đúng ràng buộc "không đổi schema").

### 2.4 Bảng phân tích 8 trường hợp Check Out (theo ngưỡng 2 giờ đã chốt)

| # | Giờ Check Out | Business Date | docId cần cập nhật | attendanceDate | Cho phép? | Thông báo nếu từ chối |
|---|---|---|---|---|---|---|
| 1 | 07:59 (05/07) | 04/07 | `2026-07-04_uid` | 04/07 | **Có** — trong ca, về sớm 1 phút (`isEarlyLeave = true`) | — |
| 2 | 08:00 (05/07) | 04/07 | `2026-07-04_uid` | 04/07 | **Có** — đúng giờ tan ca, `isEarlyLeave = false` | — |
| 3 | 08:01 (05/07) | 04/07 *(qua bước 3 của `resolveCheckoutTarget`, không phải qua `resolveBusinessDate` trực tiếp)* | `2026-07-04_uid` | 04/07 | **Có** — trễ 1 phút, trong ngưỡng 2 giờ | — |
| 4 | 08:30 (05/07) | 04/07 | `2026-07-04_uid` | 04/07 | **Có** — trễ 30 phút, trong ngưỡng 2 giờ | — |
| 5 | 09:00 (05/07) | 04/07 | `2026-07-04_uid` | 04/07 | **Có** — trễ 1 giờ, trong ngưỡng 2 giờ | — |
| 6 | 10:00 (05/07) | 04/07 | `2026-07-04_uid` | 04/07 | **Có** — đúng biên ngưỡng (trễ đúng 2 giờ, biên đóng — vẫn cho phép) | — |
| 7 | 12:00 (05/07) | — | `2026-07-04_uid` **không còn được coi hợp lệ** | — | **Không** — trễ 4 giờ, vượt ngưỡng 2 giờ | "Đã quá thời gian cho phép Check Out cho ca làm việc ngày 04/07 (quá 2 giờ so với giờ tan ca 08:00). Vui lòng liên hệ quản lý để được hỗ trợ điều chỉnh chấm công." |
| 8 | "Ngày hôm sau" (06/07 trở đi) | — | `2026-07-04_uid` **không còn được coi hợp lệ** | — | **Không** — đã qua khung ân hạn từ lâu | "Không tìm thấy ca làm việc cần Check Out hợp lệ. Vui lòng liên hệ quản lý/admin để được hỗ trợ điều chỉnh chấm công thủ công." |

### 2.5 Hệ quả cần lưu ý (không giải quyết trong tài liệu này)

- Nếu nhân viên **không bao giờ quay lại Check Out** document `04/07`, nó sẽ mãi mãi ở trạng thái mở (`checkOut: null`, `workHours: null`). Đây là khoảng trống đã tồn tại từ trước (không phải do thiết kế Business Date gây ra) — hệ thống hiện không có cơ chế admin tự sửa tay một bản ghi attendance cụ thể. Nêu ra để bạn biết, không đề xuất xử lý trong phạm vi kế hoạch này.
- Vì nhóm A vẫn làm ca đêm liên tục trong cùng block 14 ngày, ca đêm **tiếp theo** của họ (05/07 20:00 → 06/07 08:00) là một document **hoàn toàn khác** (`2026-07-05_uid`), độc lập với document `04/07` còn đang mở. Hai document không xung đột nhau, chỉ là dữ liệu `04/07` sẽ bị "treo" nếu không ai check-out.

---

## Kế hoạch triển khai (chờ xác nhận riêng cho từng phương án còn mở ở trên trước khi bắt đầu)

### TASK 1 — Sửa `getCurrentShift()` dùng `rotationDays` thay vì hardcode `14`
- **File:** `attendance_mobile/lib/features/settings/domain/company_settings_model.dart`
- **Mức độ rủi ro:** Thấp–Trung bình. Rủi ro thực sự phụ thuộc dữ liệu Firestore hiện tại: nếu `company_settings.rotationDays` đang lưu đúng `14`, hành vi không đổi gì. Nếu đang lưu giá trị khác `14`, đây là **thay đổi hành vi thực sự** (rotation sẽ tính lại theo chu kỳ khác) — cần kiểm tra giá trị thật trong Firestore Console trước khi merge, không chỉ đọc code.
- **Cách test:** Đọc giá trị `rotationDays` hiện tại trong Firestore Console trước khi sửa. Viết test thủ công/`flutter test` gọi `getCurrentShift()` với `rotationDays = 7` và `rotationDays = 14` cho cùng bộ ngày, xác nhận kết quả rotationIndex đổi đúng theo chu kỳ cấu hình.

### TASK 2 — Tách `RotationCalculator`
- **File:** mới `attendance_mobile/lib/core/utils/rotation_calculator.dart`; sửa `company_settings_model.dart` để `getCurrentShift()` ủy quyền sang class mới (chữ ký `getCurrentShift()` giữ nguyên).
- **Mức độ rủi ro:** Thấp — thuần chuyển vị trí code, không đổi API, 4 call site hiện tại (`attendance_repository.dart`, `attendance_provider.dart`, `home_provider.dart`, `attendance_history_provider.dart`) không cần sửa.
- **Cách test:** So sánh output `getCurrentShift()` cho một tập ngày mẫu (bao gồm các ngày quanh ranh giới đổi block) **trước và sau** khi tách, phải giống hệt nhau tuyệt đối.

### TASK 3 — Tạo `BusinessDateHelper.resolveBusinessDate()`
- **File:** mới `attendance_mobile/lib/core/utils/business_date_helper.dart`
- **Mức độ rủi ro:** Thấp — file mới, chưa được gọi ở đâu cả, không ảnh hưởng runtime cho tới khi Task 4/5/6 tích hợp.
- **Cách test:** Unit test đầy đủ 12 test case đã liệt kê ở `BUSINESS_DATE_DESIGN.md` mục 4 (bao gồm test case ranh giới đổi block 14 ngày).

### TASK 3B — Thiết kế `resolveCheckoutTarget()` cho Check Out
- **File:** cùng `business_date_helper.dart` (thêm hàm), hoặc đặt trực tiếp trong `AttendanceRepository.checkOut()` — quyết định vị trí đặt code sẽ chốt khi bắt tay viết code, không ảnh hưởng thiết kế.
- **Mức độ rủi ro:** Trung bình — rule nghiệp vụ mới (ngưỡng ân hạn 2 giờ, hardcode trong code, không đổi schema).
- **Cách test:** Test thủ công đúng 8 mốc giờ ở mục 2.4, đặc biệt biên 10:00 (cho phép) và 12:00 (từ chối).

### TASK 4 — Tích hợp vào `AttendanceRepository`
- **File:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (`checkIn()`, `checkOut()`, `getTodayAttendance()`)
- **Mức độ rủi ro:** **Cao nhất trong toàn kế hoạch** — đây là nơi ghi dữ liệu thật vào Firestore (`docId`, `attendanceDate`). Sai sót ảnh hưởng trực tiếp dữ liệu chấm công thật của nhân viên. `docId` vẫn giữ đúng format `<yyyy-MM-dd>_<uid>` nên không ảnh hưởng `firestore.rules` đã viết (P1-05) — chỉ đổi giá trị ngày được điền vào, không đổi cấu trúc.
- **Cách test:** Test thủ công toàn bộ 8 mốc giờ Check Out (mục 2.4) + các mốc Check In tương ứng (mục 4 của `BUSINESS_DATE_DESIGN.md`) bằng cách chỉnh giờ hệ thống thiết bị test (không thêm package mock thời gian). Kiểm tra kỹ: `docId` đúng, `attendanceDate` đúng, không tạo trùng document, không có document nào bị cập nhật nhầm.

### TASK 5 — `HomeProvider._determineAutoShift()`
- **File:** `attendance_mobile/lib/features/home/presentation/home_provider.dart`
- **Mức độ rủi ro:** Thấp–Trung bình — chỉ ảnh hưởng hiển thị, không ghi dữ liệu.
- **Cách test:** Mở màn Home ở các mốc giờ khác nhau (chỉnh giờ thiết bị), xác nhận hiển thị đúng ca — đặc biệt xác nhận đúng ca đêm tại 00:18 (ca gốc trong yêu cầu ban đầu).

### TASK 6 — `AttendanceProvider.loadTodayAttendance()`
- **File:** `attendance_mobile/lib/features/attendance/presentation/attendance_provider.dart`
- **Mức độ rủi ro:** Trung bình — ảnh hưởng cả việc xác định "đã hết ca chưa" (`isShiftEnded`) hiển thị trên màn Attendance.
- **Cách test:** Tương tự Task 5, kiểm tra thêm cờ `isShiftEnded` hiển thị đúng ở các mốc giờ biên.

### TASK 7 — `WorkScheduleHelper.countAbsentDays()` (làm cùng đợt này)
- **File:** `attendance_mobile/lib/core/utils/work_schedule_helper.dart` và nơi gọi nó `attendance_mobile/lib/features/home/presentation/home_provider.dart:_loadMonthlyStats()`
- **Mức độ rủi ro:** Trung bình-Cao hơn các task khác — hàm này hiện **không nhận `shiftGroup`** làm tham số, trong khi Business Date cần biết `shiftGroup`. Cần đổi chữ ký hàm (`countAbsentDays({required month, required attendanceDates, required shiftGroup, required settings})`), kéo theo phải sửa cả `_loadMonthlyStats()` để truyền thêm `shiftGroup`/`settings`. Phạm vi lan rộng hơn Task 1-6 vì đổi chữ ký hàm dùng chung.
- **Cách test:** So sánh số ngày vắng tính ra trước/sau ở các tháng có chứa ranh giới rotation, đối chiếu thủ công.

### Ngoài phạm vi kế hoạch này (đã xác nhận ở tài liệu trước)

- `attendance_history_provider.dart` (dòng gọi `getCurrentShift(today: date)` cho từng ngày lịch sử cụ thể) — không cần `BusinessDateHelper` vì đang lặp qua các ngày đã biết trước, không phải "resolve từ `now`".
- `attendance_admin/.../dashboard_repository.dart` — cần thiết kế truy vấn riêng (đã nêu ở `BUSINESS_DATE_DESIGN.md` mục 5), không nằm trong kế hoạch mobile này.
- Các file thuần hiển thị: `home_screen.dart`, `home_header.dart`, `attendance_record_list.dart`.

---

## Quyết định đã chốt

1. **Tách `RotationCalculator`** — thực hiện (Task 2).
2. **Khung ân hạn Check Out** — Phương án B, ngưỡng cố định **2 giờ** sau giờ tan ca (hardcode, không đổi schema).
3. **Kiểm tra `rotationDays` thật trong Firestore trước Task 1** — sẽ thực hiện, xem điều kiện tiên quyết bên dưới.
4. **Task 7 (`countAbsentDays`)** — làm cùng đợt này.

## Điều kiện tiên quyết còn lại trước khi bắt đầu Task 1

Theo quyết định #3, cần biết giá trị thật của `company_settings.rotationDays` trong Firestore trước khi sửa hardcode `14`, để biết chắc thay đổi có làm đổi hành vi rotation thực tế hay không. Tôi không có quyền truy cập trực tiếp Firestore của project (`attendance-management-sy-34105`) từ môi trường này — bạn vui lòng kiểm tra qua Firebase Console (Firestore Database → `company_settings` → document `main` → field `rotationDays`) và cho tôi biết giá trị hiện tại, hoặc xác nhận để tôi tiến hành với giả định giá trị đang là `14` (khớp default fallback trong `fromFirestore`).

Sau khi có giá trị này, tôi sẽ bắt đầu triển khai lần lượt Task 1 → Task 7 theo đúng kế hoạch, mỗi task vẫn tuân thủ quy trình: sửa xong → hiển thị diff → giải thích thay đổi → đề xuất test → chờ xác nhận trước khi sang task kế tiếp.
