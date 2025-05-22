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

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _checkIsAdmin() async {
    await _authService.isAdmin(); // Keep the method for future use if needed
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
      if (_transaction != null) {
        _selectedStatus = _transaction!.status;
      } else {
        _selectedStatus = 'pending'; // Giá trị mặc định
      }
      _isLoading = false;
    });
  }

  Future<void> _saveTransaction() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Cho phép tất cả người dùng cập nhật trạng thái
      if (_transaction != null && _selectedStatus != _transaction!.status) {
        context.read<TransactionBloc>().add(
          UpdateTransactionStatus(
            transactionId: widget.transactionId,
            status: _selectedStatus,
          ),
        );
      }
      
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật trạng thái giao dịch thành công'),
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
          title: const Text('Chỉnh sửa trạng thái giao dịch'),
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
              'Chỉnh sửa trạng thái',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            if (_transaction != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_transaction!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(_transaction!.status).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(_transaction!.status), 
                      color: _getStatusColor(_transaction!.status)
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trạng thái hiện tại:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(_transaction!.status),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(_transaction!.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Chọn trạng thái mới',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn một trạng thái và nhấn nút Cập nhật trạng thái bên dưới',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatusOption('pending', 'Chờ xử lý', Colors.orange),
          const Divider(height: 1),
          _buildStatusOption('verified', 'Đã xác nhận', Colors.blue),
          const Divider(height: 1),
          _buildStatusOption('completed', 'Hoàn thành', Colors.green),
          const Divider(height: 1),
          _buildStatusOption('rejected', 'Đã hủy', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, Color color) {
    final isSelected = _selectedStatus == value;
    
    return RadioListTile<String>(
      title: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  )
                : null,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
      value: value,
      groupValue: _selectedStatus,
      activeColor: color,
      selected: isSelected,
      onChanged: (newValue) {
        print('Đã chọn trạng thái: $newValue (trước đó: $_selectedStatus)');
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save),
                const SizedBox(width: 8),
                const Text(
                  'CẬP NHẬT TRẠNG THÁI',
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ],
            ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'verified':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        throw Exception('Unknown status');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'verified':
        return Icons.verified;
      case 'completed':
        return Icons.done;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'verified':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'rejected':
        return 'Đã hủy';
      default:
        throw Exception('Unknown status');
    }
  }
} 