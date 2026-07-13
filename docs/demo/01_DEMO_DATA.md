# 01 — Review Dữ liệu Demo

**Ngày đánh giá:** 2026-07-06
**Nguồn dữ liệu:** `backup_firestore.json` / `BACKUP_SUMMARY.md` sinh bởi `tools/firestore_backup` (chạy 2026-07-05).
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
| `attendance` | 38 | ✅ Đủ, đã có đầy đủ biến thể cần thiết |
| `leave_requests` | 0 | ❌ Trống — cần bổ sung |
| `notifications` | 0 | 🟡 Trống nhưng không cần bổ sung (chưa có UI hiển thị) |
| `company_settings` | 1 (`main`) | 🟡 Có đủ, nhưng 1 giá trị cần bạn quyết định lại (xem mục 7) |
| `dev_metadata` | 0 (bị permission-denied khi backup) | Không liên quan tới demo — bỏ qua |

---

## 2. Users

**Hiện có 5 tài khoản** — đủ để demo rotation (cả nhóm A lẫn B) và vai trò (cả admin lẫn nhân viên).

| UID (rút gọn) | employeeCode | name | email | department | shiftGroup | role | trạng thái |
|---|---|---|---|---|---|---|---|
| `4Znn...dG3` | EMP001 | Trần Văn Ab | shiroyasha284@gmail.com | dept_ga (Phòng Hành chính – Nhân sự) | A | employee | isActive: true |
| `7VtAl...05l2` | EMP003 | Danh Nhật Tiến | danhnhattien284@gmail.com | dept_pe (Phòng Kỹ thuật sản xuất) | B | employee | isActive: true |
| `CDjUg...JXv2` | EMP004 | Tạ Đình Trí | tadinhtri2004@gmail.com | dept_te (Phòng Kỹ thuật) | A | employee | isActive: true, tạo ngày 2026-06-29 (mới nhất) |
| `Nuav1...C2` | EMP002 | Lê Thị B | dntienktpm2211046@student.ctuet.edu.vn | dept_dx (Phòng Chuyển đổi số) | B | employee | isActive: true |
| `UqyJA...Agh2` | ADMIN001 | Quản trị viên UMC | admin@gmail.com | ⚠️ `dep001` (xem cảnh báo dưới) | A | admin | isActive: true |

**Đánh giá:** Đủ demo. Có cả 2 nhóm A/B, có nhân viên mới thêm gần đây (EMP004) và nhân viên "cũ" (EMP001-003), đủ cho câu chuyện "công ty đã vận hành một thời gian, thêm nhân viên mới".

**Phát hiện cần lưu ý (dữ liệu, không phải bug code):**
- Tài khoản admin (`UqyJA...`) có `departmentId: "dep001"` — giá trị này **không khớp bất kỳ department nào thực sự tồn tại** (tất cả 13 phòng ban thật đều có ID dạng `dept_xxx`, ví dụ `dept_ga`, không có `dep001`). Khi mở màn Nhân viên/Hồ sơ của tài khoản admin, tên phòng ban có thể hiển thị trống hoặc lỗi nhẹ. **Không cần sửa code** — chỉ cần vào màn "Quản Lý Nhân Viên", sửa hồ sơ admin, chọn lại đúng 1 phòng ban có thật trong dropdown (thao tác dữ liệu thuần, 30 giây).
- `Tạ Đình Trí` (EMP004) dùng `avatarUrl` trỏ tới ảnh từ `thanhnien.mediacdn.vn` (ảnh báo, không phải ảnh đại diện thật) — nếu mạng demo chặn hotlink ảnh từ domain lạ, ảnh đại diện có thể không hiển thị (icon vỡ). Rủi ro thấp, chỉ ảnh hưởng thẩm mỹ.

**Không cần bổ sung thêm user nào** — 5 tài khoản hiện có đã đủ minh hoạ mọi vai trò cần thiết.

---

## 3. Departments

**13 phòng ban** — đầy đủ, đúng phong cách tên phòng ban thật của doanh nghiệp (FAC, GA, PD, TE, PE, DX, PMC, PUR1, PUR2, Sales, ACC, QA, Internal Audit). Dropdown chọn phòng ban trong màn "Thêm Nhân Viên Mới" sẽ trông chuyên nghiệp, không trống.

**Đánh giá: ✅ Đủ đẹp để demo, không cần bổ sung.**

---

## 4. Attendance

Đây là phần dữ liệu quan trọng nhất — và **tin tốt: dữ liệu hiện có đã phủ đủ toàn bộ biến thể được yêu cầu**, không cần seed thêm nhiều.

### Đối chiếu biến thể yêu cầu

| Biến thể yêu cầu | Có trong dữ liệu hiện tại? | Ví dụ |
|---|---|---|
| Đúng giờ (`isLate: false`, `status: completed`) | ✅ Có nhiều | `2026-06-17_4Znn...` |
| Đi muộn (`isLate: true`, `status: late`) | ✅ Có nhiều | `2026-06-18_4Znn...` |
| Về sớm (`isEarlyLeave: true`, `status: early_leave`) | ✅ Có nhiều | `2026-06-16_4Znn...` |
| Đã Check Out | ✅ Có (đa số bản ghi) | — |
| Chưa Check Out (`checkOut: null`) | ✅ Có 3 bản ghi | `2026-06-29_4Znn...`, `2026-06-29_Nuav1...`, `2026-07-02_CDjUg...` |
| Ca ngày (`shift: day`) | ✅ Có | EMP001 (nhóm A) trong khối đầu, EMP002 (nhóm B) sau khi đổi ca |
| Ca đêm (`shift: night`) | ✅ Có | EMP002/EMP003 (nhóm B) trong khối đầu, EMP001 (nhóm A) sau khi đổi ca |
| Nhóm A | ✅ Có | EMP001, EMP004 |
| Nhóm B | ✅ Có | EMP002, EMP003 |

### Bằng chứng rotation hoạt động đúng (đáng để trình bày khi demo)

Dữ liệu cho thấy rõ **đúng 1 lần đổi ca** trùng khớp hoàn toàn với logic 14 ngày (`rotationStartDate = 2026-06-01`, `rotationDays = 14`):

- Từ 2026-06-16 đến 2026-06-27 (thuộc khối rotation thứ 2, ngày thứ 14-27 kể từ mốc gốc): nhóm A làm **ca ngày**, nhóm B làm **ca đêm**.
- Từ 2026-06-29 (bắt đầu khối rotation thứ 3, ngày thứ 28 trở đi): nhóm A chuyển sang **ca đêm**, nhóm B chuyển sang **ca ngày**.

→ Đây là bằng chứng thực nghiệm rất thuyết phục để trình bày trực tiếp trong buổi báo cáo ("dữ liệu thật cho thấy đúng ngày dự kiến, hệ thống tự đổi ca giữa 2 nhóm").

### Một bản ghi cần bạn lưu ý riêng

`2026-07-02_CDjUg3doU1XNqolc4peROxLnJXv2` (EMP004): check-in lúc 07:36 sáng giờ Việt Nam, cách công ty **46.6 km**, vẫn được ghi nhận `on_time`, chưa Check Out. Đối chiếu thời điểm (2026-07-02, trước khi đợt sửa Business Date được thực hiện), bản ghi này gần như chắc chắn được tạo bằng **code cũ trước khi sửa bug** — chính là ví dụ thật của loại lỗi đã được phân tích và sửa (tính "on_time" sai cho check-in bất thường giờ, và khoảng cách 46km chỉ "lọt" được vì `radius` đang được đặt rất lớn — xem mục 7). Không phải dữ liệu hỏng cần xoá gấp, nhưng **không nên vô tình demo đúng bản ghi này** như thể nó bình thường — nếu giảng viên hỏi, có thể dùng chính nó làm ví dụ "đây là dữ liệu trước khi sửa bug, minh hoạ tại sao cần Business Date".

### Kết luận

**Không cần seed thêm dữ liệu attendance mới cho phần lịch sử.** Dữ liệu hiện tại (38 bản ghi) đã kể một câu chuyện mạch lạc và đúng logic nghiệp vụ. Việc duy nhất cần làm thêm là **thực hiện 1 lượt Check In/Check Out thật trong lúc demo** (dữ liệu "hôm nay", không phải seed trước) — đúng như đã thống nhất ở phần chuẩn bị demo trước đó.

---

## 5. Leave Requests

**Hiện tại: 0 document — trống hoàn toàn.** Vì mobile chưa có màn tạo đơn nghỉ phép thật (chỉ là placeholder), collection này sẽ mãi trống nếu không bổ sung thủ công qua Firestore Console.

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

Document `main` hiện tại:

| Field | Giá trị |
|---|---|
| companyName | "UMC VIỆT NAM" |
| latitude / longitude | 21.0285 / 105.7848 |
| radius | **9999999999** ⚠️ |
| dayShiftStart / dayShiftEnd | 08:00 / 20:00 |
| nightShiftStart / nightShiftEnd | 20:00 / 08:00 |
| rotationDays | 14 |
| rotationStartDate | 2026-06-01 (giờ VN) |

**Phát hiện quan trọng cần bạn quyết định:** `radius` đang được đặt **9999999999 mét** — tức là kiểm tra "trong bán kính công ty" gần như bị vô hiệu hoá hoàn toàn (bất kỳ vị trí nào trên Trái Đất cũng "trong bán kính"). Bằng chứng: bản ghi `2026-07-02_CDjUg...` (mục 4) check-in thành công dù cách công ty 46.6km.

Đây là **thông tin quan trọng thay đổi đánh giá rủi ro GPS đã nêu ở các tài liệu trước** — với giá trị này, buổi demo **không bị ràng buộc phải diễn ra đúng tại vị trí công ty**, Check In sẽ luôn thành công bất kể demo ở đâu (miễn thiết bị có bật GPS thật, không dùng vị trí giả — hàm `isMocked` vẫn hoạt động độc lập với `radius`).

**Cần bạn quyết định:** giữ nguyên `radius` lớn này (an toàn, không lo về vị trí demo, nhưng nếu giảng viên hỏi trực tiếp "thử đứng xa xem có bị chặn không" thì tính năng sẽ không thể hiện đúng), hay đổi tạm về một giá trị thực tế (ví dụ 500m) trước ngày demo để tính năng "giới hạn theo bán kính" chứng minh được đúng như thiết kế. Đây là thay đổi dữ liệu (không phải code) — có thể đổi qua màn Settings (admin) bất kỳ lúc nào.

**Các field còn lại:** hợp lý, không cần đổi.

---

## 8. Tổng hợp việc cần bổ sung

| # | Việc | Loại | Bắt buộc? |
|---|---|---|---|
| 1 | Thêm 3 document vào `leave_requests` (mục 5) | Bổ sung dữ liệu qua Console | Có — nếu không, màn "Duyệt Nghỉ Phép" sẽ trống khi demo |
| 2 | Quyết định giữ hay đổi `company_settings.radius` (mục 7) | Quyết định + có thể sửa dữ liệu qua Settings | Nên quyết định trước, không bắt buộc đổi |
| 3 | Sửa lại `departmentId` của tài khoản admin cho khớp 1 phòng ban thật (mục 2) | Sửa dữ liệu qua màn Nhân viên | Nên làm, tránh hiển thị lỗi/trống khi demo hồ sơ admin |
| 4 | Không cần seed thêm `users`, `departments`, `attendance` | — | Không cần làm gì |
| 5 | Không cần tạo dữ liệu cho `notifications` | — | Không cần làm gì |

Không có việc nào trong danh sách này là sửa code hay đổi schema — toàn bộ đều là thao tác dữ liệu qua UI có sẵn (Console/Settings/Employee).
