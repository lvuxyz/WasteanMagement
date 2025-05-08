import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../models/transaction.dart';
import '../../services/auth_service.dart';
import '../../repositories/transaction_repository.dart';
import '../../core/api/api_client.dart';

class TransactionManagementScreen extends StatefulWidget {
  const TransactionManagementScreen({Key? key}) : super(key: key);

  @override
  State<TransactionManagementScreen> createState() => _TransactionManagementScreenState();
}

class _TransactionManagementScreenState extends State<TransactionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilterOption = 'all';
  final Map<int, bool> _deletingItems = {}; // Track which items are being deleted
  final Map<int, bool> _updatingItems = {}; // Track which items are being updated
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _checkIsAdmin();
  }

  Future<void> _checkIsAdmin() async {
    final authService = AuthService();
    final isAdmin = await authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      // Using Builder here to get the correct BlocProvider context
      Builder(
        builder: (context) {
          final bloc = context.read<TransactionBloc>();
          final state = bloc.state;
          
          if (!state.hasReachedMax) {
            if (_isAdmin) {
              bloc.add(FetchTransactions(
                page: state.currentPage + 1,
                limit: 10,
                status: _selectedFilterOption == 'all' ? null : _selectedFilterOption,
              ));
            } else {
              bloc.add(FetchMyTransactions(
                page: state.currentPage + 1,
                limit: 10,
                status: _selectedFilterOption == 'all' ? null : _selectedFilterOption,
              ));
            }
          }
          return const SizedBox.shrink();
        }
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged() {
    // Will be implemented with search functionality
    // context.read<TransactionBloc>().add(SearchTransactions(_searchController.text));
  }

  void _showDeleteConfirmation(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Builder(
          builder: (innerContext) {
            return AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    
                    // Đánh dấu là đang xóa để hiển thị loading
                    setState(() {
                      _deletingItems[transactionId] = true;
                    });
                    
                    // Thực hiện xóa qua BlocProvider
                    try {
                      innerContext.read<TransactionBloc>().add(
                        DeleteTransaction(transactionId: transactionId)
                      );
                    } catch (e) {
                      print("Error sending delete event: $e");
                    }
                    
                    // Xóa trạng thái loading sau 2 giây
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _deletingItems.remove(transactionId);
                        });
                      }
                    });
                  },
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _updateTransactionStatus(int transactionId, String status) {
    // Đánh dấu là đang cập nhật để hiển thị loading
    setState(() {
      _updatingItems[transactionId] = true;
    });
    
    // Tạo widget Builder để lấy context chứa BlocProvider
    Builder(
      builder: (innerContext) {
        try {
          // Gửi sự kiện cập nhật qua BlocProvider
          innerContext.read<TransactionBloc>().add(
            UpdateTransactionStatus(
              transactionId: transactionId,
              status: status,
            ),
          );
        } catch (e) {
          print("Error sending update status event: $e");
        }
        return const SizedBox.shrink();
      }
    );
    
    // Xóa trạng thái loading sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _updatingItems.remove(transactionId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy TransactionRepository từ context cha
    final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
    
    return BlocProvider<TransactionBloc>(
      create: (context) => TransactionBloc(transactionRepository: transactionRepository),
      child: Builder(
        builder: (context) {
          // Gọi load transactions tự động khi BlocProvider được tạo
          Future.microtask(() => 
            context.read<TransactionBloc>().add(RefreshTransactions())
          );
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quản lý giao dịch'),
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Column(
              children: [
                _buildSearchBar(),
                _buildFilterTabs(),
                Expanded(
                  child: _buildTransactionList(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-transaction');
              },
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add),
            ),
          );
        }
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm giao dịch...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterTab('all', 'Tất cả'),
            _buildFilterTab('pending', 'Chờ xử lý'),
            _buildFilterTab('processing', 'Đang xử lý'),
            _buildFilterTab('completed', 'Hoàn thành'),
            _buildFilterTab('rejected', 'Đã hủy'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final bool isSelected = _selectedFilterOption == value;
    
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedFilterOption = value;
            });
            
            // Refresh transactions with the new filter
            if (_isAdmin) {
              context.read<TransactionBloc>().add(FetchTransactions(
                status: value == 'all' ? null : value,
              ));
            } else {
              context.read<TransactionBloc>().add(FetchMyTransactions(
                status: value == 'all' ? null : value,
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == TransactionStatus.loading && state.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == TransactionStatus.failure) {
          return _buildErrorState(state.errorMessage ?? 'Không thể tải danh sách giao dịch');
        }
        
        if (state.transactions.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.separated(
          controller: _scrollController,
          itemCount: state.hasReachedMax
              ? state.transactions.length
              : state.transactions.length + 1,
          separatorBuilder: (context, index) => const Divider(height: 1),
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
        );
      },
    );
  }
  
  Widget _buildErrorState(String errorMessage) {
    return Builder(
      builder: (context) {
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
                errorMessage,
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
                  context.read<TransactionBloc>().add(RefreshTransactions());
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có giao dịch nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Giao dịch sẽ xuất hiện ở đây sau khi được tạo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isDeleting = _deletingItems[transaction.transactionId] ?? false;
    final isUpdating = _updatingItems[transaction.transactionId] ?? false;
    
    // Show loading indicators if necessary
    if (isDeleting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Builder(
      builder: (innerContext) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWasteTypeIcon(transaction.wasteTypeName),
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${transaction.quantity} ${transaction.unit} ${transaction.wasteTypeName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người dùng: ${transaction.username ?? transaction.userName ?? "Không xác định"}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  if (transaction.status == 'completed')
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          color: AppColors.primaryGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+10 điểm', // Points will be implemented based on API data
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          trailing: isUpdating 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (String value) {
                    if (value == 'view') {
                      Navigator.pushNamed(
                        context,
                        '/transaction-details',
                        arguments: transaction.transactionId,
                      );
                    } else if (value == 'edit') {
                      Navigator.pushNamed(
                        context,
                        '/edit-transaction',
                        arguments: transaction.transactionId,
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(innerContext, transaction.transactionId);
                    } else if (value.startsWith('status_')) {
                      final status = value.substring(7);
                      _updateTransactionStatus(transaction.transactionId, status);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Text('Xem chi tiết'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Chỉnh sửa'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'status_pending',
                      child: Text('Đặt trạng thái: Chờ xử lý'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'status_processing',
                      child: Text('Đặt trạng thái: Đang xử lý'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'status_completed',
                      child: Text('Đặt trạng thái: Hoàn thành'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'status_rejected',
                      child: Text('Đặt trạng thái: Đã hủy'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Xóa giao dịch'),
                    ),
                  ],
                ),
        );
      }
    );
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
      case 'processing':
        return Colors.blue;
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