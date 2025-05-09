import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../models/transaction.dart';

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
  Transaction? _transaction;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _loadTransactionDetails() {
    // In a real app, you would make an API call to fetch transaction details
    // For now, let's just use the transactions already in the bloc state
    final transactions = context.read<TransactionBloc>().state.transactions;
    try {
      final transaction = transactions.firstWhere(
        (t) => t.transactionId == widget.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );
      
      setState(() {
        _transaction = transaction;
        _quantityController.text = transaction.quantity.toString();
        _selectedStatus = transaction.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not find transaction: ${e.toString()}';
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Get the updated quantity
    final double quantity = double.parse(_quantityController.text);
    
    // Use the UpdateTransactionStatus event to update through the bloc
    context.read<TransactionBloc>().add(
      UpdateTransactionStatus(
        transactionId: widget.transactionId,
        status: _selectedStatus,
      ),
    );

    // Add a delay to simulate API call completion
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật giao dịch thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa giao dịch'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTransaction,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildEditForm(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Đã xảy ra lỗi khi tải thông tin giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    if (_transaction == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin giao dịch'),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTransactionInfoSection(),
          const SizedBox(height: 24),
          _buildEditableFields(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Mã giao dịch', '#${_transaction!.transactionId}'),
            _buildInfoRow('Người dùng', _transaction!.username ?? _transaction!.userName ?? 'Không xác định'),
            _buildInfoRow('Loại rác', _transaction!.wasteTypeName),
            _buildInfoRow('Điểm thu gom', _transaction!.collectionPointName),
            _buildInfoRow('Ngày tạo', _formatDate(_transaction!.transactionDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chỉnh sửa thông tin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                if (double.tryParse(value) == null) {
                  return 'Vui lòng nhập số hợp lệ';
                }
                if (double.parse(value) <= 0) {
                  return 'Số lượng phải lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Trạng thái giao dịch',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildStatusOption('pending', 'Chờ xử lý', Colors.orange),
          const Divider(height: 1),
          _buildStatusOption('verified', 'Đã xác nhận', Colors.blue),
          const Divider(height: 1),
          _buildStatusOption('processing', 'Đang xử lý', Colors.blue.shade700),
          const Divider(height: 1),
          _buildStatusOption('completed', 'Hoàn thành', Colors.green),
          const Divider(height: 1),
          _buildStatusOption('rejected', 'Đã hủy', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, Color color) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: _selectedStatus == value ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      value: value,
      groupValue: _selectedStatus,
      activeColor: color,
      onChanged: (newValue) {
        setState(() {
          _selectedStatus = newValue!;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveTransaction,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isSaving
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text('Đang lưu...'),
              ],
            )
          : const Text('LƯU THAY ĐỔI'),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 