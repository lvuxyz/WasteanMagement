import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/models/transaction.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/services/auth_service.dart';
import 'package:wasteanmagement/utils/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;
  bool _isAdmin = false;
  late AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _checkAdminStatus();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isAdmin();
    print('TransactionsScreen - User is admin: $isAdmin');
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (_isAdmin) {
        context.read<TransactionBloc>().add(
          FetchTransactions(
            page: context.read<TransactionBloc>().state.currentPage + 1,
            limit: 10,
            status: _selectedStatus,
          ),
        );
      } else {
        context.read<TransactionBloc>().add(
          FetchMyTransactions(
            page: context.read<TransactionBloc>().state.currentPage + 1,
            limit: 10,
            status: _selectedStatus,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final isAdmin = snapshot.data ?? false;
        print('TransactionsScreen build - Admin status from future: $isAdmin');
        
        return BlocProvider(
          create: (context) {
            final apiClient = context.read<ApiClient>();
            final transactionRepository = TransactionRepository(apiClient: apiClient);
            final bloc = TransactionBloc(transactionRepository: transactionRepository);
            
            if (isAdmin) {
              print('Adding FetchTransactions event - admin user confirmed');
              bloc.add(FetchTransactions(limit: 10));
            } else {
              print('Adding FetchMyTransactions event - regular user confirmed');
              bloc.add(FetchMyTransactions(limit: 10));
            }
            
            return bloc;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(isAdmin ? 'Quản lý giao dịch' : 'Giao dịch của bạn'),
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                if (isAdmin)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'add') {
                        Navigator.pushNamed(context, '/create-transaction');
                      } else if (value == 'edit') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chọn một giao dịch để chỉnh sửa'))
                        );
                      } else if (value == 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chọn một giao dịch để xóa'))
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: AppColors.primaryGreen),
                            SizedBox(width: 8),
                            Text('Thêm giao dịch'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primaryGreen),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa giao dịch'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa giao dịch'),
                          ],
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    context.read<TransactionBloc>().add(RefreshTransactions());
                  },
                ),
              ],
            ),
            floatingActionButton: isAdmin ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-transaction');
              },
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add),
            ) : null,
            body: Column(
              children: [
                _buildFilterBar(context, isAdmin),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state.status == TransactionStatus.initial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == TransactionStatus.loading && state.transactions.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == TransactionStatus.failure) {
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
                                'Không thể tải danh sách giao dịch',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              if (state.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('Retrying transaction fetch for ${isAdmin ? 'admin' : 'user'}');
                                  context.read<TransactionBloc>().add(RefreshTransactions());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (state.transactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primaryGreen,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Không có giao dịch nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (isAdmin)
                                const Text(
                                  'Chưa có giao dịch nào được tạo trong hệ thống',
                                  textAlign: TextAlign.center,
                                )
                              else
                                const Text(
                                  'Bạn chưa có giao dịch nào. Hãy tạo giao dịch mới!',
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        );
                      }
                      
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TransactionBloc>().add(RefreshTransactions());
                          return Future.delayed(const Duration(milliseconds: 300));
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.hasReachedMax
                              ? state.transactions.length
                              : state.transactions.length + 1,
                          itemBuilder: (context, index) {
                            if (index >= state.transactions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            
                            return _buildTransactionItem(state.transactions[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFilterBar(BuildContext context, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('Lọc theo trạng thái:'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedStatus,
                hint: const Text('Tất cả'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tất cả'),
                  ),
                  ...['pending', 'processing', 'completed', 'rejected'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(_getStatusText(status)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  if (isAdmin) {
                    context.read<TransactionBloc>().add(
                      FetchTransactions(status: value, limit: 10),
                    );
                  } else {
                    context.read<TransactionBloc>().add(
                      FetchMyTransactions(status: value, limit: 10),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final IconData icon = _getWasteTypeIcon(transaction.wasteTypeName);
    final Color iconColor = _getWasteTypeColor(transaction.wasteTypeName);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transaction.quantity} ${transaction.unit} ${transaction.wasteTypeName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.collectionPointName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isAdmin)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'view') {
                        // View transaction details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xem chi tiết giao dịch'))
                        );
                      } else if (value == 'edit') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chỉnh sửa giao dịch'))
                        );
                      } else if (value == 'delete') {
                        _showDeleteTransactionDialog(transaction);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: AppColors.primaryGreen),
                            SizedBox(width: 8),
                            Text('Xem chi tiết'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primaryGreen),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatter.format(transaction.transactionDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (transaction.status == 'completed')
                  Row(
                    children: [
                      const Icon(
                        Icons.eco_outlined,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '+12 điểm',  // Replace with actual points when available
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTransactionDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete functionality will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa sẽ được cập nhật sau'))
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getWasteTypeIcon(String wasteType) {
    if (wasteType.toLowerCase().contains('plastic')) {
      return Icons.delete_outline;
    } else if (wasteType.toLowerCase().contains('paper') || 
               wasteType.toLowerCase().contains('cardboard')) {
      return Icons.description_outlined;
    } else if (wasteType.toLowerCase().contains('electronic')) {
      return Icons.devices_outlined;
    } else if (wasteType.toLowerCase().contains('metal')) {
      return Icons.settings_outlined;
    } else if (wasteType.toLowerCase().contains('glass')) {
      return Icons.local_drink_outlined;
    } else {
      return Icons.delete_outline;
    }
  }

  Color _getWasteTypeColor(String wasteType) {
    if (wasteType.toLowerCase().contains('plastic')) {
      return Colors.blue;
    } else if (wasteType.toLowerCase().contains('paper') || 
               wasteType.toLowerCase().contains('cardboard')) {
      return Colors.amber;
    } else if (wasteType.toLowerCase().contains('electronic')) {
      return Colors.purple;
    } else if (wasteType.toLowerCase().contains('metal')) {
      return Colors.blueGrey;
    } else if (wasteType.toLowerCase().contains('glass')) {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
} 