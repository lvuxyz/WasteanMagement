import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/collection_point_repository.dart';
import '../../repositories/waste_type_repository.dart';
import '../../services/upload_service.dart';
import '../../models/collection_point.dart';
import '../../models/waste_type_model.dart';
import '../../core/api/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

// This class will be used only for the transaction screen
// It's simpler than the full WasteType model
class TransactionWasteType {
  final int id;
  final String name;
  final String unit;
  final double? unitPrice;

  TransactionWasteType({
    required this.id,
    required this.name,
    required this.unit,
    this.unitPrice,
  });

  factory TransactionWasteType.fromJson(Map<String, dynamic> json) {
    return TransactionWasteType(
      id: json['waste_type_id'],
      name: json['name'],
      unit: json['unit'] ?? 'kg',
      unitPrice: json['unit_price'] != null 
        ? (json['unit_price'] is double 
            ? json['unit_price'] 
            : double.tryParse(json['unit_price'].toString())) 
        : null,
    );
  }
  
  // Create from WasteType model
  factory TransactionWasteType.fromWasteType(WasteType wasteType) {
    return TransactionWasteType(
      id: wasteType.id,
      name: wasteType.name,
      unit: wasteType.unit,
      unitPrice: wasteType.unitPrice,
    );
  }
}

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({Key? key}) : super(key: key);
  
  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedWasteTypeId;
  String? _selectedCollectionPointId;
  File? _proofImage;
  String? _proofImageUrl;
  
  List<TransactionWasteType> _wasteTypes = [];
  bool _isLoadingWasteTypes = true;
  String _wasteTypesError = '';
  
  List<CollectionPoint> _collectionPoints = [];
  bool _isLoadingCollectionPoints = true;
  String _collectionPointsError = '';
  
  String _unit = 'kg';
  double _unitPrice = 0;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  DateTime _transactionDate = DateTime.now();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchCollectionPoints();
    _fetchWasteTypes();
  }

  Future<void> _fetchWasteTypes() async {
    setState(() {
      _isLoadingWasteTypes = true;
      _wasteTypesError = '';
    });

    try {
      final url = ApiConstants.wasteTypes;
      print('Đang gọi API trực tiếp: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Phản hồi từ API: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dữ liệu phản hồi: $data');
        
        List<dynamic> wasteTypesJson = [];
        
        // Support multiple API response formats
        if (data['status'] == 'success' && data['data'] != null) {
          if (data['data'] is List) {
            wasteTypesJson = data['data'];
          } else if (data['data'] is Map && data['data']['wasteTypes'] != null) {
            wasteTypesJson = data['data']['wasteTypes'];
          }
        }
        
        if (wasteTypesJson.isNotEmpty) {
          final wasteTypes = wasteTypesJson.map((json) => TransactionWasteType(
            id: json['waste_type_id'],
            name: json['name'],
            unit: json['unit'] ?? 'kg',
            unitPrice: json['unit_price'] != null 
              ? (double.tryParse(json['unit_price'].toString()) ?? 0.0) 
              : 0.0,
          )).toList();
          
          setState(() {
            _wasteTypes = wasteTypes;
            _isLoadingWasteTypes = false;
          });
          return;
        }
      }
      
      // If API call fails or data format is unexpected, use fallback data
      setState(() {
        _wasteTypesError = 'Không thể tải danh sách loại rác từ API';
        _isLoadingWasteTypes = false;
        
        // Fallback data for testing/development
        _wasteTypes = [
          TransactionWasteType(id: 1, name: 'Nhựa', unit: 'kg', unitPrice: 5000),
          TransactionWasteType(id: 2, name: 'Giấy', unit: 'kg', unitPrice: 3000),
          TransactionWasteType(id: 3, name: 'Kim loại', unit: 'kg', unitPrice: 15000),
        ];
      });
    } catch (e) {
      print('Lỗi khi tải danh sách loại rác: $e');
      setState(() {
        _wasteTypesError = 'Không thể tải danh sách loại rác: $e';
        _isLoadingWasteTypes = false;
        
        // Fallback data for testing/development
        _wasteTypes = [
          TransactionWasteType(id: 1, name: 'Nhựa', unit: 'kg', unitPrice: 5000),
          TransactionWasteType(id: 2, name: 'Giấy', unit: 'kg', unitPrice: 3000),
          TransactionWasteType(id: 3, name: 'Kim loại', unit: 'kg', unitPrice: 15000),
        ];
      });
    }
  }

  Future<void> _fetchCollectionPoints() async {
    setState(() {
      _isLoadingCollectionPoints = true;
      _collectionPointsError = '';
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
        _collectionPointsError = 'Không thể tải danh sách điểm thu gom: $e';
        _isLoadingCollectionPoints = false;
      });
    }
  }

  void _updateWasteTypeInfo() {
    if (_selectedWasteTypeId != null) {
      final wasteType = _wasteTypes.firstWhere(
        (type) => type.id.toString() == _selectedWasteTypeId,
        orElse: () => TransactionWasteType(id: 0, name: '', unit: 'kg', unitPrice: 0),
      );
      
      setState(() {
        _unit = wasteType.unit;
        _unitPrice = wasteType.unitPrice ?? 0;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _transactionDate) {
      setState(() {
        _transactionDate = picked;
      });
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isUploadingImage) {
        _showErrorSnackBar('Vui lòng đợi cho đến khi hình ảnh được tải lên');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final quantity = double.parse(_quantityController.text);
        final collectionPointId = int.parse(_selectedCollectionPointId!);
        final wasteTypeId = int.parse(_selectedWasteTypeId!);
        
        // Gửi sự kiện tạo giao dịch qua BLoC
        context.read<TransactionBloc>().add(
          CreateTransaction(
            collectionPointId: collectionPointId,
            wasteTypeId: wasteTypeId,
            quantity: quantity,
            unit: _unit,
            proofImageUrl: _proofImageUrl,
          ),
        );
        
        _showSuccessSnackBar('Đang tạo giao dịch...');
        
        // Quay lại màn hình trước sau khi gửi thành công
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('Lỗi: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
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
    final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
    
    return BlocProvider(
      create: (context) => TransactionBloc(transactionRepository: transactionRepository),
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.failure) {
            _showErrorSnackBar(state.errorMessage ?? 'Lỗi khi tạo giao dịch');
          } else if (state.status == TransactionStatus.success) {
            _showSuccessSnackBar('Tạo giao dịch thành công');
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
              body: state.status == TransactionStatus.loading || _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Điểm thu gom section
                            _buildSectionTitle('Điểm thu gom'),
                            _buildCollectionPointsSection(),
                            
                            const SizedBox(height: 24),
                            // Thông tin rác thải section
                            _buildSectionTitle('Thông tin rác thải'),
                            _buildWasteTypeSection(),
                            
                            const SizedBox(height: 24),
                            // Hình ảnh section
                            _buildSectionTitle('Hình ảnh chứng minh (tùy chọn)'),
                            _buildProofImageSection(),
                            
                            const SizedBox(height: 24),
                            // Ghi chú section
                            _buildSectionTitle('Ghi chú (tùy chọn)'),
                            _buildCard([
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Ghi chú',
                                  hintText: 'Nhập ghi chú hoặc hướng dẫn bổ sung',
                                  prefixIcon: const Icon(Icons.note_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                maxLines: 3,
                              ),
                            ]),
                            
                            const SizedBox(height: 32),
                            // Submit button
                            ElevatedButton(
                              onPressed: _isLoadingCollectionPoints || _isLoadingWasteTypes ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Xác nhận tạo giao dịch',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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

  Widget _buildWasteTypeSection() {
    if (_isLoadingWasteTypes) {
      return _buildCard([
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải danh sách loại rác...'),
              ],
            ),
          ),
        ),
      ]);
    } else if (_wasteTypesError.isNotEmpty) {
      return _buildCard([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_wasteTypesError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchWasteTypes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ]);
    } else if (_wasteTypes.isEmpty) {
      return _buildCard([
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Không có loại rác nào'),
          ),
        ),
      ]);
    } else {
      return _buildCard([
        DropdownButtonFormField<String>(
          value: _selectedWasteTypeId,
          decoration: InputDecoration(
            labelText: 'Loại rác thải',
            hintText: 'Chọn loại rác thải',
            prefixIcon: const Icon(Icons.delete_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _wasteTypes.map((wasteType) {
            return DropdownMenuItem<String>(
              value: wasteType.id.toString(),
              child: Text(wasteType.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWasteTypeId = value;
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
        const SizedBox(height: 20),
        TextFormField(
          controller: _quantityController,
          decoration: InputDecoration(
            labelText: 'Số lượng',
            hintText: 'Nhập số lượng',
            prefixIcon: const Icon(Icons.scale),
            suffixText: _unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        const SizedBox(height: 20),
        if (_unitPrice > 0)
          TextFormField(
            initialValue: '$_unitPrice',
            decoration: InputDecoration(
              labelText: 'Đơn giá',
              prefixIcon: const Icon(Icons.monetization_on_outlined),
              suffixText: 'đ/${_unit}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            readOnly: true,
            enabled: false,
          ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Ngày giao dịch',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(_transactionDate),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedWasteTypeId != null && _unitPrice > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Tổng giá trị ước tính',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_calculateTotal()} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cho ${_quantityController.text.isEmpty ? "0" : _quantityController.text} $_unit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
      ]);
    }
  }

  Widget _buildProofImageSection() {
    return _buildCard([
      Text(
        'Ảnh chứng minh về rác thải của bạn (tùy chọn)',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: _pickImage,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _isUploadingImage 
            ? const Center(child: CircularProgressIndicator())
            : _proofImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _proofImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.grey[500],
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chọn ảnh từ thư viện (tùy chọn)',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tính năng xác minh ảnh đang được cập nhật',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ]);
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
    } else if (_collectionPointsError.isNotEmpty) {
      return _buildCard([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_collectionPointsError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCollectionPoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
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
          value: _selectedCollectionPointId,
          decoration: InputDecoration(
            labelText: 'Điểm thu gom',
            hintText: 'Chọn điểm thu gom',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _collectionPoints.map((point) {
            return DropdownMenuItem<String>(
              value: point.collectionPointId.toString(),
              child: Text(point.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCollectionPointId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn điểm thu gom';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        if (_selectedCollectionPointId != null)
          _buildCollectionPointDetails(),
      ]);
    }
  }

  Widget _buildCollectionPointDetails() {
    final selectedPoint = _collectionPoints.firstWhere(
      (point) => point.collectionPointId.toString() == _selectedCollectionPointId,
      orElse: () => _collectionPoints.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                Icons.access_time, 
                'Giờ hoạt động', 
                selectedPoint.operatingHours
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.info_outline, 
                'Trạng thái', 
                _formatStatus(selectedPoint.status),
                textColor: _getStatusColor(selectedPoint.status)
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(
                Icons.storage, 
                'Công suất', 
                '${selectedPoint.capacity} kg'
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.phone_outlined, 
                'Liên hệ', 
                selectedPoint.phone ?? 'Chưa có thông tin'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {Color? textColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
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
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
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
} 