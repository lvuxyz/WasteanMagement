import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import 'registration_form_fields.dart';
import 'registration_submit_button.dart';
import 'login_link.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final registrationTitle = l10n.registrationTitle;
    final registrationDescription = l10n.registrationDescription;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                registrationTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                registrationDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              
              // Form fields
              RegistrationFormFields(
                fullNameController: _fullNameController,
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                phoneController: _phoneController,
                addressController: _addressController,
              ),
              
              const SizedBox(height: 30),
              
              // Submit button
              RegistrationSubmitButton(
                formKey: _formKey,
                fullNameController: _fullNameController,
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                phoneController: _phoneController,
                addressController: _addressController,
              ),
              
              const SizedBox(height: 20),
              
              // Login link
              const LoginLink(),
            ],
          ),
        ),
      ),
    );
  }
} 

