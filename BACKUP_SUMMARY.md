# Backup Summary

Tự động sinh bởi `tools/firestore_backup`. Không sửa tay file này — chạy lại tool để cập nhật.

- **Thời điểm backup:** 2026-07-14T11:11:20.008387Z
- **Tổng số collection gốc:** 7
- **Tổng số subcollection:** 0
- **Tổng số document (gồm cả subcollection):** 71
- **Collection nhiều document nhất:** `attendance` (52 document)

## Chi tiết theo collection gốc

| Collection | Số document |
|---|---|
| `attendance` | 52 |
| `company_settings` | 1 |
| `departments` | 13 |
| `dev_metadata` | 0 |
| `leave_requests` | 0 |
| `notifications` | 0 |
| `users` | 5 |

## Collection rỗng

- `dev_metadata`
- `leave_requests`
- `notifications`

## Cảnh báo đối chiếu

- Có trong code nhưng không thấy tồn tại thật trong Firestore: `users`, `company_settings`, `dev_metadata`, `departments`, `attendance`, `leave_requests`, `notifications`
- Bị từ chối quyền đọc (permission-denied), backup rỗng cho collection này: `dev_metadata`
