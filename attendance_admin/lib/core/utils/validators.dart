class Validators {
  Validators._();

  static String? required(String? value, {String message = 'Trường này không được để trống'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
    final regex = RegExp(r'^(0|\+84)[0-9]{9,10}$');
    if (!regex.hasMatch(value.trim())) return 'Số điện thoại không hợp lệ';
    return null;
  }

  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.length < length) {
      return '${fieldName ?? 'Trường này'} tối thiểu $length ký tự';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  static String? numeric(String? value, {String message = 'Vui lòng nhập số hợp lệ'}) {
    if (value == null || value.trim().isEmpty) return message;
    if (double.tryParse(value.trim()) == null) return message;
    return null;
  }
}