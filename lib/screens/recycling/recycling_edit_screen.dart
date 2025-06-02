import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/recycling/recycling_bloc.dart';
import '../../blocs/recycling/recycling_event.dart';
import '../../blocs/recycling/recycling_state.dart';
import '../../models/recycling_process_model.dart';
import '../../repositories/recycling_repository.dart';
import '../../services/recycling_service.dart';
import '../../core/network/network_info.dart';
import '../../utils/app_colors.dart';

class RecyclingEditScreen extends StatefulWidget {
  final RecyclingProcess process;

  const RecyclingEditScreen({
    Key? key,
    required this.process,
  }) : super(key: key);

  @override
  State<RecyclingEditScreen> createState() => _RecyclingEditScreenState();
}

class _RecyclingEditScreenState extends State<RecyclingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _selectedStatus;
  late TextEditingController _processedQuantityController;
  late TextEditingController _notesController;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  
  // Chi tiết xử lý
  late TextEditingController _currentStageController;
  late TextEditingController _completionPercentageController;
  late TextEditingController _qualityCheckController;
  late TextEditingController _operatorController;
  late TextEditingController _issuesEncounteredController;
  
  // Chỉ số chất lượng
  late TextEditingController _purityLevelController;
  late TextEditingController _contaminationRateController;
  late TextEditingController _moistureContentController;
  
  // Chi tiết đầu ra
  late TextEditingController _recycledMaterialQuantityController;
  late TextEditingController _wasteResidueController;
  late TextEditingController _productGradeController;
  
  final List<String> _statuses = ['pending', 'in_progress', 'completed', 'cancelled'];
  final Map<String, String> _statusLabels = {
    'pending': 'Đang chờ xử lý',
    'in_progress': 'Đang xử lý',
    'completed': 'Hoàn thành',
    'cancelled': 'Đã hủy',
  };
  
  bool _showProcessedDetails = false;
  bool _showQualityMetrics = false;
  bool _showOutputDetails = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.process.status;
    _processedQuantityController = TextEditingController(
      text: widget.process.processedQuantity?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.process.notes ?? '',
    );
    _endDate = widget.process.endDate;
    _endTime = _endDate != null 
        ? TimeOfDay(hour: _endDate!.hour, minute: _endDate!.minute) 
        : null;
    
    // Khởi tạo các controller cho chi tiết xử lý
    _currentStageController = TextEditingController();
    _completionPercentageController = TextEditingController();
    _qualityCheckController = TextEditingController();
    _operatorController = TextEditingController();
    _issuesEncounteredController = TextEditingController();
    
    // Khởi tạo các controller cho chỉ số chất lượng
    _purityLevelController = TextEditingController();
    _contaminationRateController = TextEditingController();
    _moistureContentController = TextEditingController();
    
    // Khởi tạo các controller cho chi tiết đầu ra
    _recycledMaterialQuantityController = TextEditingController();
    _wasteResidueController = TextEditingController();
    _productGradeController = TextEditingController();
  }

  @override
  void dispose() {
    _processedQuantityController.dispose();
    _notesController.dispose();
    
    // Giải phóng các controller cho chi tiết xử lý
    _currentStageController.dispose();
    _completionPercentageController.dispose();
    _qualityCheckController.dispose();
    _operatorController.dispose();
    _issuesEncounteredController.dispose();
    
    // Giải phóng các controller cho chỉ số chất lượng
    _purityLevelController.dispose();
    _contaminationRateController.dispose();
    _moistureContentController.dispose();
    
    // Giải phóng các controller cho chi tiết đầu ra
    _recycledMaterialQuantityController.dispose();
    _wasteResidueController.dispose();
    _productGradeController.dispose();
    
    super.dispose();
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: widget.process.startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      
      // Sau khi chọn ngày, hiển thị time picker
      _selectEndTime(context);
    }
  }
  
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _endTime = picked;
        if (_endDate != null) {
          _endDate = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            _endTime!.hour,
            _endTime!.minute,
          );
        }
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Chuẩn bị dữ liệu để gửi đi
      final Map<String, dynamic> updateData = {
        'status': _selectedStatus,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };
      
      // Thêm processed_quantity nếu có
      if (_processedQuantityController.text.isNotEmpty) {
        updateData['processed_quantity'] = _processedQuantityController.text;
      }
      
      // Thêm end_date nếu có
      if (_endDate != null) {
        updateData['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(_endDate!);
      }
      
      // Thêm chi tiết xử lý nếu được hiển thị và có dữ liệu
      if (_showProcessedDetails) {
        final Map<String, dynamic> processedDetails = {};
        
        if (_currentStageController.text.isNotEmpty) {
          processedDetails['current_stage'] = _currentStageController.text;
        }
        
        if (_completionPercentageController.text.isNotEmpty) {
          processedDetails['completion_percentage'] = _completionPercentageController.text;
        }
        
        if (_qualityCheckController.text.isNotEmpty) {
          processedDetails['quality_check'] = _qualityCheckController.text;
        }
        
        if (_operatorController.text.isNotEmpty) {
          processedDetails['operator'] = _operatorController.text;
        }
        
        if (_issuesEncounteredController.text.isNotEmpty) {
          processedDetails['issues_encountered'] = _issuesEncounteredController.text;
        }
        
        if (processedDetails.isNotEmpty) {
          updateData['processed_details'] = processedDetails;
        }
      }
      
      // Thêm chỉ số chất lượng nếu được hiển thị và có dữ liệu
      if (_showQualityMetrics) {
        final Map<String, dynamic> qualityMetrics = {};
        
        if (_purityLevelController.text.isNotEmpty) {
          qualityMetrics['purity_level'] = _purityLevelController.text;
        }
        
        if (_contaminationRateController.text.isNotEmpty) {
          qualityMetrics['contamination_rate'] = _contaminationRateController.text;
        }
        
        if (_moistureContentController.text.isNotEmpty) {
          qualityMetrics['moisture_content'] = _moistureContentController.text;
        }
        
        if (qualityMetrics.isNotEmpty) {
          updateData['quality_metrics'] = qualityMetrics;
        }
      }
      
      // Thêm chi tiết đầu ra nếu được hiển thị và có dữ liệu
      if (_showOutputDetails) {
        final Map<String, dynamic> outputDetails = {};
        
        if (_recycledMaterialQuantityController.text.isNotEmpty) {
          outputDetails['recycled_material_quantity'] = _recycledMaterialQuantityController.text;
        }
        
        if (_wasteResidueController.text.isNotEmpty) {
          outputDetails['waste_residue'] = _wasteResidueController.text;
        }
        
        if (_productGradeController.text.isNotEmpty) {
          outputDetails['product_grade'] = _productGradeController.text;
        }
        
        if (outputDetails.isNotEmpty) {
          updateData['output_details'] = outputDetails;
        }
      }
      
      // Gửi sự kiện cập nhật
      context.read<RecyclingBloc>().add(UpdateRecyclingProcess(
        id: widget.process.id,
        updateData: updateData,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecyclingBloc(
        repository: RecyclingRepository(
          recyclingService: RecyclingService(),
          networkInfo: NetworkInfoImpl(),
        ),
      ),
      child: BlocConsumer<RecyclingBloc, RecyclingState>(
        listener: (context, state) {
          if (state is RecyclingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state is RecyclingProcessUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật quy trình tái chế thành công'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cập nhật quy trình tái chế'),
              backgroundColor: AppColors.primaryGreen,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildEditCard(context),
                    const SizedBox(height: 16),
                    
                    if (state is RecyclingLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cập nhật quy trình',
                          style: TextStyle(fontSize: 16),
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
    );
  }

  Widget _buildInfoCard() {
    final numberFormat = NumberFormat('#,##0.00', 'vi_VN');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin quy trình',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Mã giao dịch', widget.process.transactionId),
            _buildInfoRow('Loại rác', widget.process.wasteTypeName),
            _buildInfoRow(
              'Số lượng ban đầu', 
              widget.process.transactionQuantity != null
                ? '${numberFormat.format(widget.process.transactionQuantity!)} kg'
                : (widget.process.quantity != null
                  ? '${numberFormat.format(widget.process.quantity!)} kg'
                  : '0.00 kg')
            ),
            _buildInfoRow('Ngày bắt đầu', DateFormat('dd/MM/yyyy').format(widget.process.startDate)),
            if (widget.process.userName != null)
              _buildInfoRow('Tên người dùng', widget.process.userName!),
            if (widget.process.userFullName != null)
              _buildInfoRow('Họ tên người dùng', widget.process.userFullName!),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cập nhật thông tin cơ bản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Status Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              value: _selectedStatus,
              items: _statuses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_statusLabels[value] ?? value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn trạng thái';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Processed Quantity Field
            TextFormField(
              controller: _processedQuantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng đã xử lý (kg)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                hintText: 'Ví dụ: 75.5',
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Kiểm tra định dạng số
                  final RegExp regex = RegExp(r'^\d+(\.\d+)?$');
                  if (!regex.hasMatch(value)) {
                    return 'Vui lòng nhập số hợp lệ (ví dụ: 75.5)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // End Date and Time Picker
            InkWell(
              onTap: () => _selectEndDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày và giờ kết thúc',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endDate != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)
                          : 'Chưa chọn ngày và giờ',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                hintText: 'Nhập ghi chú về quá trình xử lý',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 