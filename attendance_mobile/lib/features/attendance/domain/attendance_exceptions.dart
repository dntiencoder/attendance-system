/// Ném khi Check In được gọi sau khi ca làm việc đã kết thúc (tính vắng mặt).
/// Kiểu dữ liệu riêng thay vì so khớp `.toString()` bằng chuỗi text (TD-18,
/// docs/project/01_BACKLOG.md) — nội dung câu chữ có thể đổi mà không làm
/// gãy logic nhận diện loại lỗi.
class ShiftEndedException implements Exception {
  final String message;
  const ShiftEndedException(this.message);

  @override
  String toString() => message;
}
