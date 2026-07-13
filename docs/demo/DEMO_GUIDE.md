# DEMO GUIDE — Báo cáo tiến độ thực tập

**Ngày tổng hợp:** 2026-07-09
**Đối tượng:** Giảng viên hướng dẫn, báo cáo tiến độ (không phải bảo vệ tốt nghiệp), có thể tái sử dụng làm khung sườn cho buổi bảo vệ sau này.
**Nguồn:** Hợp nhất từ `docs/demo/01_DEMO_DATA.md` → `08_DEMO_SUMMARY.md` (đánh giá dựa trên dữ liệu Firestore thật, backup ngày 2026-07-05/06), cập nhật thêm **Demo Time System** (`ClockService`/`Demo Center`, hoàn thành 2026-07-09 — xem `docs/design/DEMO_TIME_DESIGN_v2.md`), đối chiếu lại với `ARCHITECTURE.md`, `PROJECT_OVERVIEW.md`, `ROADMAP.md`, `REVIEW.md`, `firestore.rules`, `docs/review/DEMO_READINESS_REVIEW.md`.
**Nguyên tắc xuyên suốt:** Chỉ demo những gì đã thực sự hoàn thành. Không demo chức năng dở dang. Không hứa hẹn tính năng chưa có. Nếu có hạn chế — nói thẳng, có sẵn câu trả lời, không né tránh.

---

## Mục lục

0. [Tổng quan mức độ hoàn thành](#0-tổng-quan-mức-độ-hoàn-thành)
1. [Demo Preparation](#1-demo-preparation)
2. [Demo Script](#2-demo-script)
3. [Demo Time Script](#3-demo-time-script)
4. [Error Scenarios](#4-error-scenarios)
5. [Question & Answer](#5-question--answer)
6. [Checklist](#6-checklist)
7. [Estimated Demo Time](#7-estimated-demo-time)
8. [Backup Plan — Internet/Firebase sự cố](#8-backup-plan--internetfirebase-sự-cố)

---

## 0. Tổng quan mức độ hoàn thành

### 0.1 Đã hoàn thành — có thể demo trực tiếp

| Chức năng | App | Ghi chú |
|---|---|---|
| Đăng nhập + phân quyền (`role`/`isActive`) | Cả 2 | Firebase Auth email/password, kiểm tra tại tầng ứng dụng + Firestore Rules |
| Check In / Check Out bằng GPS thật | Mobile | Haversine, chống fake GPS (`isMocked`), chặn check-in trùng, chặn check-out khi chưa check-in, ân hạn 2 giờ cho ca đêm |
| Business Date + Shift Rotation (ca đêm xuyên nửa đêm) | Mobile | Điểm mạnh kỹ thuật nhất — có bằng chứng dữ liệu thật xác nhận đúng logic (mục 1.1) |
| Tính đi muộn (Late) / về sớm (Early Leave) | Mobile | Neo theo Business Date, không theo ngày lịch |
| Lịch sử chấm công + tự sinh "vắng mặt" | Mobile | Lọc theo tháng/trạng thái |
| Home cá nhân (ca hiện tại, thống kê tháng) | Mobile | |
| Dashboard tổng quan + biểu đồ 7 ngày | Admin | |
| Quản lý nhân viên (CRUD, sinh mật khẩu ngẫu nhiên, khoá/mở tài khoản) | Admin | Mật khẩu mặc định `123456` đã được thay bằng sinh ngẫu nhiên (ROADMAP P1-07) |
| Duyệt/từ chối đơn nghỉ phép + gửi thông báo | Admin | |
| Cấu hình công ty (GPS, bán kính, giờ ca, chu kỳ xoay ca) | Admin | Đã vá bug nghiêm trọng "lưu cấu hình làm mất `rotationStartDate`" (ROADMAP P1-02) |
| Xuất báo cáo Excel/PDF | Admin | |
| Firestore Security Rules | Hạ tầng | Đã deploy, kiểm tra role/isActive/ownership theo từng collection (ROADMAP P1-05) |
| **Demo Time System** (`ClockService` + `Demo Center`) | Mobile | 🟡 **Mới hoàn thành trong phiên làm việc gần nhất, 2026-07-09.** Code sạch (`flutter analyze` không lỗi), nhưng **chưa qua kiểm thử tay trên thiết bị thật** — bắt buộc dry-run riêng trước khi tin tưởng dùng trực tiếp trước mặt giảng viên. Xem mục 1.3 và mục 3. |

### 0.2 Chưa hoàn thành — không chủ động demo, chỉ trình bày kế hoạch nếu được hỏi

- **Nghỉ phép phía mobile (tạo đơn):** tab "Nghỉ phép" chỉ là `Scaffold(Text('Nghỉ phép'))` tĩnh, chưa có repository/UI tạo đơn thật. `LeaveRequestModel` đã có ở mobile nhưng chưa dùng.
- **Notification:** chỉ có chiều ghi (khi admin duyệt/từ chối đơn nghỉ phép), **không có màn hình hiển thị** ở bất kỳ app nào — chỉ xem được qua Firestore Console.
- **Quản lý Phòng ban:** không có màn CRUD riêng, phòng ban chỉ xuất hiện qua dropdown trong màn Nhân viên; việc seed 13 phòng ban dùng route dev ẩn `/dev/seed-departments` (kDebugMode).
- **ROADMAP Phase 2-4:** transaction cho check-in, Crashlytics/logging, `firestore.indexes.json`, đồng bộ 2 cơ chế lịch làm việc song song (`WorkScheduleHelper` vs `CompanySettingsModel`), tối ưu Dashboard (7 query tuần tự), phân trang danh sách chấm công — đều chưa làm, đúng kế hoạch theo `ROADMAP.md`.

### 0.3 Không nên demo — tránh chủ động bấm vào

- Tab **"Nghỉ phép"** bên mobile — màn trống, dễ gây ấn tượng xấu nếu không có lời giải thích chuẩn bị trước.
- Tìm **màn Notification** — không tồn tại ở bất kỳ đâu trong UI.
- Tìm **"Quản lý Phòng ban"** như một màn riêng — không có.
- Bất kỳ route `/dev-...` nào ngoài kịch bản đã định (kể cả `/demo-center` — chỉ mở đúng lúc cần).
- Bản ghi chấm công `2026-07-02_CDjUg...` (EMP004, cách công ty 46.6km, dữ liệu cũ trước khi sửa bug Business Date) — không chủ động mở khi lướt Nhật ký chấm công (xem mục 1.1).
- `attendance_mobile/lib/features/attendance/presentation/checkin_screen.dart`, `gps_test_screen.dart` — dead code, không được route tới, đừng cố tìm.

---

## 1. Demo Preparation

### 1.1 Dữ liệu demo

**⚠️ CẢNH BÁO QUAN TRỌNG NHẤT CỦA TOÀN BỘ TÀI LIỆU NÀY:**
**KHÔNG chạy `flutter run -t lib/main_dev.dart` trước ngày báo cáo.** Theo đúng mô tả trong `CLAUDE.md`, entrypoint này "wipes & reseeds Firestore demo data on every launch" — mỗi lần chạy sẽ **xoá và tạo lại** dữ liệu của 3 tài khoản gốc (EMP001-003) + `company_settings` + `departments/dep001`, làm mất toàn bộ lịch sử chấm công thật đã tích luỹ hơn 1 tháng (38 bản ghi, có bằng chứng rotation thật) và có thể ảnh hưởng tài khoản EMP004 nếu trùng cấu hình. **Dữ liệu thật hiện có giá trị trình bày cao hơn nhiều so với dữ liệu random mới sinh ra.** Luôn chạy demo bằng `flutter run` (entrypoint `main.dart` mặc định, chế độ debug) — Demo Center vẫn khả dụng vì chỉ phụ thuộc `kDebugMode`, không phụ thuộc entrypoint.

**Trạng thái Firestore hiện tại** (theo backup gần nhất 2026-07-05/06 — cần mở Firebase Console xác nhận lại trước ngày báo cáo vì đã cách 3 ngày):

| Collection | Số lượng | Đánh giá |
|---|---|---|
| `users` | 5 (4 nhân viên + 1 admin) | ✅ Đủ — có cả nhóm A/B, có nhân viên thêm gần đây |
| `departments` | 13 | ✅ Đủ, tên phòng ban thật (FAC, GA, PD, TE, PE, DX, PMC, PUR1, PUR2, Sales, ACC, QA, Internal Audit) |
| `attendance` | 38 | ✅ Đủ — phủ đầy đủ đúng giờ/muộn/về sớm/chưa check-out/ca ngày/ca đêm/2 nhóm |
| `leave_requests` | 0 | ❌ Trống — **bắt buộc bổ sung trước demo** |
| `notifications` | 0 | 🟡 Trống nhưng không cần bổ sung tay — sẽ tự có khi demo duyệt đơn nghỉ phép |
| `company_settings` | 1 (`main`) | 🟡 Có đủ, nhưng `radius` đang là giá trị bất thường — xem dưới |

**5 tài khoản hiện có:**

| employeeCode | Tên | Nhóm | Vai trò | Ghi chú |
|---|---|---|---|---|
| EMP001 | Trần Văn Ab | A | employee | |
| EMP002 | Lê Thị B | B | employee | |
| EMP003 | Danh Nhật Tiến | B | employee | |
| EMP004 | Tạ Đình Trí | A | employee | Thêm gần đây (2026-06-29) — minh hoạ tốt cho "công ty vừa tuyển thêm người" |
| ADMIN001 | Quản trị viên UMC | A | admin | ⚠️ `departmentId: "dep001"` không khớp phòng ban thật nào (tất cả 13 phòng ban thật đều có ID `dept_xxx`) — nên sửa lại qua màn Nhân viên trước demo (30 giây) |

**Bằng chứng Rotation hoạt động đúng (đáng trình bày trực tiếp):** dữ liệu thật cho thấy đúng 1 lần đổi ca khớp hoàn toàn công thức `floor(daysPassed / rotationDays)`: từ 16/06–27/06 nhóm A làm ca ngày, nhóm B làm ca đêm; từ 29/06 (đầu khối rotation kế tiếp) hai nhóm đổi ngược lại. **Tính tới ngày viết tài liệu này (2026-07-09), đang trong khối 29/06–12/07: nhóm A = ca đêm, nhóm B = ca ngày.** Khối này đổi tiếp vào 13/07 — nếu buổi báo cáo diễn ra sau mốc đó, **phải mở Demo Center kiểm tra lại "Current Shift" trước khi gán tài khoản cho từng mốc trong mục 3**, không giả định cố định.

**Bản ghi cần tránh:** `2026-07-02_CDjUg...` (EMP004) — check-in cách công ty 46.6km vẫn `on_time`, dữ liệu tạo bằng code cũ trước khi sửa bug Business Date/radius. Không xoá (không cần), chỉ tránh vô tình mở ra như thể nó bình thường.

**Company Settings — cần quyết định trước:**

| Field | Giá trị hiện tại | |
|---|---|---|
| `radius` | **9999999999 mét** ⚠️ | Gần như vô hiệu hoá kiểm tra bán kính — Check In sẽ luôn thành công bất kể vị trí demo (miễn GPS thật, không mock). |
| `dayShiftStart/End` | 08:00 / 20:00 | |
| `nightShiftStart/End` | 20:00 / 08:00 | |
| `rotationDays` / `rotationStartDate` | 14 / 2026-06-01 | |

→ **Quyết định cần chốt trước demo:** giữ `radius` lớn (an toàn về mặt hậu cần, demo được ở bất kỳ đâu, nhưng nếu giảng viên chủ động hỏi "thử đứng xa xem có bị chặn không" thì tính năng không thể hiện đúng thiết kế), hay đổi tạm về giá trị thực tế (ví dụ 500m, qua màn Settings — chỉ đổi dữ liệu, không đổi code) để minh hoạ đúng tính năng giới hạn bán kính. Nếu chọn phương án 2, **bắt buộc demo đúng tại địa điểm nằm trong bán kính đã cấu hình**.

**Việc cần làm trước demo (bổ sung dữ liệu, không sửa code, không đổi schema):**

1. **Thêm 3 document mẫu vào `leave_requests`** qua Firestore Console (Add document, Auto-ID):

   | # | Trạng thái | uid / employeeCode | startDate | endDate | reason | adminNote |
   |---|---|---|---|---|---|---|
   | 1 | `pending` | EMP002 | 2026-07-10 | 2026-07-11 | "Nghỉ phép việc gia đình" | "" |
   | 2 | `approved` | EMP001 | 2026-06-20 | 2026-06-21 | "Khám sức khỏe định kỳ" | "Đã duyệt" |
   | 3 | `rejected` | EMP003 | 2026-07-15 | 2026-07-20 | "Du lịch cá nhân" | "Trùng lịch cao điểm sản xuất, đề nghị dời lịch" |

   Schema đầy đủ: `uid` (string), `employeeCode` (string), `startDate`/`endDate`/`createdAt`/`updatedAt` (Timestamp), `reason` (string), `status` (string), `adminNote` (string). Giữ lại đúng 1 đơn `pending` (EMP002) để demo thao tác duyệt trực tiếp lúc báo cáo — 2 đơn còn lại chỉ để danh sách không trông trống trải.

2. **Sửa `departmentId` của tài khoản admin** qua màn "Quản Lý Nhân Viên" → sửa hồ sơ ADMIN001 → chọn lại 1 phòng ban thật trong dropdown.

3. **Quyết định + (nếu cần) đổi `company_settings.radius`** qua màn Settings.

4. **Không cần** seed thêm `users`/`departments`/`attendance` — dữ liệu hiện tại đã đủ và đã "thật" (điểm cộng lớn khi trình bày).

### 1.2 Môi trường demo

| Hạng mục | Chuẩn bị |
|---|---|
| **Thiết bị mobile** | Máy Android **thật** (không phải emulator) — để tránh mọi rủi ro liên quan `position.isMocked`/độ chính xác GPS của máy ảo. Chạy bằng `flutter run` (KHÔNG dùng `-t lib/main_dev.dart`). |
| **Web admin** | Chạy `flutter run -d chrome` (hoặc build sẵn, mở trình duyệt) trên laptop trình chiếu. |
| **Firebase Console** | Mở sẵn 1 tab, đăng nhập đúng project `attendance-management-sy-34105`, để dự phòng đối chiếu dữ liệu trực tiếp (đặc biệt hữu ích khi demo Notification — chỉ xem được qua đây). |
| **Demo Time (Demo Center)** | Chỉ khả dụng bản debug (`kDebugMode`). Vào Profile → "Demo Center" (icon 🧪). **Bắt buộc dry-run riêng trước** — xem mục 1.3. |
| **GPS** | Bật GPS thật trên thiết bị demo, tắt hẳn mọi app giả lập vị trí (mock location) đã cài trước đó — kể cả khi không dùng, sự tồn tại của app mock-location đang bật quyền "chọn làm mock app" trong Developer Options có thể khiến `isMocked` trả về `true` dù không chủ động bật giả lập. |
| **Internet** | Wi-Fi nơi báo cáo làm chính, chuẩn bị hotspot 4G dự phòng đã thử kết nối trước — xem mục 8. |
| **Cửa sổ trình chiếu** | Ưu tiên: (1) màn hình điện thoại demo cast/chiếu qua HDMI hoặc chia sẻ màn hình (Scrcpy) để giảng viên nhìn rõ thao tác tay, không chỉ nghe kể; (2) cửa sổ trình duyệt admin full màn hình khi tới phần admin; (3) tab Firebase Console thu nhỏ, chỉ phóng to đúng lúc cần. |
| **Thứ tự mở màn hình trước khi bắt đầu** | Mở sẵn (chưa trình chiếu): app mobile đã đăng nhập EMP002 hoặc EMP004 (tuỳ mốc mở đầu), tab admin đã đăng nhập ADMIN001 ở Dashboard, tab Firebase Console ở collection `attendance`. Tất cả mở nền, chỉ chuyển sang khi tới đúng bước. |

### 1.3 Đánh giá rủi ro / hạn chế nên tránh

| Hạng mục | Đánh giá | Workaround |
|---|---|---|
| **Demo Center — chưa test tay** | Cao nhất trong toàn bộ chuẩn bị. Code hoàn chỉnh, `flutter analyze` sạch, nhưng chưa từng chạy thật trên thiết bị. Nếu lỗi xảy ra lần đầu ngay trước mặt giảng viên, rủi ro mất điểm tiến độ rất lớn. | **Bắt buộc**: dry-run toàn bộ 7 kịch bản test đã đề xuất (xem lịch sử triển khai `docs/design/DEMO_TIME_DESIGN_v2.md`) ở một ngày giả lập **khác** ngày sẽ dùng khi báo cáo thật (tránh tạo trùng document `attendance` cho đúng Business Date sẽ demo — xem mục 3). Nếu dry-run phát hiện lỗi mà không kịp sửa, **chuyển hẳn sang Phương án dự phòng B** (Check In thật theo thời gian thực, không dùng Demo Time) — xem mục 3.4. |
| GPS mock detection | Trung bình — vấn đề hậu cần, không phải lỗi kỹ thuật. `radius` hiện đang rất lớn nên rủi ro "ngoài bán kính" gần như không còn (trừ khi chủ động đổi về giá trị nhỏ ở mục 1.1). | Luôn dùng máy thật, tắt mock-location app trước giờ demo. |
| Dashboard tải hơi chậm (7 query tuần tự) | Thấp — chậm vài trăm ms/giây, không đáng kể trong 1 buổi báo cáo. | Nếu chậm, tiếp tục nói trong lúc chờ thay vì im lặng. |
| Department không có màn quản lý riêng | Không phải lỗi — tính năng chưa tới lượt trong roadmap, không phải tính năng hỏng. | Trình bày chủ động là "kế hoạch tiếp theo" nếu được hỏi, không né tránh. |
| Leave Request mobile là placeholder | Có ảnh hưởng nếu vô tình bấm vào mà không chuẩn bị. | Không chủ động bấm tab "Nghỉ phép" bên mobile; nếu bị hỏi, có câu trả lời sẵn (mục 5). |
| Notification không có UI hiển thị | Thấp nếu không chủ động đưa vào phần demo chính. | Dùng chính khoảnh khắc duyệt đơn nghỉ phép để mở Firestore Console cho xem document `notifications` vừa được tạo — biến hạn chế thành một đoạn demo có chủ đích thay vì bị động né tránh. |
| Kiến trúc (không interface Repository, model trùng lặp 2 app...) | Không ảnh hưởng buổi báo cáo tiến độ — thuộc tầm phản biện tốt nghiệp. | Không chủ động nhắc; có câu trả lời sẵn nếu bị hỏi sâu (mục 5). |

---

## 2. Demo Script

### 2.1 Demo Flow tổng quan

```
00:00 ─ 02:00   1.  Giới thiệu đề tài
02:00 ─ 04:00   2.  Kiến trúc & công nghệ
04:00 ─ 05:00   3.  Mobile — Đăng nhập
05:00 ─ 07:00   4.  Mobile — Home (giới thiệu Rotation)
07:00 ─ 13:00   5.  Mobile — Demo Time: Check In/Out qua các mốc giờ (xem mục 3)
13:00 ─ 14:00   6.  Mobile — Lịch sử chấm công
14:00 ─ 15:00   7.  Admin — Đăng nhập
15:00 ─ 17:00   8.  Admin — Dashboard
17:00 ─ 18:00   9.  Admin — Nhật Ký Chấm Công (đối chiếu bản ghi vừa tạo)
18:00 ─ 20:00  10.  Admin — Quản Lý Nhân Viên
20:00 ─ 22:00  11.  Admin — Duyệt Nghỉ Phép (+ xem Notification qua Console)
22:00 ─ 23:00  12.  Admin — Cấu Hình GPS/Settings
23:00 ─ 25:00  13.  Kết luận & kế hoạch tiếp theo
```

**Vì sao sắp xếp theo thứ tự này:**

- **Giới thiệu → Kiến trúc trước khi vào máy**: giảng viên cần hiểu bài toán và lựa chọn công nghệ trước khi xem thao tác cụ thể, tránh xem demo như một chuỗi thao tác rời rạc không có bối cảnh.
- **Mobile trước Admin**: đi theo đúng **vòng đời thật của dữ liệu** — dữ liệu sinh ra từ hành động của nhân viên (Check In/Out) trước, rồi mới tới góc nhìn admin giám sát/quản lý dữ liệu đó. Đây cũng là cách kể chuyện nhân quả dễ theo dõi nhất: "nhân viên làm gì → admin thấy gì".
- **Demo Time đặt ngay sau Home**: đây là phần thay thế hoàn toàn "Check In thật 1 lần" của kịch bản cũ — thay vì chỉ chứng minh 1 thời điểm, Demo Time cho phép chứng minh **toàn bộ các nhánh nghiệp vụ** (đúng giờ/muộn/về sớm/Business Date xuyên nửa đêm) trong cùng một mạch trình bày liền mạch, không phải chờ hoặc "giả vờ" đã qua nhiều giờ.
- **Lịch sử chấm công ngay sau đó**: xác nhận trực quan bản ghi vừa tạo bằng Demo Time đã lưu đúng, đồng thời cho xem dữ liệu thật tích luỹ hơn 1 tháng (không phải dựng tạm).
- **Admin: Dashboard → Nhật ký → Nhân viên → Nghỉ phép → Settings**: đi từ tổng quan (Dashboard) tới chi tiết (Nhật ký đối chiếu đúng bản ghi vừa demo) tới các nghiệp vụ quản trị (Nhân viên, Nghỉ phép), kết ở Settings vì đây là màn "cấu hình nền" ít kịch tính nhất — hợp lý để đặt gần cuối trước khi chuyển sang kết luận.
- **Kết luận cuối cùng**: tóm tắt đúng 3 trọng tâm buổi báo cáo tiến độ — đã làm gì, đang đi đúng hướng ra sao, kế hoạch tiếp theo là gì.

### 2.2 Chi tiết từng bước

#### Bước 1 — Giới thiệu đề tài
- **Mục tiêu:** "Tại bước này tôi muốn chứng minh giảng viên hiểu đúng bài toán trước khi xem bất kỳ thao tác nào."
- **Thao tác:** Không thao tác trên máy — trình bày bằng lời/slide.
- **Dữ liệu:** Không có.
- **Màn hình:** Slide giới thiệu.
- **Kết quả mong đợi:** Giảng viên nắm được bài toán (chấm công GPS theo ca xoay vòng) và phạm vi (2 ứng dụng, 1 backend Firebase).
- **Lời thoại gợi ý:**
  > Em xin phép báo cáo tiến độ đồ án thực tập: hệ thống chấm công bằng GPS cho nhân viên làm việc theo ca xoay vòng. Bài toán thực tế là công ty có nhân viên làm ca ngày và ca đêm, luân phiên đổi ca theo chu kỳ, cần xác nhận nhân viên chấm công đúng tại vị trí công ty. Em xây dựng 2 ứng dụng: app di động cho nhân viên chấm công, và web quản trị cho admin quản lý — cả 2 dùng chung 1 backend Firebase.
- **Thời gian:** 2 phút.

#### Bước 2 — Kiến trúc & công nghệ
- **Mục tiêu:** "Tại bước này tôi muốn chứng minh lựa chọn công nghệ có chủ đích, không tuỳ tiện."
- **Thao tác:** Slide sơ đồ kiến trúc (feature-first, Riverpod, Firebase).
- **Dữ liệu:** Không có.
- **Kết quả mong đợi:** Giảng viên hiểu vì sao Flutter + Firebase + Riverpod + Firestore Rules (thay vì backend riêng) là lựa chọn hợp lý cho quy mô đồ án.
- **Lời thoại gợi ý:**
  > Em dùng Flutter cho cả 2 ứng dụng — một ngôn ngữ Dart, một mình em phát triển song song 2 app trong thời gian thực tập. Backend là Firebase: Authentication để đăng nhập, Cloud Firestore lưu toàn bộ dữ liệu nghiệp vụ. Quản lý state dùng Riverpod — mỗi tính năng có Repository lo đọc/ghi Firestore, Provider expose dữ liệu ra UI. Một điểm em muốn nhấn mạnh: vì không có backend riêng, toàn bộ phân quyền nằm ở Firestore Security Rules — em sẽ quay lại điểm này ở phần sau vì đây là phần em đầu tư khá kỹ.
- **Thời gian:** 2 phút.

#### Bước 3 — Mobile — Đăng nhập
- **Mục tiêu:** "Tại bước này tôi muốn xác nhận luồng xác thực hoạt động và phân quyền đúng vai trò."
- **Thao tác:** Mở app mobile, đăng nhập bằng tài khoản nhân viên đúng nhóm sẽ cần cho Demo Time (xem mục 3 để chọn EMP002/EMP003 nếu mở đầu bằng mốc ca ngày, hoặc EMP001/EMP004 nếu mở đầu bằng mốc ca đêm).
- **Dữ liệu:** 1 trong 4 tài khoản nhân viên đã có sẵn.
- **Màn hình:** Login → Home.
- **Kết quả mong đợi:** Đăng nhập thành công, chuyển thẳng vào Home.
- **Lời thoại gợi ý:**
  > Đây là app dành cho nhân viên. Tài khoản đăng nhập do admin tạo sẵn — nhân viên không tự đăng ký, chỉ nhận email/mật khẩu từ công ty rồi đăng nhập.
- **Thời gian:** 1 phút.

#### Bước 4 — Mobile — Home (giới thiệu Rotation)
- **Mục tiêu:** "Tại bước này tôi muốn giới thiệu tính năng thông minh nhất của hệ thống trước khi đi vào thao tác cụ thể."
- **Thao tác:** Chỉ vào phần hiển thị ca làm việc hiện tại trên Home.
- **Dữ liệu:** `shiftGroup` của tài khoản đang đăng nhập + `company_settings`.
- **Màn hình:** Home.
- **Kết quả mong đợi:** Home hiển thị đúng ca hiện tại của tài khoản, khớp với bảng rotation ở mục 1.1.
- **Lời thoại gợi ý:**
  > Công ty có 2 nhóm nhân viên — nhóm A và nhóm B — luân phiên đổi ca ngày/ca đêm mỗi 14 ngày. Nhân viên không tự chọn ca, hệ thống tự tính dựa trên nhóm và ngày hiện tại. Cái khó nằm ở ca đêm — bắt đầu 20 giờ tối, kết thúc 8 giờ sáng hôm sau, xuyên qua nửa đêm. Em sẽ minh hoạ ngay sau đây bằng công cụ mô phỏng thời gian, để không phải chờ tới đúng giờ thật mới thấy được toàn bộ các trường hợp.
- **Thời gian:** 2 phút.

#### Bước 5 — Mobile — Demo Time: Check In/Out qua các mốc giờ
- **Mục tiêu:** Xem chi tiết đầy đủ ở mục 3 — đây là phần trọng tâm kỹ thuật của buổi demo.
- **Thời gian:** 6 phút (rút gọn còn 4 mốc tiêu biểu — xem mục 3.3).

#### Bước 6 — Mobile — Lịch sử chấm công
- **Mục tiêu:** "Tại bước này tôi muốn chứng minh dữ liệu đã tích luỹ thật, không phải dựng tạm cho buổi demo hôm nay."
- **Thao tác:** Chuyển tab "Lịch sử", cuộn xem vài bản ghi cũ (tháng 6).
- **Dữ liệu:** 38 bản ghi thật, hơn 1 tháng.
- **Màn hình:** Attendance History (có banner Demo Mode nếu vẫn đang bật Demo Time — xem mục 3.5 để nhớ Reset trước khi rời màn này).
- **Kết quả mong đợi:** Danh sách hiển thị đủ các trạng thái: đúng giờ, đi muộn, về sớm, đổi ca giữa 2 nhóm đúng ngày dự kiến; bản ghi vừa tạo ở Bước 5 xuất hiện đúng vị trí theo Business Date.
- **Lời thoại gợi ý:**
  > Đây là lịch sử chấm công thật hơn 1 tháng qua — không phải dữ liệu giả dựng cho buổi demo hôm nay. Các thầy cô có thể thấy đủ trường hợp: đúng giờ, đi trễ, về sớm, và đúng ngày hệ thống tự đổi ca giữa 2 nhóm theo chu kỳ 14 ngày như em vừa nói.
- **Thời gian:** 1 phút.

#### Bước 7 — Admin — Đăng nhập
- **Mục tiêu:** "Tại bước này tôi chuyển góc nhìn sang phía quản trị."
- **Thao tác:** Mở web admin, đăng nhập ADMIN001.
- **Màn hình:** Login → Dashboard.
- **Kết quả mong đợi:** Đăng nhập thành công.
- **Lời thoại gợi ý:**
  > Chuyển sang phía quản trị — admin quản lý toàn bộ nhân viên, chấm công, nghỉ phép, cấu hình công ty.
- **Thời gian:** 1 phút.

#### Bước 8 — Admin — Dashboard
- **Mục tiêu:** "Tại bước này tôi muốn tạo ấn tượng trực quan đầu tiên cho phía quản trị."
- **Thao tác:** Chỉ vào 4 thẻ số liệu ("Tổng nhân viên", "Đã chấm công hôm nay", "Đơn nghỉ phép chờ duyệt", "Phòng ban") và biểu đồ "Chấm công 7 ngày gần nhất".
- **Dữ liệu:** Tổng hợp từ `users`, `attendance`, `leave_requests`, `departments`.
- **Kết quả mong đợi:** Dashboard tải được, số liệu hợp lý.
- **Lời thoại gợi ý:**
  > Đây là Dashboard tổng quan — số nhân viên, số người đã chấm công hôm nay, số đơn nghỉ phép đang chờ, và biểu đồ chấm công theo tuần.
- **Thời gian:** 2 phút.

#### Bước 9 — Admin — Nhật Ký Chấm Công
- **Mục tiêu:** "Tại bước này tôi muốn chứng minh trực quan luồng dữ liệu mobile → Firestore → admin gần như tức thời."
- **Thao tác:** Mở màn "Nhật Ký Chấm Công", tìm đúng (các) bản ghi vừa tạo ở Bước 5.
- **Dữ liệu:** Bản ghi vừa demo bằng Demo Time.
- **Kết quả mong đợi:** Thấy đúng bản ghi, đúng giờ Check In/Out, đúng trạng thái (late/on_time/early_leave) khớp với những gì đã trình bày ở Bước 5.
- **Lời thoại gợi ý:**
  > Đây chính là các bản ghi em vừa tạo trên điện thoại — dữ liệu đi thẳng từ mobile lên Firestore, admin thấy ngay lập tức, không qua bước đồng bộ trung gian nào.
- **Thời gian:** 1 phút.

#### Bước 10 — Admin — Quản Lý Nhân Viên
- **Mục tiêu:** "Tại bước này tôi muốn trình bày tính năng quản trị kèm 1 điểm cộng bảo mật đã cải tiến gần đây."
- **Thao tác:** Mở màn "Danh Sách Hồ Sơ Nhân Sự UMC", bấm "Thêm Nhân Viên Mới", điền Mã NV/Họ tên/Email, chỉ vào ô "Mật khẩu đăng nhập" đã tự sinh sẵn (nút 🔄 để sinh lại), chọn Phòng ban/Ca làm việc, lưu.
- **Dữ liệu:** 1 nhân viên demo mới (có thể huỷ/không lưu thật nếu muốn tránh phát sinh tài khoản Auth thừa — hoặc lưu thật để minh hoạ trọn vẹn, vì `EmployeeRepository.addEmployee` dùng `SecondaryApp` nên không làm mất phiên đăng nhập admin).
- **Kết quả mong đợi:** Tài khoản tạo thành công, SnackBar hiện "Đã tạo tài khoản thành công! Mật khẩu: ..." kèm nút "Sao chép".
- **Lời thoại gợi ý:**
  > Khi tạo tài khoản mới, hệ thống tự sinh mật khẩu ngẫu nhiên đủ mạnh thay vì đặt sẵn mật khẩu mặc định — đây là cải tiến bảo mật em vừa hoàn thành, vì trước đó mọi tài khoản mới đều dùng chung 1 mật khẩu dễ đoán là "123456".
- **Thời gian:** 2 phút.

#### Bước 11 — Admin — Duyệt Nghỉ Phép (+ xem Notification qua Console)
- **Mục tiêu:** "Tại bước này tôi muốn trình bày tính năng đã có, đồng thời biến phần đang làm dở (tạo đơn từ mobile) và phần chưa có UI (Notification) thành nội dung chủ động thay vì bị hỏi mới trả lời."
- **Thao tác:** Mở màn "Phê Duyệt Đơn Xin Nghỉ Phép", xử lý đơn `pending` (EMP002) đã seed sẵn — bấm ✅ hoặc ❌, nhập ghi chú, xác nhận. Ngay sau đó chuyển qua tab Firebase Console đã mở sẵn, refresh collection `notifications`, chỉ vào document vừa được tạo.
- **Dữ liệu:** Đơn nghỉ phép `pending` của EMP002.
- **Kết quả mong đợi:** Trạng thái đơn đổi thành "Đã duyệt"/"Từ chối", document mới xuất hiện trong `notifications` với `type: leave_approved`/`leave_rejected`.
- **Lời thoại gợi ý:**
  > Nhân viên gửi đơn nghỉ phép, admin duyệt hoặc từ chối kèm ghi chú, hệ thống tự gửi thông báo lại cho nhân viên — em cho thầy cô xem trực tiếp document vừa được tạo trên Firestore, vì hiện tại em chưa kịp làm màn hình hiển thị thông báo ở app, đây là phần em ưu tiên cho giai đoạn tiếp theo.
  >
  > Và nhân tiện nói luôn phần đang dở: hiện tại phía mobile, màn "Nghỉ phép" chưa cho nhân viên tự tạo đơn — em ưu tiên hoàn thiện lõi chấm công GPS trước, phần này nằm trong kế hoạch giai đoạn tiếp theo.
- **Thời gian:** 2 phút.

#### Bước 12 — Admin — Cấu Hình GPS/Settings
- **Mục tiêu:** "Tại bước này tôi muốn chứng minh hệ thống cấu hình được theo từng doanh nghiệp, không hardcode."
- **Thao tác:** Mở màn Settings, chỉ vào các trường Toạ độ/Bán kính/Giờ ca/Chu kỳ xoay ca.
- **Kết quả mong đợi:** Số liệu hiển thị đúng giá trị đã chốt ở mục 1.1.
- **Lời thoại gợi ý:**
  > Toàn bộ tham số nghiệp vụ — toạ độ công ty, bán kính cho phép, giờ ca, chu kỳ xoay ca — đều cấu hình được qua đây, không hardcode trong code. Nếu triển khai cho công ty khác chỉ cần đổi cấu hình, không cần build lại ứng dụng.
- **Thời gian:** 1 phút.

#### Bước 13 — Kết luận & kế hoạch tiếp theo
- **Mục tiêu:** "Tại bước này tôi muốn kết thúc đúng trọng tâm buổi báo cáo tiến độ — chứng minh đúng hướng và có kế hoạch rõ ràng."
- **Thao tác:** Không thao tác trên máy — quay lại slide.
- **Lời thoại gợi ý:**
  > Tóm lại, giai đoạn vừa qua em đã hoàn thành: luồng chấm công GPS đầy đủ, xử lý đúng ca đêm xuyên nửa đêm qua khái niệm Business Date, cơ chế xoay ca tự động, và đã rà soát vá lại toàn bộ Firestore Security Rules — ban đầu dữ liệu gần như không có lớp bảo vệ nào ở tầng cơ sở dữ liệu. Em cũng vừa hoàn thành một công cụ nội bộ mô phỏng thời gian để phục vụ chính buổi demo hôm nay, giúp minh hoạ được toàn bộ các mốc nghiệp vụ mà không phải chờ thời gian thực trôi qua.
  >
  > Phần đang làm dở và sẽ hoàn thiện ở giai đoạn tiếp theo: cho nhân viên tự tạo đơn nghỉ phép từ mobile, xây màn hiển thị thông báo, màn quản lý phòng ban độc lập cho admin.
  >
  > Em xin dừng phần trình bày ở đây, sẵn sàng nhận câu hỏi từ thầy cô.
- **Thời gian:** 2 phút.

---

## 3. Demo Time Script

### 3.1 Nguyên tắc quan trọng cần hiểu trước khi demo phần này

**Demo Time KHÔNG giả GPS, KHÔNG giả kết quả tính toán — chỉ giả lập "đồng hồ hệ thống" mà logic nghiệp vụ đọc.** Check In/Check Out vẫn là hành động thật (GPS thật, ghi Firestore thật); chỉ có `DateTime.now()` được thay bằng thời gian do người demo chọn, thông qua `ClockService.now()` — điểm neo duy nhất mà toàn bộ nghiệp vụ (Business Date, Shift, Late, Early Leave) đều dùng. Đây là điểm nên nói thẳng với giảng viên nếu được hỏi — thể hiện sự trung thực và đúng bản chất kỹ thuật, không phải "diễn".

**⚠️ Rủi ro cần tránh:** mỗi lần Check In/Check Out thật ở một mốc Demo Time sẽ **ghi 1 document Firestore thật** cho đúng Business Date đó (docId `"<yyyy-MM-dd>_<uid>"`). Nếu dry-run luyện tập ở đúng ngày sẽ dùng khi báo cáo thật, lần diễn thật sẽ bị từ chối với lỗi "Bạn đã Check In hôm nay rồi". **Cách xử lý:** luyện tập ở một ngày giả lập khác hẳn (ví dụ lùi xa vài ngày so với ngày dự định demo thật), giữ ngày "sạch" (chưa từng check-in) dành riêng cho buổi báo cáo thật.

### 3.2 Bảng đầy đủ 10 mốc thời gian

Giả định demo diễn ra ở "hôm nay" (ngày thật lúc báo cáo). Cột "Tài khoản" ghi theo nhóm hiện đang làm ca tương ứng tại **thời điểm viết tài liệu này** (khối 29/06–12/07: A=đêm, B=ngày) — **luôn xác nhận lại bằng khối "Current Shift" trên Demo Center trước khi demo**, vì rotation đổi mỗi 14 ngày.

| Mốc | Demo gì | Tài khoản gợi ý | Mong đợi | Firestore ghi gì | Home hiển thị | Attendance History hiển thị |
|---|---|---|---|---|---|---|
| **07:50** | Sắp tới giờ vào ca ngày | Nhóm ca ngày (VD: EMP002) | Check In thành công, không muộn (trong cửa sổ cho phép sớm 60 phút trước 08:00) | Chưa ghi gì (chỉ xem Home) | Nút Check In khả dụng, ca ngày, "Nhấn để check in" | — |
| **08:10** | Check In muộn ca ngày | Cùng tài khoản trên | Check In thành công, `isLate: true` | Tạo doc mới `checkIn: 08:10`, `isLate: true`, `status: 'late'` | Sau khi bấm: hiển thị giờ Check In 08:10, badge "Đi muộn" | Bản ghi hôm nay xuất hiện, trạng thái "Đi muộn" |
| **12:30** | Giữa ca, chưa check-out | Cùng tài khoản trên | Trạng thái "đã check-in, chưa check-out" | Không đổi | Check In 08:10, Check Out "--:--", "Nhấn để check out" | Bản ghi hôm nay: chưa có giờ ra |
| **13:00** | Vẫn giữa ca | Cùng tài khoản trên | Như trên | Không đổi | Như trên | Như trên |
| **19:50** | Sắp tới giờ vào ca đêm (nhóm khác) | Nhóm ca đêm (VD: EMP001 hoặc EMP004) | Home hiển thị đúng ca đêm sắp tới | Chưa ghi gì | Ca đêm, "Nhấn để check in" | — |
| **20:00** | Check In đúng giờ ca đêm | Cùng tài khoản trên | Check In thành công, `isLate: false` | Tạo doc mới `checkIn: 20:00`, `isLate: false`, `status: 'on_time'` | Check In 20:00, không có badge muộn | Bản ghi hôm nay: đúng giờ |
| **20:15** | Check In muộn ca đêm (tài khoản khác) | Tài khoản thứ 2 cùng nhóm ca đêm | Check In thành công, `isLate: true` | Tạo doc mới cho tài khoản này, `isLate: true` | Check In 20:15, badge "Đi muộn" | Bản ghi hôm nay: đi muộn |
| **23:30** | Vẫn thuộc Business Date "hôm nay" dù đã khuya | Tài khoản đã check-in lúc 20:00 | Business Date vẫn = hôm nay (ca đêm chưa qua nửa đêm) | Không đổi | Vẫn hiển thị trạng thái đã check-in bình thường, không "nhảy ngày" | Bản ghi vẫn đứng đúng ngày hôm nay |
| **00:15** | **Điểm chứng minh quan trọng nhất — Business Date xuyên nửa đêm** | Cùng tài khoản trên | `BusinessDateHelper` trả về Business Date = hôm qua (ngày ca đêm *bắt đầu*), KHÔNG phải ngày lịch mới | Không đổi (vẫn cùng document, docId theo ngày hôm qua) | Home vẫn hiển thị đúng trạng thái ca đêm hôm qua, không tạo nhầm "ca mới" cho ngày lịch hôm nay | Bản ghi vẫn đứng đúng dưới ngày hôm qua, không tách thành 2 dòng |
| **07:59** | Check Out cuối ca đêm (1 phút trước giờ tan ca 08:00) | Tài khoản đã check-in ca đêm | Check Out thành công, tìm đúng document đã tạo lúc 20:00/20:15 (không tạo mới); vì `calculateEarlyLeave` dùng phép so sánh nghiêm ngặt (`isBefore`), Check Out lúc 07:59 — dù chỉ sớm 1 phút — vẫn được tính `isEarlyLeave: true` | Update document cũ: `checkOut: 07:59`, `isEarlyLeave: true`, `status: 'completed'`, `workHours` tính đúng theo `checkOut - checkIn` | Check Out hiển thị 07:59, "Đã làm X giờ" | Bản ghi hôm qua giờ có đủ Check In + Check Out |

### 3.3 Bộ mốc rút gọn dùng khi trình chiếu thật (khuyến nghị)

Đi đủ 10 mốc sẽ vượt ngân sách thời gian của 1 buổi báo cáo tiến độ (~20-25 phút tổng). Vì Demo Center có Fast Forward/Rewind (đổi mốc trong vài giây), khuyến nghị chỉ trình bày **4 mốc tiêu biểu** trong Bước 5 (mục 2.2), đủ để chứng minh cả 4 nhánh nghiệp vụ chính, và nói rõ với giảng viên rằng các mốc còn lại có thể xem ngay nếu được yêu cầu:

1. **08:10** — Check In muộn ca ngày (chứng minh Late).
2. **20:00 → 20:15** — 2 tài khoản Check In ca đêm, 1 đúng giờ 1 muộn (chứng minh Shift Rotation + so sánh trực tiếp đúng/muộn).
3. **23:30 → 00:15** — Fast Forward qua mốc nửa đêm, chỉ vào Home không đổi gì bất thường (chứng minh Business Date — **đây là khoảnh khắc kỹ thuật ấn tượng nhất, nên dành thời gian giải thích kỹ**).
4. **07:59** — Check Out cuối ca đêm (khép kín ví dụ, chứng minh Early Leave với độ chính xác tới từng phút).

**Lời thoại gợi ý cho cụm này:**
> Để không phải chờ tới đúng giờ thật, em có một công cụ nội bộ — chỉ bật được ở bản debug, không có trong bản chính thức — cho phép mô phỏng đồng hồ hệ thống. Nó không giả GPS, không giả kết quả tính toán, chỉ thay đổi "thời gian hiện tại" mà toàn bộ logic nghiệp vụ đọc vào, để mọi phép tính vẫn chạy y hệt logic thật.
>
> *(Set 08:10, ca ngày)* Đây là Check In muộn 10 phút — hệ thống đánh dấu "Đi muộn" ngay.
>
> *(Set 20:00 rồi 20:15, ca đêm, 2 tài khoản)* Đây là ca đêm của nhóm còn lại — một người vào đúng giờ, một người vào muộn 15 phút.
>
> *(Fast Forward từ 23:30 sang 00:15)* Và đây là điểm em muốn nhấn mạnh nhất: dù đồng hồ đã sang ngày mới, hệ thống vẫn hiểu đây là cùng một ca làm việc bắt đầu từ tối hôm qua — không bị "nhảy ngày" giữa chừng. Đây chính là khái niệm Business Date em đã trình bày ở phần Home.
>
> *(Set 07:59, Check Out)* Và Check Out ngay trước giờ tan ca — hệ thống vẫn tìm đúng bản ghi đã tạo từ tối hôm qua để cập nhật, không tạo nhầm bản ghi mới.

### 3.4 Phương án dự phòng — nếu Demo Center chưa kịp kiểm thử ổn định

Nếu dry-run (mục 1.3) phát hiện lỗi không kịp sửa trước ngày báo cáo, **quay lại đúng kịch bản gốc đã kiểm chứng trong `docs/demo/02_DEMO_FLOW.md`/`03_DEMO_SCRIPT.md`**: Check In/Check Out **thật theo thời gian thực**, không dùng Demo Time, chỉ demo đúng 1 lượt (không đi qua các mốc muộn/về sớm/nửa đêm), và giải thích Business Date bằng lời + chỉ vào dữ liệu lịch sử thật đã có sẵn bằng chứng (mục 1.1) thay vì minh hoạ trực tiếp. Đây là phương án an toàn tuyệt đối vì không phụ thuộc tính năng mới chưa kiểm chứng.

### 3.5 Lưu ý vận hành

- Sau khi demo xong mục 3, **bắt buộc bấm "Reset to Current Time"** trong Demo Center trước khi chuyển sang Bước 6 (Lịch sử chấm công) và các bước còn lại — nếu quên, mọi màn hình sau đó (kể cả admin đối chiếu dữ liệu) sẽ tính toán theo giờ giả lập thay vì giờ thật, dễ gây nhầm lẫn khi đối chiếu với Nhật Ký Chấm Công phía admin (admin luôn dùng giờ thật của máy chạy web, không có Demo Time).
- Banner cam "🧪 DEMO —..." sẽ tự hiện ở Home/History khi Demo Time đang bật — chủ động chỉ vào banner này và giải thích 1 câu ngắn để giảng viên không hiểu nhầm là lỗi hiển thị.

---

## 4. Error Scenarios

Giảng viên thường thích xem xử lý lỗi — đây là danh sách nên chủ động demo hoặc chuẩn bị sẵn để trả lời khi được hỏi "thử làm sai xem sao".

| # | Tình huống | Cách tạo ra | Thông báo lỗi chính xác | Đáng demo chủ động? |
|---|---|---|---|---|
| 1 | GPS ngoài bán kính | Chỉ tái hiện được nếu đã đổi `radius` về giá trị nhỏ (mục 1.1) và đứng ngoài phạm vi | *"Bạn đang ở ngoài phạm vi công ty.\nKhoảng cách hiện tại: Xm\nBán kính cho phép: Ym"* | Có, nếu đã chốt `radius` thực tế — minh hoạ rất trực quan |
| 2 | Check In trùng (đã check-in hôm nay rồi) | Bấm Check In lần 2 cùng 1 tài khoản, cùng Business Date | *"Bạn đã Check In hôm nay rồi"* | Có — dễ tái hiện, an toàn |
| 3 | Check Out khi chưa Check In hợp lệ | Bấm Check Out cho tài khoản chưa từng Check In trong ca hiện tại / đã quá khung ân hạn | *"Không tìm thấy ca làm việc cần Check Out hợp lệ.\nVui lòng liên hệ quản lý/admin để được hỗ trợ điều chỉnh chấm công."* | Có |
| 4 | Check Out trùng | Bấm Check Out lần 2 sau khi đã check-out | *"Bạn đã Check Out hôm nay rồi"* | Tuỳ chọn |
| 5 | Check In khi chưa tới giờ ca | Check In sớm hơn 60 phút trước giờ vào ca (dùng Demo Time set giờ rất sớm) | *"Chưa tới giờ Check In.\nCa làm việc bắt đầu lúc HH:mm, bạn có thể Check In sớm nhất từ HH:mm (trước giờ vào ca 1 tiếng)."* | Có — minh hoạ rõ ràng nhờ Demo Time |
| 6 | Check In khi đã hết ca (tính vắng mặt) | Check In sau giờ kết thúc ca (dùng Demo Time) | *"Ca làm việc đã kết thúc (HH:mm).\nNgày hôm nay được tính là vắng mặt."* | Có — minh hoạ rõ ràng nhờ Demo Time |
| 7 | GPS chưa bật | Tắt GPS trên thiết bị rồi bấm Check In | *"GPS chưa được bật. Vui lòng bật GPS và thử lại."* | Tuỳ chọn — rủi ro quên bật lại GPS sau đó |
| 8 | Quyền GPS bị từ chối | Từ chối quyền vị trí khi app xin | *"Quyền GPS bị từ chối."* / *"Quyền GPS bị từ chối vĩnh viễn. Vui lòng vào Cài đặt để cấp quyền."* | Không khuyến nghị demo trực tiếp (khó phục hồi nhanh giữa buổi), chỉ nêu bằng lời |
| 9 | **Fake GPS bị chặn** | Bật 1 app giả lập vị trí (Developer Options → Mock location app), thử Check In | *"Phát hiện vị trí giả. Không thể chấm công."* | **Rất nên demo chủ động** — đây là điểm cộng bảo mật ấn tượng, thể hiện tư duy chống gian lận chấm công |
| 10 | Sai tài khoản (mobile đăng nhập bằng tài khoản admin) | Đăng nhập mobile bằng tài khoản `role: admin` | *"Tài khoản quản trị vui lòng đăng nhập trên web admin"* | Có — nhanh, an toàn, minh hoạ tốt phân quyền |
| 11 | Sai tài khoản (admin đăng nhập bằng tài khoản employee) | Đăng nhập admin bằng tài khoản `role: employee` | *"Bạn không có quyền truy cập quản trị"* | Có |
| 12 | Permission Denied (Firestore Rules) | Khó tái hiện an toàn trong lúc demo trực tiếp (cần sửa `role`/`isActive` tay trên Console) | Lỗi Firestore chuẩn `permission-denied` | Không demo trực tiếp — chỉ giải thích bằng lời, dẫn chứng bằng `firestore.rules` đã version-control |
| 13 | Rotation/Business Date (đã có ở mục 3) | Xem mục 3.2, mốc 00:15 | — | Có, đã có kịch bản riêng |

**Khuyến nghị chọn demo trực tiếp trong buổi báo cáo:** #2 (Check In trùng), #9 (Fake GPS), #10 hoặc #11 (sai tài khoản) — 3 tình huống này an toàn, nhanh, phục hồi dễ, và thể hiện rõ tư duy xử lý lỗi + bảo mật. Các tình huống còn lại để trả lời bằng lời nếu được hỏi.

---

## 5. Question & Answer

33 câu hỏi kỹ thuật đã chuẩn bị sẵn (Flutter, Firebase, Firestore, Riverpod, GPS, Business Date, Rotation, Security Rules, Database, Architecture) — xem đầy đủ tại `docs/demo/07_DEMO_QA.md`, giữ nguyên không đổi vì vẫn chính xác với trạng thái hiện tại của dự án. Dưới đây là các câu hỏi **mới**, bổ sung riêng cho Demo Time System:

**Q34. Vì sao cần một hệ thống "Demo Time" riêng, không dùng cách nào khác?**
- *Ngắn:* Để chứng minh được toàn bộ nhánh nghiệp vụ (đúng giờ/muộn/về sớm/xuyên nửa đêm) trong 1 buổi báo cáo ngắn, thay vì phải chờ nhiều giờ hoặc đổi giờ hệ điều hành (rủi ro ảnh hưởng chứng chỉ TLS, log hệ thống).
- *Chi tiết:* Xem `docs/design/DEMO_TIME_DESIGN_v2.md` mục 1 — phân tích đầy đủ lý do và các phương án đã cân nhắc (static/singleton/Riverpod provider).

**Q35. Demo Time có ảnh hưởng dữ liệu thật hay ảnh hưởng bản chính thức (production) không?**
- *Ngắn:* Không — chỉ hoạt động ở `kDebugMode`, ở bản release nhánh này không bao giờ chạy được.
- *Chi tiết:* `ClockService.now()` kiểm tra `kDebugMode` trước khi trả về thời gian giả lập; ở bản build `--release`, biểu thức này luôn `false`, hàm luôn trả `DateTime.now()` thật. Menu "Demo Center" trong Profile cũng chỉ hiển thị khi `kDebugMode`. Dữ liệu ghi xuống Firestore vẫn là dữ liệu thật (Check In/Check Out thật), chỉ có "thời gian" đầu vào là giả lập — không có cơ chế nào tách biệt hay đánh dấu dữ liệu demo với dữ liệu thật trong Firestore.

**Q36. Vì sao Admin Dashboard không phản ánh đúng khi dùng Demo Time bên mobile?**
- *Ngắn:* Vì Demo Time chỉ tồn tại trong tiến trình app mobile (biến static trong RAM) — admin là ứng dụng/tiến trình hoàn toàn khác, vẫn dùng giờ thật của máy đang chạy web.
- *Chi tiết:* Đây là giới hạn đã biết trước khi thiết kế (`docs/design/DEMO_TIME_DESIGN_v2.md` mục 8) — nếu demo mô phỏng mốc xuyên nửa đêm, bản ghi ghi nhận theo Business Date giả lập (có thể là "ngày mai" so với ngày thật), nên Dashboard admin (đếm theo "hôm nay" thật) có thể không thấy ngay bản ghi đó. Không phải bug, mà là hệ quả tất yếu của việc Demo Time không mở rộng sang admin trong phạm vi hiện tại.

---

## 6. Checklist

### 6.1 Trước 1 ngày

```
☐ ĐÃ XÁC NHẬN: sẽ demo bằng `flutter run` (main.dart), TUYỆT ĐỐI KHÔNG chạy `main_dev.dart`
☐ Đã thêm 3 document mẫu vào leave_requests (mục 1.1)
☐ Đã quyết định giữ hay đổi company_settings.radius (mục 1.1)
☐ Đã sửa lại departmentId của tài khoản admin cho khớp 1 phòng ban thật
☐ Đã dry-run toàn bộ Demo Time System (Apply/Reset/Fast Forward/Rewind/Reset to Current Time) trên đúng thiết bị demo, ở NGÀY GIẢ LẬP KHÁC ngày sẽ dùng khi báo cáo thật
☐ Đã kiểm thử tay Check In/Check Out (cả có và không dùng Demo Time) trên đúng thiết bị sẽ dùng để demo
☐ Đã kiểm thử đăng nhập cả 2 app bằng đúng tài khoản sẽ dùng khi demo
☐ Đã xác nhận lại "Current Shift" hiện tại của từng nhóm A/B qua Demo Center (rotation đổi mỗi 14 ngày — không giả định cố định)
☐ Đã chạy flutter analyze cho cả 2 app, không còn lỗi mới
☐ Đã thử tình huống Fake GPS (#9 mục 4) ít nhất 1 lần để chắc chắn thông báo hiện đúng
☐ Đã sạc đầy pin điện thoại demo + laptop
☐ Đã chuẩn bị phương án mạng dự phòng (hotspot 4G) — xem mục 8
☐ Đã đọc qua mục 2 (Demo Script) và mục 5 (Q&A) ít nhất 1 lượt
```

### 6.2 Ngay trước giờ báo cáo

```
☐ Mobile Login — đã đăng nhập sẵn hoặc xác nhận đăng nhập nhanh được
☐ Admin Login — đã đăng nhập sẵn hoặc xác nhận đăng nhập nhanh được
☐ GPS trên điện thoại demo đã bật, không còn app mock-location nào đang bật quyền giả lập từ trước (trừ lúc chủ động demo tình huống #9)
☐ Internet ổn định — đã thử tải Dashboard admin ít nhất 1 lần thành công
☐ Firebase Console đã mở sẵn 1 tab, đúng project, đúng collection attendance/notifications
☐ Demo Center — kiểm tra đang ở trạng thái "Use Real Time" (chưa bật Demo Time) trước khi bắt đầu
☐ Dashboard admin đã tải thử, không còn lỗi quyền truy cập
☐ Attendance (Nhật ký chấm công) đã mở thử, hiển thị đúng dữ liệu
☐ Employee (Quản lý nhân viên) đã mở thử, dropdown phòng ban hiển thị đủ 13 phòng ban
☐ Leave (Duyệt nghỉ phép) đã mở thử, thấy đủ 3 đơn mẫu (pending/approved/rejected)
☐ Settings đã mở thử, số liệu hiển thị đúng giá trị đã chốt
☐ Đã chuẩn bị sẵn hotspot 4G, đã thử chuyển mạng 1 lần để chắc chắn hoạt động
☐ Đã tắt thông báo/tin nhắn cá nhân trên điện thoại + laptop dùng demo
```

### 6.3 Trong lúc demo

```
☐ Mở đầu đúng kịch bản (mục 2.2 Bước 1-2)
☐ Mobile Login thành công
☐ Home hiển thị đúng ca dự kiến
☐ Demo Time: đủ 4 mốc rút gọn (mục 3.3), có Reset to Current Time trước khi rời phần này
☐ Lịch sử chấm công hiển thị đúng bản ghi cũ + bản ghi vừa tạo, banner Demo Mode đã tắt
☐ Admin Login thành công
☐ Dashboard tải được, không lỗi
☐ Nhật ký chấm công hiển thị đúng bản ghi Check In/Out vừa demo ở mobile
☐ Thêm nhân viên mới thành công, mật khẩu ngẫu nhiên hiển thị đúng
☐ Duyệt/từ chối 1 đơn nghỉ phép mẫu thành công + đã cho xem document notifications qua Console
☐ Settings mở được, không lỗi
☐ Kết luận đúng trọng tâm: đã làm gì — đang làm gì — kế hoạch tiếp theo
```

---

## 7. Estimated Demo Time

| Cấu phần | Thời gian |
|---|---|
| Giới thiệu + Kiến trúc (Bước 1-2) | 4 phút |
| Mobile: Đăng nhập + Home (Bước 3-4) | 3 phút |
| **Demo Time Script — 4 mốc rút gọn (Bước 5, mục 3.3)** | 6 phút |
| Mobile: Lịch sử chấm công (Bước 6) | 1 phút |
| Admin: Đăng nhập + Dashboard (Bước 7-8) | 3 phút |
| Admin: Nhật ký + Nhân viên (Bước 9-10) | 3 phút |
| Admin: Nghỉ phép + Notification qua Console (Bước 11) | 2 phút |
| Admin: Settings (Bước 12) | 1 phút |
| Kết luận (Bước 13) | 2 phút |
| **Tổng (kịch bản chính, không tính lỗi/Q&A)** | **≈ 25 phút** |
| Dự phòng nếu bị hỏi giữa chừng / xử lý sự cố nhỏ | +5 phút |
| Q&A sau demo | 10-15 phút (tuỳ giảng viên) |

**Nếu bị rút ngắn thời gian:** bỏ theo thứ tự ưu tiên giảm dần — (1) Bước 12 Settings, (2) rút Demo Time Script từ 4 mốc xuống 2 mốc (chỉ giữ 08:10 và cụm 23:30→00:15 — 2 mốc quan trọng nhất), (3) Bước 6 Lịch sử chấm công (đã có bằng chứng dữ liệu nói bằng lời thay thế). **Không cắt:** Bước 5 mốc 23:30→00:15 (Business Date) và Bước 11 (Duyệt nghỉ phép) — đây là 2 điểm thể hiện chiều sâu kỹ thuật và tính trung thực rõ nhất.

---

## 8. Backup Plan — Internet/Firebase sự cố

| Sự cố | Dấu hiệu | Xử lý ngay tại chỗ |
|---|---|---|
| **Mất Wi-Fi nơi báo cáo** | App treo loading, Dashboard không tải được, Check In không phản hồi | Chuyển ngay sang hotspot 4G đã chuẩn bị và thử trước — không cố debug mạng giữa buổi. Nếu chuyển mạng cũng mất thời gian, tạm dừng thao tác máy, chuyển sang trình bày bằng lời + ảnh chụp màn hình đã chuẩn bị sẵn (khuyến nghị: chụp sẵn 5-6 ảnh màn hình các bước quan trọng làm phương án dự phòng cuối cùng). |
| **Firestore chậm/không phản hồi** | Loading xoay mãi không ra kết quả | Tiếp tục nói trong lúc chờ (biến độ trễ thành khoảnh khắc giải thích: "hệ thống đang đồng bộ với Firestore..."), không im lặng chờ quá 10-15 giây — nếu quá lâu, chuyển tạm sang bước khác rồi quay lại sau. |
| **`permission-denied` bất ngờ** | Lỗi quyền truy cập dù trước đó chạy bình thường | Kiểm tra nhanh qua Firebase Console: tài khoản đang đăng nhập có đúng `role`/`isActive: true` không — sửa trực tiếp trên Console nếu cần (không cần khởi động lại app). |
| **Firebase Console không mở được (do mất mạng)** | Không dùng được để đối chiếu dữ liệu/xem Notification | Bỏ qua bước đối chiếu Console, chỉ mô tả bằng lời "document sẽ được tạo trong collection notifications với các field..." — không có gì bắt buộc phải xem trực tiếp Console. |
| **Thiết bị demo hết pin/gặp sự cố phần cứng** | Máy tắt nguồn, sạc không kịp | Có sẵn 1 thiết bị dự phòng thứ 2 đã đăng nhập sẵn cùng tài khoản (khuyến nghị chuẩn bị trước), hoặc dùng ảnh chụp màn hình đã chuẩn bị. |
| **Demo Time gặp lỗi runtime ngoài dự kiến** | Crash, ClockService không phản hồi, banner không cập nhật | Chuyển ngay sang Phương án dự phòng B (mục 3.4) — Check In/Check Out thật theo thời gian thực, bỏ qua phần mô phỏng nhiều mốc. Không cố debug trực tiếp trước mặt giảng viên. |
| **Toàn bộ máy tính/điện thoại gặp sự cố không thể phục hồi** | Mất khả năng demo trực tiếp hoàn toàn | Phương án cuối cùng: trình bày bằng slide + ảnh/video quay màn hình đã chuẩn bị sẵn trước đó (khuyến nghị quay 1 video ngắn 3-5 phút toàn bộ luồng chính làm phương án dự phòng tối hậu, không bắt buộc nhưng nên có). |

**Nguyên tắc chung khi gặp sự cố bất kỳ:** không hoảng, không xin lỗi dài dòng, không cố gắng debug kỹ thuật trước mặt giảng viên quá 15-20 giây cho 1 sự cố — chuyển hướng nhanh sang phương án dự phòng tương ứng hoặc sang bước tiếp theo, rồi quay lại nếu còn thời gian.
