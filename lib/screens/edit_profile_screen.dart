import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _fullNameController.text = state.user.fullName;
      _emailController.text = state.user.email;
      _phoneController.text = state.user.phone ?? '';
      _addressController.text = state.user.address ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          'Chỉnh sửa thông tin cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ProfileLoaded) {
            setState(() {
              _isLoading = false;
            });
          } else if (state is ProfileUpdateSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cập nhật thông tin thành công'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && _fullNameController.text.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Avatar section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primaryGreen,
                                child: Text(
                                  _fullNameController.text.isNotEmpty
                                      ? _fullNameController.text[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(fontSize: 40, color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Thay đổi ảnh đại diện',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Personal Information Form
                    CustomTextField(
                      labelText: 'Họ và Tên',
                      hintText: 'Nhập họ và tên của bạn',
                      controller: _fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      labelText: 'Email',
                      hintText: 'Nhập địa chỉ email của bạn',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại của bạn',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^\+?[0-9]{10,12}$').hasMatch(value)) {
                            return 'Số điện thoại không hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      labelText: 'Địa chỉ',
                      hintText: 'Nhập địa chỉ của bạn',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 40),

                    CustomButton(
                      text: 'Lưu thay đổi',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Cập nhật tên sự kiện trong edit_profile_screen.dart
                          context.read<ProfileBloc>().add(
                            UpdateProfile( // Thay vì ProfileUpdateEvent
                              fullName: _fullNameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              address: _addressController.text,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}