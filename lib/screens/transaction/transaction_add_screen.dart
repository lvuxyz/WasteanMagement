import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/collection_point_repository.dart';
import '../../services/upload_service.dart';
import '../../models/collection_point.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({Key? key}) : super(key: key);
  
  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedWasteType;
  String? _selectedCollectionPoint;
  File? _proofImage;
  String? _proofImageUrl;
  
  final List<Map<String, dynamic>> _wasteTypes = [
    {'id': 1, 'name': 'Chai nhựa', 'unit': 'kg', 'unitPrice': 2000},
    {'id': 2, 'name': 'Giấy vụn', 'unit': 'kg', 'unitPrice': 1500},
    {'id': 3, 'name': 'Pin điện', 'unit': 'kg', 'unitPrice': 3000},
    {'id': 4, 'name': 'Lon kim loại', 'unit': 'kg', 'unitPrice': 4000},
    {'id': 5, 'name': 'Thủy tinh', 'unit': 'kg', 'unitPrice': 1000},
  ];
  
  List<CollectionPoint> _collectionPoints = [];
  bool _isLoadingCollectionPoints = true;
  String _loadingError = '';
  
  String _unit = 'kg';
  double _unitPrice = 0;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchCollectionPoints();
  }

  Future<void> _fetchCollectionPoints() async {
    setState(() {
      _isLoadingCollectionPoints = true;
      _loadingError = '';
    });

    try {
      final collectionPointRepository = Provider.of<CollectionPointRepository>(context, listen: false);
      final collectionPoints = await collectionPointRepository.getAllCollectionPoints();
      
      setState(() {
        _collectionPoints = collectionPoints;
        _isLoadingCollectionPoints = false;
      });
    } catch (e) {
      setState(() {
        _loadingError = 'Không thể tải danh sách điểm thu gom: $e';
        _isLoadingCollectionPoints = false;
      });
    }
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _proofImage = File(image.path);
        _isUploadingImage = true;
      });

      try {
        // Upload the image to your server
        final uploadService = UploadService();
        final uploadResult = await uploadService.uploadImage(_proofImage!);
        
        if (uploadResult.success) {
          setState(() {
            _proofImageUrl = uploadResult.imageUrl;
            _isUploadingImage = false;
          });
        } else {
          _showErrorSnackBar('Không thể tải lên hình ảnh: ${uploadResult.message}');
          setState(() {
            _isUploadingImage = false;
          });
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi tải lên hình ảnh: $e');
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_proofImageUrl == null && _proofImage == null) {
        _showErrorSnackBar('Vui lòng tải lên ảnh chứng minh');
        return;
      }

      if (_isUploadingImage) {
        _showErrorSnackBar('Vui lòng đợi cho đến khi hình ảnh được tải lên');
        return;
      }

      try {
        // Chuyển đổi chuỗi sang số
        final quantity = double.parse(_quantityController.text);
        final collectionPointId = int.parse(_selectedCollectionPoint!);
        final wasteTypeId = int.parse(_selectedWasteType!);
        
        // Gửi sự kiện tạo giao dịch
        context.read<TransactionBloc>().add(
          CreateTransaction(
            collectionPointId: collectionPointId,
            wasteTypeId: wasteTypeId,
            quantity: quantity,
            unit: _unit,
            proofImageUrl: _proofImageUrl,
          ),
        );
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang tạo giao dịch...'),
            backgroundColor: Colors.blue,
          ),
        );
        
        // Quay lại màn hình trước
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('Lỗi: $e');
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy repository từ Provider
    final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
    
    return BlocProvider(
      create: (context) => TransactionBloc(transactionRepository: transactionRepository),
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.failure) {
            _showErrorSnackBar(state.errorMessage ?? 'Lỗi khi tạo giao dịch');
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tạo giao dịch mới'),
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              body: state.status == TransactionStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                            _buildSectionTitle('Hình ảnh chứng minh'),
                            _buildCard([
                              InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: _isUploadingImage 
                                    ? const Center(child: CircularProgressIndicator())
                                    : _proofImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            _proofImage!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate_outlined,
                                                color: Colors.grey[400],
                                                size: 48,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tải lên ảnh chứng minh',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ]),
                            
                            const SizedBox(height: 24),
                            _buildSectionTitle('Địa điểm thu gom'),
                            _buildCollectionPointsSection(),
                            
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
          },
        ),
      ),
    );
  }

  Widget _buildCollectionPointsSection() {
    if (_isLoadingCollectionPoints) {
      return _buildCard([
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải danh sách điểm thu gom...'),
              ],
            ),
          ),
        ),
      ]);
    } else if (_loadingError.isNotEmpty) {
      return _buildCard([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_loadingError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCollectionPoints,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ]);
    } else if (_collectionPoints.isEmpty) {
      return _buildCard([
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Không có điểm thu gom nào'),
          ),
        ),
      ]);
    } else {
      return _buildCard([
        DropdownButtonFormField<String>(
          value: _selectedCollectionPoint,
          decoration: const InputDecoration(
            labelText: 'Điểm thu gom',
            hintText: 'Chọn điểm thu gom',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: _collectionPoints.map((point) {
            return DropdownMenuItem<String>(
              value: point.collectionPointId.toString(),
              child: Text(point.name),
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
          _buildCollectionPointDetails(),
      ]);
    }
  }

  Widget _buildCollectionPointDetails() {
    final selectedPoint = _collectionPoints.firstWhere(
      (point) => point.collectionPointId.toString() == _selectedCollectionPoint,
      orElse: () => _collectionPoints.first,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPoint.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedPoint.address,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                'Giờ hoạt động: ${selectedPoint.operatingHours}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                'Trạng thái: ${_formatStatus(selectedPoint.status)}',
                style: TextStyle(
                  color: _getStatusColor(selectedPoint.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.storage, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                'Công suất: ${selectedPoint.capacity} kg',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Ngừng hoạt động';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
      (point) => point.collectionPointId.toString() == _selectedCollectionPoint,
      orElse: () => _collectionPoints.first,
    );
    
    return point.address;
  }
} 