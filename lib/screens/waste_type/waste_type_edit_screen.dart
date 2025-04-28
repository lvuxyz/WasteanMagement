import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_type/waste_type_bloc.dart';
import '../blocs/waste_type/waste_type_event.dart';
import '../blocs/waste_type/waste_type_state.dart';
import '../models/waste_type_model.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_dropdown_field.dart';
import '../widgets/common/custom_switch_field.dart';
import '../widgets/common/custom_button.dart';

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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _recyclingMethodController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _unitController;
  late TextEditingController _recentPointsController;
  String _selectedCategory = 'Tái chế';
  bool _isRecyclable = true;
  bool _isLoading = false;
  bool _isEditing = false;
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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _recyclingMethodController = TextEditingController();
    _buyingPriceController = TextEditingController();
    _unitController = TextEditingController(text: 'kg');
    _recentPointsController = TextEditingController();

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
    _recyclingMethodController.dispose();
    _buyingPriceController.dispose();
    _unitController.dispose();
    _recentPointsController.dispose();
    super.dispose();
  }

  // Populate form with existing data
  void _populateForm(WasteType wasteType) {
    _nameController.text = wasteType.name;
    _descriptionController.text = wasteType.description;
    _recyclingMethodController.text = wasteType.recyclingMethod;
    _buyingPriceController.text = wasteType.buyingPrice.toString();
    _unitController.text = wasteType.unit;
    _recentPointsController.text = wasteType.recentPoints;
    _selectedCategory = wasteType.category;
    _isRecyclable = wasteType.category == 'Tái chế';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final finalExamples = _examples.where((example) => example.isNotEmpty).toList();

      if (finalExamples.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cần nhập ít nhất một ví dụ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int buyingPrice = 0;
      try {
        buyingPrice = int.parse(_buyingPriceController.text);
      } catch (e) {
        // Default to 0 if parsing fails
      }

      final wasteType = WasteType(
        id: _isEditing ? widget.wasteTypeId! : 0, // Temporary ID for new items
        name: _nameController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        icon: _availableIcons[_selectedIconKey]!,
        color: _selectedColor,
        recyclingMethod: _recyclingMethodController.text,
        examples: finalExamples,
        buyingPrice: buyingPrice,
        unit: _unitController.text,
        recentPoints: _recentPointsController.text,
      );

      setState(() {
        _isLoading = true;
      });

      if (_isEditing) {
        context.read<WasteTypeBloc>().add(UpdateWasteType(wasteType));
      } else {
        context.read<WasteTypeBloc>().add(CreateWasteType(wasteType));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          _isEditing ? 'Sửa loại rác thải' : 'Thêm loại rác thải',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is WasteTypeDetailLoaded && _isEditing && !_isLoading) {
            // Populate form only once when loading details for editing
            _populateForm(state.wasteType);
          } else if (state is WasteTypeCreated || state is WasteTypeUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Cập nhật loại rác thành công'
                      : 'Tạo loại rác mới thành công',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is WasteTypeError) {
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
          if (state is WasteTypeLoading && _isEditing && !_isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  Text(
                    'Thông tin cơ bản',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    label: 'Tên loại rác',
                    hintText: 'Nhập tên loại rác',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tên loại rác là bắt buộc';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Description field
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Mô tả',
                    hintText: 'Nhập mô tả về loại rác',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mô tả là bắt buộc';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Category dropdown
                  CustomDropdownField<String>(
                    label: 'Danh mục',
                    value: _selectedCategory,
                    items: const [
                      'Tái chế',
                      'Hữu cơ',
                      'Nguy hại',
                      'Thường',
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                          // Update recyclable based on category
                          _isRecyclable = value == 'Tái chế';
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
                        // Update category if needed
                        if (value && _selectedCategory != 'Tái chế') {
                          _selectedCategory = 'Tái chế';
                        } else if (!value && _selectedCategory == 'Tái chế') {
                          _selectedCategory = 'Thường';
                        }
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  // Visual representation section
                  Text(
                    'Biểu thị trực quan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Icon selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biểu tượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _availableIcons.entries.map((entry) {
                            final isSelected = _selectedIconKey == entry.key;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIconKey = entry.key;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _selectedColor.withOpacity(0.2)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(color: _selectedColor)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      entry.value,
                                      color: isSelected
                                          ? _selectedColor
                                          : Colors.grey[600],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? _selectedColor
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Color selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Màu sắc',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _availableColors.map((color) {
                            final isSelected = _selectedColor == color;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: Colors.black, width: 2)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Processing Instructions Section
                  Text(
                    'Hướng dẫn xử lý',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Recycling method field
                  CustomTextField(
                    controller: _recyclingMethodController,
                    label: 'Phương pháp xử lý',
                    hintText: 'Nhập hướng dẫn cách xử lý loại rác này',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hướng dẫn xử lý là bắt buộc';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Examples section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ví dụ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addExample,
                            icon: Icon(Icons.add, color: AppColors.primaryGreen),
                            label: Text(
                              'Thêm ví dụ',
                              style: TextStyle(color: AppColors.primaryGreen),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ...List.generate(_examples.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _examples[index],
                                  decoration: InputDecoration(
                                    hintText: 'Nhập ví dụ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _updateExample(index, value);
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeExample(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Incentives Section
                  Text(
                    'Khuyến khích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Buying price field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: CustomTextField(
                          controller: _buyingPriceController,
                          label: 'Giá thu mua',
                          hintText: 'Nhập giá thu mua',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          controller: _unitController,
                          label: 'Đơn vị',
                          hintText: 'kg',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Points field
                  CustomTextField(
                    controller: _recentPointsController,
                    label: 'Điểm thưởng',
                    hintText: 'Ví dụ: Tái chế 1kg = 5 điểm',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Thông tin điểm thưởng là bắt buộc';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Submit button
                  CustomButton(
                    text: _isEditing ? 'Cập nhật' : 'Tạo mới',
                    isLoading: _isLoading,
                    onPressed: _submitForm,
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}