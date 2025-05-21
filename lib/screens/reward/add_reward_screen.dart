import 'package:flutter/material.dart';
import 'package:wasteanmagement/services/auth_service.dart';
import 'package:wasteanmagement/services/reward_service.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/loading_indicator.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRewardScreen extends StatefulWidget {
  const AddRewardScreen({Key? key}) : super(key: key);

  @override
  _AddRewardScreenState createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  
  int? _selectedUserId;
  List<dynamic> _users = [];
  bool _isLoading = false;
  bool _isCheckingAdmin = true;
  bool _isAdmin = false;
  String _message = '';
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadUsers();
  }
  
  @override
  void dispose() {
    _pointsController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAdminStatus() async {
    setState(() {
      _isCheckingAdmin = true;
    });
    
    final isAdmin = await _authService.isAdmin();
    
    setState(() {
      _isAdmin = isAdmin;
      _isCheckingAdmin = false;
    });
    
    if (!isAdmin) {
      // Show unauthorized message
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền truy cập chức năng này'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.users),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        setState(() {
          _users = data['data'] as List<dynamic>;
        });
      } else {
        setState(() {
          _message = 'Lỗi: ${data['message'] ?? 'Không thể lấy danh sách người dùng'}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });
      
      try {
        final rewardService = RewardService();
        int? transactionId;
        
        if (_transactionIdController.text.isNotEmpty) {
          transactionId = int.tryParse(_transactionIdController.text);
        }
        
        final reward = await rewardService.createReward(
          _selectedUserId!,
          int.parse(_pointsController.text),
          transactionId: transactionId,
        );
        
        setState(() {
          _message = 'Thêm điểm thưởng thành công!';
          _selectedUserId = null;
          _pointsController.clear();
          _transactionIdController.clear();
        });
      } catch (e) {
        setState(() {
          _message = 'Lỗi: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isCheckingAdmin) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }
    
    if (!_isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn không có quyền truy cập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chức năng này chỉ dành cho quản trị viên',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Điểm Thưởng Thủ Công'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_message.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _message.contains('thành công') 
                        ? Colors.green.shade100 
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('thành công') 
                          ? Colors.green.shade800 
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Chọn người dùng',
                  border: OutlineInputBorder(),
                ),
                value: _selectedUserId,
                items: _users.map((user) {
                  final userId = user['user_id'] ?? user['id'];
                  final username = user['username'] ?? '';
                  final email = user['email'] ?? '';
                  final fullName = user['full_name'] ?? user['name'] ?? '';
                  
                  String displayName = fullName.isNotEmpty 
                      ? fullName 
                      : (username.isNotEmpty ? username : 'User $userId');
                  
                  return DropdownMenuItem<int>(
                    value: userId,
                    child: Text(
                      '$displayName${email.isNotEmpty ? ' ($email)' : ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn người dùng';
                  }
                  return null;
                },
                isExpanded: true,
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(
                  labelText: 'Số điểm',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điểm';
                  }
                  final points = int.tryParse(value);
                  if (points == null) {
                    return 'Số điểm phải là số';
                  }
                  if (points <= 0) {
                    return 'Số điểm phải là số dương';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _transactionIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Giao dịch (tùy chọn)',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập ID giao dịch nếu có',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final transactionId = int.tryParse(value);
                    if (transactionId == null) {
                      return 'ID giao dịch phải là số';
                    }
                    if (transactionId <= 0) {
                      return 'ID giao dịch phải là số dương';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Thêm Điểm Thưởng',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 