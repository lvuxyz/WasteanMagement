import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({Key? key}) : super(key: key);
  
  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedWasteType;
  String? _selectedCollectionPoint;
  
  final List<Map<String, dynamic>> _wasteTypes = [
    {'id': 1, 'name': 'Chai nhựa', 'unit': 'kg', 'unitPrice': 2000},
    {'id': 2, 'name': 'Giấy vụn', 'unit': 'kg', 'unitPrice': 1500},
    {'id': 3, 'name': 'Pin điện', 'unit': 'kg', 'unitPrice': 3000},
    {'id': 4, 'name': 'Lon kim loại', 'unit': 'kg', 'unitPrice': 4000},
    {'id': 5, 'name': 'Thủy tinh', 'unit': 'kg', 'unitPrice': 1000},
  ];
  
  final List<Map<String, dynamic>> _collectionPoints = [
    {'id': 1, 'name': 'Điểm thu gom An Phú', 'address': '123 Phạm Văn Đồng, P. An Phú, Q.2, TP.HCM'},
    {'id': 2, 'name': 'Điểm thu gom Thảo Điền', 'address': '45 Xuân Thủy, P. Thảo Điền, Q.2, TP.HCM'},
    {'id': 3, 'name': 'Điểm thu gom Bình Thạnh', 'address': '78 Điện Biên Phủ, P.15, Q. Bình Thạnh, TP.HCM'},
  ];
  
  String _unit = 'kg';
  double _unitPrice = 0;
  bool _isLoading = false;

  void _updateWasteTypeInfo() {
    if (_selectedWasteType != null) {
      final wasteType = _wasteTypes.firstWhere(
        (type) => type['id'].toString() == _selectedWasteType,
        orElse: () => {'unit': 'kg', 'unitPrice': 0},
      );
      
      setState(() {
        _unit = wasteType['unit'];
        _unitPrice = wasteType['unitPrice'].toDouble();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giao dịch đã được tạo thành công'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo giao dịch mới'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Thông tin người dùng'),
                    _buildCard([
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên người dùng hoặc email',
                          hintText: 'Nhập tên người dùng hoặc email',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên người dùng';
                          }
                          return null;
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Chi tiết rác thải'),
                    _buildCard([
                      DropdownButtonFormField<String>(
                        value: _selectedWasteType,
                        decoration: const InputDecoration(
                          labelText: 'Loại rác thải',
                          hintText: 'Chọn loại rác thải',
                          prefixIcon: Icon(Icons.delete_outline),
                        ),
                        items: _wasteTypes.map((wasteType) {
                          return DropdownMenuItem<String>(
                            value: wasteType['id'].toString(),
                            child: Text(wasteType['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWasteType = value;
                          });
                          _updateWasteTypeInfo();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn loại rác thải';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Số lượng',
                          hintText: 'Nhập số lượng',
                          prefixIcon: const Icon(Icons.scale),
                          suffixText: _unit,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          }
                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Số lượng phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Display unit price (read only)
                      TextFormField(
                        initialValue: '$_unitPrice',
                        decoration: InputDecoration(
                          labelText: 'Đơn giá',
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          suffixText: 'đ/${_unit}',
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      // Calculate total price
                      if (_selectedWasteType != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng giá trị:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_calculateTotal()} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Địa điểm thu gom'),
                    _buildCard([
                      DropdownButtonFormField<String>(
                        value: _selectedCollectionPoint,
                        decoration: const InputDecoration(
                          labelText: 'Điểm thu gom',
                          hintText: 'Chọn điểm thu gom',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: _collectionPoints.map((point) {
                          return DropdownMenuItem<String>(
                            value: point['id'].toString(),
                            child: Text(point['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCollectionPoint = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn điểm thu gom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedCollectionPoint != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getCollectionPointAddress() ?? 'Không có địa chỉ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Ghi chú (tùy chọn)'),
                    _buildCard([
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú',
                          hintText: 'Nhập ghi chú hoặc hướng dẫn bổ sung',
                          prefixIcon: Icon(Icons.note_outlined),
                        ),
                        maxLines: 3,
                      ),
                    ]),
                    
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tạo giao dịch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
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
          const SizedBox(width: 8),
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

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  String _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    return (quantity * _unitPrice).toStringAsFixed(0);
  }

  String? _getCollectionPointAddress() {
    if (_selectedCollectionPoint == null) return null;
    
    final point = _collectionPoints.firstWhere(
      (point) => point['id'].toString() == _selectedCollectionPoint,
      orElse: () => {'address': null},
    );
    
    return point['address'];
  }
} 