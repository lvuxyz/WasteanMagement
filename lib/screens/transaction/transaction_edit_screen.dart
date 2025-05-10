import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/auth_service.dart';
import '../../core/api/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIsAdmin();
    _loadTransactionDetails();
  }

  Future<void> _checkIsAdmin() async {
    final isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First try to load transaction from bloc state
      final transactions = context.read<TransactionBloc>().state.transactions;
      if (transactions.isNotEmpty) {
        try {
          _transaction = transactions.firstWhere(
            (t) => t.transactionId == widget.transactionId,
          );
          _setupFormFields();
          return;
        } catch (e) {
          // Transaction not found in bloc state, will fetch from API instead
          print('Transaction not found in bloc state, fetching from API: ${e.toString()}');
        }
      }

      // If not found in bloc state, fetch directly
      final repository = Provider.of<TransactionRepository>(context, listen: false);
      final url = '${ApiConstants.transactions}/${widget.transactionId}';
      print('Fetching transaction details from API: $url');
      
      final response = await repository.apiClient.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300 && 
          response.data['data'] != null) {
        final transactionData = response.data['data'];
        _transaction = Transaction.fromJson(transactionData);
        _setupFormFields();
      } else {
        throw Exception('Could not find transaction details');
      }
    } catch (e) {
      print('Error loading transaction details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _setupFormFields() {
    setState(() {
      _quantityController.text = _transaction!.quantity.toString();
      _selectedStatus = _transaction!.status;
      _isLoading = false;
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get the updated quantity
      final double quantity = double.parse(_quantityController.text);
      
      // Using the bloc to update the transaction
      if (_transaction != null) {
        // First update the status if needed and user is admin
        if (_isAdmin && _selectedStatus != _transaction!.status) {
          context.read<TransactionBloc>().add(
            UpdateTransactionStatus(
              transactionId: widget.transactionId,
              status: _selectedStatus,
            ),
          );
        }
        
        // Then update the transaction details
        context.read<TransactionBloc>().add(
          UpdateTransaction(
            transactionId: widget.transactionId,
            collectionPointId: _transaction!.collectionPointId,
            wasteTypeId: _transaction!.wasteTypeId,
            quantity: quantity,
            unit: _transaction!.unit,
            proofImageUrl: _transaction!.proofImageUrl,
          ),
        );
      }
      
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật giao dịch thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<TransactionBloc>(context),
      child: Scaffold(
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
      ),
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
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              Text(
                'Trạng thái giao dịch (Chỉ dành cho Admin)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusSelector(),
            ],
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