# 01_RELEASE_CHECKLIST.md

**Mục tiêu:** Checklist thao tác thuần tuý cho ngày build release candidate — không giải thích lý do (lý do đã có ở `docs/project/PROJECT_MASTER_PLAN.md` Phase E), chỉ để tick khi thực hiện.

**Phạm vi:** Từ lúc bắt đầu build tới khi có git tag cụ thể.

**Khi nào dùng:** Sprint 7 (`docs/project/02_SPRINT.md`), ngay trước Milestone M3 (Release Candidate) → M4 (Source Freeze).

**Liên kết:** Điều kiện bắt đầu/hoàn thành/rủi ro đầy đủ — `docs/project/PROJECT_MASTER_PLAN.md` Phase E; trạng thái dữ liệu Firestore cần đạt trước khi release — `docs/project/04_DATA_FREEZE_PLAN.md`.

---

## Code

```
☐ Toàn bộ task Sprint 1-6 (docs/project/02_SPRINT.md) ở trạng thái Done hoặc quyết định dừng có chủ đích
☐ git status sạch cho attendance_mobile/, attendance_admin/, firestore.rules, firestore.indexes.json (không có thay đổi chưa commit)
```

## Flutter Analyze

```
☐ flutter analyze (attendance_mobile) — 0 issue, hoặc issue còn lại đã ghi lý do giữ trong docs/testing/02_BUG_TRACKER.md
☐ flutter analyze (attendance_admin) — 0 issue, hoặc tương tự
```

## Flutter Test

```
☐ flutter test (attendance_mobile) — pass 100%
☐ flutter test (attendance_admin) — pass 100%
```

## Manual Test

```
☐ docs/testing/01_TEST_PLAN.md — toàn bộ mục B, C, D, E ở trạng thái Pass (không còn "Chưa chạy"/"Fail")
☐ RG-04 (docs/testing/01_TEST_PLAN.md) — đã chạy ít nhất 1 lượt bằng thời gian thực, không chỉ Demo Time
```

## Firestore

```
☐ Xác nhận dữ liệu demo/thật ở đúng trạng thái theo docs/project/04_DATA_FREEZE_PLAN.md (mức freeze phù hợp cho Release)
☐ Không còn document rác từ quá trình test (tài khoản test tạm, đơn nghỉ phép test tạm) trong dữ liệu dùng để release/demo
```

## Firebase Rules

```
☐ git status -- firestore.rules sạch (đúng bản đã commit)
☐ firebase deploy --only firestore:rules đã chạy, xác nhận trên Firebase Console đúng bản mới nhất
```

## Indexes

```
☐ firestore.indexes.json khớp với các query thực tế đang dùng (không phát sinh FAILED_PRECONDITION khi test)
☐ firebase deploy --only firestore:indexes đã chạy
```

## APK

```
☐ flutter build apk --release (hoặc appbundle) tại attendance_mobile/ chạy thành công
☐ Cài thử APK trên thiết bị thật, mở app, đăng nhập thử ít nhất 1 tài khoản
```

## Web

```
☐ flutter build web tại attendance_admin/ chạy thành công
☐ Serve thử bản build (flutter run -d chrome --release hoặc serve tĩnh), đăng nhập thử admin
```

## Git Tag

```
☐ Quyết định tên tag (ví dụ v1.0.0-rc1) — nhất quán với Version bên dưới
☐ git tag <tên tag> tại đúng commit đã build
```

## Version

```
☐ Quyết định chính sách version (hiện đứng yên ở 1.0.0+1 từ đầu dự án — xem docs/decision/01_DECISION_LOG.md nếu cần ghi lại lý do chọn số mới)
☐ Cập nhật version trong attendance_mobile/pubspec.yaml
☐ Cập nhật version trong attendance_admin/pubspec.yaml
```

---

Sau khi tick hết: cập nhật `docs/project/03_PROGRESS.md` (đạt Milestone M3), sau đó tuyên bố Source Freeze theo `docs/project/PROJECT_MASTER_PLAN.md` Phase F (M4).
