import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/auth_service.dart';
import '../../models/transaction.dart';
import '../../core/api/api_constants.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);
  
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _filterOption = 'all';
  bool _isAdmin = false;
  bool _adminStatusChecked = false; // Flag để theo dõi trạng thái kiểm tra
  final AuthService _authService = AuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _printEndpointInfo();
    
    // Đăng ký observer để phát hiện khi app trở về từ background
    WidgetsBinding.instance.addObserver(this);
    
    // Kiểm tra admin status khi khởi tạo màn hình
    _checkAdminStatus();
  }
  
  // Đơn giản hóa phương thức khởi tạo dữ liệu
  Future<void> _initializeData() async {
    // Đảm bảo đã kiểm tra admin status trước khi tải dữ liệu
    if (!_adminStatusChecked) {
      await _checkAdminStatus();
    }
    
    setState(() {
      _isInitialized = true;
    });
    
    // Tải giao dịch dựa trên vai trò
    _loadTransactionsBasedOnRole();
  }
  
  // Cải thiện phương thức kiểm tra admin status
  Future<void> _checkAdminStatus() async {
    try {
      // Sử dụng phương thức forceAdminCheck để bỏ qua cache nếu cần thiết
      final isAdmin = await _authService.forceAdminCheck();
      print('TRANSACTION LIST: Admin status = $isAdmin');
      
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _adminStatusChecked = true;
          
          // Khởi tạo dữ liệu nếu chưa được khởi tạo
          if (!_isInitialized) {
            _isInitialized = true;
            _loadTransactionsBasedOnRole();
          }
        });
      }
    } catch (e) {
      print('TRANSACTION LIST: Error checking admin status: $e');
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _adminStatusChecked = true;
          
          // Khởi tạo dữ liệu với quyền người dùng thường
          if (!_isInitialized) {
            _isInitialized = true;
            _loadTransactionsBasedOnRole();
          }
        });
      }
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Khi app trở về từ nền, kiểm tra lại trạng thái admin
    if (state == AppLifecycleState.resumed) {
      _checkAdminStatus();
    }
  }
  
  @override 
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Kiểm tra admin status mỗi khi context thay đổi
    _checkAdminStatus();
  }

  void _loadTransactionsBasedOnRole() async {
    try {
      final bloc = context.read<TransactionBloc>();
      
      if (_isAdmin) {
        print('Loading admin transactions with isAdmin flag set to true');
        bloc.add(FetchTransactions(
          status: _filterOption == 'all' ? null : _filterOption,
          page: 1,
          limit: 10,
          isAdmin: true,
        ));
      } else {
        print('Loading user transactions');
        bloc.add(FetchMyTransactions(
          status: _filterOption == 'all' ? null : _filterOption,
          page: 1,
          limit: 10,
        ));
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  void _onSearchChanged() {
    // Will be implemented to filter transactions by search term
    // context.read<TransactionBloc>().add(SearchTransactions(_searchController.text));
  }

  void _onScroll() {
    if (_isBottom) {
      // Load more transactions when scrolled to bottom
      final state = context.read<TransactionBloc>().state;
      
      if (!state.hasReachedMax) {
        if (_isAdmin) {
          print('Loading more admin transactions, page: ${state.currentPage + 1}');
          context.read<TransactionBloc>().add(FetchTransactions(
            page: state.currentPage + 1,
            limit: 10,
            status: _filterOption == 'all' ? null : _filterOption,
            isAdmin: true,
          ));
        } else {
          print('Loading more user transactions, page: ${state.currentPage + 1}');
          context.read<TransactionBloc>().add(FetchMyTransactions(
            page: state.currentPage + 1,
            limit: 10,
            status: _filterOption == 'all' ? null : _filterOption,
          ));
        }
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterOption = filter;
    });
    
    // Refresh with new filter
    _refreshTransactions();
  }

  void _navigateToDetails(int transactionId) {
    Navigator.pushNamed(
      context,
      '/transaction-details',
      arguments: transactionId,
    ).then((_) {
      // Kiểm tra admin status khi quay lại
      _checkAdminStatus();
      // Refresh the list when returning from details
      _refreshTransactions();
    });
  }

  void _navigateToEdit(int transactionId) {
    Navigator.pushNamed(
      context,
      '/edit-transaction',
      arguments: transactionId,
    ).then((_) {
      // Kiểm tra admin status khi quay lại
      _checkAdminStatus();
      // Refresh the list when returning from edit
      _refreshTransactions();
    });
  }

  void _refreshTransactions() {
    // Reset to first page when refreshing
    _loadTransactionsBasedOnRole();
  }

  void _printEndpointInfo() {
    print('===== API INFO =====');
    print('Regular endpoint: ${ApiConstants.transactions}');
    print('Admin endpoint: http://localhost:5000/api/v1/transactions');
    print('====================');
  }

  @override
  Widget build(BuildContext context) {
    // Get transaction repository from provider
    final transactionRepository = Provider.of<TransactionRepository>(context, listen: false);
    
    // Sử dụng FutureBuilder để hiển thị UI dựa trên admin status
    return FutureBuilder<bool>(
      // Sử dụng phương thức isAdmin từ AuthService
      future: _authService.isAdmin(),
      builder: (context, snapshot) {
        // Cập nhật biến state dựa trên kết quả từ Future
        final bool isAdmin = snapshot.data ?? false;
        
        // Cập nhật _isAdmin nếu cần
        if (isAdmin != _isAdmin && snapshot.connectionState == ConnectionState.done) {
          _isAdmin = isAdmin;
          print('Admin status updated in build: $_isAdmin');
          
          // Reload transactions if needed
          if (_isInitialized) {
            Future.microtask(() => _loadTransactionsBasedOnRole());
          }
        }
        
        // Create a new TransactionBloc
        return BlocProvider(
          create: (context) {
            final bloc = TransactionBloc(transactionRepository: transactionRepository);
            
            // Chỉ tải giao dịch nếu đã khởi tạo
            if (_isInitialized) {
              print('TransactionListScreen build: isAdmin=$_isAdmin, initializing transactions');
              _loadTransactionsBasedOnRole();
            }
            
            return bloc;
          },
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              // Debugging
              print('TransactionState: ${state.status}, transactions: ${state.transactions.length}, isAdmin: $_isAdmin');
              
              return Scaffold(
                appBar: AppBar(
                  title: Text(_isAdmin ? 'Tất cả giao dịch' : 'Giao dịch của tôi'),
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshTransactions,
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    _buildSearchBar(),
                    
                    // Filter options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'Tất cả'),
                            const SizedBox(width: 8),
                            _buildFilterChip('pending', 'Chờ xử lý'),
                            const SizedBox(width: 8),
                            _buildFilterChip('verified', 'Đã xác nhận'),
                            const SizedBox(width: 8),
                            _buildFilterChip('processing', 'Đang xử lý'),
                            const SizedBox(width: 8),
                            _buildFilterChip('completed', 'Hoàn thành'),
                            const SizedBox(width: 8),
                            _buildFilterChip('rejected', 'Đã hủy'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Expanded(
                      child: _buildTransactionList(state),
                    ),
                  ],
                ),
                floatingActionButton: _isAdmin 
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-transaction').then((_) {
                          // Refresh the list when returning from add
                          _refreshTransactions();
                        });
                      },
                      backgroundColor: AppColors.primaryGreen,
                      child: const Icon(Icons.add),
                    )
                  : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(TransactionState state) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.status == TransactionStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.status == TransactionStatus.loading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.status == TransactionStatus.failure) {
      return _buildErrorState(state.errorMessage);
    }
    
    if (state.transactions.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        _refreshTransactions();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
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
          return _buildTransactionCard(state.transactions[index]);
        },
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
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
            errorMessage ?? 'Đã xảy ra lỗi khi tải danh sách giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshTransactions,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _filterOption == value;
    
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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
            'Không tìm thấy giao dịch phù hợp với bộ lọc hiện tại',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onFilterChanged('all');
            },
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Xóa bộ lọc'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(transaction.transactionId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(transaction.status),
                      color: _getStatusColor(transaction.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Transaction info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã: #${transaction.transactionId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Người dùng: ${transaction.userName ?? transaction.username ?? "Không xác định"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loại rác: ${transaction.wasteTypeName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số lượng: ${transaction.quantity} ${transaction.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(transaction.status),
                          style: TextStyle(
                            color: _getStatusColor(transaction.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Kiểm tra đúng trạng thái admin và trạng thái giao dịch
                      Visibility(
                        visible: _isAdmin && transaction.status != 'completed',
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _navigateToEdit(transaction.transactionId);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.primaryGreen),
                                    SizedBox(width: 8),
                                    Text('Chỉnh sửa trạng thái giao dịch'),
                                  ],
                                ),
                              ),
                            ];
                          },
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
                  // Date
                  Text(
                    'Ngày: ${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Points for completed transactions
                  if (transaction.status == 'completed')
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '+10 điểm', // Points amount would be from API in real implementation
                          style: TextStyle(
                            color: Colors.green,
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
      ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'verified':
        return Icons.verified;
      case 'processing':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
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