# DEMO TIME DESIGN — v2

Tài liệu phân tích & thiết kế cơ chế mô phỏng thời gian ("Demo Time") để phục vụ demo trước giảng viên, cho phép Check In/Check Out/Shift Rotation/Business Date/Late/Early Leave hoạt động đúng tại các mốc giờ giả lập mà không phải chờ thời gian thực.

**Trạng thái: CHỈ PHÂN TÍCH — CHƯA CODE.** Đây là bản cập nhật từ `DEMO_TIME_DESIGN.md` (v1) sau phản hồi ngày hôm nay. Chờ xác nhận trước khi triển khai.

---

## 0. Thay đổi so với v1

| # | Yêu cầu | Thay đổi |
|---|---|---|
| 1 | Đánh giá lại static vs singleton vs provider | Mục 3 viết lại hoàn toàn — chọn **mô hình lai (Hybrid): static `ClockService` + `ValueNotifier` nội bộ**, không dùng Riverpod provider thuần cho phần lõi. Lý do chi tiết ở mục 3. |
| 2 | Fast Forward | Thêm vào mục 5 (UI) — các nút +5 phút / +30 phút / +1 giờ / +6 giờ / +12 giờ / +1 ngày. |
| 3 | Banner Demo mở rộng | Mục 5 viết lại nội dung banner: DEMO MODE + Business Date + Current Time + Current Shift. Thêm mục 5.3 mô tả nguồn dữ liệu cho banner. |
| 4 | Công cụ debug bổ sung | Mục 6 (mới) — đánh giá go/no-go cho từng công cụ được đề xuất (Current Rotation, Current Business Date, Current Shift, GPS Status, Current User, Seed/Reset Demo Data). |
| — | File cần sửa / LOC / câu hỏi xác nhận | Cập nhật lại ở mục 10, 13, 15 cho khớp với thiết kế mới. |
| — | (Cập nhật lần 2, cùng ngày) Đổi tên "Developer Tools" → **"Demo Center"**; bổ sung Rewind (-5 phút/-30 phút/-1 giờ/-6 giờ/-12 giờ/-1 ngày) đối xứng với Fast Forward; bổ sung nút **"Reset to Current Time"** 1-chạm cạnh cụm Fast Forward/Rewind | Không đổi kiến trúc, không mở rộng phạm vi — chi tiết ở mục 5.1/5.3. Đã xác nhận, sẵn sàng triển khai code. |

Các mục không liên quan tới 4 yêu cầu trên (mục 1 "Nguyên nhân", mục 2 phân loại `DateTime.now()`, mục 4 phạm vi/ràng buộc, mục 7 ảnh hưởng module, mục 8 rủi ro, mục 9 danh sách file không cần sửa, mục 11 test plan) được giữ nguyên nội dung như v1, chỉ đánh lại số thứ tự.

---

## 1. Nguyên nhân

Toàn bộ quyết định nghiệp vụ chấm công (Business Date, Shift, Late, Early Leave, giới hạn Check In sớm/muộn, ân hạn Check Out ca đêm) đều neo vào `DateTime.now()` được gọi trực tiếp tại nhiều điểm rải rác trong `attendance_mobile` (repository, provider, một vài widget hiển thị). Không có điểm trung gian nào đứng giữa "thời gian hệ thống" và "logic nghiệp vụ".

Hệ quả: để demo các tình huống 07:50 (sắp đến giờ), 08:10 (late), 19:50/20:00/20:15 (chuyển ca đêm), 23:30/00:15 (Business Date xuyên nửa đêm), 07:59 hôm sau (Check Out cuối ca đêm) — người demo buộc phải đợi thời gian thực trôi qua đúng các mốc đó, hoặc phải sửa giờ hệ điều hành của thiết bị (rủi ro: làm sai lệch chứng chỉ TLS, log hệ thống, và không kiểm soát được chính xác từng phút).

Cần một điểm neo duy nhất để "thay thế" `DateTime.now()` bằng thời gian giả lập, chỉ khi ở chế độ debug, không đụng đến schema Firestore hay kiến trúc hiện có.

---

## 2. Phân loại toàn bộ nơi lấy thời gian hiện tại

### 2.1. `attendance_mobile` — Quyết định nghiệp vụ (BẮT BUỘC phải theo Demo Time)

| File | Dòng | Mục đích |
|---|---|---|
| `features/attendance/data/attendance_repository.dart` | 105 | `checkIn()` — tính Business Date, Shift, cửa sổ ca, Late |
| `features/attendance/data/attendance_repository.dart` | 236 | `getTodayAttendance()` — tính Business Date để tìm đúng document hôm nay |
| `features/attendance/data/attendance_repository.dart` | 299 | `checkOut()` — tính Business Date, ân hạn ca đêm, Early Leave |
| `features/attendance/presentation/attendance_provider.dart` | 68 | Xác định `isShiftEnded` (còn hạn Check In hay không) |
| `features/home/presentation/home_provider.dart` | 108 | `_determineAutoShift()` — ca hiện tại hiển thị ở Home |
| `features/home/presentation/home_provider.dart` | 163 | `_loadMonthlyStats()` — biên đầu/cuối tháng để đếm Late/Early/Absent |
| `features/home/presentation/home_screen.dart` | 28 | `isOffDay` — có phải ngày nghỉ bắt buộc hôm nay không |
| `features/attendance/presentation/attendance_history_provider.dart` | 68, 108, 172 | Tháng mặc định, biên "Absent" tự sinh, chặn chọn tháng tương lai |
| `core/utils/work_schedule_helper.dart` | 78 | `countAbsentDays()` — chặn "ngày chưa tới" khi đếm vắng |

### 2.2. `attendance_mobile` — Chỉ hiển thị UI (NÊN theo Demo Time để demo nhất quán, không bắt buộc)

| File | Dòng | Mục đích |
|---|---|---|
| `features/home/presentation/widgets/home_header.dart` | 18 | Chuỗi "Thứ X, dd/mm/yyyy" trên header Home |
| `features/home/presentation/home_screen.dart` | 97 | `month:` truyền cho `MonthlyStats` |
| `features/attendance/presentation/widgets/attendance_record_list.dart` | 48 | Gom nhóm "Tuần này/Tuần trước" trong Attendance History |

### 2.3. `attendance_mobile` — Audit timestamp / fallback phòng thủ (KHÔNG cần đổi)

| File | Dòng | Ghi chú |
|---|---|---|
| `features/settings/domain/company_settings_model.dart` | 76, 81, 211 | Fallback khi Firestore thiếu field + `updatedAt` khi admin sửa cấu hình — không nằm trong kịch bản demo |
| `features/attendance/domain/attendance_model.dart` | 78, 134 | Fallback chỉ chạy khi document Firestore thiếu field — không xảy ra trong luồng thực tế |
| `features/auth/domain/user_model.dart` | 57 | Fallback tương tự cho `createdAt` |

### 2.4. `attendance_mobile` — Dev/seed tooling (KHÔNG đổi — chạy trước demo, không phải runtime logic)

`lib/dev/demo_seeder.dart`, `lib/dev/seed_firestore.dart`, `lib/dev/create_test_user.dart` — dùng `DateTime.now()`/`Timestamp.now()` để tạo dữ liệu mẫu một lần, không tham gia vào flow Check In/Out lúc demo.

### 2.5. `attendance_admin` — không nằm trong luồng Check In/Out (đánh giá riêng ở mục 8)

| File | Dòng | Mục đích |
|---|---|---|
| `features/dashboard/data/dashboard_repository.dart` | 48, 75 | "Hôm nay" cho `todayCheckedIn` + cửa sổ 7 ngày cho biểu đồ Dashboard |
| `features/leave/presentation/leave_provider.dart` | 39 | `createdAt` của notification — audit |
| `features/attendance/presentation/attendance_screen.dart` | 84, 86 | Biên `initialDate`/`lastDate` của DatePicker lọc lịch sử — UI thuần |
| `core/services/export_service.dart` | 143, 183 | Nhãn "Xuất ngày" + fallback hiển thị trong PDF export |

Admin là project Flutter độc lập, build/chạy trên máy khác (máy giảng viên hoặc máy admin riêng), **không** dùng chung tiến trình với `attendance_mobile`. Vì vậy không thể "chia sẻ" Demo Time qua biến static — xem phân tích rủi ro ở mục 8.

---

## 3. Kiến trúc: static vs singleton vs Riverpod provider

### 3.1. So sánh 3 phương án

| Tiêu chí | Static class (v1) | Singleton (instance có thể inject) | Riverpod Provider thuần |
|---|---|---|---|
| Số file/constructor phải sửa để "đấu dây" | 0 — gọi `ClockService.now()` trực tiếp ở bất kỳ đâu, kể cả class thuần Dart (`BusinessDateHelper`, `WorkScheduleHelper`) | 0 nếu dùng singleton mặc định qua static getter; tăng lên nếu muốn inject qua constructor (phải sửa chữ ký `AttendanceRepository`, `WorkScheduleHelper`...) | Cao — mọi nơi gọi `DateTime.now()` hiện nay đều nằm trong class **không** có `Ref`/`WidgetRef` (`AttendanceRepository` được khởi tạo trực tiếp bằng `AttendanceRepository()` ở nhiều nơi, `WorkScheduleHelper`/`BusinessDateHelper`/`RotationCalculator` là static). Phải luồn `Ref` xuống tất cả các lớp này → refactor chữ ký hàm/constructor trên diện rộng. |
| Khớp phong cách hiện tại của repo | Khớp hoàn toàn — `BusinessDateHelper`, `RotationCalculator`, `WorkScheduleHelper`, `DateHelper` đều là static utility class | Gần khớp, nhưng repo hiện chưa có tiền lệ dùng "injectable singleton" cho tiện ích thời gian/ngày | Không khớp — đi ngược lại nhóm static helper đã có, tạo 2 phong cách DI song song trong cùng layer `core/utils` |
| Reactive (UI tự rebuild khi đổi Demo Time) | Không tự động — phải gọi `ref.invalidate(...)` thủ công | Không tự động (như static) | Có — `ref.watch` tự rebuild khi provider đổi state |
| Dễ test | Trung bình — `setDemoTime()`/`useRealTime()` gọi được trong test, nhưng là state toàn cục (test phải tự reset ở `tearDown`, không chạy song song an toàn) | Tương tự static nếu vẫn dùng instance mặc định; chỉ thực sự lợi thế nếu cho phép tạo instance mới để cô lập test — nhưng khi đó lại phải đổi constructor các repository để nhận instance đó, quay lại vấn đề "Cao" ở dòng 1 | Tốt nhất về lý thuyết (`ProviderScope(overrides:...)`), nhưng vô nghĩa trong repo này vì các hàm nghiệp vụ lõi (`BusinessDateHelper`, `RotationCalculator`, `calculateIsLate/calculateEarlyLeave`) **đã** là pure function nhận `DateTime` trực tiếp — chúng vốn dĩ đã test được 100% mà không cần biết `ClockService`/provider là gì. Lợi ích override chỉ có giá trị ở tầng gọi `now()`, nơi hiện chưa có test nào (`flutter test` trong repo chỉ có `widget_test.dart` mặc định). |
| Rủi ro side-effect toàn cục | Có (biến static dùng chung toàn app) | Có, y hệt static nếu dùng theo kiểu singleton mặc định | Không (state cô lập trong `ProviderContainer`) nhưng đây là ưu điểm không tận dụng được vì lý do ở trên |
| Chi phí triển khai | Thấp nhất | Thấp–trung bình (tuỳ có inject hay không) | Cao nhất, vi phạm trực tiếp "không refactor lớn" |

### 3.2. Quyết định: Hybrid — static `ClockService` + `ValueNotifier` nội bộ

Giữ đúng phần lõi của v1 (`ClockService` là static class, gọi trực tiếp từ mọi nơi, không đổi constructor nào), nhưng bổ sung **1 `ValueNotifier<DateTime?>` nằm bên trong chính `ClockService`** chỉ để phục vụ phần UI cần tự động cập nhật (banner Demo Mode, và tuỳ chọn: màn Demo Center tự refresh khi Fast Forward). Đây **không phải** Riverpod provider — là cơ chế reactive nhẹ nhất của Flutter (`ValueListenableBuilder`), không cần `Ref`, không đổi constructor của bất kỳ class nào.

```dart
import 'package:flutter/foundation.dart';

class ClockService {
  ClockService._();

  static DateTime? _demoTime;

  /// Widget nào cần tự rebuild khi Demo Time đổi thì bọc bằng
  /// ValueListenableBuilder(valueListenable: ClockService.demoTimeListenable, ...)
  static final ValueNotifier<DateTime?> demoTimeListenable =
      ValueNotifier<DateTime?>(null);

  static bool get isDemoActive => kDebugMode && _demoTime != null;

  static DateTime now() {
    if (kDebugMode && _demoTime != null) return _demoTime!;
    return DateTime.now();
  }

  static void setDemoTime(DateTime time) {
    if (!kDebugMode) return;
    _demoTime = time;
    demoTimeListenable.value = time;
  }

  static void useRealTime() {
    _demoTime = null;
    demoTimeListenable.value = null;
  }
}
```

**Vì sao đây là lựa chọn tốt nhất theo 3 ưu tiên đã nêu (ít thay đổi nhất / dễ test / không refactor lớn):**

- *Ít thay đổi nhất*: 100% giống v1 ở tầng gọi — vẫn chỉ là đổi `DateTime.now()` → `ClockService.now()` tại 12 điểm, không đụng constructor, không đụng Provider nào đang có.
- *Không refactor lớn*: không luồn `Ref` xuống `AttendanceRepository`/`BusinessDateHelper`/`WorkScheduleHelper`. `demoTimeListenable` là thành phần cộng thêm thuần tuý, không thay thế gì.
- *Dễ test*: giữ nguyên lợi thế lớn nhất đã có sẵn trong kiến trúc hiện tại — `BusinessDateHelper`, `RotationCalculator`, `calculateIsLate`/`calculateEarlyLeave` là pure function nhận `DateTime`, unit test được ngay bằng cách truyền `DateTime` giả lập trực tiếp, **hoàn toàn không cần quan tâm `ClockService` tồn tại hay không**. Đây là lý do việc chọn Riverpod provider cho lớp `ClockService` không mang lại giá trị test tương xứng với chi phí refactor — điểm cần test nằm ở tầng dưới, không ở tầng lấy "now".

**Đánh đổi được chấp nhận:** `demoTimeListenable` là "nguồn thứ 2" (song song với biến `_demoTime`) — nhưng vì cả hai chỉ được set/reset cùng lúc trong đúng 2 hàm `setDemoTime()`/`useRealTime()`, không có nguy cơ lệch pha nếu không có code nào khác tự ý gán `_demoTime` trực tiếp (đây là lý do giữ `_demoTime` là `private`).

**Các provider Home/Attendance/History vẫn dùng cơ chế cũ (`ref.invalidate(...)` thủ công sau khi Apply/Reset — mục 5.4)** — không đổi thành watch `ClockService` để tránh việc mọi provider tự động re-fetch Firestore mỗi lần đổi Demo Time (tốn quota đọc không cần thiết); chỉ nơi cần hiển thị tức thời (banner) mới dùng `ValueListenableBuilder`.

---

## 4. Phạm vi & ràng buộc

- Demo Time chỉ đọc/ghi được qua `ClockService.setDemoTime()`/`useRealTime()`, và cả hai đều tự vô hiệu hoá ngoài `kDebugMode`.
- UI "Demo Center" (mục 5) chỉ được thêm vào route/entry point vốn đã ẩn sau `kDebugMode` (tương tự cách `attendance_admin` đã ẩn `/dev/seed-departments`).
- Không đổi bất kỳ field/document nào trong Firestore. `Timestamp.fromDate(ClockService.now())` ghi xuống Firestore vẫn là timestamp hợp lệ bình thường — Firestore không biết và không cần biết nó đến từ thời gian giả lập.
- Release build (`flutter build apk/ipa/web --release`) không đóng gói khác biệt gì thêm — do toàn bộ nhánh demo bị loại bởi `kDebugMode`.

---

## 5. Đề xuất UI (cập nhật)

### 5.1. Cấu trúc màn hình

```
Profile
 └── (kDebugMode) "Demo Center"  →  DemoCenterScreen
       ├── Banner (nếu isDemoActive): xem 5.2
       ├── "Demo Time"
       │     ○ Use Real Time
       │     ○ Use Demo Time
       │          Date: [DatePicker]
       │          Time: [TimePicker]
       │          [Apply]   [Reset]
       ├── "Fast Forward / Rewind" (chỉ hiện khi đang ở chế độ Use Demo Time — xem 5.3)
       │     Tiến:  [+5 phút] [+30 phút] [+1 giờ] [+6 giờ] [+12 giờ] [+1 ngày]
       │     Lùi:   [-5 phút] [-30 phút] [-1 giờ] [-6 giờ] [-12 giờ] [-1 ngày]
       │     [Reset to Current Time]  (quay về giờ thật ngay lập tức, không cần mở DatePicker)
       └── "Thông tin hiện tại" (xem mục 6)
             Current User · Current Business Date · Current Shift
```

### 5.2. Banner Demo Mode (mở rộng theo yêu cầu)

```
🧪 DEMO MODE
Current Time:    20/07/2026 20:15
Business Date:   20/07/2026
Current Shift:   Ca đêm (Nhóm A)
```

Hiển thị ở đầu `DemoCenterScreen`, và **khuyến nghị thêm 1 banner rút gọn 1 dòng** dán cố định phía trên `HomeScreen`/`AttendanceHistoryScreen` khi `ClockService.isDemoActive == true` (ví dụ: dải màu cam "🧪 DEMO — 20/07 20:15", tap vào để mở lại Demo Center) — để giảng viên nhìn thấy ngay cả khi người demo không đứng ở màn Demo Center. Đây là bổ sung nhỏ (1 widget dùng lại ở 2 nơi), không phát sinh route hay provider mới.

Banner cập nhật tức thời nhờ bọc trong `ValueListenableBuilder(valueListenable: ClockService.demoTimeListenable, ...)` — không cần `ref.invalidate`.

### 5.3. Fast Forward / Rewind / Reset to Current Time — đánh giá: NÊN bổ sung cả ba

Lý do: giảm thao tác lặp lại (mở DatePicker + TimePicker) khi cần nhảy qua nhiều mốc liên tiếp trong 1 buổi demo (07:50 → 08:10 → 12:30 → ...), giảm rủi ro bấm nhầm giờ khi thao tác trực tiếp trên UI trước mặt giảng viên. Chi phí triển khai thấp: mỗi nút chỉ là `ClockService.setDemoTime(ClockService.now().add(Duration(...)))` (Fast Forward) hoặc `.subtract(Duration(...))` (Rewind).

Rewind (lùi giờ) hữu ích khi demo lỡ đi quá mốc cần trình bày hoặc muốn diễn lại một kịch bản (ví dụ vừa demo xong "20:15 — Late" nhưng muốn quay lại "20:00 — đúng giờ" để giải thích lại) mà không phải tính lại và mở DatePicker/TimePicker thủ công. Dùng chung một nguyên tắc tính mốc với Fast Forward, chỉ khác chiều cộng/trừ.

Quy tắc mốc gốc: nếu đang **Use Real Time**, bấm Fast Forward hoặc Rewind lần đầu sẽ tự chuyển sang **Use Demo Time** với mốc gốc = `DateTime.now()` thật tại thời điểm bấm, rồi cộng/trừ thêm khoảng đã chọn — người dùng không bắt buộc phải mở DatePicker trước mới dùng được các nút này.

Danh sách nút:
- Tiến: `+5 phút`, `+30 phút`, `+1 giờ`, `+6 giờ`, `+12 giờ`, `+1 ngày`
- Lùi: `-5 phút`, `-30 phút`, `-1 giờ`, `-6 giờ`, `-12 giờ`, `-1 ngày`
- `Reset to Current Time`: gọi thẳng `ClockService.useRealTime()` — khác với nút `Reset` trong khối "Demo Time" (5.1) vốn nằm trong luồng chọn DatePicker/TimePicker, nút này là thao tác 1-chạm đặt cạnh cụm Fast Forward/Rewind để không phải kéo lên khối phía trên khi đang thao tác nhanh giữa các mốc giờ. Cả hai đều gọi cùng 1 hàm (`useRealTime()`), không tạo thêm state hay logic mới.

### 5.4. Luồng Apply/Reset (giữ nguyên từ v1)

Sau khi bấm **Apply**/**Reset**/**Fast Forward**, cần chủ động gọi lại các provider đang cache dữ liệu theo giờ cũ: `ref.invalidate(homeProvider)`, `ref.invalidate(attendanceProvider)`, `ref.invalidate(attendanceHistoryProvider)`.

Route thêm vào `app_router.dart`: `GoRoute(path: '/demo-center', builder: (_, __) => const DemoCenterScreen())`.

---

## 6. Đánh giá công cụ debug bổ sung

Nguyên tắc lọc: chỉ thêm nếu (a) tái dùng dữ liệu/logic đã có sẵn (không viết thêm business logic mới), và (b) trực tiếp phục vụ việc giải thích Demo Time cho giảng viên trong lúc demo — không biến `DemoCenterScreen` thành màn hình debug tổng quát.

| Đề xuất | Quyết định | Lý do |
|---|---|---|
| Current Business Date | **Thêm** | Đã tính sẵn trong banner (5.2), hiển thị lại ở khối "Thông tin hiện tại" khi banner chưa set Demo Time (Use Real Time) để người dùng vẫn thấy Business Date thật trước khi bắt đầu demo. Không thêm logic mới — gọi lại `BusinessDateHelper.resolveBusinessDate()`. |
| Current Shift | **Thêm** | Cùng nguồn với banner, tái dùng `settings.getCurrentShift()`. |
| Current Rotation (nhóm A/B đang làm ca gì) | **Gộp vào "Current Shift"**, không tách riêng | Thông tin trùng lặp — "Ca đêm (Nhóm A)" trong banner đã trả lời đúng câu hỏi "ai đang làm ca gì". Tách thêm mục riêng sẽ dư thừa. |
| Current User | **Thêm** | Rẻ (chỉ đọc `homeState.user` đã load sẵn: mã NV, tên, `shiftGroup`), hữu ích để giảng viên biết đang demo bằng tài khoản nào khi chuyển đổi giữa các tài khoản nhóm A/B. |
| GPS Status | **Không thêm** | Lạc phạm vi — đây là tài liệu thiết kế cho **thời gian**, không phải vị trí. GPS đã có thông báo lỗi riêng ngay trong luồng Check In/Out (khoảng cách + bán kính cho phép hiển thị trong exception message). Thêm vào đây sẽ biến Demo Center thành debug panel tổng, đi ngược yêu cầu "không quá phức tạp". Có thể đề xuất thành công cụ riêng nếu cần. |
| Seed Demo Data | **Không thêm ở Phase này** | Hiện đã có `main_dev.dart` tự wipe & reseed mỗi lần chạy — chức năng tương đương đã tồn tại ở "cấp khởi động app", thêm nút trùng chức năng trong lúc app đang chạy làm tăng bề mặt rủi ro (gọi `DemoSeeder` giữa phiên demo có thể xoá dữ liệu đang dùng dở) mà lợi ích tăng thêm không nhiều. Đánh dấu là ứng viên Phase 2 nếu thực tế demo cho thấy cần "reset nhanh không khởi động lại app". |
| Reset Demo Data | **Không thêm ở Phase này** | Cùng lý do với Seed Demo Data — hành động phá huỷ dữ liệu, nên giữ ngoài phạm vi tối thiểu; nếu cần, nên là màn hình/nút riêng có xác nhận rõ ràng (dialog "Bạn chắc chắn?"), không lẫn vào cụm điều khiển Demo Time. |

Kết quả: khối "Thông tin hiện tại" trong `DemoCenterScreen` chỉ gồm 3 dòng — **Current User, Current Business Date, Current Shift** — dùng lại đúng dữ liệu banner đã tính, không phát sinh logic hay provider mới ngoài 1 hàm tổng hợp nhỏ (mục 10, file mới `demo_status_provider.dart`).

---

## 7. Đánh giá ảnh hưởng — module tự động hưởng lợi

Vì `BusinessDateHelper`, `RotationCalculator`, `CompanySettingsModel.calculateIsLate/calculateEarlyLeave` vốn đã là hàm thuần nhận `DateTime` làm tham số, chỉ cần đổi ~12 điểm gọi `DateTime.now()` ở tầng trên là toàn bộ các module sau tự động chạy đúng theo Demo Time, không cần sửa thêm gì trong chính các module đó:

- **Check In / Check Out** — `AttendanceRepository`
- **Shift Rotation** — `RotationCalculator.getCurrentShift()`
- **Business Date** — `BusinessDateHelper.resolveBusinessDate()`
- **Late / Early Leave** — `calculateIsLate()`/`calculateEarlyLeave()`
- **Home** — ca hiển thị, trạng thái nút Check In/Out, thống kê tháng
- **Attendance History** — sinh "Absent" tự động, chặn chọn tháng tương lai
- **Dashboard (trong `attendance_mobile`)** — không có màn Dashboard riêng trong mobile; số liệu tháng ở Home đã nằm trong danh sách trên. Dashboard của **admin** là ứng dụng khác — xem mục 8.

---

## 8. Rủi ro

| Rủi ro | Mức độ | Ghi chú/giảm thiểu |
|---|---|---|
| Quên đổi một `DateTime.now()` còn sót ở nghiệp vụ | Trung bình | Danh sách mục 2.1 đã liệt kê đủ 12 điểm qua grep toàn repo; sau khi sửa nên grep lại để xác nhận 0 kết quả còn "lọt lưới". |
| **Admin Dashboard không đồng bộ với Demo Time bên mobile** | **Cao (cần quyết định trước khi demo)** | `attendance_admin` là app/tiến trình riêng. Nếu demo mô phỏng mốc xuyên nửa đêm, `attendanceDate` ghi xuống Firestore mang ngày giả lập, còn `DashboardRepository` phía admin vẫn dùng `DateTime.now()` thật → không đếm được record đó vào "hôm nay" cho tới khi ngày thật trôi tới. Ba lựa chọn: (1) chấp nhận + giải thích khi demo, (2) chỉ demo Dashboard bằng mốc cùng ngày lịch thực, (3) mở rộng `ClockService` sang `attendance_admin` (ngoài phạm vi Phase 1). |
| Firebase/Firestore Timestamp | Thấp | `Timestamp.fromDate(ClockService.now())` hoạt động bình thường, không ảnh hưởng `serverTimestamp()`. |
| Query Firestore theo khoảng ngày | Thấp–Trung bình | Tự động đúng theo demo time vì chỉ đổi nguồn `now`, không đổi cấu trúc query. |
| Cache Riverpod giữ dữ liệu cũ sau khi đổi Demo Time | Trung bình | Bắt buộc `ref.invalidate(...)` sau Apply/Reset/Fast Forward (mục 5.4) — nếu quên, màn hình hiển thị sai cho tới khi có thao tác khác kích hoạt rebuild. |
| Timezone | Thấp | Không phát sinh lệch timezone mới so với hành vi `DateTime.now()` hiện tại. |
| Quên Reset Demo Time rồi bấm Check In/Out thật | Trung bình | Banner cảnh báo nổi bật (5.2) là biện pháp giảm thiểu chính; `_demoTime` không persist qua session (mất khi kill app). |
| **Mới (v2): 2 nguồn trạng thái (`_demoTime` và `demoTimeListenable`) lệch nhau** | Thấp | Chỉ xảy ra nếu có code mới gán trực tiếp vào 1 trong 2 biến mà bỏ qua `setDemoTime()`/`useRealTime()`. Giảm thiểu: giữ `_demoTime` private, toàn bộ thay đổi bắt buộc đi qua 2 hàm public duy nhất. |
| **Mới (v2): Fast Forward cộng dồn quá xa ngoài kịch bản đã test** | Thấp | Ví dụ bấm `+1 ngày` nhiều lần liên tiếp có thể đưa Demo Time sang chu kỳ rotation khác (qua khỏi mốc `rotationDays`), khiến Shift Rotation hiển thị đúng nhưng không còn khớp kịch bản đã chuẩn bị trước cho giảng viên. Không phải lỗi kỹ thuật, chỉ là rủi ro thao tác — banner luôn hiển thị Business Date/Shift hiện tại giúp người demo tự nhận ra ngay. |

---

## 9. Danh sách file KHÔNG cần sửa

- `core/utils/business_date_helper.dart`, `core/utils/rotation_calculator.dart` — đã là pure function theo `DateTime` truyền vào.
- `features/settings/domain/company_settings_model.dart`, `features/attendance/domain/attendance_model.dart`, `features/auth/domain/user_model.dart` — fallback phòng thủ, không nằm trong luồng demo.
- `lib/dev/demo_seeder.dart`, `lib/dev/seed_firestore.dart`, `lib/dev/create_test_user.dart` — công cụ seed dữ liệu, không phải runtime logic.
- Toàn bộ `attendance_admin/**` — mặc định **không đổi** trong Phase 1 (xem mục 8).
- Mọi nơi dùng `FieldValue.serverTimestamp()`.
- Firestore Rules, Firestore schema.

---

## 10. Danh sách file cần sửa (khi được duyệt triển khai)

**Mới:**
1. `attendance_mobile/lib/core/services/clock_service.dart` — `ClockService` + `demoTimeListenable`
2. `attendance_mobile/lib/features/dev_tools/presentation/demo_center_screen.dart` — màn hình chính (Demo Time + Fast Forward + khối "Thông tin hiện tại")
3. `attendance_mobile/lib/features/dev_tools/presentation/widgets/demo_mode_banner.dart` — widget banner dùng chung (Demo Center + Home/History)
4. `attendance_mobile/lib/features/dev_tools/domain/demo_status.dart` hoặc `presentation/demo_status_provider.dart` — hàm/provider nhỏ tổng hợp `{businessDate, shift, user}` tái dùng `BusinessDateHelper` + `CompanySettingsModel.getCurrentShift()`, dùng chung cho banner và khối "Thông tin hiện tại" (tránh viết trùng logic 2 lần)

**Sửa (đổi `DateTime.now()` → `ClockService.now()`, không đổi logic khác):**
5. `attendance_mobile/lib/features/attendance/data/attendance_repository.dart` (3 vị trí)
6. `attendance_mobile/lib/features/attendance/presentation/attendance_provider.dart` (1 vị trí)
7. `attendance_mobile/lib/features/home/presentation/home_provider.dart` (2 vị trí)
8. `attendance_mobile/lib/features/home/presentation/home_screen.dart` (2 vị trí)
9. `attendance_mobile/lib/features/attendance/presentation/attendance_history_provider.dart` (3 vị trí)
10. `attendance_mobile/lib/core/utils/work_schedule_helper.dart` (1 vị trí)
11. `attendance_mobile/lib/features/home/presentation/widgets/home_header.dart` (1 vị trí — tuỳ chọn)
12. `attendance_mobile/lib/features/attendance/presentation/widgets/attendance_record_list.dart` (1 vị trí — tuỳ chọn)

**Sửa (thêm route + entry menu + gắn banner dùng chung):**
13. `attendance_mobile/lib/core/router/app_router.dart` (thêm 1 `GoRoute`)
14. `attendance_mobile/lib/features/profile/presentation/profile_screen.dart` (thêm 1 mục menu điều kiện `kDebugMode`)
15. `attendance_mobile/lib/features/home/presentation/home_screen.dart` (gắn thêm `DemoModeBanner` — cùng file đã sửa ở #8, không tính thêm file mới)
16. `attendance_mobile/lib/features/attendance/presentation/attendance_history_screen.dart` (gắn thêm `DemoModeBanner` — file mới cần sửa, chưa xuất hiện ở danh sách trước vì v1 chưa đề cập banner ở màn History)

---

## 11. Đề xuất Test Plan

Thực hiện tuần tự trên 1 tài khoản nhân viên nhóm A (hoặc B), theo đúng chuỗi mốc giờ đã nêu trong yêu cầu:

| # | Demo Time | Hành động | Kỳ vọng |
|---|---|---|---|
| 1 | Hôm nay, 07:50 | Mở Home | Nút Check In khả dụng, hiển thị ca sắp tới đúng theo Shift Rotation của nhóm |
| 2 | Hôm nay, 08:10 | Check In | Thành công, `isLate = true`, status `late` |
| 3 | Hôm nay, 12:30 | Mở Home/History | Trạng thái "Đã Check In", chưa Check Out |
| 4 | Hôm nay, 13:00 | Mở History | Record hôm nay hiển thị đúng ca, đúng giờ vào |
| 5 | Hôm nay, 19:50 | Mở Home (ca đêm nhóm ngược lại) | Hiển thị đúng ca đêm sắp tới |
| 6 | Hôm nay, 20:00 | Check In (tài khoản ca đêm) | Đúng giờ, `isLate = false` |
| 7 | Hôm nay, 20:15 | Check In (tài khoản khác, ca đêm) | `isLate = true` |
| 8 | Hôm nay, 23:30 | Mở Home | Vẫn thuộc Business Date hôm nay |
| 9 | Hôm nay, 00:15 (ngày lịch mới) | Mở Home | Business Date vẫn là ngày ca đêm bắt đầu |
| 10 | Hôm nay, 00:15 | Check Out (tài khoản ca đêm ở bước 6/7) | Tìm đúng document đã tạo lúc 20:00/20:15 |
| 11 | Hôm sau, 07:59 | Check Out (nếu chưa Check Out ở bước 10) | Trong khung ân hạn 2 giờ → thành công |
| 12 | Hôm sau, 07:59 | Check Out (kịch bản về sớm) | `isEarlyLeave = true` nếu checkout trước giờ kết thúc ca |
| 13 | Bất kỳ mốc nào | Bấm **Reset** | `ClockService.now()` quay lại thật, banner biến mất ở cả Demo Center lẫn Home/History |
| 14 | Từ 07:50, bấm **+5 phút** 4 lần liên tiếp | — | Demo Time = 08:10, banner + khối "Thông tin hiện tại" cập nhật tức thời không cần thao tác thêm |
| 15 | Đang **Use Real Time**, bấm thẳng **+1 giờ** (chưa từng bấm Use Demo Time) | — | Tự chuyển sang Use Demo Time với mốc gốc = giờ thật hiện tại + 1 giờ (theo quy tắc 5.3) |
| 16 | Build `--release` | Kiểm tra không có mục "Demo Center" trong Profile, không có banner nào xuất hiện | Xác nhận `kDebugMode == false` chặn hoàn toàn |

Sau bước 9–11, kiểm tra chéo dữ liệu trên Firestore Console: `attendanceDate` phải đúng ngày ca đêm bắt đầu.

---

## 12. Ước lượng số dòng code thay đổi

| Hạng mục | Ước lượng |
|---|---|
| `clock_service.dart` (mới, gồm `demoTimeListenable`) | ~25 dòng |
| `demo_status_provider.dart` (mới — tính Business Date/Shift/User dùng chung) | ~35–45 dòng |
| `demo_mode_banner.dart` (mới — widget dùng chung 2 nơi) | ~40–60 dòng |
| `demo_center_screen.dart` (mới — Demo Time + Fast Forward + khối thông tin) | ~180–220 dòng (tăng so với v1 do thêm Fast Forward + khối thông tin) |
| Đổi `DateTime.now()` → `ClockService.now()` tại 8 file nghiệp vụ | ~12 dòng sửa + 8 dòng import |
| Đổi tuỳ chọn ở `home_header.dart`, `attendance_record_list.dart` | ~2 dòng sửa + 2 dòng import |
| Gắn `DemoModeBanner` vào `home_screen.dart` + `attendance_history_screen.dart` | ~10–15 dòng |
| Thêm route + menu (`app_router.dart`, `profile_screen.dart`) | ~15–20 dòng |
| **Tổng** | **~320–400 dòng**, tăng so với v1 (~170–220) chủ yếu do Fast Forward + banner mở rộng + khối thông tin; vẫn toàn bộ trong `attendance_mobile`, không đụng `attendance_admin`, không đụng Firestore Rules/schema |

---

## 13. Câu hỏi cần xác nhận trước khi triển khai

1. Chấp nhận rủi ro "Admin Dashboard không đồng bộ" ở mục 8 (phương án 1/2), hay muốn mở rộng `ClockService` sang `attendance_admin` luôn (phương án 3)?
2. Vị trí đặt các file mới: `lib/features/dev_tools/` (feature riêng, đề xuất trong tài liệu này) hay gộp vào `lib/dev/` (đúng tinh thần "dev-only tooling" đã có sẵn cho `demo_seeder.dart`)?
3. Có cần đổi cả 2 vị trí "tuỳ chọn" (`home_header.dart`, `attendance_record_list.dart`) hay chỉ chắc chắn đổi 8 vị trí nghiệp vụ bắt buộc?
4. Đồng ý banner rút gọn gắn thêm ở `attendance_history_screen.dart` (mục 10, #16) hay chỉ cần banner ở Home là đủ?
5. Xác nhận danh sách "Thông tin hiện tại" chỉ gồm Current User / Current Business Date / Current Shift (mục 6) — không thêm GPS Status/Seed/Reset Demo Data ở phase này?

Sau khi bạn xác nhận, sẽ triển khai code theo đúng danh sách ở mục 10.
