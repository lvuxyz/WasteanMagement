import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: const Text(
          'Thay đổi mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Security icon at top
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Brief instruction text
                const Text(
                  'Để bảo mật tài khoản của bạn, vui lòng tạo mật khẩu mạnh với ít nhất 8 ký tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Current Password
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu hiện tại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 8) {
                      return 'Mật khẩu phải có ít nhất 8 ký tự';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 chữ thường';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 số';
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm New Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Password strength indicator
                _buildPasswordStrengthIndicator(),

                const SizedBox(height: 40),

                // Submit button
                CustomButton(
                  text: 'Cập nhật mật khẩu',
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implement actual password change logic
                      _mockChangePassword();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This is just for UI mockup - would be replaced with real API call
  void _mockChangePassword() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu đã được cập nhật thành công'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // Go back to previous screen
      Navigator.pop(context);
    });
  }

  Widget _buildPasswordStrengthIndicator() {
    String password = _newPasswordController.text;
    double strength = 0;
    String label = 'Rất yếu';
    Color color = Colors.red;

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check password length
    if (password.length >= 8) strength += 0.25;

    // Check for uppercase letters
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;

    // Check for lowercase letters
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.25;

    // Check for numbers
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;

    // Check for special characters
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.10;

    // Determine label and color based on strength
    if (strength <= 0.25) {
      label = 'Rất yếu';
      color = Colors.red;
    } else if (strength <= 0.5) {
      label = 'Yếu';
      color = Colors.orange;
    } else if (strength <= 0.75) {
      label = 'Khá tốt';
      color = Colors.amber;
    } else {
      label = 'Mạnh';
      color = AppColors.primaryGreen;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Độ mạnh mật khẩu:',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}