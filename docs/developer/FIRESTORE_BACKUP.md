# Firestore Backup Tool

Công cụ dòng lệnh độc lập tại `tools/firestore_backup/` dùng để chụp lại toàn bộ
dữ liệu Firestore của project `attendance-management-sy-34105`, phục vụ mục
đích demo (có bản snapshot để đối chiếu/khôi phục tay nếu dữ liệu demo bị thay
đổi trước buổi báo cáo).

**Đây KHÔNG phải Firestore Export/Import chính thức của Google** (`gcloud
firestore export`) — cơ chế đó bắt buộc phải có Cloud Storage bucket và gói
Blaze (Billing). Công cụ này chỉ gọi các API đọc dữ liệu thông thường
(Firestore REST API + Firebase Auth REST API), y hệt cách 2 app hiện tại đang
đọc Firestore — không cần Billing, không cần Cloud Storage.

## Cách chạy

```bash
cd tools/firestore_backup
dart pub get   # chỉ cần lần đầu
dart run bin/backup_firestore.dart
```

Chương trình sẽ hỏi email/mật khẩu của một **tài khoản admin** đã có trong hệ
thống (hoặc đọc từ biến môi trường `BACKUP_ADMIN_EMAIL`/`BACKUP_ADMIN_PASSWORD`
nếu đã set sẵn). Thông tin đăng nhập **không được lưu lại ở bất kỳ đâu** —
chỉ dùng để lấy token cho phiên chạy hiện tại.

Kết quả sinh ra ở gốc repo:

- `backup_firestore.json` — toàn bộ dữ liệu (đã bị `.gitignore`, không commit vì chứa dữ liệu thật).
- `BACKUP_SUMMARY.md` — thống kê tổng quan (không chứa dữ liệu cá nhân, có thể commit).

## Cách hoạt động

1. **Quét source code** (`attendance_mobile/lib/**/*.dart` và
   `attendance_admin/lib/**/*.dart`) tìm mọi lời gọi dạng
   `.collection('tên')` bằng regex, gom thành danh sách collection duy nhất.
   Đây là danh sách **không hardcode** — tự động phản ánh đúng những gì code
   thực sự đang dùng tại thời điểm chạy.
2. **Đăng nhập** bằng tài khoản admin qua Firebase Auth REST API
   (`accounts:signInWithPassword`), lấy `idToken`.
3. **Đối chiếu** danh sách collection tìm được trong code với danh sách
   collection **thật sự đang tồn tại** trong Firestore (gọi
   `documents:listCollectionIds` ở gốc database). Nếu lệch nhau (có trong code
   nhưng không tồn tại thật, hoặc tồn tại thật nhưng không thấy trong code),
   ghi cảnh báo vào `BACKUP_SUMMARY.md` — không âm thầm bỏ sót.
4. Với mỗi collection, gọi Firestore REST API đọc toàn bộ document (có phân
   trang qua `pageToken` nếu nhiều hơn 1 trang).
5. Với **mỗi document**, gọi thêm `listCollectionIds` ngay trên đường dẫn
   document đó để phát hiện subcollection thật sự tồn tại (không đoán qua
   code, vì subcollection có thể được tạo với tên động lúc runtime), rồi đệ
   quy đọc tiếp (tối đa 5 cấp, đủ dư cho mọi cấu trúc dữ liệu hợp lý).
6. Convert từng field từ định dạng Firestore REST API sang JSON thuần (xem
   bảng bên dưới), ghi ra `backup_firestore.json`.
7. Tổng hợp số liệu, ghi `BACKUP_SUMMARY.md`.

## Những gì backup được

- Toàn bộ document, toàn bộ field, giữ nguyên document ID, ở mọi collection
  mà tài khoản admin đăng nhập có quyền đọc theo `firestore.rules` hiện tại.
- Subcollection ở bất kỳ độ sâu nào (tối đa 5 cấp).
- Collection rỗng vẫn được ghi vào JSON dưới dạng object rỗng `{}`.
- Chuyển đổi kiểu dữ liệu đầy đủ:

  | Kiểu Firestore | Chuyển thành trong JSON |
  |---|---|
  | Timestamp | Chuỗi ISO 8601 |
  | GeoPoint | `{ "latitude": ..., "longitude": ... }` |
  | DocumentReference | Đường dẫn tương đối dạng chuỗi (vd `"users/abc123"`) |
  | Array | List, convert đệ quy từng phần tử |
  | Map (field lồng nhau) | Object, convert đệ quy từng field |
  | Bytes | Chuỗi base64 |

- Subcollection được biểu diễn như một entry riêng trong `collections`, khoá
  theo đường dẫn đầy đủ (vd `"users/abc123/logs"`) thay vì lồng vào bên trong
  document — tránh nhầm lẫn với field thật, giữ JSON dễ đọc/dễ parse lại.

## Những gì KHÔNG thể backup được

- **Không bỏ qua được Firestore Security Rules.** Công cụ đăng nhập như một
  tài khoản admin bình thường (không dùng Service Account), nên chỉ đọc được
  đúng những gì `firestore.rules` cho phép admin đọc. Nếu về sau có collection
  mới mà rules chưa cấp quyền đọc, backup cho collection đó sẽ rỗng và được
  ghi rõ trong mục "Cảnh báo đối chiếu"/"permission-denied" của
  `BACKUP_SUMMARY.md` — không hiển thị nhầm thành "collection thực sự rỗng".
- **Không backup được Firebase Authentication** (danh sách tài khoản
  email/password, UID) — đây là dữ liệu nằm ngoài Firestore, API đọc dữ liệu
  Firestore không truy cập được. Muốn backup danh sách user Auth cần Admin SDK
  (`firebase auth:export`), nằm ngoài phạm vi công cụ này.
- **Không backup được Cloud Storage** (nếu sau này project có lưu file/ảnh) —
  công cụ chỉ đọc Firestore, không đọc Storage.
- **Không phát hiện được collection được tham chiếu bằng biến động**
  (vd `.collection(someVariable)` thay vì `.collection('users')`) trong bước
  quét source code — nhưng bước đối chiếu với `listCollectionIds` ở mục 3 phía
  trên sẽ vẫn bắt được collection đó nếu nó thực sự tồn tại dữ liệu, và ghi
  cảnh báo tương ứng.
- **Chỉ backup (đọc), không phục hồi (ghi ngược lại Firestore).** Nếu cần
  khôi phục dữ liệu từ file `backup_firestore.json`, đó là một công cụ/yêu cầu
  riêng, chưa được xây dựng.
- Không chạy được trực tiếp trong trình duyệt/app di động — đây là script
  Dart thuần chạy qua `dart run`, cần máy có cài Dart SDK.

## Ghi chú bảo mật

- `backup_firestore.json` chứa dữ liệu thật (email nhân viên, số điện thoại,
  toạ độ GPS...) nên đã được thêm vào `.gitignore` — **không commit file
  này**.
- Web API Key hardcode trong script (`_webApiKey`) **không phải secret** —
  đây là giá trị public dùng trong mọi client Firebase app (đã có sẵn trong
  `attendance_admin/lib/firebase_options.dart`). An toàn của hệ thống nằm ở
  `firestore.rules`, không nằm ở việc giấu key này.
- Mật khẩu tài khoản admin nhập lúc chạy **không được lưu lại** ở bất kỳ file
  hay biến môi trường lâu dài nào — chỉ tồn tại trong bộ nhớ của tiến trình
  đang chạy.
