import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
// import '../../blocs/transaction/transaction_event.dart';
// import '../../blocs/transaction/transaction_state.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/auth_service.dart';
import '../../core/api/api_constants.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailsScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Transaction? _transaction;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;
  bool _isUpdatingStatus = false;
  final AuthService _authService = AuthService();

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
          setState(() {
            _isLoading = false;
          });
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
          response.data != null && response.data['data'] != null) {
        final transactionData = response.data['data'];
        _transaction = Transaction.fromJson(transactionData);
        setState(() {
          _isLoading = false;
        });
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

  Future<void> _updateTransactionStatus(String status) async {
    if (!_isAdmin) return;
    
    setState(() {
      _isUpdatingStatus = true;
    });
    
    try {
      final repository = Provider.of<TransactionRepository>(context, listen: false);
      final result = await repository.updateTransactionStatus(
        transactionId: widget.transactionId,
        status: status,
      );
      
      if (result['success']) {
        // Update local transaction status
        setState(() {
          if (_transaction != null) {
            _transaction = Transaction(
              transactionId: _transaction!.transactionId,
              userId: _transaction!.userId,
              collectionPointId: _transaction!.collectionPointId,
              wasteTypeId: _transaction!.wasteTypeId,
              quantity: _transaction!.quantity,
              unit: _transaction!.unit,
              transactionDate: _transaction!.transactionDate,
              status: status,
              proofImageUrl: _transaction!.proofImageUrl,
              userName: _transaction!.userName,
              username: _transaction!.username,
              collectionPointName: _transaction!.collectionPointName,
              wasteTypeName: _transaction!.wasteTypeName,
            );
          }
          _isUpdatingStatus = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trạng thái giao dịch đã được cập nhật thành: ${_getStatusText(status)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      setState(() {
        _isUpdatingStatus = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildTransactionDetails(),
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
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadTransactionDetails();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    if (_transaction == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin giao dịch'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfoSection('THÔNG TIN GIAO DỊCH', [
            _buildInfoRow('Mã giao dịch', '#${_transaction!.transactionId}'),
            _buildInfoRow('Trạng thái', _getStatusText(_transaction!.status)),
            _buildInfoRow('Loại rác', _transaction!.wasteTypeName),
            _buildInfoRow('Số lượng', '${_transaction!.quantity} ${_transaction!.unit}'),
            _buildInfoRow('Ngày giao dịch', _formatDate(_transaction!.transactionDate)),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('THÔNG TIN NGƯỜI DÙNG', [
            _buildInfoRow('Mã người dùng', '#${_transaction!.userId}'),
            _buildInfoRow('Tên người dùng', _transaction!.userName ?? 'Không xác định'),
            _buildInfoRow('Tên đăng nhập', _transaction!.username ?? 'Không xác định'),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('THÔNG TIN ĐIỂM THU GOM', [
            _buildInfoRow('Mã điểm thu gom', '#${_transaction!.collectionPointId}'),
            _buildInfoRow('Tên điểm thu gom', _transaction!.collectionPointName),
          ]),
          if (_transaction!.proofImageUrl != null) ...[
            const SizedBox(height: 24),
            _buildImageSection('HÌNH ẢNH MINH CHỨNG', _transaction!.proofImageUrl!),
          ],
          if (_isAdmin) ...[
            const SizedBox(height: 24),
            _buildAdminStatusControls(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_transaction!.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getStatusColor(_transaction!.status).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWasteTypeIcon(_transaction!.wasteTypeName),
              color: _getStatusColor(_transaction!.status),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_transaction!.quantity} ${_transaction!.unit} ${_transaction!.wasteTypeName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_transaction!.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(_transaction!.status),
                    style: TextStyle(
                      color: _getStatusColor(_transaction!.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminStatusControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUẢN LÝ TRẠNG THÁI (ADMIN)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cập nhật trạng thái giao dịch',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              _isUpdatingStatus 
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusButton('pending', 'Chờ xử lý'),
                      _buildStatusButton('verified', 'Xác nhận'),
                      _buildStatusButton('completed', 'Hoàn thành'),
                      _buildStatusButton('rejected', 'Hủy bỏ'),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String status, String label) {
    final bool isCurrentStatus = _transaction?.status == status;
    final Color statusColor = _getStatusColor(status);
    
    return ElevatedButton(
      onPressed: isCurrentStatus ? null : () => _updateTransactionStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? statusColor : statusColor.withOpacity(0.1),
        foregroundColor: isCurrentStatus ? Colors.white : statusColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        disabledBackgroundColor: statusColor,
        disabledForegroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  IconData _getWasteTypeIcon(String wasteType) {
    if (wasteType.toLowerCase().contains('nhựa')) {
      return Icons.delete_outline;
    } else if (wasteType.toLowerCase().contains('giấy')) {
      return Icons.description_outlined;
    } else if (wasteType.toLowerCase().contains('điện')) {
      return Icons.devices_outlined;
    } else if (wasteType.toLowerCase().contains('kim loại')) {
      return Icons.settings_outlined;
    } else if (wasteType.toLowerCase().contains('thủy tinh')) {
      return Icons.local_drink_outlined;
    } else {
      return Icons.delete_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'verified':
        return Colors.blue;
      case 'processing':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'verified':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'completed':
        return 'Hoàn thành';
      case 'rejected':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
} 