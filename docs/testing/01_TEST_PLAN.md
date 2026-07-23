# 01_TEST_PLAN.md

**Mục tiêu:** Kế hoạch kiểm thử đầy đủ cho `attendance-system`, ở dạng có thể chấm điểm Pass/Fail từng trường hợp — thứ mà checklist Phase C của `PROJECT_MASTER_PLAN.md` (chỉ là danh sách gạch đầu dòng) chưa đủ chi tiết để làm.

**Phạm vi:** Unit test (hàm thuần, không phụ thuộc Firestore) + Manual test (luồng phụ thuộc Firestore/GPS/thiết bị, không mock được vì kiến trúc hiện tại không có Repository interface — xem `docs/decision/01_DECISION_LOG.md` D-008).

**Khi nào dùng:** Từ Sprint 4-5 (`docs/project/02_SPRINT.md`) trở đi; chạy lại toàn bộ (regression) sau mỗi đợt sửa lỗi lớn ở Phase A/B; chạy lại có chọn lọc trước Phase E (Release) và trước Phase D.2 (Demo bảo vệ).

**Liên kết:** Nguồn gốc checklist — `PROJECT_MASTER_PLAN.md` Phase C; bug phát hiện trong lúc test → ghi vào `docs/testing/02_BUG_TRACKER.md`, không ghi trực tiếp vào đây; 10 mốc Demo Time chi tiết → `docs/demo/DEMO_GUIDE.md` §3.2 (tham chiếu, không copy lại).

---

## Chú giải cột

**Status:** `Chưa chạy` / `Pass` / `Fail` / `Blocked` (không chạy được vì phụ thuộc việc khác chưa xong).

---

## A. Unit Test (tự động, `flutter test`)

Khả thi vì đây là các hàm thuần Dart, không đụng `cloud_firestore`/`firebase_auth` — không vi phạm ràng buộc "không đổi kiến trúc".

| ID | Hàm kiểm thử | Test case | Expected | Status |
|---|---|---|---|---|
| UT-01 | `Haversine.calculateDistance()` | Khoảng cách = 0 (cùng toạ độ) | trả về 0 | **Pass** (2026-07-20, `test/core/utils/haversine_test.dart`) |
| UT-02 | `Haversine.calculateDistance()` | Khoảng cách đúng bằng bán kính cho phép (biên) | so sánh `<=` đúng như code dùng | **Pass** (2026-07-20) — test qua `isWithinRadius()`, đúng hàm biên thực tế dùng trong code |
| UT-03 | `Haversine.calculateDistance()` | Khoảng cách rất lớn (khác lục địa) | không lỗi tràn số, trả về giá trị hợp lý (km) | **Pass** (2026-07-20) |
| UT-04 | `CompanySettingsModel.getCurrentShift()` | Đúng ngày đổi ca (biên `daysPassed % rotationDays == 0`) | nhóm A/B đổi vai trò đúng dự kiến | **Pass** (2026-07-20, `test/core/utils/rotation_calculator_test.dart`) — test trực tiếp qua `RotationCalculator.getCurrentShift()` |
| UT-05 | `CompanySettingsModel.getCurrentShift()` | 1 ngày trước/sau mốc đổi ca | ca giữ nguyên, không đổi sớm/muộn 1 ngày | **Pass** (2026-07-20) |
| UT-06 | `calculateIsLate()` | Check-in đúng giờ bắt đầu ca | `isLate = false` | **Pass** (2026-07-20, `test/features/settings/company_settings_model_test.dart`) |
| UT-07 | `calculateIsLate()` | Check-in trễ 1 phút / trễ nhiều | `isLate = true` | **Pass** (2026-07-20) |
| UT-08 | `calculateIsLate()` | Ca đêm, check-in ngay trước nửa đêm | tính đúng theo giờ ca đêm, không lệch ngày | **Pass** (2026-07-20) |
| UT-09 | `calculateEarlyLeave()` | Check-out đúng giờ / sau giờ kết thúc ca | `isEarlyLeave = false` | **Pass** (2026-07-20) |
| UT-10 | `calculateEarlyLeave()` | Check-out sớm | `isEarlyLeave = true` | **Pass** (2026-07-20) |
| UT-11 | `calculateEarlyLeave()` | Ca đêm, check-out sau khi qua nửa đêm (thuộc "ngày hôm sau" theo đồng hồ) | vẫn tính đúng cho ca làm đêm hôm trước | **Pass** (2026-07-20) |
| UT-12 | `BusinessDateHelper.resolveBusinessDate()` | Sự kiện lúc 23:59 | resolve đúng ngày làm việc hiện tại | **Pass** (2026-07-20, `test/core/utils/business_date_helper_test.dart`) |
| UT-13 | `BusinessDateHelper.resolveBusinessDate()` | Sự kiện lúc 00:00 | resolve đúng ranh giới (kiểm tra nhóm có làm đêm "hôm qua" không) | **Pass** (2026-07-20) |
| UT-14 | `BusinessDateHelper.resolveBusinessDate()` | Sự kiện lúc 00:15 (đúng mốc trong `docs/demo/DEMO_GUIDE.md`) | khớp với hành vi đã ghi trong Demo Guide | **Pass** (2026-07-20) — có thêm 1 test đối chứng (nhóm làm ngày hôm qua thì không lùi ngày) |

## B. Manual Test — Check In / Check Out

Khuyến nghị dùng Demo Time System (`ClockService`, Fast Forward/Rewind) để tạo nhanh các mốc giờ biên thay vì chờ thời gian thực — xem `docs/decision/01_DECISION_LOG.md` D-005.

| ID | Kịch bản | Precondition | Steps | Expected | Status |
|---|---|---|---|---|---|
| MT-01 | Check In đúng giờ, trong bán kính | tài khoản chưa check-in hôm nay | mở Home → bấm Check In | tạo doc `attendance`, `isLate=false` | **Pass** (2026-07-22, test tay thiết bị thật) |
| MT-02 | Check In trễ | như trên, đồng hồ demo sau giờ bắt đầu ca | Check In | `isLate=true` | **Pass** (2026-07-22, test tay Demo Time) |
| MT-03 | Check In ngoài bán kính GPS | vị trí giả lập ngoài `radius` | Check In | bị từ chối, thông báo đúng theo `gps_service.dart` | **Pass** (2026-07-22) — phát hiện thêm 3 chỗ popup còn dư chữ "Exception: " (`attendance_history_provider.dart`, `attendance_provider.dart` loadTodayAttendance, `home_provider.dart`), đã sửa cùng đợt |
| MT-04 | Check In với vị trí giả (mock location) | bật app giả lập GPS | Check In | bị từ chối: "Phát hiện vị trí giả..." | **Pass** (2026-07-22, test tay thiết bị thật) |
| MT-05 | Check In trùng lặp trong cùng ngày làm việc | đã Check In rồi | bấm Check In lần 2 | bị từ chối rõ ràng, không tạo doc trùng | **Pass (gián tiếp)** (2026-07-22) — UI tự ẩn nút Check In khi đã có `todayAttendance` nên không bấm lại bình thường được (đây chính là kỳ vọng "không tạo doc trùng" ở tầng UX); lớp bảo vệ backend (transaction) được xác nhận trực tiếp qua TD01-02 |
| MT-06 | Check Out đúng giờ | đã Check In | Check Out | `workHours` đúng, `status='completed'` | **Pass** (2026-07-22) — quá trình test phát hiện thêm 4 bug thật (BUG-016→019, xem `02_BUG_TRACKER.md`) qua kịch bản ca đêm carryover sang ngày mới/ngày nghỉ bắt buộc, cả 4 đã sửa và xác nhận Pass |
| MT-07 | Check Out sớm | đồng hồ demo trước giờ kết thúc ca | Check Out | `isEarlyLeave=true` | **Pass** (2026-07-22, test tay Demo Time) |
| MT-08 | Check Out mà chưa Check In | chưa có doc hôm nay | bấm Check Out | bị từ chối, thông báo rõ ràng | **Pass (gián tiếp)** (2026-07-22) — nút Check Out bị khoá/xám ở tầng UI, không bấm được (giống MT-05); hành vi backend (`checkOut()` ném "Không tìm thấy ca làm việc cần Check Out hợp lệ...") chưa test trực tiếp qua đường vòng |
| MT-09 | Check Out quá giờ ân hạn | đồng hồ demo quá xa giờ kết thúc ca | Check Out | hành vi đúng theo business rule hiện có (xem `attendance_repository.dart`) | **Pass (một phần)** (2026-07-22) — trong khung ân hạn (1 giờ) đã test Pass qua BUG-016→019. Còn 1 kịch bản phụ chưa test: nhảy demo time **qua khỏi** khung ân hạn rồi mới bấm Check Out → xác nhận bị từ chối đúng với thông báo "Không tìm thấy ca làm việc cần Check Out hợp lệ..." |
| MT-10 | Check In sau khi quá giờ kết thúc ca (bị coi là vắng) | đồng hồ demo sau giờ kết thúc ca | Check In | bị từ chối/đánh dấu vắng đúng logic | **Pass** (2026-07-22, test tay Demo Time) |
| TD01-01 | Check In bình thường, không tranh chấp (sau khi đổi sang `runTransaction()`, TD-01) | tài khoản chưa check-in hôm nay | Check In | thành công, dữ liệu đúng như trước khi có transaction | **Pass** (2026-07-13, test tay trên `RMX3491`) |
| TD01-02 | Double tap nút Check In thật nhanh | như trên | bấm 2 lần liên tiếp nhanh | chỉ 1 lần thành công, lần kia nhận đúng lỗi "Bạn đã Check In hôm nay rồi" — không ghi đè âm thầm | **Pass** (2026-07-22, thiết bị thật, tín hiệu GPS tốt) — đóng nốt BUG-014: xác nhận nguyên nhân timeout trước đây là do tín hiệu yếu, không phải do `runTransaction()` xử lý sai khi đụng độ 2 request |
| TD01-04 | Ngắt mạng đúng lúc gọi transaction | GPS đã lấy xong, tắt mạng trước khi bấm xác nhận cuối | Check In | "Không có kết nối Internet. Vui lòng kết nối mạng trước khi Check In." — không có document rác | **Pass** (2026-07-23, thiết bị thật) — đúng thông báo, không tạo document rác |
| TD01-08 | Check In khi thiết bị offline hoàn toàn | tắt mạng trước khi mở app | Check In | lỗi rõ ràng ngay, không "thành công giả" rồi đồng bộ ngầm | **Pass** (2026-07-23, thiết bị thật) — lỗi rõ ràng ngay, không có "thành công giả" hay document rác sau khi bật mạng lại |
| TD01-03 | 2 request gần như đồng thời | 2 thiết bị/phiên cùng tài khoản | Check In gần như cùng lúc trên cả 2 | đúng 1 thành công, 1 báo lỗi nghiệp vụ | **Blocked** — không có thiết bị thứ 2 để test, để lại làm việc tồn đọng |

## C. Manual Test — Rotation / Business Date

| ID | Kịch bản | Steps | Expected | Status |
|---|---|---|---|---|
| MT-11 | Xác nhận ca hiện tại đúng nhóm A/B theo `rotationStartDate` | mở Home bằng tài khoản nhóm A và nhóm B | So khớp với `CompanySettingsModel.getCurrentShift()` tính tay | đúng | **Pass** (2026-07-22) — nhóm A ca ngày, nhóm B ca đêm, đối nghịch đúng. Quá trình test phát hiện thêm BUG-020 (dữ liệu tài khoản cũ còn sót khi đổi tài khoản), đã sửa và xác nhận Pass, xem `02_BUG_TRACKER.md` |
| MT-12 | Đổi ca đúng ngày dự kiến | dùng Demo Time nhảy qua đúng ngày đổi ca (`rotationDays`) | Home hiển thị ca đảo ngược cho cả 2 nhóm | đúng | **Pass** (2026-07-22, test tay Demo Time, +14 ngày) |
| MT-13 | Business Date quanh nửa đêm ca đêm — 10 mốc | dùng Demo Time đặt lần lượt 10 mốc trong `docs/demo/DEMO_GUIDE.md` §3.2 | khớp đúng bảng dự đoán Firestore/Home/History đã ghi trong Demo Guide | **Pass** (2026-07-22, test tay Demo Time, cả 10/10 mốc) |

## D. Manual Test — Phân quyền / Bảo mật

| ID | Kịch bản | Steps | Expected | Status |
|---|---|---|---|---|
| MT-14 | Employee đăng nhập vào app admin | đăng nhập tài khoản `role=employee` trên admin | bị từ chối + signOut, thông báo đúng | **Pass** (2026-07-22, test tay) |
| MT-15 | Admin đăng nhập vào app mobile | đăng nhập tài khoản `role=admin` trên mobile | bị từ chối + signOut, thông báo đúng | **Pass** (2026-07-22, test tay) |
| MT-16 | Tài khoản `isActive=false` đăng nhập | set `isActive=false` trên Firestore Console, thử đăng nhập | bị từ chối cả 2 app | **Pass** (2026-07-22, test tay qua chức năng Vô hiệu hoá của Admin) |
| MT-17 | Đọc/ghi trái phép qua Firebase Console/REST với tài khoản không đủ quyền | dùng tài khoản employee thử đọc `company_settings` write, hoặc đọc `attendance` của người khác qua truy vấn không lọc | bị chặn bởi `firestore.rules` | **Pass** (2026-07-22) — test qua REST API thật (idToken thật của tài khoản employee) trên Production, 6/6 kịch bản bị từ chối đúng: ghi `company_settings`, đọc `users` người khác, đọc `attendance` người khác, query không lọc `attendance`, đọc `device_activations` của chính mình, tự đổi `role` thành admin |

## E. Manual Test — Demo Time System (chưa từng test tay)

| ID | Kịch bản | Steps | Expected | Status |
|---|---|---|---|---|
| MT-18 | Bật Use Demo Time, đặt ngày/giờ cụ thể | mở Demo Center → chọn Use Demo Time → Apply | Home/History phản ánh đúng ngày/giờ đã đặt | **Pass** (2026-07-13, test tay trên `RMX3491`) |
| MT-19 | Fast Forward từng mức (+5p, +30p, +1h, +6h, +12h, +1d) | bấm lần lượt | đồng hồ demo tăng đúng, UI cập nhật | **Pass** (2026-07-13) |
| MT-20 | Rewind từng mức (-5p, -30p, -1h, -6h, -12h, -1d) | bấm lần lượt | đồng hồ demo giảm đúng | **Pass** (2026-07-13) |
| MT-21 | Reset to Current Time | bấm nút Reset | quay lại giờ thực, banner Demo Mode biến mất | **Pass** (2026-07-13) |
| MT-22 | Demo Mode Banner hiển thị đúng trên Home + History | bật Demo Time, mở lần lượt 2 màn | banner hiện, đúng Business Date/Shift | **Pass** (2026-07-13) |
| MT-23 | Xác nhận Release build không lộ Demo Center | build `flutter build apk --release` rồi kiểm tra route `/demo-center` | không truy cập được (chặn bởi `kDebugMode`) | **Pass** (2026-07-13, sau khi sửa BUG-013) — route bọc `if (kDebugMode)` giống P1-06; xác nhận bằng lý luận compile-time elimination + cài/chạy thử release APK thật trên thiết bị (`RMX3491`), khởi động sạch, không crash |

## F. Regression

| ID | Kịch bản | Khi nào chạy | Status |
|---|---|---|---|
| RG-01 | Chạy lại toàn bộ mục B + C | sau mỗi đợt sửa lỗi liên quan Attendance/Rotation ở Phase A/B | Chưa chạy |
| RG-02 | Chạy lại toàn bộ mục D | sau mỗi thay đổi liên quan `firestore.rules`/Auth | Chưa chạy |
| RG-03 | Chạy lại mục A (unit test) | mỗi lần `flutter test`, lý tưởng là mỗi lần commit liên quan business logic | Chưa chạy |
| RG-04 | Ít nhất 1 lượt kiểm thử B+C bằng **thời gian thực** (không dùng Demo Time) | trước Milestone M3 (Release) và trước M6 (Demo bảo vệ) | **Skipped** (2026-07-23, theo quyết định của bạn — bỏ qua có chủ đích, không phải Blocked) |

## G. Edge Case tổng hợp (không thuộc nhóm nào ở trên)

| ID | Kịch bản | Expected | Status |
|---|---|---|---|
| EC-01 | `company_settings` bị thiếu field khi đọc (test khả năng chịu lỗi của `fromFirestore`) | không crash, dùng fallback hợp lý | **Pass** (2026-07-22, test tay xoá tạm field `companyName`) |
| EC-02 | Document `attendance` thiếu `attendanceDate` (test P1-04 vẫn đứng vững) | không crash toàn bộ danh sách, chỉ bỏ qua/log document lỗi | **Pass** (2026-07-22, test tay) |
| EC-03 | Mất mạng giữa lúc Check In (test hành vi khi Firestore write thất bại) | thông báo lỗi rõ ràng, không tạo doc dở dang | **Pass** (2026-07-22) — phát hiện thêm BUG-021 (`getTodayAttendance()` lộ lỗi thô khi offline), đã sửa và xác nhận Pass, xem `02_BUG_TRACKER.md` |
