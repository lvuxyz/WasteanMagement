class Validators {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return fieldName;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName phải là số';
    }
    return null;
  }

  static String? validateCoordinate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    final coordinate = double.tryParse(value);
    if (coordinate == null) {
      return '$fieldName phải là số thực';
    }
    
    if (fieldName == 'vĩ độ' && (coordinate < -90 || coordinate > 90)) {
      return 'Vĩ độ phải nằm trong khoảng -90 đến 90';
    }
    
    if (fieldName == 'kinh độ' && (coordinate < -180 || coordinate > 180)) {
      return 'Kinh độ phải nằm trong khoảng -180 đến 180';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    final phoneRegExp = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }
} 