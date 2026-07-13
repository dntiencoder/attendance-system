# 02_BUG_TRACKER.md

**Mục tiêu:** Theo dõi các bug thật (defect có kịch bản tái hiện cụ thể), tách biệt khỏi nợ kỹ thuật/cải tiến chung (những thứ đó sống ở `docs/project/01_BACKLOG.md` mục B).

**Phạm vi:** Bug đã biết từ `REVIEW.md` (đã fix hoặc còn mở) + bug mới phát hiện trong quá trình Phase B/C trở đi.

**Khi nào dùng:** Mỗi khi phát hiện hành vi sai khi test (`docs/testing/01_TEST_PLAN.md`) hoặc dùng thực tế — thêm dòng mới ngay, không đợi tổng hợp cuối kỳ.

**Liên kết:** Nguồn gốc — `REVIEW.md` §15 "Potential bugs" + các mục Critical/High khác; đã fix theo — `ROADMAP.md`; kịch bản test liên quan — `docs/testing/01_TEST_PLAN.md`.

---

## Chú giải cột

- **Severity:** Critical / High / Medium / Low.
- **Status:** `Open` / `In Progress` / `Fixed` / `Won't Fix` (có lý do, ví dụ nằm trong phạm vi cố ý loại trừ — xem `docs/decision/01_DECISION_LOG.md`).
- **Regression:** ID test case tương ứng ở `docs/testing/01_TEST_PLAN.md` dùng để xác nhận không tái phát.

---

## Đã Fixed (trước khi tài liệu này được tạo — 2026-07-13)

| Bug ID | Severity | Status | Module | Description | Fix | Regression |
|---|---|---|---|---|---|---|
| BUG-001 | Critical | Fixed | Settings/Rotation | Lưu cấu hình ở Admin Settings xoá mất `rotationStartDate` → reset toàn bộ chu kỳ xoay ca (REVIEW 15.1) | Round-trip `rotationStartDate` khi build `CompanySettingsModel` (commit `0f63721`, P1-02) | MT-11, MT-12 |
| BUG-002 | High | Fixed | Attendance (mobile) | `AttendanceModel.fromFirestore` ép kiểu cứng `Timestamp` → crash toàn bộ danh sách nếu 1 document thiếu field (REVIEW 15.2) | Null-safety + try-catch per-document (commit `7b1e524`, P1-04) | EC-02 |
| BUG-003 | High | Fixed | Settings (admin) | `double.parse`/`int.parse` không try-catch, validator chỉ kiểm tra rỗng (REVIEW 8.1) | Dùng `Validators.numeric` + bọc try-catch (commit `ef37704`, P1-03) | — |
| BUG-004 | Medium-High | Fixed | Router (admin) | Route dev ẩn `/dev/seed-departments` biên dịch vào bản production (REVIEW 7.2/13.5) | Bọc `kDebugMode` (commit `317c317`, P1-06) | MT-23 (tương tự, khác route) |
| BUG-005 | Critical | Fixed | Dev scripts (mobile) | Credential/UID/email thật hardcode trong source (REVIEW 13.1) | Thay bằng `String.fromEnvironment` placeholder (commit `507df9a`, P1-01) | — |
| BUG-006 | High | Fixed | Employee (admin) | Mật khẩu mặc định `123456` gợi ý sẵn cho nhân viên mới (REVIEW 13.4) | Sinh mật khẩu ngẫu nhiên + copy-to-clipboard (commit `f6cb032`, P1-07) | — |
| BUG-007 | High | Fixed | Firestore | Không có Security Rules nào trong repo để xác minh phân quyền server-side (REVIEW 4.2) | Viết + deploy `firestore.rules` (commit `55da6da`, P1-05) | MT-14 đến MT-17 |

## Đang Open

| Bug ID | Severity | Status | Module | Description | Fix đề xuất | Regression (khi fix) |
|---|---|---|---|---|---|---|
| BUG-008 | High | Open | Attendance (mobile) | Race condition lý thuyết: `checkIn()` kiểm tra `existing.exists` rồi mới `.set()`, không dùng transaction — 2 request gần như đồng thời có thể ghi đè nhau thay vì báo lỗi "đã check-in" (REVIEW 15.5) | `runTransaction()` (backlog TD-01) | MT-05 |
| BUG-009 | High | Open | Attendance/Home (mobile) | Hai cơ chế xác định lịch làm việc song song không đồng bộ: `WorkScheduleHelper` hardcode `2026-06-01`, `CompanySettingsModel.getCurrentShift()` đọc `rotationStartDate` từ Firestore (REVIEW 1.4) | Đồng bộ 1 nguồn mốc ngày duy nhất (backlog TD-03) | MT-11, MT-12 |
| BUG-010 | Medium | Open | Employee (admin) | `deleteEmployee` không kiểm tra `isActive` trước khi xoá — dễ xoá nhầm hồ sơ đang hoạt động (REVIEW liên quan 4.5) | Ràng buộc UI chỉ cho xoá khi `isActive==false` (backlog TD-02) | (test tay thủ công khi fix) |
| BUG-011 | Medium | Open | Auth (mobile) | `.toUpperCase()` không rõ lý do trên email trước khi đăng nhập, không khớp cách admin xử lý (REVIEW 15.3) | Xoá `.toUpperCase()`, giữ `.trim()` (backlog TD-05) | (test tay thủ công khi fix) |
| BUG-012 | Low | Open | Leave (admin) | `request.startDate?.day` dùng `?.` thừa trên field không nullable (REVIEW 15.4) | Xoá toán tử thừa (backlog TD-16) | — |

| BUG-013 | Medium | Open | Router (mobile) / Demo Time System | Route `/demo-center` trong `app_router.dart:52-56` không bọc `kDebugMode` — chỉ ẩn lối vào UI (tile ở `profile_screen.dart`), route vẫn tồn tại trong router ở bản release. Phát hiện lúc chạy MT-23 (`docs/testing/01_TEST_PLAN.md`) khi thực hiện FEAT-04. Không lộ dữ liệu/không đổi được business logic thật (`ClockService` tự chặn khi `!kDebugMode`), nhưng không đúng thiết kế đã thống nhất và không nhất quán với precedent P1-06 (`attendance_admin` bọc cả route registration, không chỉ UI entry) | Bọc `if (kDebugMode) GoRoute(path: '/demo-center', ...)` giống hệt pattern P1-06 | MT-23 |

| BUG-014 | Medium | Open | GPS (mobile) / `checkIn()` | `GpsService.getCurrentPosition()` (`gps_service.dart:27-32`, `timeLimit: Duration(seconds: 15)`) ném `TimeoutException` thô, không được bọc thành thông báo tiếng Việt thân thiện. Ban đầu nghi do double-tap gây tranh chấp 2 yêu cầu GPS đồng thời (TD01-02), nhưng cùng lỗi cũng tái hiện ở **1 lần gọi đơn lẻ, không đồng thời** khi test offline (TD01-04/TD01-08) — cho thấy nguyên nhân có khả năng cao hơn là **GPS không lấy được vị trí trong 15s ở điều kiện tín hiệu/mạng hiện tại** (trong nhà, hoặc định vị độ chính xác cao phụ thuộc hỗ trợ mạng khi offline), không hẳn do concurrency. Chặn cả TD01-02, TD01-03, TD01-04, TD01-08 (`docs/testing/01_TEST_PLAN.md`) — không lần nào trong số này chạm tới được đoạn code Firestore của TD-01 vì bị dừng lại ở bước GPS trước đó. Ngoài phạm vi file được duyệt sửa cho TD-01 (`gps_service.dart` không nằm trong danh sách) | Chưa đề xuất — cần điều tra thêm ở điều kiện tín hiệu GPS tốt hơn để tách bạch giữa "chậm do tín hiệu yếu" và "lỗi concurrency thật"; tối thiểu nên bọc `TimeoutException` bằng thông báo thân thiện trong `GpsService.getCurrentPosition()` | TD01-02, TD01-04, TD01-08 |

## Mẫu thêm bug mới

```
| BUG-0XX | <Critical/High/Medium/Low> | Open | <module> | <mô tả + cách tái hiện> | <chưa có / đề xuất> | <ID test liên quan hoặc "chưa có"> |
```

Bug mới phát hiện trong Sprint 4-5 (`docs/project/02_SPRINT.md`, chạy `docs/testing/01_TEST_PLAN.md`) hoặc trong Demo Time System (12 file chưa từng test tay — khả năng cao phát sinh bug mới ở đây) sẽ được thêm vào bảng "Đang Open" theo đúng mẫu trên, đánh số tiếp từ `BUG-013`.
