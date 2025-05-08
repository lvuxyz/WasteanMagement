import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

class TransactionEditScreen extends StatefulWidget {
  final int transactionId;
  
  const TransactionEditScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);
  
  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  
  String? _selectedWasteType;
  String? _selectedCollectionPoint;
  String? _selectedStatus;
  
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
  
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'pending', 'label': 'Chờ xử lý', 'color': Colors.orange, 'icon': Icons.pending_outlined},
    {'value': 'processing', 'label': 'Đang xử lý', 'color': Colors.blue, 'icon': Icons.hourglass_top},
    {'value': 'completed', 'label': 'Hoàn thành', 'color': Colors.green, 'icon': Icons.check_circle_outline},
    {'value': 'rejected', 'label': 'Đã hủy', 'color': Colors.red, 'icon': Icons.cancel_outlined},
  ];
  
  String _unit = 'kg';
  double _unitPrice = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  late Map<String, dynamic> _transaction;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
    _loadTransactionData();
  }

  void _loadTransactionData() {
    // In a real app, this would fetch data from the backend
    // For now, we'll simulate with a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Mock transaction data for the given ID
      _transaction = _getDummyTransaction(widget.transactionId);
      
      // Populate form fields
      _usernameController.text = _transaction['username'];
      _quantityController.text = _transaction['quantity'].toString();
      _notesController.text = _transaction['notes'] ?? '';
      
      setState(() {
        _selectedWasteType = _transaction['wasteTypeId'].toString();
        _selectedCollectionPoint = _transaction['collectionPointId'].toString();
        _selectedStatus = _transaction['status'];
        _updateWasteTypeInfo();
        _isLoading = false;
      });
    });
  }

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
        _isSaving = true;
      });
      
      // In a real app, this would send data to the backend
      // Simulate API call with a delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giao dịch đã được cập nhật thành công'),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa giao dịch'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa giao dịch #${widget.transactionId}'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Thông tin giao dịch'),
                    _buildCard([
                      // Status dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          hintText: 'Chọn trạng thái',
                          prefixIcon: Icon(Icons.pending_actions),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status['value'],
                            child: Row(
                              children: [
                                Icon(status['icon'], color: status['color'], size: 18),
                                const SizedBox(width: 8),
                                Text(status['label']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn trạng thái';
                          }
                          return null;
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Thông tin người dùng'),
                    _buildCard([
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên người dùng hoặc email',
                          hintText: 'Nhập tên người dùng hoặc email',
                          prefixIcon: Icon(Icons.person),
                        ),
                        readOnly: true,  // Can't change user
                        enabled: false,
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
                    _buildSectionTitle('Ghi chú'),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.primaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
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
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Map<String, dynamic> _getDummyTransaction(int id) {
    // Dummy data for UI mockup
    return {
      'id': id,
      'username': 'user123',
      'wasteTypeId': 1,
      'wasteType': 'Chai nhựa',
      'quantity': 5.0,
      'unit': 'kg',
      'unitPrice': 2000,
      'status': 'completed',
      'date': '15/11/2023',
      'points': 10,
      'collectionPointId': 1,
      'collectionPoint': 'Điểm thu gom An Phú',
      'address': '123 Đường Phạm Văn Đồng, Phường An Phú, Quận 2, TP.HCM',
      'notes': 'Khách hàng sẽ giao rác vào buổi sáng từ 7h-9h. Vui lòng liên hệ trước khi đến.',
    };
  }
} 