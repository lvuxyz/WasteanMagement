import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../models/waste_type_model.dart';
import '../../repositories/user_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/snackbar_utils.dart';
import 'dart:developer' as developer;
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_switch_field.dart';

class WasteTypeEditScreen extends StatefulWidget {
  final int? wasteTypeId; // Null for create, not null for update

  const WasteTypeEditScreen({
    Key? key,
    this.wasteTypeId,
  }) : super(key: key);

  @override
  State<WasteTypeEditScreen> createState() => _WasteTypeEditScreenState();
}

class _WasteTypeEditScreenState extends State<WasteTypeEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _handlingInstructionsController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _recentPointsController = TextEditingController();
  
  String _selectedCategory = 'Tái chế';
  bool _isRecyclable = true;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isAdmin = false; // Default to false until we check user role
  List<String> _examples = [''];
  
  // Available icon options could be extended
  final Map<String, IconData> _availableIcons = {
    'Chai nhựa': Icons.local_drink_outlined,
    'Giấy': Icons.description_outlined,
    'Kim loại': Icons.settings_outlined,
    'Thủy tinh': Icons.wine_bar_outlined,
    'Thực phẩm': Icons.restaurant_outlined,
    'Pin': Icons.battery_alert_outlined,
    'Điện tử': Icons.smartphone_outlined,
    'Quần áo': Icons.checkroom_outlined,
    'Khác': Icons.category_outlined,
  };

  String _selectedIconKey = 'Chai nhựa';
  Color _selectedColor = Colors.blue;

  // Available color options
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.grey,
    Colors.lightBlue,
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminPrivileges();
    
    _isEditing = widget.wasteTypeId != null;

    if (_isEditing) {
      // Load waste type details for editing
      context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _handlingInstructionsController.dispose();
    _unitPriceController.dispose();
    _unitController.dispose();
    _recentPointsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Populate form with existing data
  void _populateForm(WasteType wasteType) {
    _nameController.text = wasteType.name;
    _descriptionController.text = wasteType.description;
    _handlingInstructionsController.text = wasteType.handlingInstructions;
    _unitPriceController.text = wasteType.unitPrice.toString();
    _unitController.text = wasteType.unit;
    _recentPointsController.text = wasteType.recentPoints;
    _selectedCategory = wasteType.category;
    _isRecyclable = wasteType.recyclable;

    // Find icon and color
    _selectedIconKey = _availableIcons.entries
        .firstWhere(
          (entry) => entry.value == wasteType.icon,
      orElse: () => MapEntry('Khác', Icons.category_outlined),
    )
        .key;

    _selectedColor = wasteType.color;

    // Set examples
    _examples = List.from(wasteType.examples);
    if (_examples.isEmpty) {
      _examples.add('');
    }
  }

  void _addExample() {
    setState(() {
      _examples.add('');
    });
    
    // Scroll to the new field after rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeExample(int index) {
    if (_examples.length > 1) {
      setState(() {
        _examples.removeAt(index);
      });
    }
  }

  void _updateExample(int index, String value) {
    setState(() {
      _examples[index] = value;
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    // Validate examples
    final finalExamples = _examples.where((example) => example.isNotEmpty).toList();
    if (finalExamples.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cần nhập ít nhất một ví dụ'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    
    return true;
  }

  void _submitForm() {
    if (!_validateForm()) return;
    
    final finalExamples = _examples.where((example) => example.isNotEmpty).toList();
    
    double unitPrice = 0;
    try {
      unitPrice = double.parse(_unitPriceController.text);
    } catch (e) {
      // Default to 0 if parsing fails
    }

    setState(() {
      _isLoading = true;
    });

    if (_isEditing) {
      context.read<WasteTypeBloc>().add(UpdateWasteType(
        WasteType(
          id: widget.wasteTypeId!,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          icon: _availableIcons[_selectedIconKey]!,
          color: _selectedColor,
          handlingInstructions: _handlingInstructionsController.text.trim(),
          examples: finalExamples,
          unitPrice: unitPrice,
          unit: _unitController.text,
          recentPoints: _recentPointsController.text,
          recyclable: _isRecyclable,
        ),
      ));
    } else {
      context.read<WasteTypeBloc>().add(
        CreateWasteType(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          recyclable: _isRecyclable,
          handlingInstructions: _handlingInstructionsController.text.trim(),
          unitPrice: unitPrice,
        ),
      );
    }
  }

  Future<void> _checkAdminPrivileges() async {
    try {
      final userRepository = RepositoryProvider.of<UserRepository>(context);
      final user = await userRepository.getUserProfile();
      
      setState(() {
        _isAdmin = user.isAdmin;
      });
      
      // If not admin and trying to edit, navigate back
      if (!_isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền chỉnh sửa loại rác'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Navigate back after showing the error
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
      
      developer.log('User admin status: $_isAdmin');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      // Default to non-admin in case of error
      setState(() {
        _isAdmin = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác minh quyền truy cập'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Navigate back after showing the error
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          _isEditing ? 'Cập nhật loại rác thải' : 'Thêm loại rác thải mới',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _submitForm,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text(
                'Lưu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is WasteTypeDetailLoaded && _isEditing && !_isLoading) {
            // Populate form only once when loading details for editing
            _populateForm(state.wasteType);
          } else if (state is WasteTypeCreated || state is WasteTypeUpdated) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Cập nhật loại rác thành công'
                      : 'Tạo loại rác mới thành công',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is WasteTypeError) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WasteTypeLoading && _isEditing && !_isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải thông tin...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                physics: BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and Color Selection
                      _buildIconAndColorSection(),
                      
                      SizedBox(height: 24),
                      
                      // Basic Information Section
                      _buildSectionTitle('Thông tin cơ bản'),
                      _buildBasicInfoSection(),
                      
                      SizedBox(height: 24),
                      
                      // Description and Recycling Method Section
                      _buildSectionTitle('Mô tả và Hướng dẫn'),
                      _buildDescriptionAndRecyclingSection(),
                      
                      SizedBox(height: 24),
                      
                      // Example Items Section
                      _buildSectionTitle('Các ví dụ về loại rác'),
                      _buildExamplesSection(),
                      
                      SizedBox(height: 24),
                      
                      // Pricing Information Section
                      _buildSectionTitle('Thông tin thu mua'),
                      _buildPricingSection(),
                      
                      SizedBox(height: 24),
                      
                      // Reward Points Section
                      _buildSectionTitle('Điểm thưởng'),
                      _buildRewardPointsSection(),
                      
                      SizedBox(height: 80), // Extra space for button
                    ],
                  ),
                ),
              ),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _isLoading 
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Cập nhật' : 'Tạo mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconAndColorSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu tượng và màu sắc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                // Preview
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _availableIcons[_selectedIconKey],
                    color: _selectedColor,
                    size: 48,
                  ),
                ),
                SizedBox(width: 16),
                // Selection
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biểu tượng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedIconKey,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        items: _availableIcons.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Row(
                              children: [
                                Icon(_availableIcons[key], size: 18),
                                SizedBox(width: 8),
                                Text(key),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedIconKey = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Màu sắc',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            CustomTextField(
              controller: _nameController,
              labelText: 'Tên loại rác thải',
              hintText: 'Ví dụ: Chai nhựa PET',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên loại rác thải';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Category selection
            Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                'Tái chế',
                'Hữu cơ',
                'Nguy hại',
                'Thường',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    _isRecyclable = newValue == 'Tái chế';
                  });
                }
              },
            ),
            SizedBox(height: 16),
            // Recyclable switch
            CustomSwitchField(
              label: 'Có thể tái chế',
              value: _isRecyclable,
              onChanged: (value) {
                setState(() {
                  _isRecyclable = value;
                  if (value) {
                    _selectedCategory = 'Tái chế';
                  } else if (_selectedCategory == 'Tái chế') {
                    _selectedCategory = 'Thường';
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDescriptionAndRecyclingSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description field
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Mô tả',
              hintText: 'Mô tả chi tiết về loại rác thải này',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Recycling method field
            CustomTextField(
              controller: _handlingInstructionsController,
              labelText: 'Hướng dẫn xử lý',
              hintText: 'Cách thức xử lý, phân loại hoặc tái chế',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập hướng dẫn xử lý';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExamplesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _examples.length; i++) ...[
              if (i > 0) SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _examples[i],
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Chai nước suối',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) => _updateExample(i, value),
                    ),
                  ),
                  if (_examples.length > 1)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeExample(i),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                ],
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addExample,
              icon: Icon(Icons.add),
              label: Text('Thêm ví dụ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                side: BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPricingSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _unitPriceController,
                    labelText: 'Giá thu mua',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        try {
                          double.parse(value);
                        } catch (e) {
                          return 'Nhập số hợp lệ';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _unitController,
                    labelText: 'Đơn vị',
                    hintText: 'kg',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập đơn vị';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Để mức giá là 0 nếu không thu mua loại rác này',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardPointsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _recentPointsController,
              labelText: 'Thông tin điểm thưởng',
              hintText: 'Ví dụ: Tái chế 1kg giấy = 3 điểm',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập thông tin điểm thưởng';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}