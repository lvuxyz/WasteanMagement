import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_button.dart';
import '../generated/l10n.dart';

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
    final l10n = S.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          l10n.changePassword,
          style: const TextStyle(color: Colors.white),
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
                Text(
                  l10n.passwordRequirements,
                  style: const TextStyle(
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
                    labelText: l10n.currentPassword,
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
                      return l10n.currentPasswordRequired;
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
                    labelText: l10n.newPassword,
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
                      return l10n.newPasswordRequired;
                    }
                    if (value.length < 8) {
                      return l10n.passwordMinLength;
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return l10n.passwordRequireUppercase;
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return l10n.passwordRequireLowercase;
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return l10n.passwordRequireNumber;
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return l10n.passwordRequireSpecial;
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
                    labelText: l10n.confirmNewPassword,
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
                      return l10n.confirmPasswordRequired;
                    }
                    if (value != _newPasswordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Password strength indicator
                _buildPasswordStrengthIndicator(),

                const SizedBox(height: 40),

                // Submit Button
                CustomButton(
                  text: l10n.changePassword,
                  isLoading: _isLoading,
                  onPressed: _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final l10n = S.of(context);
    final String password = _newPasswordController.text;
    
    // Mặc định là yếu
    String strengthText = l10n.passwordStrengthWeak;
    Color strengthColor = Colors.red;
    double strengthLevel = 0.25;
    
    if (password.length >= 8) {
      // Mật khẩu có đủ độ dài cơ bản
      int strength = 0;
      
      // Kiểm tra các yếu tố phức tạp
      if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
      if (RegExp(r'[a-z]').hasMatch(password)) strength++;
      if (RegExp(r'[0-9]').hasMatch(password)) strength++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
      
      // Đánh giá độ mạnh dựa trên số yếu tố đạt được
      if (strength == 1) {
        strengthText = l10n.passwordStrengthWeak;
        strengthColor = Colors.red;
        strengthLevel = 0.25;
      } else if (strength == 2) {
        strengthText = l10n.passwordStrengthMedium;
        strengthColor = Colors.orange;
        strengthLevel = 0.5;
      } else if (strength == 3) {
        strengthText = l10n.passwordStrengthGood;
        strengthColor = Colors.green;
        strengthLevel = 0.75;
      } else if (strength == 4) {
        strengthText = l10n.passwordStrengthStrong;
        strengthColor = AppColors.primaryGreen;
        strengthLevel = 1.0;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passwordStrength,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strengthLevel,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          strengthText,
          style: TextStyle(
            color: strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _changePassword() async {
    final l10n = S.of(context);
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API request
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.passwordChangedTitle),
            content: Text(l10n.passwordChangedMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    }
  }
}