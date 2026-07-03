# P1-03 — Phân tích: `double.parse`/`int.parse` không được bảo vệ trong Settings Screen

> Tài liệu phân tích theo Development Workflow (`CLAUDE.md`). **Không có dòng code nào bị sửa** khi tạo tài liệu này.
>
> Phạm vi: `attendance_admin/lib/features/settings/presentation/settings_screen.dart`, tham chiếu `attendance_admin/lib/core/utils/validators.dart`.

---

## 1. Mô tả bug hiện tại

Màn hình **Cấu hình hệ thống** (`SettingsScreen`, app Admin) cho phép nhập 4 trường số: **Vĩ độ (Latitude)**, **Kinh độ (Longitude)**, **Bán kính cho phép (mét)**, **Chu kỳ xoay ca (ngày)**.

Cả 4 trường này đều dùng chung một validator generic (`_buildTextField`, dòng 198-209) chỉ kiểm tra **"không được để trống"** — không kiểm tra định dạng số. Khi bấm **"Lưu cấu hình"**, hàm `_saveSettings()` (dòng 211-241) gọi trực tiếp `double.parse()`/`int.parse()` trên nội dung 4 controller đó (dòng 216-218, 223) để dựng `CompanySettingsModel` mới, và **các lệnh `parse` này nằm ngoài khối `try-catch`** (khối `try` chỉ bọc quanh `updateSettings()` ở dòng 227-233).

Hậu quả: nếu người dùng nhập bất kỳ chuỗi không phải số hợp lệ nào vào 1 trong 4 ô trên (kể cả gõ nhầm, dán nhầm nội dung, hoặc dùng dấu phẩy thập phân thay vì dấu chấm theo locale máy), form vẫn coi là "hợp lệ" (vì không rỗng) nhưng `double.parse`/`int.parse` sẽ ném `FormatException` **không được bắt** → lỗi không được xử lý, không có thông báo thân thiện nào hiển thị cho người dùng, thao tác lưu cấu hình bị gián đoạn giữa chừng.

## 2. Hướng dẫn cách tái hiện bug

1. Đăng nhập app Admin bằng tài khoản `role: admin`, vào màn **Settings** (sidebar → "Cấu Hình Vị Trí GPS").
2. Đợi form load xong dữ liệu hiện có (các ô đã có giá trị số hợp lệ từ Firestore).
3. Xoá nội dung ô **"Bán kính cho phép (mét)"**, gõ vào một chuỗi không phải số, ví dụ: `abc` (hoặc gõ `100,5` — dùng dấu phẩy thay vì dấu chấm thập phân, tuỳ locale bàn phím).
4. Bấm nút **"Lưu cấu hình"**.
5. Quan sát: `_formKey.currentState!.validate()` trả về `true` (vì validator hiện tại chỉ kiểm tra "không rỗng"), sau đó `double.parse(_radiusController.text)` ném `FormatException: Invalid double` ngay tại dòng dựng `CompanySettingsModel` — **trước** khối `try`, nên không được `catch (e)` xử lý. Ứng dụng không hiển thị SnackBar lỗi nào cho người dùng; hành vi thực tế phụ thuộc runtime (Flutter Web sẽ log lỗi ra console và có thể hiện "red screen"/exception overlay ở debug mode, ở release mode UI có thể đứng im không phản hồi mà không rõ lý do).
6. Có thể lặp lại tương tự với ô **Latitude**, **Longitude**, hoặc **Chu kỳ xoay ca (ngày)** — cùng một lỗi.

## 3. Phân tích nguyên nhân gốc

Hai nguyên nhân độc lập cộng hưởng với nhau:

- **Nguyên nhân 1 — Validator sai loại kiểm tra:** `_buildTextField()` (dòng 198-209) được dùng chung cho **mọi** ô nhập trong form (cả text tự do như "Tên công ty", cả giờ dạng chuỗi `HH:mm`, lẫn số như Latitude/Longitude/Radius/RotationDays), nhưng chỉ có **một** validator cứng: `v == null || v.isEmpty ? 'Không được để trống' : null`. Không có nhánh nào kiểm tra riêng "đây có phải một số hợp lệ không" cho các ô cần parse thành `double`/`int`.
  - Đáng chú ý: `Validators.numeric()` (dòng 41-45, `core/utils/validators.dart`) đã được viết sẵn đúng mục đích này (`double.tryParse(value.trim()) == null` → báo lỗi) nhưng **không được gọi ở bất kỳ đâu trong `settings_screen.dart`** — đây là dead code đã được ghi nhận trong `REVIEW.md` (mục 11 — Dead code) và giờ là nguyên nhân trực tiếp của bug này.
- **Nguyên nhân 2 — Vị trí đặt code sai:** Ngay cả khi validator có lọt qua input xấu (hoặc trước khi sửa validator), việc gọi `double.parse`/`int.parse` để dựng `CompanySettingsModel` (dòng 214-225) lại nằm **ngoài** khối `try { ... } catch (e) { ... }` (dòng 227-240) — khối `try` hiện tại chỉ bảo vệ lệnh `await ref.read(settingsRepositoryProvider).updateSettings(newSettings)`, không bảo vệ bước dựng object phía trên nó. Đây là lỗi logic thuần tuý về phạm vi (scope) của khối try-catch, độc lập với việc có sửa validator hay không.

Kết luận: đây là bug thuộc dạng **thiếu validation đầu vào + xử lý lỗi không đầy đủ (exception ném ra ngoài phạm vi try-catch)**, không phải vấn đề kiến trúc hay thiết kế.

## 4. Đề xuất giải pháp sửa

Sửa cả hai nguyên nhân gốc, giữ nguyên UI/UX và cấu trúc code hiện tại (không thêm class/layer mới):

**a) Sửa validator cho 4 ô số** — thêm tham số `validator` tuỳ chọn cho `_buildTextField()` (mặc định giữ nguyên hành vi cũ "không được để trống" để không ảnh hưởng các ô text/giờ khác), rồi truyền `Validators.numeric` (đã có sẵn, chỉ cần import và gọi) cho 4 lời gọi `_buildTextField(...)` ứng với Latitude, Longitude, Radius, Rotation Days.

**b) Di chuyển toàn bộ việc dựng `CompanySettingsModel` (bao gồm các lệnh `parse`) vào bên trong khối `try`** trong `_saveSettings()`, để nếu vẫn có `FormatException` lọt qua (phòng hờ), người dùng vẫn nhận được thông báo lỗi qua SnackBar hiện có thay vì app bị crash/treo im lặng.

Hai thay đổi này bổ trợ nhau: (a) ngăn chặn từ gốc (người dùng không thể submit input sai định dạng), (b) là lớp phòng vệ thứ hai (an toàn ngay cả khi có input lọt qua theo cách nào đó trong tương lai). Không cần thêm package, không đổi model, không đổi Firestore schema, không đổi luồng UI.

## 5. Liệt kê toàn bộ file cần sửa

| File | Cần sửa? |
|---|---|
| `attendance_admin/lib/features/settings/presentation/settings_screen.dart` | **Có** — sửa `_buildTextField()`, 4 lời gọi tương ứng, và `_saveSettings()` |
| `attendance_admin/lib/core/utils/validators.dart` | **Không** — `Validators.numeric()` đã tồn tại sẵn và đáp ứng đúng nhu cầu, chỉ cần được gọi tới, không cần sửa nội dung |

Không có file nào ở app Mobile hay ở tầng Firestore (rules/schema) cần sửa cho task này.

## 6. Giải thích vì sao từng file cần sửa

- **`settings_screen.dart` — bắt buộc sửa** vì đây là nơi duy nhất chứa cả 2 nguyên nhân gốc: (1) hàm `_buildTextField()` dựng validator sai loại cho ô số, (2) hàm `_saveSettings()` đặt lệnh `parse` sai vị trí (ngoài `try`). Sửa bug phải diễn ra tại đúng nơi phát sinh lỗi.
- **`validators.dart` — không cần sửa** vì hàm `Validators.numeric()` đã được viết đúng, đầy đủ, kiểm tra chính xác điều kiện cần (rỗng hoặc không parse được thành số) và đã trả về thông báo lỗi tiếng Việt phù hợp. Vấn đề duy nhất là nó chưa được "gọi tới" từ `settings_screen.dart` — nên chỉ cần import và sử dụng, không cần chỉnh sửa logic bên trong file này.

## 7. Đánh giá mức độ rủi ro

- **Rủi ro của bug hiện tại (nếu không sửa):** Cao (đã xếp Critical trong `REVIEW.md`/`ROADMAP.md`) — đây là lỗi có thể **tái hiện 100%** chỉ bằng một thao tác gõ nhầm rất dễ xảy ra trong thực tế (dấu phẩy thay dấu chấm thập phân, dán nhầm nội dung), làm gián đoạn hoàn toàn khả năng cập nhật cấu hình công ty (toạ độ văn phòng, bán kính GPS, chu kỳ xoay ca) — đây là các thông số ảnh hưởng trực tiếp đến khả năng chấm công của toàn bộ nhân viên.
- **Rủi ro của fix đề xuất:** Thấp.
  - Thay đổi (a) chỉ thêm một nhánh validator mới cho đúng 4 field đã xác định, không đổi hành vi của các field khác (company name, giờ ca dạng `HH:mm` vẫn giữ validator "không rỗng" như cũ).
  - Thay đổi (b) chỉ mở rộng phạm vi khối `try` đã có sẵn, không đổi logic nghiệp vụ, không đổi những gì được gửi lên Firestore khi input hợp lệ.
  - Không có rủi ro phá vỡ tính năng khác vì thay đổi khoanh vùng hoàn toàn trong 1 file, không đụng tới model/repository/provider.
- **Rủi ro còn sót lại sau khi sửa (chấp nhận được, ngoài phạm vi P1-03):** Các ô giờ ca (`dayShiftStart`, `dayShiftEnd`, `nightShiftStart`, `nightShiftEnd`) hiện vẫn chỉ validate "không rỗng", chưa kiểm tra đúng định dạng `HH:mm`. Nếu admin nhập sai định dạng giờ (vd. `25:99`), lỗi sẽ không xảy ra ngay tại `settings_screen.dart` mà có thể gây lỗi `int.parse`/`RangeError` sau này ở nơi khác tiêu thụ dữ liệu này (`CompanySettingsModel.calculateIsLate`/`calculateEarlyLeave`, cả hai app). Đây là một rủi ro tương tự nhưng **nằm ngoài phạm vi được giao cho P1-03** (P1-03 theo `ROADMAP.md` chỉ nêu 4 ô số: Latitude/Longitude/Radius/Rotation Days) — xin phép không tự ý mở rộng phạm vi sửa, ghi nhận lại để cân nhắc thành một task riêng nếu cần.

## 8. Đánh giá ảnh hưởng đến Mobile, Admin và Firestore

- **Admin:** Bị ảnh hưởng trực tiếp — đây là nơi duy nhất chứa bug và cũng là nơi duy nhất cần sửa code.
- **Mobile:** Không cần sửa code nào. Tuy nhiên **hưởng lợi gián tiếp**: vì `company_settings` là dữ liệu dùng chung, việc Admin không còn bị crash khi lưu cấu hình giúp giảm rủi ro Admin bỏ dở thao tác lưu ở trạng thái dữ liệu không nhất quán, gián tiếp bảo vệ tính đúng đắn của dữ liệu mà Mobile phụ thuộc vào (toạ độ văn phòng, bán kính, giờ ca).
- **Firestore:** Không đổi schema, không đổi field, không đổi document ID. Fix chỉ ngăn việc gửi lệnh ghi lên Firestore khi dữ liệu đầu vào không hợp lệ — tức là **giảm khả năng ghi dữ liệu sai** (vd. nếu trước đây `parse` bằng cách nào đó không throw nhưng cho ra giá trị bất thường) chứ không thay đổi cấu trúc dữ liệu được ghi khi input hợp lệ.

## 9. Đề xuất các bước kiểm thử thủ công sau khi sửa

1. **Test input hợp lệ (regression):** Mở Settings, sửa từng ô trong 4 ô số (Latitude, Longitude, Radius, Rotation Days) bằng giá trị số hợp lệ khác nhau, bấm Lưu → xác nhận vẫn lưu thành công như trước, SnackBar "Đã cập nhật cấu hình hệ thống thành công!" hiển thị bình thường.
2. **Test validator chặn input sai định dạng:**
   - Nhập `abc` vào ô Radius → bấm Lưu → kỳ vọng: form hiển thị lỗi validator ngay dưới ô (không rời màn hình, không crash), thông báo dạng "Vui lòng nhập số hợp lệ".
   - Lặp lại tương tự cho Latitude, Longitude, Rotation Days.
3. **Test dấu phân cách thập phân:** Nhập `21,0285` (dấu phẩy) vào ô Latitude → xác nhận validator báo lỗi rõ ràng thay vì crash im lặng.
4. **Test giá trị rỗng (regression cho validator cũ):** Xoá trắng ô Radius → bấm Lưu → xác nhận vẫn hiển thị lỗi (không được để trống/không hợp lệ) như hành vi mong đợi, không có gì thay đổi xấu đi so với trước.
5. **Test không có exception rơi ra ngoài UI:** Trong lúc thực hiện bước 2-3, mở DevTools/console (nếu chạy Flutter Web ở chế độ debug) để xác nhận **không** còn `Unhandled Exception: FormatException` nào được log ra — toàn bộ lỗi phải được validator chặn trước khi tới `_saveSettings()`, hoặc nếu lọt qua thì phải được `catch` và hiển thị SnackBar đỏ "Lỗi khi lưu: ..." thay vì crash.
6. **Test không ảnh hưởng field khác:** Xác nhận các ô "Tên công ty" và 4 ô giờ ca (`HH:mm`) vẫn giữ nguyên hành vi validate cũ ("không được để trống"), không bị áp nhầm validator số.
7. **Test hồi quy P1-02:** Sau khi lưu thành công ở bước 1, kiểm tra lại Firestore Console rằng `rotationStartDate` vẫn được giữ nguyên (không bị mất) — đảm bảo fix P1-03 không vô tình phá lại fix P1-02 đã làm trước đó trong cùng file.
