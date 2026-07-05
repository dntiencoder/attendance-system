# Thiết kế lại nghiệp vụ chấm công (Business Flow gốc)

> Tài liệu thiết kế tổng thể. **Chưa sửa bất kỳ dòng code nào.**
> Thay thế cách tiếp cận "vá từng bug" trước đây. Gộp và thay thế `docs/design/BUSINESS_DATE_DESIGN.md` +
> `docs/design/BUSINESS_DATE_IMPLEMENTATION_PLAN.md` thành một luồng nghiệp vụ duy nhất, có bổ sung Bug 3 (mới phát hiện).
> Giữ nguyên kiến trúc project, Firestore schema, UI hiện tại — chỉ thiết kế lại **thứ tự và nơi đưa ra quyết định**.

---

## 1. Phân tích toàn bộ nghiệp vụ chấm công

Bản chất nghiệp vụ chấm công của hệ thống này là trả lời đúng thứ tự 4 câu hỏi, cho MỌI hành động (mở Home, CheckIn, CheckOut):

1. **"Bây giờ đang thuộc về ngày làm việc nào?"** (Business Date) — không phải lúc nào cũng là ngày trên lịch, vì ca đêm xuyên qua nửa đêm thuộc về ngày nó bắt đầu.
2. **"Nhóm ca của nhân viên này làm ca gì vào đúng ngày làm việc đó?"** (Shift) — phụ thuộc rotation (nhóm A/B, `rotationDays`, `rotationStartDate`), tính trên Business Date, không phải ngày lịch hiện tại.
3. **"Ca đó, về mặt đồng hồ tuyệt đối, bắt đầu và kết thúc lúc nào?"** (Shift Window) — một khi đã biết Business Date + Shift, hai mốc này là cố định, không còn gì mơ hồ.
4. **"Bây giờ đang ở đâu trong khung giờ đó?"** (chưa tới giờ / trong giờ / đã quá giờ) — quyết định có cho CheckIn/CheckOut không, và tính `isLate`/`isEarlyLeave`.

**Nguyên nhân gốc của toàn bộ 4 bug đang gặp:** hệ thống hiện tại **không có bước 1 và bước 3** như một khái niệm tường minh, thống nhất. Mỗi hàm (`checkIn()`, `checkOut()`, `getTodayAttendance()`, `_determineAutoShift()`, `calculateIsLate()`, `calculateEarlyLeave()`, `loadTodayAttendance()`) tự suy luận "hôm nay"/"giờ bắt đầu ca"/"giờ kết thúc ca" theo cách riêng của nó, dùng thẳng `DateTime.now()` và tự viết lại phép cộng/trừ ngày cho ca đêm — dẫn đến 4-5 phiên bản logic gần giống nhau nhưng không đồng nhất (Bug 4 chính là triệu chứng của việc thiếu 1 điểm neo duy nhất).

---

## 2. Luồng xử lý: Home → CheckIn → CheckOut

```
┌─────────────────────────────────────────────────────────────────────┐
│  MỞ HOME                                                             │
│  ─────────                                                           │
│  B1. resolveBusinessDate(now, settings, shiftGroup)                  │
│  B2. RotationCalculator.getCurrentShift(rotationStartDate,           │
│        rotationDays, shiftGroup, businessDate)                       │
│  B3. resolveShiftWindow(businessDate, shift, settings)                │
│         -> {start, end}                                              │
│  B4. Đọc todayAttendance = get(docId = "<businessDate>_<uid>")        │
│         - Nếu tồn tại  -> hiển thị theo dữ liệu ĐÃ CHỐT lúc CheckIn   │
│                           (attendance.shift, không tính lại)          │
│         - Nếu chưa có  -> hiển thị "ca dự kiến" = shift từ B2,        │
│                           kèm trạng thái nút CheckIn:                 │
│                             now < start - 60' -> disable, "Chưa tới   │
│                                                    giờ Check In"      │
│                             now trong [start-60', end] -> enable      │
│                             now > end    -> disable, "Đã hết ca"      │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼  (nhân viên bấm Check In)
┌─────────────────────────────────────────────────────────────────────┐
│  CHECK IN                                                            │
│  ────────                                                            │
│  1. Business Date  = resolveBusinessDate(now, settings, shiftGroup)   │
│  2. Shift          = RotationCalculator.getCurrentShift(...)         │
│  3. Shift Window   = resolveShiftWindow(businessDate, shift, settings)│
│  4. now < window.start.subtract(60 phút) ?                            │
│         -> TỪ CHỐI: "Chưa tới giờ Check In (mở lúc {start-60'})"      │
│  5. now > window.end ?                                                │
│         -> TỪ CHỐI: "Ca làm việc đã kết thúc, hôm nay tính vắng mặt"  │
│  6. docId = "<businessDate>_<uid>"; đã tồn tại chưa?                  │
│         -> TỪ CHỐI: "Bạn đã Check In hôm nay rồi"                     │
│  7. isLate = now.isAfter(window.start)  (KHÔNG đổi bởi Bước 4 —       │
│       check-in sớm trong 60' vẫn có thể isLate=false; check-in sau   │
│       window.start dù chỉ 1 phút vẫn isLate=true)                     │
│  8. Lưu Firestore: attendanceDate = businessDate, checkIn = now,      │
│       shift, isLate, status, GPS fields (không đổi so với hiện tại)   │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼  (nhân viên bấm Check Out, có thể trễ)
┌─────────────────────────────────────────────────────────────────────┐
│  CHECK OUT                                                           │
│  ─────────                                                           │
│  1. candidate = resolveBusinessDate(now, settings, shiftGroup)        │
│  2. Thử đọc doc tại candidate (docId="<candidate>_<uid>")             │
│       - Tồn tại & checkOut == null -> DÙNG DOC NÀY, sang bước 4       │
│  3. Không thấy & candidate == hôm nay (không rollback) ->             │
│       thử doc của HÔM QUA (candidate - 1 ngày):                       │
│       - Tồn tại, shift=='night', checkOut==null,                      │
│         VÀ (now - shiftWindow(hôm qua).end) <= 2 giờ                  │
│         -> DÙNG DOC NÀY, sang bước 4                                  │
│       - Ngược lại -> TỪ CHỐI (xem thông báo ở mục 5.3)                │
│  4. Lấy lại Shift Window của ĐÚNG document tìm được (dùng             │
│       attendanceDate + shift LƯU SẴN trong document, không tính lại)  │
│  5. isEarlyLeave = now.isBefore(window.end)                           │
│  6. workHours = now.difference(checkIn).inMinutes / 60                │
│  7. Cập nhật đúng document đã tìm ở bước 2/3                          │
└─────────────────────────────────────────────────────────────────────┘
```

**Nguyên tắc bao trùm:** Business Date (bước 1) chỉ được tính **một lần** cho mỗi hành động, ngay từ đầu. Mọi bước sau đó (Shift, Shift Window, isLate, isEarlyLeave, docId) đều là **hàm thuần của Business Date + Shift** — không có bước nào được phép tự ý gọi lại `DateTime.now()` để suy ra lại ngày/ca một lần nữa theo cách khác.

---

## 3. Thứ tự quyết định chuẩn (chi tiết từng bước)

| Bước | Tên | Input | Output | Hàm sở hữu |
|---|---|---|---|---|
| 1 | Xác định Business Date | `now`, `settings`, `shiftGroup` | `businessDate: DateTime` | `BusinessDateHelper.resolveBusinessDate()` |
| 2 | Xác định Shift | `businessDate`, `shiftGroup`, `rotationStartDate`, `rotationDays` | `shift: 'day'\|'night'` | `RotationCalculator.getCurrentShift()` |
| 3 | Xác định Shift Window | `businessDate`, `shift`, `settings` | `(start: DateTime, end: DateTime)` | `BusinessDateHelper.resolveShiftWindow()` |
| 4 | Kiểm tra đã tới giờ CheckIn chưa | `now`, `window.start - 60 phút` | allow / reject | Inline trong `AttendanceRepository.checkIn()` |
| 5 | Kiểm tra đã quá giờ chưa | `now`, `window.end` | allow / reject (absence) | Inline trong `AttendanceRepository.checkIn()` |
| 6 | Kiểm tra đã CheckIn ngày này chưa | `docId` | allow / reject (duplicate) | Inline trong `AttendanceRepository.checkIn()` (đã có, giữ nguyên) |
| 7 | Tính `isLate` | `now`, `window.start` | `bool` | Inline — so sánh trực tiếp, không cần hàm riêng nữa (xem mục 5.4) |
| 8 | Tạo `docId` | `businessDate`, `uid` | `String` | `DateHelper.toDateString(businessDate) + '_' + uid` (đã có, đổi input) |
| 9 | Lưu Firestore | tất cả field trên | — | `AttendanceRepository.checkIn()` (đã có, giữ nguyên cấu trúc ghi) |

Đây chính xác là thứ tự ví dụ bạn đưa ra, chỉ bổ sung Bước 4 (hiện đang **thiếu hoàn toàn** trong code — xem Bug 3) và làm rõ Bước 3 là một hàm tường minh riêng (hiện đang bị hoà lẫn vào nhiều chỗ khác nhau dưới dạng hack).

---

## 4. Toàn bộ điểm hiện tại đang sai so với luồng chuẩn

| # | Vị trí | Đang làm gì (sai) | Nên làm gì (theo luồng chuẩn) | Bug liên quan |
|---|---|---|---|---|
| 1 | `home_provider.dart` `_determineAutoShift()` | Gọi `getCurrentShift(shiftGroup, today: DateTime.now())` — dùng thẳng Calendar Date | Phải qua Bước 1 (Business Date) rồi mới Bước 2 (Shift) | **Bug 1** |
| 2 | `attendance_repository.dart` `checkIn()` | Dùng `now = DateTime.now()` trực tiếp để build `docId`/`attendanceDate` — không qua Business Date | Bước 1 trước, mọi thứ sau tính từ `businessDate` | Bug 1, Bug 4 |
| 3 | `attendance_repository.dart` `checkIn()` | Chỉ có kiểm tra "đã quá giờ chưa" (`workEnd`, tính thủ công bằng hack `if shift=='night' && hour<12 thì +1 ngày`) — **hoàn toàn không có** kiểm tra "đã tới giờ chưa" | Cần cả Bước 4 (mới, chưa tồn tại — cho phép sớm tối đa 60 phút trước `window.start`) lẫn Bước 5 (đã có nhưng cần thay hack bằng `resolveShiftWindow().end`) | **Bug 3** (nguyên nhân trực tiếp: thiếu hẳn Bước 4) |
| 4 | `company_settings_model.dart` `calculateIsLate()` | Tính `workStart = DateTime(checkInTime.year/month/day, startHour, startMinute)` — dùng **ngày lịch của thời điểm check-in**, không phải Business Date | Phải dùng `window.start` đã neo theo Business Date (Bước 3), rồi so sánh trực tiếp (Bước 7) | **Bug 2** |
| 5 | `company_settings_model.dart` `calculateEarlyLeave()` | Tự viết hack `if (checkOutTime.hour >= 12 && endHour < 12) workEnd = workEnd.add(Duration(days:1))` để xử lý ca đêm xuyên nửa đêm | Thay bằng `window.end` đã tính sẵn ở Bước 3 (Check Out dùng lại `resolveShiftWindow` của document tìm được) | Bug 4 (một biến thể khác của cùng gốc) |
| 6 | `attendance_repository.dart` `checkOut()` | Build `docId` từ `DateHelper.toDateString(DateTime.now())` — sai ngay khi Check Out muộn hơn giờ kết thúc ca (vd 08:01) vì rơi ra khỏi "khung nhạy cảm" | Cần bước tìm document mục tiêu riêng cho Check Out (mục 2, luồng Check Out bước 1-3) — không dùng thẳng `resolveBusinessDate()` một lần rồi build docId | Bug liên quan đến báo lỗi "Lịch sử chấm công"/permission-denied đã gặp trước đây, và tiềm ẩn Check Out sai document nếu không sửa |
| 7 | `attendance_repository.dart` `getTodayAttendance()` | Build `docId` từ Calendar Date hiện tại | Phải dùng `businessDate` (Bước 1) | Bug 1 (gián tiếp, vì Home/Attendance provider gọi hàm này) |
| 8 | `attendance_provider.dart` `loadTodayAttendance()` | Tự tính lại `currentShift`/`workEnd` bằng một bản sao logic riêng (không dùng chung với `checkIn()`) | Dùng lại đúng Bước 1-3, không viết lại | Bug 1, Bug 2, Bug 4 |
| 9 | `attendance_history_provider.dart` `loadRecords()` — biến `lastDayToFill` | Dùng `DateTime.now()` thô làm mốc "ngày đã qua" khi tự sinh bản ghi vắng mặt | Dùng `businessDate` (Bước 1) làm mốc, để nhất quán với ngày mà `checkIn()` thực sự dùng | Bug 4 (ảnh hưởng nhỏ, chỉ lệch quanh nửa đêm) |
| 10 | `work_schedule_helper.dart` `countAbsentDays()` | Dùng `DateTime.now()` thô làm cutoff — không nhận `shiftGroup` nên không thể tính Business Date | Đổi chữ ký nhận thêm `shiftGroup`+`settings`, dùng Bước 1 | Bug 4 (đã ghi nhận từ trước, xem mục "Ngoài phạm vi tối thiểu") |
| 11 | Toàn bộ `getCurrentShift()` (đã sửa hardcode `14` ở Task 1 trước đó) | Vẫn đúng, không có gì sai thêm — nhưng vẫn bị gọi với `today` sai (Calendar Date thay vì Business Date) ở tất cả các điểm trên | Không cần sửa thêm bản thân hàm; chỉ cần sửa **input** truyền vào tại các điểm gọi | — |

**Quan sát quan trọng:** không có điểm nào trong bảng trên cần sửa vì *bản thân thuật toán tính rotation sai* (đã sửa xong ở Task 1) — toàn bộ các lỗi còn lại đều là hệ quả của việc **thiếu một điểm neo Business Date + Shift Window duy nhất**, khiến mỗi nơi tự suy luận lại và suy luận sai theo những cách khác nhau.

---

## 5. Kiến trúc nghiệp vụ đề xuất (cuối cùng)

### 5.1 Hai file thuần (pure, không đụng Firestore) — không đổi so với kế hoạch đã thống nhất trước đó

**`attendance_mobile/lib/core/utils/rotation_calculator.dart`** (mới)
```dart
class RotationCalculator {
  RotationCalculator._();

  static String getCurrentShift({
    required DateTime rotationStartDate,
    required int rotationDays,
    required String shiftGroup,
    required DateTime date, // luôn là Business Date, không phải DateTime.now()
  }) { ... } // logic y hệt getCurrentShift() hiện tại, đã dùng rotationDays (Task 1)
}
```

**`attendance_mobile/lib/core/utils/business_date_helper.dart`** (mới)
```dart
class BusinessDateHelper {
  BusinessDateHelper._();

  static DateTime resolveBusinessDate(
    DateTime now,
    CompanySettingsModel settings,
    String shiftGroup,
  ) { ... } // thuật toán đã chốt ở BUSINESS_DATE_DESIGN.md mục 3.4

  static ({DateTime start, DateTime end}) resolveShiftWindow(
    DateTime businessDate,
    String shift,
    CompanySettingsModel settings,
  ) { ... } // HÀM MỚI — thay thế mọi hack "+1 ngày nếu ca đêm" rải rác
}
```

Dùng **Dart record** `({DateTime start, DateTime end})` làm kiểu trả về thay vì tạo một class `ShiftWindow` riêng — tránh thêm 1 abstraction không cần thiết cho một cặp giá trị đơn giản.

### 5.2 `CompanySettingsModel` — sửa nội dung, giữ nguyên chữ ký

- `getCurrentShift()`: giữ nguyên chữ ký, ủy quyền sang `RotationCalculator` (đã thống nhất ở lượt trước, Task 2).
- `calculateIsLate()` / `calculateEarlyLeave()`: **giữ nguyên tên và chữ ký hàm** (để không phải sửa call site nào khác ngoài dự kiến), nhưng viết lại nội dung bên trong để gọi `resolveShiftWindow()` rồi so sánh trực tiếp, thay vì tự tính `workStart`/`workEnd` bằng hack ngày-giờ như hiện tại. Đây là sửa lỗi tại đúng nơi bug đang nằm (Bug 2), không phải thêm lớp mới.

### 5.3 `AttendanceRepository` — nơi duy nhất orchestrate cả luồng (đúng vai trò `data/` hiện tại)

- `checkIn()`: chèn đúng thứ tự Bước 1→9 ở mục 3. Bước 4 (mới) cho phép Check In sớm tối đa **60 phút** trước `window.start` (đã chốt); nếu vẫn quá sớm, thông báo: `"Chưa tới giờ Check In. Ca làm việc mở lúc {window.start trừ 60 phút}."`.
- `checkOut()`: viết lại theo đúng luồng "tìm document mục tiêu" ở mục 2 (candidate → fallback hôm qua trong khung ân hạn 2 giờ — **đã chốt ở lượt trước**, giữ nguyên). Nếu không tìm thấy gì hợp lệ: `"Không tìm thấy ca làm việc cần Check Out hợp lệ. Vui lòng liên hệ quản lý/admin để được hỗ trợ điều chỉnh chấm công."`
- `getTodayAttendance()`: đổi nguồn build `docId` từ `DateTime.now()` sang `businessDate` (cần biết `shiftGroup` của user — đọc từ `users/{uid}` như code hiện tại đã làm ở `checkIn()`, áp dụng thêm ở đây).

### 5.4 Không tạo thêm những gì (để tránh over-engineering)

- Không tạo class/interface `ShiftWindow` riêng — dùng Dart record.
- Không tạo `AttendanceService`/use-case layer mới — `AttendanceRepository` vẫn là nơi orchestrate duy nhất, đúng kiến trúc `data/` hiện tại.
- Không tạo `CheckInPolicy`/`CheckOutPolicy`/strategy pattern — các bước vẫn là code tuần tự trong đúng 2 hàm `checkIn()`/`checkOut()` đã có.
- Không đổi Riverpod provider, không đổi routing, không đổi UI, không đổi Firestore schema, không thêm package.
- Không xoá `calculateIsLate()`/`calculateEarlyLeave()` dù nội dung giờ có thể rút gọn thành 1 dòng — giữ lại như hàm bọc (wrapper) để không phải sửa thêm bất kỳ call site nào ngoài dự kiến.

### 5.5 File cần sửa (tổng số — tối thiểu để giải quyết toàn bộ 4 bug)

| File | Loại thay đổi |
|---|---|
| `core/utils/rotation_calculator.dart` | Mới |
| `core/utils/business_date_helper.dart` | Mới |
| `features/settings/domain/company_settings_model.dart` | Sửa (đã sửa 1 phần ở Task 1; sửa thêm `calculateIsLate`/`calculateEarlyLeave`/ủy quyền `getCurrentShift`) |
| `features/attendance/data/attendance_repository.dart` | Sửa (`checkIn`, `checkOut`, `getTodayAttendance`) |
| `features/attendance/presentation/attendance_provider.dart` | Sửa (`loadTodayAttendance` dùng lại helper, bỏ logic trùng lặp) |
| `features/home/presentation/home_provider.dart` | Sửa (`_determineAutoShift`) |
| `features/attendance/presentation/attendance_history_provider.dart` | Sửa nhỏ (`lastDayToFill`) |
| `core/utils/work_schedule_helper.dart` | Sửa (`countAbsentDays` nhận thêm `shiftGroup`/`settings`) |

**7 file sửa + 2 file mới = 9 file**, giải quyết đồng thời cả 4 bug đã nêu — không có file nào bị sửa 2 lần vì lý do khác nhau, không có file ngoài phạm vi nghiệp vụ chấm công bị đụng tới.

---

## 6. Các điểm cần bạn xác nhận trước khi viết code

Đa số quyết định đã được chốt ở các lượt trước (giữ nguyên, liệt kê lại để tài liệu này tự đầy đủ):

| # | Quyết định | Trạng thái |
|---|---|---|
| 1 | `rotationDays` = 14, đã sửa hardcode | ✅ Đã áp dụng (Task 1) |
| 2 | Tách `RotationCalculator` riêng | ✅ Đã chốt |
| 3 | Khung ân hạn Check Out = 2 giờ cố định | ✅ Đã chốt |
| 4 | `countAbsentDays` sửa cùng đợt | ✅ Đã chốt |
| 5 | Cho phép Check In sớm tối đa **60 phút** trước `window.start`; sau `window.start` luôn tính `isLate = true` (không có vùng đệm cho trễ) | ✅ Đã chốt |

Tất cả điểm mở đã được xác nhận. Tôi sẽ bắt đầu viết diff cụ thể cho từng file ở mục 5.5, theo đúng quy trình: sửa xong → hiển thị diff → giải thích → đề xuất test → chờ xác nhận trước khi sang file kế tiếp.
