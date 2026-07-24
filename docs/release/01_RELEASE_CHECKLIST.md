# 01_RELEASE_CHECKLIST.md

**Mục tiêu:** Checklist thao tác thuần tuý cho ngày build release candidate — không giải thích lý do (lý do đã có ở `docs/project/PROJECT_MASTER_PLAN.md` Phase E), chỉ để tick khi thực hiện.

**Phạm vi:** Từ lúc bắt đầu build tới khi có git tag cụ thể.

**Khi nào dùng:** Sprint 7 (`docs/project/02_SPRINT.md`), ngay trước Milestone M3 (Release Candidate) → M4 (Source Freeze).

**Liên kết:** Điều kiện bắt đầu/hoàn thành/rủi ro đầy đủ — `docs/project/PROJECT_MASTER_PLAN.md` Phase E; trạng thái dữ liệu Firestore cần đạt trước khi release — `docs/project/04_DATA_FREEZE_PLAN.md`.

---

## Code

```
☑ Toàn bộ task Sprint 1-6 (docs/project/02_SPRINT.md) ở trạng thái Done hoặc quyết định dừng có chủ đích
☑ git status sạch cho attendance_mobile/, attendance_admin/, firestore.rules, firestore.indexes.json (không có thay đổi chưa commit) (2026-07-24)
```

## Flutter Analyze

```
☑ flutter analyze (attendance_mobile) — 0 issue (2026-07-24)
☑ flutter analyze (attendance_admin) — 0 issue (2026-07-24)
```

## Flutter Test

```
☑ flutter test (attendance_mobile) — pass 100% (19/19, 2026-07-24)
☑ flutter test (attendance_admin) — pass 100% (1/1, 2026-07-24)
```

## Manual Test

```
☑ docs/testing/01_TEST_PLAN.md — toàn bộ mục B, C, D, E ở trạng thái Pass (không còn "Chưa chạy"/"Fail") — ngoại trừ ~~TD01-03~~ **Blocked có chủ đích** (quyết định 2026-07-24, không có thiết bị thứ 2), không chặn Release
☑ ~~RG-04 (docs/testing/01_TEST_PLAN.md) — đã chạy ít nhất 1 lượt bằng thời gian thực, không chỉ Demo Time~~ — **Skipped có chủ đích** (quyết định 2026-07-23, xem `01_TEST_PLAN.md`), không chặn Release
```

## Firestore

```
☑ Xác nhận dữ liệu demo/thật ở đúng trạng thái theo docs/project/04_DATA_FREEZE_PLAN.md (mức freeze phù hợp cho Release) — radius 9999999 → 100m thật (2026-07-24)
☑ Không còn document rác từ quá trình test — xoá 7 bản ghi attendance ngày tương lai do Demo Time sinh ra (2026-07-24)
```

## Firebase Rules

```
☑ git status -- firestore.rules sạch (đúng bản đã commit) (2026-07-24)
☑ firebase deploy --only firestore:rules đã chạy, xác nhận trên Firebase Console đúng bản mới nhất — deploy từ đợt đóng FEAT-05 (2026-07-22, commit `710ced9`), xác nhận lại không lệch (2026-07-24)
```

## Indexes

```
☑ firestore.indexes.json khớp với các query thực tế đang dùng — đối chiếu trực tiếp qua `firebase firestore:indexes`, khớp 100% (2026-07-24)
☑ firebase deploy --only firestore:indexes đã chạy (đợt đóng FEAT-05, xác nhận lại 2026-07-24)
```

## APK

```
☑ flutter build apk --release (hoặc appbundle) tại attendance_mobile/ chạy thành công (2026-07-24, 54.2MB)
☐ Cài thử APK trên thiết bị thật, mở app, đăng nhập thử ít nhất 1 tài khoản — chờ bạn tự xác nhận
```

## Web

```
☑ flutter build web tại attendance_admin/ chạy thành công (2026-07-24)
☐ Serve thử bản build, đăng nhập thử admin — đã deploy thật lên https://umc-attendance-admin.web.app (HTTP 200 xác nhận), chờ bạn tự đăng nhập thử
```

## Git Tag

```
☑ Quyết định tên tag — **v1.0.0-rc1** (2026-07-24)
☑ git tag v1.0.0-rc1 tại commit `a1aa641` (2026-07-24)
```

## Version

```
☑ Quyết định chính sách version — giữ nguyên **1.0.0+1** (2026-07-24, đây là Release Candidate đầu tiên, chưa từng phát hành trước đó nên không cần đổi số)
☑ attendance_mobile/pubspec.yaml — 1.0.0+1 (không đổi, theo quyết định trên)
☑ attendance_admin/pubspec.yaml — 1.0.0+1 (không đổi, theo quyết định trên)
```

---

Sau khi tick hết: cập nhật `docs/project/03_PROGRESS.md` (đạt Milestone M3), sau đó tuyên bố Source Freeze theo `docs/project/PROJECT_MASTER_PLAN.md` Phase F (M4).
