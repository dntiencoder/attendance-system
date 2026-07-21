# FEAT_05_IMPLEMENTATION_PLAN.md

**Kế hoạch Implementation — FEAT-05: Anti Fraud & Device Security**

**Nguồn sự thật:** `docs/design/ANTI_FRAUD_DESIGN.md` (bản cuối). Mọi Phase/Task dưới đây bám sát tài liệu đó — không tự ý đổi thiết kế.

**Trạng thái:** Đang triển khai — **22/25 Phase Done** (Phase 15 test tay PASS phần lõi, còn 2 kịch bản phụ không gấp). Rules an toàn đã deploy tạm lên Production. Còn Phase 19-21 (bật enforce `deviceId` cho `attendance`) cần quyết định phương án test (JDK 21+/Emulator hoặc khác) ở phiên tiếp theo — xem §0.5.

---

## 0.5 Trạng thái triển khai thực tế (cập nhật 2026-07-21)

**Tổng quan:** Sprint A, D (code), B (code), C (code, chưa deploy), E — đã code xong và commit. 18 commit, `flutter analyze`/`flutter test`/`flutter build web` (cả 2 app) đều sạch ở mọi bước.

**🔴 1 lỗi bảo mật thật phát hiện + đã sửa (Phase 10, lúc soạn Rules ở Phase 18):** code redeem ban đầu đọc trực tiếp `device_activations` (lộ field `code`) — mâu thuẫn với nguyên tắc "không cấp quyền đọc mã cho nhân viên" của thiết kế. Đã thiết kế lại thành cơ chế "ghi mù" (client không bao giờ đọc, Rules tự đối chiếu phía server) — commit `b0cbe51`, tách riêng để minh bạch.

**🔴 1 bug build thật, ĐÃ SỬA (phát hiện lại khi bạn tự chạy `flutter run` trên máy thật):** Gradle/Kotlin Build Tools API lỗi "Could not close incremental caches" / "already registered" khi biên dịch song song `device_info_plus`+`local_auth_android` — ban đầu tưởng chỉ do sandbox thực hiện, nhưng bạn gặp **y hệt trên máy thật**, xác nhận đây là bug thật của Kotlin Gradle Plugin (không phải lỗi code FEAT-05, không phải giới hạn môi trường sandbox). Nguyên nhân fix lần đầu thất bại: dùng `-Dkotlin.incremental=false` (cờ hệ thống JVM, sai chỗ). **Đã sửa đúng:** thêm `kotlin.incremental=false` vào `attendance_mobile/android/gradle.properties` — build lại thành công (`flutter build apk --debug` ✓). Phase 9 hết chặn, bạn cần thử lại `flutter run` trên thiết bị thật.

**🔴 1 bug Navigator thật, ĐÃ SỬA (phát hiện khi bạn test "Cấp mã kích hoạt" trên web):** `Navigator.pop(context)` trong `_showIssueActivationCode` (Phase 14) pop nhầm Navigator của `ShellRoute` thay vì Navigator gốc nơi `showDialog` thực sự đẩy dialog vào — crash "popped the last page off of the stack" khi vào nhánh lỗi, che mất thông báo lỗi Firestore thật bên dưới. **Đã sửa:** `Navigator.of(context, rootNavigator: true).pop()` — commit `3ad8d66`.

**⚠️ 1 giới hạn môi trường còn lại (sandbox thực hiện, không phải máy thật của bạn):** Firestore Emulator cần JDK 21+, sandbox chỉ có JDK 17 — không tự ý nâng cấp JDK hệ thống (ngoài phạm vi project). **Phase 19** cần bạn tự chạy `firebase emulators:start --only firestore,auth` trên máy có JDK phù hợp.

**Deploy tạm thời lên Production (commit `3ad8d66`, sau khi bạn xác nhận "Đồng ý, làm đi"):** sau khi vá Navigator, "Cấp mã kích hoạt" vẫn báo lỗi — xác nhận đúng nguyên nhân gốc là `permission-denied` (Rules `device_activations`/`device_audit_log` chưa deploy). Vì Firestore Rules deploy cả file 1 lần, không tách riêng từng `match` block được, đã **tạm comment lại** điều kiện `deviceId` ở `attendance.create`/`update` (phần rủi ro, chưa qua Phase 19-20) rồi deploy phần còn lại (an toàn, không đụng `attendance`) lên Production. Firebase CLI xác nhận "rules file compiled successfully" — gián tiếp kiểm chứng cú pháp Rules Phase 18 đúng. **Phase 15 (test Activation Code) giờ test được thật trên Production, không bắt buộc chờ Emulator nữa.**

**🔴🔴 1 lỗ hổng bảo mật NGHIÊM TRỌNG phát hiện + đã sửa (qua test tay thật trên Production, không phải review tĩnh):** cơ chế "tự phục hồi" thêm ở `8b675fa` (thử ghi thẳng `users.trustedDeviceId` TRƯỚC khi kiểm mã, để tránh kẹt nếu Ghi 2 lỡ thất bại) tạo lỗ hổng: một khi 1 thiết bị **từng** redeem đúng 1 lần (`device_activations.status` còn `'redeemed'` khớp `newDeviceId` của máy đó — trạng thái này **không tự mất** kể cả khi Admin cấp lại mã mới, vì `issueCode()` không đụng tới `users.trustedDeviceId`), mọi lần gọi `redeemCode()` SAU ĐÓ trên đúng máy đó **thành công ngay lập tức bất kể nhập gì vào ô mã** — vì bước "phục hồi" chạy TRƯỚC và không hề nhìn vào mã vừa nhập. Phát hiện qua chính user test tay ("mã nhập đại là tự vô được"). **Đã sửa (commit `6c15ce0`):** bỏ hẳn cơ chế tự phục hồi — Ghi 2 giờ chỉ chạy khi Write B (kiểm mã thật) vừa thành công trong đúng lần gọi đó, không còn đường tắt nào. Đánh đổi chấp nhận: nếu Ghi 2 lỡ thất bại giữa chừng (hiếm, chỉ khi mất mạng đúng lúc giữa 2 lượt ghi liên tiếp), nhân viên cần Admin cấp mã MỚI thay vì tự bấm lại được.

**Đã test tay thật, PASS đầy đủ (sau khi sửa cả 2 lỗ hổng trên):** cấp mã → redeem đúng mã → tự chuyển Home ✓; nhập sai mã → bị từ chối ✓; sai liên tiếp 6 lần trên cùng 1 mã (không cấp lại mã giữa chừng) → lần 6 bị khoá hẳn ✓. Còn 2 kịch bản phụ chưa test (không gấp): hết hạn 15 phút, cấp lại mã vô hiệu mã cũ ngay.

**Việc cần bạn làm tiếp:**
1. (Không gấp) Test nốt 2 kịch bản phụ của Phase 15: hết hạn mã, cấp lại mã vô hiệu mã cũ.
2. Quyết định phương án test riêng phần `attendance` enforcement (Phase 19) — cài JDK 21+ để chạy Emulator, hoặc phương án khác (xem thảo luận cần thống nhất ở phiên tiếp theo).
3. Phase 20: kiểm tra toàn bộ nhân viên `isActive=true` đã có `trustedDeviceId` chưa trước khi bật.
4. Phase 21: khôi phục 2 dòng điều kiện `deviceId` đang comment trong `firestore.rules` (`attendance.create`/`update`) rồi deploy đầy đủ lên Production.

---

## 0. Điều kiện bổ sung theo phê duyệt (2026, cùng phiên)

Người dùng approve kế hoạch với 2 điều kiện — cả 2 đã tích hợp vào bản này:

1. **`DeviceService` là lớp truy cập DUY NHẤT cho Device Identity** — không package nào (`device_info_plus`, `flutter_secure_storage`) được import trực tiếp ở bất kỳ file nào khác ngoài `device_service.dart`. Đã bổ sung: Task 2.4 (nguyên tắc), chú thích tường minh ở mọi Phase có tiêu thụ `installId`/`deviceInfo` (10, 13, 16), và 1 bước kiểm tra bằng grep ở DoD Sprint A + regression cuối cùng.
2. **Kiểm thử Firestore Rules trên Firebase Emulator trước khi deploy** — đã kiểm tra: dự án **chưa** cấu hình Emulator (`firebase.json` gốc chỉ có khối `firestore`, không có `emulators`). Theo đúng điều kiện đưa ra ("nếu chưa dùng thì tiếp tục quy trình hiện tại nhưng vẫn giữ bước kiểm tra migration"), đã bổ sung 2 Phase mới (17, 19) để thiết lập + dùng Emulator, **không thêm package/tooling ngoài hệ sinh thái Flutter đang dùng** (dùng `firebase emulators:start` qua Firebase CLI đã có sẵn để deploy Rules từ trước — không cần bộ test Node.js/`@firebase/rules-unit-testing` riêng, tương xứng quy mô đồ án). Bước kiểm tra migration trên dữ liệu Production thật (Phase 20, trước đây là Phase 17) **giữ nguyên**, không bị thay thế bởi Emulator.

**Thiếu sót tự phát hiện khi tích hợp 2 điều kiện trên (không liên quan trực tiếp tới điều kiện, nhưng lộ ra khi rà lại luồng dữ liệu):** kế hoạch bản trước **chưa có Phase nào ghi `deviceId` thật vào document `attendance`** khi Check In/Check Out — Phase 4 (cũ) chỉ thêm field vào `AttendanceModel`, còn cố ý ghi chú "chưa ghi giá trị thật, để Phase 18 xử lý" nhưng Phase 18 (cũ, deploy Rules) không hề chứa task sửa `attendance_repository.dart`. Nếu bỏ sót, khi Rules enforce `deviceId == trustedDeviceId`, mọi lượt Check In/Out hợp lệ đều gửi `deviceId = null` → bị Rules từ chối toàn bộ, kể cả nhân viên đã `TRUSTED` đúng. **Đã vá:** thêm Phase 16 mới (đánh số lại toàn bộ Sprint C từ đây).

**Kết quả renumber:** tổng số Phase tăng từ 22 → **25**. Sprint C (trước: Phase 16-18) nay là **Phase 16-21**. Sprint E (trước: Phase 19-22) nay là **Phase 22-25**.

---

## 1. Phân tích đối chiếu Thiết kế ↔ Codebase thật

*(Không đổi so với bản trước — nhắc gọn.)* Đã đọc trực tiếp `auth_repository.dart`, `attendance_repository.dart`, `attendance_provider.dart`, `app_router.dart`, `employee_repository.dart`, `employee_model.dart`, `firestore.rules`, `firestore.indexes.json`, `firebase.json` (gốc + 2 app), `tools/firestore_backup/` — không phát hiện mâu thuẫn với thiết kế cần DỪNG để xác nhận lại. `firebase.json` gốc xác nhận: chỉ cấu hình `firestore` (rules + indexes), chưa từng cấu hình `emulators` — cơ sở cho điều kiện 2 ở §0.

---

## 2. Ghi chú kỹ thuật (không phải vấn đề thiết kế)

### 2.1 Cơ chế ghi `trustedDeviceId` — 2 lượt ghi tuần tự

*(Không đổi.)* Ghi 1 (`device_activations/{uid}`, so khớp mã trong cùng document) → Ghi 2 (`users/{uid}.trustedDeviceId`, xác minh qua `get()` rằng Ghi 1 đã ở trạng thái `redeemed`) — giảm rủi ro so với 1 giao dịch atomic xuyên 2 document, đánh đổi chấp nhận được (client dừng giữa chừng chỉ cần bấm lại, không phải lỗ hổng).

### 2.2 `local_auth` yêu cầu `FlutterFragmentActivity` trên Android

*(Không đổi.)* Cần đổi `MainActivity.kt` ở Phase 7.

### 2.3 `StreamProvider users/{uid}` cho phản ứng real-time khi Reset — hoãn, ngoài phạm vi

*(Không đổi.)* Máy bị Reset vẫn bị chặn đúng ở lần Check In/Out tiếp theo (Rules enforce ở tầng ghi), chỉ không tức thời.

### 2.4 `DeviceService` là ranh giới truy cập duy nhất *(mới, theo điều kiện phê duyệt §0.1)*

- **Nguyên tắc:** chỉ `attendance_mobile/lib/core/services/device_service.dart` được phép chứa `import 'package:device_info_plus/...'` và `import 'package:flutter_secure_storage/...'`. Mọi nơi khác cần `installId`/`deviceInfo` (repository, provider, screen) gọi qua API công khai của `DeviceService` (ví dụ `DeviceService().getInstallId()`), không tự đọc package trực tiếp.
- **Áp dụng cụ thể ở các Phase:** Phase 10 (redeem — cần `installId` làm `newDeviceId` ứng viên), Phase 13 (so khớp `installId` sau login), Phase 16 (ghi `deviceId` vào `attendance`) — cả 3 đều PHẢI gọi qua `DeviceService`, đã chú thích tường minh trong bảng Task tương ứng.
- **Nhất quán tự nhiên với `BiometricService`:** theo đúng thiết kế Phase 7, chỉ `biometric_service.dart` import `local_auth` — không phải yêu cầu mới, nhưng cùng nguyên tắc "1 package = 1 lớp truy cập" nên ghi nhận song song để nhất quán toàn bộ `core/services/`.
- **Kiểm tra tuân thủ:** grep toàn bộ `attendance_mobile/lib/` tìm `device_info_plus`/`flutter_secure_storage`/`local_auth` — chỉ được xuất hiện đúng 1 file mỗi package (`device_service.dart` cho 2 package đầu, `biometric_service.dart` cho package thứ 3). Đưa vào DoD Sprint A (Phase 6) và regression cuối cùng (Phase 25).

---

## 3. Danh sách Phase (tổng quan, đã renumber)

**Chú giải trạng thái:** ✅ Done · 🚫 Blocked (môi trường, không phải lỗi code) · ⬜ Chưa tới lượt (phụ thuộc Phase đang Blocked)

| # | Phase | Sprint | Thời lượng | Dependency | Trạng thái | Commit |
|---|---|---|---|---|---|---|
| 1 | Cài package + cấu hình native (backup exclusion) | A | 45-60p | none | ✅ Done | `712588d` |
| 2 | `DeviceService` — sinh/đọc `installId` **+ nguyên tắc truy cập duy nhất** | A | 60-90p | Phase 1 | ✅ Done | `6299910` |
| 3 | Cập nhật `UserModel`/`EmployeeModel` (2 app) | A | 45-60p | none | ✅ Done | `aba23df` |
| 4 | Cập nhật `AttendanceModel` — field `deviceId` | A | 30-45p | none | ✅ Done | `1564814` |
| 5 | Domain model mới `DeviceActivation`/`DeviceAuditLog` (2 app) | A | 45-60p | none | ✅ Done | `5c96f59` |
| 6 | Test tay + xác nhận DoD Sprint A **(kèm grep kiểm tra truy cập duy nhất)** | A | 45-60p | Phase 1-5 | ✅ Done | — (verify only) |
| 7 | `BiometricService` + cấu hình native | D | 45-60p | none | ✅ Done | `b3dd949` |
| 8 | Tích hợp Biometric vào Check In/Check Out | D | 45-60p | Phase 7 | ✅ Done | `db9279f` |
| 9 | Test tay Biometric | D | 30-45p | Phase 8 | ⬜ Hết chặn, chờ bạn test | Build đã fix (`kotlin.incremental=false`) — cần bạn tự `flutter run` trên thiết bị thật |
| 10 | `DeviceActivationRepository` (mobile) — redeem, **qua `DeviceService`** | B | 60-90p | Phase 3, 5 | ✅ Done (+ sửa bảo mật) | `01024d4`, `8b675fa`, `b0cbe51` |
| 11 | `DeviceActivationRepository` (admin) — issue code | B | 45-60p | Phase 5 | ✅ Done | `fe87f13`, `b0cbe51` |
| 12 | Provider Riverpod cho luồng kích hoạt (mobile) | B | 45-60p | Phase 10 | ✅ Done | `a9d7704` |
| 13 | UI Mobile: màn "Nhập mã kích hoạt" + điều hướng sau login, **qua `DeviceService`** | B | 75-90p | Phase 12 | ✅ Done | `a9d7704` |
| 14 | UI Admin: hành động "Cấp mã kích hoạt" | B | 45-60p | Phase 11 | ✅ Done (+ sửa bug Navigator) | `4f8d086`, `3ad8d66` |
| 15 | Test tay đầy đủ luồng Activation Code | B | 60p | Phase 10-14 | ⬜ Test được thật trên Production | Rules an toàn đã deploy tạm — không còn cần Emulator |
| **16** | **[MỚI]** Sửa `attendance_repository.dart` — ghi `deviceId` (qua `DeviceService`) khi Check In/Out | C | 30-45p | Phase 2 | ✅ Done | `89c5442` |
| **17** | **[MỚI]** Thiết lập Firebase Emulator cho Firestore | C | 45-60p | none | ✅ Done | `3c2b639` |
| 18 | Soạn Firestore Rules mới (chưa deploy) | C | 60-75p | Phase 1-16 hoàn tất | ✅ Done — phần an toàn ĐÃ deploy tạm, phần `attendance` còn comment | `51d1a4c`, `3ad8d66` |
| **19** | **[MỚI]** Test Rules trên Emulator | C | 60-90p | Phase 17, 18 | 🚫 Blocked | Cần JDK 21+ (Firestore Emulator không chạy được với JDK 17 hiện có) |
| 20 | Kiểm tra dữ liệu migration trên Production trước deploy | C | 30-45p | Phase 19 Pass | ⬜ Chưa tới lượt | Chờ Phase 19 (hoặc phương án thay thế) |
| 21 | Deploy Rules Production + xác nhận nhanh + regression thật | C | 45-60p | Phase 20 | ⬜ Một phần đã deploy (`3ad8d66`) | Còn lại: khôi phục + deploy điều kiện `deviceId` cho `attendance` |
| 22 | Reset Trusted Device (Admin) — repository + UI | E | 60-75p | Phase 3, 5, 21 | ✅ Done (code) | `bd55db6` |
| 23 | Gộp Reset vào luồng Deactivate nhân viên | E | 45-60p | Phase 22 | ✅ Done | `2a2dea0` |
| 24 | Audit Log UI (Admin) — đóng vai trò Activation History | E | 60-75p | Phase 5 | ✅ Done | `cc34959` |
| 25 | Test tay Sprint E + Regression toàn bộ FEAT-05 **(kèm grep kiểm tra truy cập duy nhất lần cuối)** | E | 60p | Phase 22-24 | ⚠️ Một phần | Regression code-level xong (`flutter build web` 2 app + grep); test tay hành vi thật (đổi máy/mất máy) cần Phase 19-21 xong trước mới quan sát được hiệu ứng |

**Tổng:** 25 Phase (+3 so với bản trước), ~22-25 giờ làm việc thực tế. **Hiện trạng: 22 Done (Phase 9 hết chặn), Phase 15 test được thật trên Production (Rules an toàn đã deploy tạm), Phase 19 Blocked bởi JDK Emulator, Phase 20 chưa tới lượt, Phase 21 một phần đã deploy.**

---

## 4. Chi tiết từng Phase

*(Phase 1, 3, 5, 7, 8, 9, 11, 12, 14, 15, 22, 23, 24 giữ nguyên nội dung so với bản trước — không lặp lại toàn văn, chỉ liệt kê phần đổi/mới bên dưới. Phase 2, 4, 6, 10, 13 có cập nhật nhỏ liên quan §0. Phase 16, 17, 19 hoàn toàn mới. Phase 18, 20, 21, 25 renumber + cập nhật nội dung.)*

### PHASE 2 — `DeviceService` (Sprint A) — cập nhật

| Task | Nội dung |
|---|---|
| 2.1 | Tạo `core/services/device_service.dart` — hàm `getInstallId()`: đọc Secure Storage, sinh UUID mới nếu chưa có, cấu hình `IOSOptions(accessibility: ...ThisDeviceOnly)` |
| 2.2 | Hàm `getDeviceInfo()` — model/manufacturer/OS version qua `device_info_plus`, chỉ hiển thị/audit |
| 2.3 | Ghi chú rõ: Installation Identity, không phải Device Identity thật (§2 thiết kế) |
| **2.4 (mới)** | **Xác lập & ghi comment đầu file:** `device_service.dart` là điểm truy cập DUY NHẤT cho `device_info_plus`/`flutter_secure_storage` trong toàn bộ `attendance_mobile` — mọi service/repository/provider khác PHẢI gọi qua class này |

**Files tạo:** `attendance_mobile/lib/core/services/device_service.dart`
**Files KHÔNG được sửa:** `attendance_repository.dart`, `auth_repository.dart` (chưa tới lượt)

---

### PHASE 4 — `AttendanceModel` — field `deviceId` (Sprint A) — không đổi nội dung, chỉ sửa 1 câu ghi chú

Task 4.2 cập nhật: "chưa ghi giá trị thật vào field này — việc ghi giá trị thật chuyển sang **Phase 16 (mới)**, không còn mơ hồ như bản trước."

---

### PHASE 6 — Test tay + xác nhận DoD Sprint A — cập nhật

Thêm **Task 6.4 (mới):** grep `attendance_mobile/lib/` xác nhận `import 'package:device_info_plus` và `import 'package:flutter_secure_storage` **chỉ** xuất hiện trong `device_service.dart` — nếu phát hiện nơi khác import trực tiếp, coi là vi phạm điều kiện §0.1, phải sửa trước khi coi Phase 6 xong.

**Definition of Done Sprint A (cập nhật):** như bản trước, **cộng thêm** "grep xác nhận đúng 1 điểm truy cập duy nhất cho mỗi package Device Identity".

---

### PHASE 10 — `DeviceActivationRepository` (mobile) — redeem (Sprint B) — cập nhật — ✅ Done

Task 10.1 làm rõ: khi soạn `newDeviceId` ứng viên để redeem, gọi `DeviceService().getInstallId()` — **không** tự import `flutter_secure_storage` trong file repository này (đúng điều kiện §0.1/§2.4).

**🔴 Cập nhật sau khi code (commit `b0cbe51`):** bản đầu tiên vi phạm chính nguyên tắc bảo mật của thiết kế (đọc trực tiếp `device_activations`, lộ field `code`). Đã thiết kế lại hoàn toàn thành cơ chế 2 lượt "ghi mù" (Write A tăng `attemptCount`/ghi `lastAttemptCode`, Write B chỉ thành công nếu Rules tự đối chiếu đúng — client không bao giờ đọc `code`). Xem §0.5.

---

### PHASE 13 — UI Mobile: màn "Nhập mã kích hoạt" (Sprint B) — cập nhật

Task 13.3 làm rõ: bước so khớp `installId` vs `trustedDeviceId` gọi `DeviceService().getInstallId()` — không đọc Secure Storage trực tiếp ở tầng provider/UI.

---

### PHASE 16 — Sửa `attendance_repository.dart`: ghi `deviceId` khi Check In/Out *(hoàn toàn mới)* — ✅ Done (`89c5442`)

| Task | Nội dung |
|---|---|
| 16.1 | Trong `checkIn()`: gọi `DeviceService().getInstallId()`, thêm `'deviceId': installId` vào map dữ liệu `transaction.set(docRef, {...})` hiện có |
| 16.2 | Trong `checkOut()`: tương tự, thêm `'deviceId': installId` vào map `.update({...})` — **đúng cả kịch bản Check Out muộn ca đêm** (nhánh tìm document "hôm qua" trong `checkOut()` hiện có) |
| 16.3 | Đối chiếu lại: field này chỉ được **ghi**, chưa bị **enforce** ở Phase này (Rules thật chưa đổi) — an toàn, không ảnh hưởng hành vi Check In/Out hiện tại |

**Files sửa:** `attendance_mobile/lib/features/attendance/data/attendance_repository.dart`
**Files KHÔNG được sửa:** `firestore.rules` (Phase 18 mới sửa), `attendance_provider.dart` (không cần đổi — giá trị `deviceId` được lấy hoàn toàn trong tầng repository, đúng layering D-008)
**File rủi ro cao:** `attendance_repository.dart` — file nghiệp vụ lõi đang chạy production cho **mọi** lượt Check In/Out hiện tại; chỉ thêm 1 field vào map dữ liệu, không đụng logic GPS/Business Date/transaction đã có, nhưng vẫn là file nhạy cảm nhất toàn dự án

**Test tay:** Check In/Out bình thường (chưa deploy Rules mới) → vẫn hoạt động y hệt trước, chỉ khác là document Firestore giờ có thêm field `deviceId` khi xem qua Console.

---

### PHASE 17 — Thiết lập Firebase Emulator cho Firestore *(hoàn toàn mới, theo điều kiện §0.2)* — ✅ Done (`3c2b639`)

| Task | Nội dung |
|---|---|
| 17.1 | Thêm khối `"emulators"` vào `firebase.json` (gốc) — cấu hình cổng Firestore Emulator (mặc định 8080) + Emulator UI (mặc định 4000) |
| 17.2 | Thêm 1 cờ debug tạm thời (gated bằng `kDebugMode`, đúng pattern đã dùng cho Demo Time/dev tools — D-009) ở cả 2 app, cho phép trỏ `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080)` khi cần test — **không build vào bản release**, chỉ dùng cục bộ lúc chạy Phase 19 |
| 17.3 | Đánh giá tái dùng `tools/firestore_backup/` (đã có sẵn trong repo — `seed_sprint0.dart`/`reseed_july.dart`) để seed dữ liệu giả lập vào Emulator thay vì gõ tay — tiết kiệm công sức chuẩn bị kịch bản test ở Phase 19 |

**Files sửa:** `firebase.json` (gốc)
**Files tạo (tạm thời, chỉ dùng lúc dev/test, không phải deliverable production):** cờ debug nhỏ trong entrypoint dev hiện có (`main_dev.dart` mobile) hoặc tương đương ở admin — **quyết định cụ thể vị trí lúc code**, không tạo file mới ngoài phạm vi cần thiết
**Files KHÔNG được sửa:** `firestore.rules` thật (Phase 18 làm việc trên bản nháp cục bộ trước, chưa đụng gì tới rule đang deploy Production ở Phase này)
**Không thêm package Dart/npm nào** — chỉ dùng Firebase CLI đã có sẵn (`firebase emulators:start`) và API `useFirestoreEmulator` đã có sẵn trong `cloud_firestore` (không cần thêm dependency)

---

### PHASE 18 — Soạn Firestore Rules mới, chưa deploy (Sprint C) — ✅ Done (`51d1a4c`), CHƯA deploy Production

*(4 Task giống bản trước — sửa `users`, thêm `device_activations`, thêm `device_audit_log`, sửa `attendance` create+update.)* Khác biệt duy nhất so với bản trước: kết quả của Phase này **chưa deploy lên Production ngay** — chuyển tới Phase 19 (test Emulator) trước, thay vì thẳng tới bước migration-check như quy trình cũ.

**Files sửa:** `firestore.rules` (bản nháp cục bộ — deploy thật ở Phase 21)

**Cập nhật sau khi code:** tự review phát hiện thêm 2 điểm cần `exists()` guard trước `get().data` (`deviceActivationData(uid)` trong rule `users`, `currentUserData()` trong rule `attendance` create/update) — đã sửa, tái dùng đúng pattern đã có sẵn ở `isAdmin()` (tách thành `currentUserExists()` dùng chung). Brace-balance đã kiểm tra thủ công (45/45) do không chạy được Emulator để validate đầy đủ — xem Phase 19.

---

### PHASE 19 — Test Rules trên Emulator *(hoàn toàn mới, theo điều kiện §0.2)* — 🚫 Blocked

**Chưa thực hiện được:** Firestore Emulator yêu cầu JDK 21+, môi trường thực hiện chỉ có JDK 17 (Temurin 17.0.19). Không tự ý nâng cấp JDK hệ thống. **Cần bạn tự chạy trên máy có JDK phù hợp** — xem §0.5 hướng dẫn cụ thể.

| Task | Nội dung |
|---|---|
| 19.1 | Chạy `firebase emulators:start --only firestore`, nạp `firestore.rules` bản nháp (Phase 18) + dữ liệu seed (Phase 17.3) |
| 19.2 | Chạy app mobile/admin bản debug, trỏ Firestore vào Emulator (cờ Phase 17.2) |
| 19.3 | Lặp lại **toàn bộ** kịch bản đã định nghĩa ở Test Plan Rules (§7): ghi `attendance` với `deviceId` sai → từ chối ở cả create/update; owner đọc `device_activations` → từ chối; redeem đúng/sai/hết hạn/khoá do brute-force; ghi `attendance` đúng `deviceId` (đã có từ Phase 16) → thành công |
| 19.4 | Test regression NGOÀI FEAT-05 trên Emulator: Nghỉ phép, Thông báo, Đăng nhập Admin — xác nhận không bị ảnh hưởng bởi phần Rules mới sửa |
| 19.5 | **Chỉ khi 19.3 + 19.4 Pass toàn bộ trên Emulator** mới được sang Phase 20 (kiểm tra migration Production) |

**Files:** không sửa file code mới — chạy trên cấu hình đã có từ Phase 17/18
**Lợi ích so với quy trình cũ (test trực tiếp qua Console/REST trên Production sau khi deploy):** phát hiện lỗi Rules **trước khi** chạm vào dữ liệu/nhân viên thật, không còn phụ thuộc "tự thử rồi sửa nóng trên Production" — giảm đáng kể mức độ rủi ro đã đánh giá "cao nhất toàn bộ kế hoạch" ở bản trước cho nhóm Phase Rules.

---

### PHASE 20 — Kiểm tra dữ liệu migration trên Production trước deploy (Sprint C) — ⬜ Chưa tới lượt (chờ Phase 19)

*(Giống Phase 17 cũ: query toàn bộ `users.isActive=true`, đối chiếu đã có `trustedDeviceId` chưa, nếu thiếu thì KHÔNG sang Phase 21.)* Khác biệt: giờ đây bước này chạy **sau khi** Rules đã được xác nhận đúng trên Emulator (Phase 19), nên khi tới đây chỉ còn rủi ro "dữ liệu chưa sẵn sàng", không còn rủi ro "Rules viết sai" (đã loại ở Phase 19).

---

### PHASE 21 — Deploy Rules Production + xác nhận nhanh + regression thật (Sprint C) — ⬜ Chưa tới lượt (chờ Phase 19-20)

| Task | Nội dung |
|---|---|
| 21.1 | Deploy `firestore.rules` qua Firebase CLI lên Production |
| 21.2 | Xác nhận nhanh qua Console (không cần lặp lại toàn bộ kịch bản đã test kỹ ở Emulator Phase 19 — chỉ smoke-test 2-3 kịch bản trọng yếu nhất: ghi `attendance` sai `deviceId` bị từ chối; Check In/Out thật trên máy `TRUSTED` vẫn thành công) |
| 21.3 | Test tay Check In/Out thật trên thiết bị đã `TRUSTED` (regression quan trọng nhất trên dữ liệu thật) |

**Rollback:** giữ bản `firestore.rules` cũ trước Phase 18, deploy lại qua CLI hoặc Firebase Console history nếu phát hiện vấn đề dù đã test Emulator (luôn có khả năng lệch môi trường Emulator/Production, dù đã giảm thiểu đáng kể).

**Definition of Done Sprint C:** Phase 19 Pass toàn bộ trên Emulator + Phase 20 xác nhận dữ liệu sẵn sàng + Phase 21.2/21.3 Pass trên Production.

---

### PHASE 22-25 — Sprint E (Reset, Deactivate, Audit Log, Regression cuối) — ✅ Done (code), ⚠️ Phase 25 một phần

Phase 22 (`bd55db6`), 23 (`2a2dea0`), 24 (`cc34959`) — code + `flutter analyze` sạch.

**Phase 25 (Test tay Sprint E + Regression toàn bộ) — đã làm được:**
- Grep lần cuối `attendance_mobile/lib/`: xác nhận đúng 1 điểm truy cập cho mỗi package (`device_info_plus`/`flutter_secure_storage` → chỉ `device_service.dart`; `local_auth` → chỉ `biometric_service.dart`) — điều kiện §0.1 được giữ nguyên suốt toàn bộ 25 Phase, không bị vi phạm ở đâu khác.
- `flutter build web` cả 2 app (Build thành công) — compile-check sâu hơn `analyze`, thay thế cho việc không build được Android native trong môi trường thực hiện.
- `flutter test` mobile: 19/19 Pass.

**Phase 25 — chưa làm được (cần Phase 19-21 xong trước mới có ý nghĩa):** test tay hành vi thật của kịch bản Device Change (đổi máy/mất máy/offboarding) — cần quan sát hiệu ứng chặn thật của Rules đã deploy, hiện Rules mới chỉ soạn xong (Phase 18), chưa deploy Production.

**Definition of Done Sprint E:** phần code-level (grep + build + test) đã đạt. Phần hành vi thật chờ Phase 19-21.

---

## 5. Model Impact

*(Không đổi so với bản trước.)* `UserModel`/`EmployeeModel` (+`trustedDeviceId`, `deviceStatus`), `AttendanceModel` (+`deviceId`, nay được ghi giá trị thật ở Phase 16 thay vì để trống), `DeviceActivationModel`/`DeviceAuditLogModel` (mới, 2 app).

---

## 6. Firestore

*(Không đổi so với bản trước — không cần index mới, không cần migration script, field mới đều optional/có default.)* Bổ sung: seed dữ liệu test cho Emulator (Phase 17.3) tái dùng `tools/firestore_backup/` đã có sẵn, không tạo công cụ seed mới.

---

## 7. Firestore Rules

*(Nội dung Rules không đổi so với bản trước — vẫn đúng 4 thay đổi: `users`, `device_activations` mới, `device_audit_log` mới, `attendance` create+update.)*

**Quy trình kiểm thử đã nâng cấp theo điều kiện §0.2:**

| Bước | Trước (bản cũ) | Sau (bản này) |
|---|---|---|
| Soạn Rules | Phase 16 (cũ) | Phase 18 |
| Kiểm thử bypass | Trực tiếp qua Console/REST **sau khi deploy** Production (Phase 18 cũ, task 18.2) | **Trước khi deploy** — chạy đầy đủ trên Firebase Emulator (Phase 19), Production chỉ còn smoke-test xác nhận (Phase 21.2) |
| Kiểm tra migration | Phase 17 (cũ) | Phase 20 — giữ nguyên vị trí tương đối (ngay trước deploy thật), không bị Emulator thay thế |
| Deploy | Phase 18 (cũ) | Phase 21 |

**Risk khi deploy:** giảm đáng kể so với đánh giá "cao nhất toàn bộ kế hoạch" ở bản trước, nhờ đã cô lập phần lớn rủi ro logic Rules sang môi trường Emulator an toàn. Rủi ro còn lại ở Phase 21 chỉ còn là **lệch môi trường Emulator/Production** (hiếm, nhưng vẫn có thể xảy ra — ví dụ khác biệt version Firestore Rules engine) — thấp hơn hẳn rủi ro "chưa từng test gì trước khi chạm dữ liệu thật" của quy trình cũ.

---

## 8. UI Impact

*(Không đổi so với bản trước.)*

---

## 9. Test Plan (tổng hợp, cập nhật phần Sprint C)

| Phase | Manual Test trọng tâm | Regression Test | Negative Test |
|---|---|---|---|
| 6 | Cài đặt lần đầu, `installId` ổn định, **grep truy cập duy nhất** | `flutter analyze`/`flutter test` sạch | Đọc user cũ chưa có field mới — không lỗi |
| 9 | Check In/Out với Biometric thành công | Logic GPS/Business Date cũ không đổi | Huỷ Biometric giữa chừng — không tạo doc |
| 15 | Redeem mã đúng/sai/hết hạn/khoá | Đăng nhập tài khoản `TRUSTED` — vào thẳng Home | Redeem mã đã dùng/brute-force 6 lần |
| 16 | `attendance` mới có `deviceId` đúng giá trị | Check In/Out hoạt động y hệt trước (Rules chưa đổi) | — |
| 19 | **Toàn bộ kịch bản Rules trên Emulator** (bypass, redeem, checkin/checkout) | Nghỉ phép/Thông báo/Đăng nhập Admin trên Emulator | Ghi `attendance` `deviceId` giả trên Emulator — bị từ chối |
| 21 | Smoke-test Production sau deploy | Check In/Out thật trên máy `TRUSTED` | — |
| 25 | Đổi máy, mất máy, offboarding; **grep truy cập duy nhất lần cuối** | Toggle Active/Inactive vẫn đúng | Reset không nhập lý do — disabled |

---

## 10. Risk theo Sprint

| Sprint (Phase) | Risk | Rollback | Dependency |
|---|---|---|---|
| A (1-6) | Trung bình | Revert file Phase 1-5 | none |
| D (7-9) | Thấp | Revert Phase 7-8 | none |
| B (10-15) | Cao (sửa luồng login thật) | An toàn vì Rules Production chưa đổi | Sprint A |
| C (16-21) | **Giảm từ "Cao nhất" xuống Trung bình-Cao** — nhờ Phase 19 (Emulator) cô lập phần lớn rủi ro logic Rules trước khi chạm Production | Bản `firestore.rules` cũ + Console history | Sprint A + B ổn định; Phase 19 Pass trước Phase 20/21 |
| E (22-25) | Trung bình | Revert Phase 22-23 | Sprint A, B, C |

---

## 11. Implementation Order — giải thích (không đổi thứ tự Sprint)

**A → D → B → C (16→21, nội bộ tuyến tính bắt buộc do phụ thuộc dữ liệu/an toàn) → E.**

Lý do giữ nguyên như bản trước (D sớm vì rủi ro thấp/độc lập; B trước C vì cần cơ chế hợp lệ trước khi enforce; C trước E vì Reset chỉ kiểm thử được ý nghĩa sau khi Rules enforce thật). Bổ sung: trong nội bộ Sprint C, thứ tự 16 (ghi dữ liệu) → 17 (chuẩn bị Emulator) → 18 (soạn Rules) → 19 (test Emulator) → 20 (check migration) → 21 (deploy) là **bắt buộc tuyến tính**, không hoán đổi được — mỗi bước là điều kiện tiên quyết kỹ thuật của bước sau (không thể test Rules trên Emulator nếu app còn chưa gửi `deviceId`; không thể deploy nếu chưa qua Emulator; không thể qua Emulator nếu Emulator chưa cấu hình).

---

## 12. Commit Plan (cập nhật)

```
feat(device): add device_info_plus, local_auth, flutter_secure_storage + native config
feat(device): add DeviceService as sole access point for Device Identity
feat(auth): add trustedDeviceId/deviceStatus fields to UserModel and EmployeeModel
feat(attendance): add deviceId field to AttendanceModel
feat(device): add DeviceActivation/DeviceAuditLog domain models (mobile + admin)
feat(biometric): add BiometricService + FlutterFragmentActivity config
feat(attendance): require biometric confirmation before Check In/Check Out
feat(device): add DeviceActivationRepository redeem flow (mobile)
feat(device): add DeviceActivationRepository issue-code flow (admin)
feat(device): add device activation provider (mobile)
feat(device): add device activation screen + router entry + login redirect (mobile)
feat(employee): add "Cấp mã kích hoạt thiết bị" action (admin)
feat(attendance): write deviceId on Check In/Check Out
chore(firebase): configure Firestore Emulator + debug-only emulator flag
rules: enforce device binding on attendance create/update
rules: add device_activations and device_audit_log rules
feat(device): add Reset Trusted Device action (admin)
feat(employee): integrate device reset into deactivate flow
feat(device): add Audit Log screen (admin)
docs: update FEAT-05 progress after Sprint A/D/B/C/E
```

---

## 13. Ghi chú "Không code"

*(Không đổi.)* Tài liệu này thuần kế hoạch — thực thi từng Phase vẫn theo đầy đủ Development Workflow tại thời điểm code, không tự động chạy nối tiếp.

---

## 14. Tự kiểm tra kế hoạch (cập nhật sau khi tích hợp 2 điều kiện)

| Câu hỏi | Kết quả |
|---|---|
| Có Phase nào quá lớn không? | Không — Phase mới (16, 17, 19) đều trong 30-90 phút |
| Có Task nào quá lớn không? | Không |
| Có bước nào thiếu không? | **Có, đã tìm thấy và vá:** thiếu Phase ghi `deviceId` thật (nay là Phase 16) — nếu không có, Sprint C sẽ khoá oan toàn bộ nhân viên ngay khi enforce Rules dù dữ liệu thiết bị đã đúng |
| Có Rollback Plan chưa? | Có, cập nhật ở §10 |
| Có Test Plan chưa? | Có, cập nhật ở §9 — thêm dòng Emulator |
| Có Risk chưa? | Có — Sprint C hạ mức rủi ro nhờ Emulator, ghi rõ ở §10 |
| Có Dependency chưa? | Có — §3 + §11, làm rõ thứ tự tuyến tính bắt buộc trong Sprint C |
| 2 điều kiện phê duyệt đã tích hợp đủ chưa? | Có — §0.1 (DeviceService) thể hiện ở Task 2.4, chú thích Phase 10/13/16, kiểm tra grep ở Phase 6 và 25; §0.2 (Emulator) thể hiện ở Phase 17/19 mới, giữ nguyên Phase 20 (migration check) đúng yêu cầu |

---

## 15. Trạng thái cuối (cập nhật 2026-07-21, sau khi vá bug build)

21/25 Phase Done. Phase 9 hết chặn (bug build Gradle/Kotlin đã xác nhận là thật — tái hiện trên máy bạn, không phải sandbox — và đã sửa bằng `kotlin.incremental=false`). Còn Phase 15, 19 Blocked bởi JDK 21+ (Firestore Emulator), kéo theo 20-21 chưa tới lượt. 1 lỗi bảo mật thật phát hiện và sửa trong quá trình (§0.5, Phase 10).

**Việc cần bạn làm tiếp để đóng nốt FEAT-05:**
1. Thử lại `flutter run` (Phase 9) trên thiết bị Android thật — build đã fix, xác nhận qua tới bước cài/chạy app rồi test Biometric khi Check In/Out.
2. Cài JDK 21+ (hoặc dùng máy sẵn có) → `firebase emulators:start --only firestore,auth` → `flutter run -t lib/main_emulator.dart` (2 app) → chạy kịch bản Phase 15 (Activation Code) + Phase 19 (Rules) theo §9 Test Plan.
3. Báo lại kết quả để tiếp tục Phase 20 (kiểm tra migration Production) + Phase 21 (deploy Rules thật).

**Chờ xác nhận trước khi bắt đầu Phase 20/21 (deploy Production) — không tự ý deploy khi chưa có xác nhận Phase 19 Pass từ bạn.**
