# Business Date (Work Date) — Thiết kế `BusinessDateHelper`

> Tài liệu thiết kế. Chưa cài đặt, chưa sửa bất kỳ file source nào.
> Bối cảnh: bug "Home hiển thị sai ca đêm / check-in 00:18 tính đúng giờ" (xem phân tích trước đó trong hội thoại) và kết luận cần một khái niệm Business Date tách khỏi Calendar Date.

## 1. Quyết định nghiệp vụ (đầu vào cố định cho thiết kế)

- Ca đêm thuộc về **ngày bắt đầu ca**, không phải ngày đồng hồ hiện tại.
- Ví dụ chốt: ca đêm 04/07 20:00 → 05/07 08:00. Check-in lúc 00:18 ngày 05/07 phải cho ra:
  - `Business Date = 04/07`
  - `attendanceDate = 04/07`
  - `docId = 2026-07-04_<uid>`
  - Home hiển thị **ca đêm**
  - Check-out (bất kể lúc nào trước khi ca kết thúc) phải cập nhật đúng document `2026-07-04_<uid>`

- Ca ngày không cần điều chỉnh gì: ca ngày nằm gọn trong một ngày dương lịch, Business Date luôn trùng Calendar Date.

## 2. API đề xuất

Đặt trong file mới `lib/core/utils/business_date_helper.dart` (mobile), là một class static thuần function — không phụ thuộc Firestore, không phụ thuộc Riverpod, dễ unit test độc lập.

```dart
class BusinessDateHelper {
  BusinessDateHelper._();

  /// Trả về Business Date (đã chuẩn hoá về 00:00:00) cho thời điểm [now],
  /// dựa trên cấu hình ca [settings] và nhóm ca [shiftGroup] của nhân viên.
  static DateTime resolveBusinessDate(
    DateTime now,
    CompanySettingsModel settings,
    String shiftGroup,
  ) { ... }
}
```

Vì sao đặt là helper riêng thay vì method trong `CompanySettingsModel`:
- `CompanySettingsModel` mô tả **cấu hình công ty** (dữ liệu), không nên chứa thêm thuật toán phụ thuộc vào **nhân viên cụ thể** (`shiftGroup` là thuộc tính của user, không phải của settings).
- Giữ `BusinessDateHelper` độc lập giúp unit test thuần (không cần mock Firestore document để dựng `CompanySettingsModel`, chỉ cần `CompanySettingsModel(...)` constructor thường).
- Cùng namespace với `WorkScheduleHelper`/`DateHelper` đã có sẵn trong `core/utils/`, giữ đúng convention hiện tại của project.

Hàm phụ trợ (không bắt buộc, nhưng giúp các call site gọn hơn — vẫn thuộc phạm vi thiết kế, chưa cài đặt):

```dart
/// Tiện ích: Business Date dạng docId-friendly string "yyyy-MM-dd"
static String resolveBusinessDateString(
  DateTime now,
  CompanySettingsModel settings,
  String shiftGroup,
) => DateHelper.toDateString(resolveBusinessDate(now, settings, shiftGroup));
```

## 3. Thuật toán

### 3.1 Vấn đề vòng lặp phụ thuộc (circular dependency)

Muốn biết "hôm nay có phải vẫn đang là ca đêm hôm qua kéo dài không", trực giác cần biết "ca hiện tại đang diễn ra là ca gì". Nhưng `getCurrentShift()` lại cần biết "ngày nghiệp vụ nào" để tính đúng block xoay ca 14 ngày — chính là thứ ta đang muốn tìm. Nếu tính `getCurrentShift` trực tiếp bằng Calendar Date hôm nay thì quay lại đúng bug ban đầu (ở ranh giới đổi block, kết quả đổi ngay lúc 00:00 dù ca thực tế chưa kết thúc).

Cách phá vòng lặp: **không hỏi "ca nào đang diễn ra bây giờ"**, mà hỏi một câu hỏi khác, không mơ hồ và không cần biết Business Date trước: **"Hôm qua (một ngày dương lịch xác định, không cần suy luận), nhóm ca này có được xếp làm ca đêm không?"** Câu hỏi này gọi `getCurrentShift(shiftGroup, today: yesterday)` với `yesterday` là một Calendar Date thuần, luôn tính được dứt khoát, không phụ thuộc gì vào giờ hiện tại.

- Nếu **có** (hôm qua nhóm này làm ca đêm) → ca đêm đó (bắt đầu 20:00 hôm qua) có thể vẫn đang kéo dài tới sáng nay → nếu giờ hiện tại còn nằm trong "khung giờ sáng sớm" (00:00 → giờ kết thúc ca đêm), Business Date = hôm qua.
- Nếu **không** (hôm qua nhóm này làm ca ngày) → không có ca đêm nào của nhóm này kéo dài qua đêm nay → Business Date = hôm nay như bình thường.

Vì câu hỏi luôn tra cứu **một ngày cụ thể trong quá khứ** (hôm qua), nó không bao giờ rơi vào tình huống "ranh giới đổi block đúng lúc nửa đêm" như bug gốc — ranh giới đổi block chỉ ảnh hưởng đến việc so sánh "hôm qua" vs "hôm nay" thuộc 2 block khác nhau, và thuật toán ở đây cố tình **chỉ dùng hôm qua** làm mốc tra cứu khi cần quyết định có "kéo dài ca đêm" hay không.

### 3.2 Khung giờ nhạy cảm (early-morning window)

Chỉ có ca đêm xuyên qua nửa đêm mới cần điều chỉnh. Áp dụng đúng heuristic đã tồn tại sẵn trong `attendance_repository.dart:138` (`if (currentShift == 'night' && int.parse(endParts[0]) < 12)`) để nhận diện "ca đêm có xuyên nửa đêm hay không": chỉ coi là xuyên nửa đêm nếu giờ kết thúc ca đêm (`nightShiftEnd`) có **giờ < 12** (buổi sáng). Nếu admin cấu hình ca đêm kết thúc buổi chiều (hiếm, sai cấu hình), thuật toán không áp dụng điều chỉnh — giữ nguyên Calendar Date, để không đoán bừa.

Khung giờ nhạy cảm = `[00:00:00, nightShiftEnd]` (đóng ở cả hai đầu — xem lý do ở mục 3.3), chỉ áp dụng khi `nightShiftEnd.hour < 12`.

### 3.3 Vì sao chọn biên đóng tại `nightShiftEnd` (bao gồm đúng thời điểm 08:00)

Có 2 lựa chọn cho biên: `< nightShiftEnd` (mở) hay `<= nightShiftEnd` (đóng). Chọn **đóng** vì:

- Check-out đúng giờ (ví dụ chấm công lúc 08:00:00 sát giờ tan ca) phải được tính vào ca đêm vừa kết thúc (04/07), không phải bị đẩy sang ngày mới — nếu dùng biên mở, một check-out đúng 08:00:00 sẽ bị tính nhầm sang `05/07` và không tìm thấy document để cập nhật.
- Rủi ro duy nhất của biên đóng: một check-in MỚI xảy ra đúng 08:00:00 cho nhân viên nhóm ca đêm sẽ bị resolveBusinessDate trả về hôm qua (04/07) thay vì hôm nay. Nhưng xét hệ quả thực tế: `checkIn()` sẽ tìm thấy document `04/07` đã tồn tại (họ đã check-in lúc 20:00 hôm qua) → bị chặn bởi điều kiện "Bạn đã Check In hôm nay rồi" — đây thực chất là hành vi **đúng mong muốn** (ngăn tạo double check-in nhầm, đúng ra họ nên bấm Check Out chứ không phải Check In lần nữa).
- Vì thuật toán tra cứu theo đúng `shiftGroup` của từng nhân viên, một nhân viên **ca ngày** bấm check-in lúc 08:00:00 sẽ không bị ảnh hưởng: bước tra "hôm qua nhóm này có làm ca đêm không" trả về `false` (họ làm ca ngày), nên không có rollback — Business Date vẫn là hôm nay như bình thường.

### 3.4 Pseudocode đầy đủ

```dart
static DateTime resolveBusinessDate(
  DateTime now,
  CompanySettingsModel settings,
  String shiftGroup,
) {
  final today = DateTime(now.year, now.month, now.day);

  final nightEndParts = settings.nightShiftEnd.split(':');
  final nightEndHour = int.parse(nightEndParts[0]);
  final nightEndMinute = int.parse(nightEndParts[1]);

  // Ca đêm không xuyên nửa đêm (cấu hình bất thường) -> không có gì để điều chỉnh.
  if (nightEndHour >= 12) {
    return today;
  }

  // Có nằm trong khung giờ sáng sớm [00:00, nightShiftEnd] không?
  final isBeforeOrAtNightEnd =
      now.hour < nightEndHour ||
      (now.hour == nightEndHour && now.minute <= nightEndMinute);

  if (!isBeforeOrAtNightEnd) {
    return today; // Không phải khung giờ nhạy cảm -> Calendar Date như bình thường.
  }

  // Có nằm trong khung giờ nhạy cảm -> kiểm tra hôm qua nhóm ca này có làm ca đêm không.
  final yesterday = today.subtract(const Duration(days: 1));
  final wasNightYesterday = settings.getCurrentShift(
        shiftGroup: shiftGroup,
        today: yesterday,
      ) ==
      'night';

  return wasNightYesterday ? yesterday : today;
}
```

Ghi chú quan trọng: hàm này **gọi lại** `getCurrentShift()` hiện có — nghĩa là bug hardcode `14` thay vì dùng `rotationDays` (đã nêu ở phân tích trước) **vẫn còn tồn tại độc lập** và **không được sửa bởi thiết kế này**. Nếu muốn `resolveBusinessDate` phản ánh đúng chu kỳ xoay ca admin cấu hình, bug đó cần được xử lý riêng (đã phân tích ở lượt trước, chưa xác nhận sửa).

## 4. Bảng test case

Giả định: `nightShiftStart = "20:00"`, `nightShiftEnd = "08:00"`, `rotationStartDate`/`rotationDays` sao cho nhóm **A** được xếp ca đêm vào ngày **04/07/2026**, nhóm **B** làm ca ngày cùng ngày đó.

| # | Thời điểm `now` | `shiftGroup` | Trong khung nhạy cảm? | Hôm qua (04/07) nhóm này làm ca gì? | `resolveBusinessDate` | Ghi chú |
|---|---|---|---|---|---|---|
| 1 | 04/07 19:59 | A | Không (19:59 ≥ 08:00, và > 00:00 nhưng ngoài [00:00,08:00]) | — (không cần tra) | **04/07** | Trước giờ vào ca đêm, vẫn là hôm nay bình thường |
| 2 | 04/07 20:00 | A | Không | — | **04/07** | Đúng thời điểm bắt đầu ca đêm |
| 3 | 04/07 23:59 | A | Không | — | **04/07** | Giữa ca đêm, nửa đầu |
| 4 | 05/07 00:00 | A | Có (đúng biên dưới) | 04/07 = night | **04/07** | Vừa qua nửa đêm, ca đêm vẫn tiếp diễn |
| 5 | 05/07 00:18 | A | Có | 04/07 = night | **04/07** | **Ca gốc trong yêu cầu — phải khớp `docId = 2026-07-04_uid`** |
| 6 | 05/07 07:59 | A | Có | 04/07 = night | **04/07** | Sát giờ tan ca đêm |
| 7 | 05/07 08:00 | A | Có (đúng biên trên, đóng) | 04/07 = night | **04/07** | Check-out đúng giờ tan ca vẫn khớp document 04/07 |
| 8 | 05/07 08:01 | A | Không (vừa qua biên) | — | **05/07** | Ca đêm coi như đã kết thúc, mọi check-in/out mới thuộc ngày mới |
| 9 | 05/07 00:18 | **B** (ca ngày cùng thời điểm) | Có (khung giờ chỉ phụ thuộc giờ, không phụ thuộc group) | 04/07 = **day** (nhóm B không làm đêm hôm qua) | **05/07** | Xác nhận không có rollback sai cho nhân viên ca ngày ở cùng khung giờ |
| 10 | 05/07 08:00 | **B** | Có | 04/07 = day | **05/07** | Nhân viên ca ngày check-in đúng 08:00 không bị đẩy lùi |
| 11 | Ngày đúng ranh giới đổi block 14 ngày: hôm qua (block cũ) nhóm A = night, hôm nay (block mới) nhóm A = day; check-in lúc 00:18 | A | Có | 04/07 (hôm qua, **vẫn tra theo block cũ**) = night | **04/07** | **Test case then chốt tái hiện đúng bug gốc**: dù "hôm nay" theo rotation đã đổi sang block mới (day), `resolveBusinessDate` vẫn đúng vì nó tra "hôm qua" (thuộc block cũ) chứ không tra "hôm nay" |
| 12 | 05/07 03:00, chưa từng check-in, chỉ mở Home | A | Có | 04/07 = night | **04/07** | Home phải tự xác định đúng ca đêm dù chưa có attendance doc nào cho việc tra cứu |

Test case 11 chính là kịch bản gây ra bug ban đầu ("Home hiển thị ca ngày" dù lẽ ra phải là ca đêm) — bảng trên xác nhận thiết kế này giải quyết đúng gốc rễ vì nó không bao giờ tra cứu rotation theo "hôm nay", chỉ tra theo "hôm qua" khi cần quyết định có rollback hay không.

## 5. Các file sẽ dùng `BusinessDateHelper` (nếu triển khai — chưa sửa)

**Mobile:**

| File | Thay đổi dự kiến khi triển khai |
|---|---|
| `lib/core/utils/business_date_helper.dart` | File mới — chứa `resolveBusinessDate()` |
| `lib/features/attendance/data/attendance_repository.dart` | `checkIn()`, `checkOut()`, `getTodayAttendance()`: thay `DateHelper.toDateString(DateTime.now())` bằng `DateHelper.toDateString(BusinessDateHelper.resolveBusinessDate(now, settings, shiftGroup))` khi build `docId`; dùng cùng Business Date cho `attendanceDate` lưu vào Firestore và cho tham số `today` truyền vào `getCurrentShift()` |
| `lib/features/attendance/presentation/attendance_provider.dart` | `loadTodayAttendance()`: dùng Business Date thay vì tự tính `now`/`workEnd` riêng |
| `lib/features/home/presentation/home_provider.dart` | `_determineAutoShift()`: dùng Business Date để Home hiển thị đúng ca đêm/ngày |
| `lib/core/utils/work_schedule_helper.dart` | `countAbsentDays()`: cân nhắc dùng Business Date làm cutoff "ngày đã qua" thay vì `DateTime.now()` thô |

**Không cần đổi (thuần hiển thị, đã liệt kê ở phân tích trước):** `home_screen.dart`, `home_header.dart`, `attendance_record_list.dart`, `attendance_history_provider.dart` (phần default tháng/chặn chọn tương lai).

**Admin — cần thiết kế bổ sung riêng, KHÔNG áp dụng trực tiếp được:**

`attendance_admin/lib/features/dashboard/data/dashboard_repository.dart` (`getDashboardStats`, `_getWeeklyAttendance`) hiện đếm "đã check-in hôm nay" bằng một truy vấn TOÀN CỤC (`where('attendanceDate', isEqualTo: startOfToday)`), nhưng Business Date là khái niệm **theo từng nhân viên/nhóm ca**, không phải một mốc ngày duy nhất áp dụng cho toàn công ty — tại 00:18, nhân viên nhóm A (ca đêm) có Business Date = hôm qua trong khi nhân viên nhóm B (ca ngày) có Business Date = hôm nay, cùng một thời điểm. Áp `BusinessDateHelper` vào dashboard đòi hỏi đổi cách truy vấn (ví dụ query theo khoảng 2 ngày rồi lọc theo nhóm ca từng nhân viên) chứ không đơn thuần gọi lại hàm — đây là một thiết kế riêng, ngoài phạm vi tài liệu này.

## 6. Giới hạn đã biết

- Không sửa bug hardcode `14` ngày trong `getCurrentShift()` (vẫn dùng `rotationDays` sai) — `resolveBusinessDate()` kế thừa nguyên trạng bug này vì nó gọi lại `getCurrentShift()` hiện có.
- Giả định `nightShiftEnd.hour < 12` để nhận diện "ca đêm xuyên nửa đêm" — nếu admin cấu hình bất thường (ca đêm kết thúc buổi chiều), thuật toán không áp dụng điều chỉnh, giữ nguyên Calendar Date.
- Admin dashboard cần thiết kế truy vấn riêng, không dùng trực tiếp được `resolveBusinessDate()` theo kiểu 1-1 như phía mobile.
- Tài liệu này **không bao gồm cài đặt** — chỉ là thiết kế chờ xác nhận.

---

Chờ xác nhận trước khi triển khai bất kỳ thay đổi nào vào code.
