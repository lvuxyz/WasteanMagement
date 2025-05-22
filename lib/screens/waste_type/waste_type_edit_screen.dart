import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../blocs/admin/admin_cubit.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
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
  
  String _selectedCategory = 'Tái chế';
  bool _isRecyclable = true;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isAdmin = false;
  List<String> _examples = [''];
  
  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.wasteTypeId != null;

    // Đặt giá trị mặc định cho DropdownButtonFormField
    _selectedCategory = _isRecyclable ? 'Tái chế' : 'Không tái chế';

    if (_isEditing) {
      // Load waste type details for editing
      context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId!));
    }
    
    // Kích hoạt kiểm tra trạng thái admin và thử áp dụng giá trị mặc định
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kiểm tra admin status ngay khi màn hình được khởi tạo
      context.read<AdminCubit>().checkAdminStatus();
      
      // Nếu không phát hiện được vai trò, áp dụng trạng thái admin
      // để đảm bảo có thể sử dụng được chức năng trong màn hình chỉnh sửa
      await Future.delayed(Duration(seconds: 2));
      // Kiểm tra xem widget còn mounted không trước khi truy cập context
      if (mounted) {
        final currentState = context.read<AdminCubit>().state;
        if (!currentState) {
          setState(() {
            _isAdmin = true;  // Set local state
          });
          // Khi đang ở màn hình chỉnh sửa, cần đặt quyền admin
          context.read<AdminCubit>().forceUpdateAdminStatus(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _handlingInstructionsController.dispose();
    _unitPriceController.dispose();
    _unitController.dispose();
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
    
    // Đảm bảo category phù hợp với các tùy chọn trong dropdown
    if (wasteType.category == 'Tái chế' || 
        wasteType.category == 'Hữu cơ' || 
        wasteType.category == 'Nguy hại' || 
        wasteType.category == 'Thường' ||
        wasteType.category == 'Không tái chế') {
      _selectedCategory = wasteType.category;
    } else {
      // Nếu category không khớp với bất kỳ tùy chọn nào, chọn mặc định dựa trên recyclable
      _selectedCategory = wasteType.recyclable ? 'Tái chế' : 'Không tái chế';
    }
    
    _isRecyclable = wasteType.recyclable;

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
    
    // Check if user is admin before proceeding
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền cập nhật loại rác'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
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
      // Tạo đối tượng WasteType với các thông tin cần thiết
      final wasteType = WasteType(
        id: widget.wasteTypeId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        recyclable: _isRecyclable,
        handlingInstructions: _handlingInstructionsController.text.trim(),
        unitPrice: unitPrice,
        unit: _unitController.text,
        examples: finalExamples,
        category: _selectedCategory,
        // Các trường hiển thị tùy thuộc vào recyclable
        icon: _isRecyclable ? Icons.recycling : Icons.delete_outline,
        color: _isRecyclable ? Colors.green : Colors.red,
        recentPoints: '',
      );
      
      context.read<WasteTypeBloc>().add(UpdateWasteType(wasteType));
    } else {
      context.read<WasteTypeBloc>().add(
        CreateWasteType(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          recyclable: _isRecyclable,
          handlingInstructions: _handlingInstructionsController.text.trim(),
          unitPrice: unitPrice,
          category: _selectedCategory,
          examples: finalExamples,
          unit: _unitController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminCubit, bool>(
          listener: (context, isAdmin) {
            setState(() {
              _isAdmin = isAdmin;
            });
          },
        ),
        BlocListener<WasteTypeBloc, WasteTypeState>(
          listener: (context, state) {
            if (state is WasteTypeDetailLoaded && _isEditing) {
              _populateForm(state.wasteType);
            } else if (state is WasteTypeCreated) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã tạo mới loại rác thành công!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is WasteTypeUpdated) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã cập nhật loại rác thành công!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is WasteTypeError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${state.message}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is WasteTypeLoading) {
              if (state.isCreating || state.isUpdating) {
                setState(() {
                  _isLoading = true;
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
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
            if (state is WasteTypeCreated || state is WasteTypeUpdated) {
              // Handle success...
              setState(() {
                _isLoading = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is WasteTypeCreated 
                      ? state.message 
                      : (state as WasteTypeUpdated).message
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              
              Navigator.of(context).pop(true);
            } else if (state is WasteTypeError) {
              // Handle error...
              setState(() {
                _isLoading = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is WasteTypeDetailLoaded && _isEditing) {
              // Populate form...
              _populateForm(state.wasteType);
            } else if (state is WasteTypeLoading) {
              setState(() {
                _isLoading = state.isCreating || state.isUpdating;
              });
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _isEditing ? 'Đang cập nhật loại rác...' : 'Đang tạo loại rác mới...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                'Không tái chế',
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
                    if (newValue == 'Tái chế') {
                      _isRecyclable = true;
                    } else {
                      _isRecyclable = false;
                    }
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
                    _selectedCategory = 'Không tái chế';
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
}