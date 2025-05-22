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
  
  final List<String> _statuses = ['pending', 'in_progress', 'completed', 'cancelled'];
  final Map<String, String> _statusLabels = {
    'pending': 'Đang chờ xử lý',
    'in_progress': 'Đang xử lý',
    'completed': 'Hoàn thành',
    'cancelled': 'Đã hủy',
  };

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
  }

  @override
  void dispose() {
    _processedQuantityController.dispose();
    _notesController.dispose();
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
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      double? processedQuantity;
      if (_processedQuantityController.text.isNotEmpty) {
        processedQuantity = double.tryParse(_processedQuantityController.text);
      }
      
      context.read<RecyclingBloc>().add(UpdateRecyclingProcess(
        id: widget.process.id,
        status: _selectedStatus,
        processedQuantity: processedQuantity,
        endDate: _endDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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
                    const SizedBox(height: 24),
                    
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
            _buildInfoRow('Số lượng ban đầu', '${widget.process.quantity ?? 0} kg'),
            _buildInfoRow('Ngày bắt đầu', DateFormat('dd/MM/yyyy').format(widget.process.startDate)),
            _buildInfoRow('Mã người dùng', widget.process.userId ?? 'Không có'),
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
              'Cập nhật thông tin',
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
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final double? parsed = double.tryParse(value);
                  if (parsed == null) {
                    return 'Vui lòng nhập số hợp lệ';
                  }
                  if (parsed <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }
                  final quantity = widget.process.quantity ?? 0;
                  if (parsed > quantity) {
                    return 'Số lượng không thể lớn hơn số lượng ban đầu';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // End Date Picker
            InkWell(
              onTap: () => _selectEndDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày kết thúc',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : 'Chưa chọn ngày',
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
            width: 120,
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