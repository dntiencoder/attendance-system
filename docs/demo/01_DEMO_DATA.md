# 01 — Review Dữ liệu Demo

**Ngày đánh giá:** 2026-07-06, **cập nhật lại 2026-07-14** sau khi làm sạch và tạo lại toàn bộ dữ liệu nghiệp vụ cho tháng 7/2026 (xem `docs/project/01_BACKLOG.md` mục E) — nội dung bên dưới đã thay thế hoàn toàn bản đánh giá dữ liệu tháng 6 cũ.
**Nguồn dữ liệu:** `backup_firestore.json` / `BACKUP_SUMMARY.md` sinh bởi `tools/firestore_backup` (chạy 2026-07-14, sau khi reseed).
**Nguyên tắc:** Chỉ đánh giá dữ liệu **thật** đang có. Không tạo lại dữ liệu đã có, không tạo dữ liệu trùng, không đổi schema.

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Users](#2-users)
3. [Departments](#3-departments)
4. [Attendance](#4-attendance)
5. [Leave Requests](#5-leave-requests)
6. [Notifications](#6-notifications)
7. [Company Settings](#7-company-settings)
8. [Tổng hợp việc cần bổ sung](#8-tổng-hợp-việc-cần-bổ-sung)

---

## 1. Tổng quan

| Collection | Số document | Đủ demo? |
|---|---|---|
| `users` | 5 (4 nhân viên + 1 admin) | ✅ Đủ |
| `departments` | 13 | ✅ Đủ, thậm chí dư |
| `attendance` | 44 (1-14/7/2026, số bản ghi/người dao động do random có trọng số — xem mục 4) | ✅ Đủ, đã có đầy đủ biến thể cần thiết |
| `leave_requests` | 0 | 🟡 Trống có chủ đích — hoãn theo quyết định 2026-07-14, chưa cần cho demo hiện tại |
| `notifications` | 0 | 🟡 Trống nhưng không cần bổ sung (chưa có UI hiển thị) |
| `company_settings` | 1 (`main`) | ✅ Đủ, `radius` đã chỉnh về giá trị thực tế (xem mục 7) |
| `dev_metadata` | 0 (bị permission-denied khi backup) | Không liên quan tới demo — bỏ qua |

---

## 2. Users

**Hiện có 5 tài khoản** — đủ để demo rotation (cả nhóm A lẫn B) và vai trò (cả admin lẫn nhân viên).

| UID (rút gọn) | employeeCode | name | email | department | shiftGroup | role | trạng thái |
|---|---|---|---|---|---|---|---|
| `4Znn...dG3` | EMP001 | Trần Văn Ab | shiroyasha284@gmail.com | dept_ga (Phòng Hành chính – Nhân sự) | A | employee | isActive: true |
| `7VtAl...05l2` | EMP003 | Danh Nhật Tiến | danhnhattien284@gmail.com | dept_pe (Phòng Kỹ thuật sản xuất) | B | employee | isActive: true |
| `CDjUg...JXv2` | EMP004 | Tạ Đình Trí | tadinhtri2004@gmail.com | dept_te (Phòng Kỹ thuật) | A | employee | isActive: true |
| `Nuav1...C2` | EMP002 | Lê Thị B | dntienktpm2211046@student.ctuet.edu.vn | dept_dx (Phòng Chuyển đổi số) | B | employee | isActive: true |
| `UqyJA...Agh2` | ADMIN001 | Quản trị viên UMC | admin@gmail.com | dept_ga (Phòng Hành chính – Nhân sự) | A | admin | isActive: true |

**Đánh giá:** Đủ demo. Có cả 2 nhóm A/B, đủ cho câu chuyện rotation.

**Cập nhật 2026-07-14 (đã xử lý, không còn là vấn đề):**
- `departmentId` của admin trước đây trỏ `dep001` (không tồn tại) — đã sửa thành `dept_ga`, một phòng ban thật.
- `avatarUrl` của tất cả 5 tài khoản hiện để trống (`""`) sau khi tạo lại — không còn rủi ro hotlink ảnh ngoài như trước (EMP004 từng dùng ảnh từ `thanhnien.mediacdn.vn`). Đánh đổi: không có ảnh đại diện demo sẵn, chỉ hiển thị icon mặc định — nếu cần ảnh đẹp hơn, tự upload qua màn Hồ sơ trước buổi demo.

**Không cần bổ sung thêm user nào** — 5 tài khoản hiện có đã đủ minh hoạ mọi vai trò cần thiết.

---

## 3. Departments

**13 phòng ban** — đầy đủ, đúng phong cách tên phòng ban thật của doanh nghiệp (FAC, GA, PD, TE, PE, DX, PMC, PUR1, PUR2, Sales, ACC, QA, Internal Audit). Dropdown chọn phòng ban trong màn "Thêm Nhân Viên Mới" sẽ trông chuyên nghiệp, không trống.

**Đánh giá: ✅ Đủ đẹp để demo, không cần bổ sung.**

---

## 4. Attendance

**Cập nhật 2026-07-14:** toàn bộ 38 bản ghi tháng 6 cũ (mô tả ở các mục dưới đây trong bản đánh giá gốc) đã bị xoá và thay bằng **44 bản ghi mới cho 1-14/7/2026** (dao động 10-12 bản ghi/người tuỳ random — mỗi ngày làm/tăng ca có 10% khả năng "vắng" không có bản ghi, ngoài ra vẫn luôn bỏ qua 1 ngày nghỉ tuyệt đối 12/7), sinh bởi `tools/firestore_backup/bin/reseed_july.dart`, dùng đúng logic rotation/mandatory-workday thật (port từ `rotation_calculator.dart`/`work_schedule_helper.dart`) cho phần ngày làm/ca, còn biến thể đúng giờ/muộn/về sớm/vắng chọn ngẫu nhiên có trọng số (không seed cố định — mỗi lần chạy lại script cho kết quả khác nhau).

### Đối chiếu biến thể yêu cầu

| Biến thể yêu cầu | Có trong dữ liệu hiện tại? |
|---|---|
| Đúng giờ (`status: on_time`/`completed`) | ✅ Có (8 completed + 4 on_time "đang làm việc") |
| Đi muộn (`isLate: true`, `status: late`) | ✅ Có (24 bản ghi, gồm cả muộn thuần và muộn+về sớm) |
| Về sớm (`isEarlyLeave: true`, `status: early_leave`) | ✅ Có (8 bản ghi về sớm thuần) |
| **Vừa đi muộn vừa về sớm** (`isLate` và `isEarlyLeave` cùng `true`) | ✅ Có (12 bản ghi) |
| **Ngày vắng** (ngày làm bắt buộc, không có bản ghi nào) | ✅ Có (2 ngày/người, không tính hôm nay) |
| Đã Check Out | ✅ Có (10/11 ngày mỗi nhân viên) |
| Chưa Check Out (`checkOut: null`, "đang làm việc") | ✅ Có đúng 1 bản ghi/người — ngày 14/7 (hôm nay) |
| Ca ngày / Ca đêm | ✅ Có cả hai, đổi ca giữa 12/7 và 13/7 (xem bằng chứng rotation dưới) |
| Nhóm A | ✅ EMP001, EMP004 |
| Nhóm B | ✅ EMP002, EMP003 |
| Ngày nghỉ tuyệt đối (không có bản ghi, khác với "vắng") | ✅ 12/7/2026 (Chủ Nhật, tuần rotation) |

### Bằng chứng rotation hoạt động đúng (đáng để trình bày khi demo)

Dữ liệu cho thấy rõ **đúng 1 lần đổi ca** trùng khớp hoàn toàn với logic 14 ngày (`rotationStartDate = 2026-06-01`, `rotationDays = 14`, không đổi):

- Từ 2026-07-01 đến 2026-07-12 (thuộc khối rotation thứ 3 kể từ mốc gốc): nhóm A làm **ca đêm**, nhóm B làm **ca ngày**.
- Từ 2026-07-13 (bắt đầu khối rotation thứ 4): nhóm A chuyển sang **ca ngày**, nhóm B chuyển sang **ca đêm**.

→ Vẫn là bằng chứng thực nghiệm thuyết phục để trình bày trực tiếp trong buổi báo cáo, y hệt tinh thần bản đánh giá gốc — chỉ khác mốc ngày cụ thể (giờ rơi vào 12/13 tháng 7 thay vì 27/29 tháng 6).

### Bản ghi bất thường (46.6km, `on_time` sai) đã không còn tồn tại

Bản ghi `2026-07-02_CDjUg...` từng được ghi nhận ở bản đánh giá gốc (check-in cách công ty 46.6km vẫn `on_time`, do `radius` cũ bị đặt 9999999999m) đã bị xoá cùng đợt làm sạch dữ liệu — không còn là rủi ro khi demo.

### Kết luận

**Không cần seed thêm dữ liệu attendance cho phần lịch sử tháng 7.** Việc duy nhất cần làm thêm là **thực hiện 1 lượt Check In/Check Out thật trong lúc demo** (dữ liệu "hôm nay", không phải seed trước) — đúng như đã thống nhất ở phần chuẩn bị demo trước đó, và đúng mục (4) còn lại ở `docs/project/01_BACKLOG.md` mục E.

---

## 5. Leave Requests

**Hiện tại: 0 document — trống hoàn toàn.** Vì mobile chưa có màn tạo đơn nghỉ phép thật (chỉ là placeholder), collection này sẽ mãi trống nếu không bổ sung thủ công qua Firestore Console.

**Quyết định 2026-07-14:** tạm **hoãn** việc seed 3 document mẫu bên dưới — chưa cần cho buổi demo hiện tại (xem `docs/project/01_BACKLOG.md` mục E, mục 1 = Deferred). Nội dung đề xuất dưới đây vẫn giữ nguyên để dùng khi cần.

### Đề xuất bổ sung (đúng schema hiện tại — `LeaveRequestModel`, xem `attendance_admin/lib/features/leave/domain/leave_request_model.dart`)

Schema mỗi document:
```
uid: string
employeeCode: string
startDate: Timestamp
endDate: Timestamp
reason: string
status: string ("pending" | "approved" | "rejected")
adminNote: string
createdAt: Timestamp
updatedAt: Timestamp
```

Đề xuất **đúng 3 document**, dùng lại 3 tài khoản nhân viên đã có sẵn (không tạo người mới):

| # | Trạng thái | uid / employeeCode | startDate | endDate | reason | adminNote |
|---|---|---|---|---|---|---|
| 1 | `pending` | `Nuav1I87ZOg1M0AysReIoaeUv2C2` / EMP002 | 2026-07-10 | 2026-07-11 | "Nghỉ phép việc gia đình" | "" |
| 2 | `approved` | `4Znnqs0bxiXbFeYimTQ5znDL5dG3` / EMP001 | 2026-06-20 | 2026-06-21 | "Khám sức khỏe định kỳ" | "Đã duyệt" |
| 3 | `rejected` | `7VtAl9r6rcRgBGLXcVTtUcNn05l2` / EMP003 | 2026-07-15 | 2026-07-20 | "Du lịch cá nhân" | "Trùng lịch cao điểm sản xuất, đề nghị dời lịch" |

`createdAt`/`updatedAt`: đặt `createdAt` sớm hơn `startDate` vài ngày (hợp lý về mặt câu chuyện — nhân viên xin nghỉ trước); với đơn `pending`, để `updatedAt` bằng `createdAt` (chưa ai xử lý); với `approved`/`rejected`, đặt `updatedAt` sau `createdAt` 1 ngày (thời điểm admin xử lý).

**Cách tạo:** Firestore Console → collection `leave_requests` → Add document → để Firestore tự sinh Document ID (Auto-ID) → nhập đúng các field trên. Không cần sửa code, không đổi schema.

---

## 6. Notifications

**Hiện tại: 0 document — trống.** Đây **không phải thiếu sót cần bổ sung** — dự án chưa có màn hình nào ở cả 2 app để hiển thị lại notification (chỉ có chiều ghi, tự động khi admin duyệt/từ chối đơn nghỉ phép). Nếu bổ sung 3 đơn nghỉ phép ở mục 5 và demo thao tác duyệt/từ chối trực tiếp, collection này sẽ **tự động có dữ liệu** như hệ quả của demo, không cần tạo tay.

**Kết luận: không cần làm gì thêm cho collection này.**

---

## 7. Company Settings

Document `main` hiện tại (đã cập nhật 2026-07-14):

| Field | Giá trị |
|---|---|
| companyName | "UMC VIỆT NAM" |
| latitude / longitude | 21.0285 / 105.7848 |
| radius | **500** (mét) — đã sửa, xem bên dưới |
| dayShiftStart / dayShiftEnd | 08:00 / 20:00 |
| nightShiftStart / nightShiftEnd | 20:00 / 08:00 |
| rotationDays | 14 |
| rotationStartDate | 2026-06-01 (giờ VN, không đổi) |

**Đã xử lý (trước đây `radius = 9999999999` — vô hiệu hoá kiểm tra bán kính):** quyết định 2026-07-14 chọn đổi về giá trị thực tế **500m** để tính năng "giới hạn theo bán kính" chứng minh đúng như thiết kế nếu giảng viên hỏi trực tiếp. **Hệ quả bắt buộc:** buổi demo (và mọi lượt test tay Check In/Check Out — mục 4 ở `docs/project/01_BACKLOG.md` mục E) **phải diễn ra trong vòng 500m quanh toạ độ công ty** (21.0285, 105.7848), khác với trước đây (radius lớn cho phép demo ở bất kỳ đâu). Đây là điểm cần nhớ trước khi ra khỏi phạm vi công ty để test.

**Các field còn lại:** hợp lý, không cần đổi.

---

## 8. Tổng hợp việc cần bổ sung

| # | Việc | Trạng thái (2026-07-14) |
|---|---|---|
| 1 | Thêm 3 document vào `leave_requests` (mục 5) | **Deferred** — chưa cần cho demo hiện tại |
| 2 | Quyết định giữ hay đổi `company_settings.radius` (mục 7) | **Done** — đổi về 500m |
| 3 | Sửa lại `departmentId` của tài khoản admin cho khớp 1 phòng ban thật (mục 2) | **Done** — `dept_ga` |
| 4 | Không cần seed thêm `users`, `departments`, `attendance` | Đã **làm sạch + tạo lại toàn bộ** cho tháng 7/2026 (ngoài phạm vi ban đầu của review này — theo yêu cầu riêng 2026-07-14, xem `docs/project/01_BACKLOG.md` mục E) |
| 5 | Không cần tạo dữ liệu cho `notifications` | Không cần làm gì |

Việc (2)/(3)/(4) đều là thao tác dữ liệu qua script (`tools/firestore_backup/bin/`), không sửa schema/rules; không có thay đổi nào trong `lib/` của 2 app.
