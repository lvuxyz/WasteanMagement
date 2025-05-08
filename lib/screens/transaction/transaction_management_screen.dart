import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TransactionManagementScreen extends StatefulWidget {
  const TransactionManagementScreen({Key? key}) : super(key: key);

  @override
  State<TransactionManagementScreen> createState() => _TransactionManagementScreenState();
}

class _TransactionManagementScreenState extends State<TransactionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilterOption = 'all';
  Map<int, bool> _deletingItems = {}; // Track which items are being deleted
  Map<int, bool> _updatingItems = {}; // Track which items are being updated

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      // This would be implemented with actual bloc
      // context.read<TransactionBloc>().add(
      //   FetchMoreTransactions(
      //     page: context.read<TransactionBloc>().state.currentPage + 1,
      //     limit: 10,
      //   ),
      // );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged() {
    // Will be implemented with actual bloc
    // context.read<TransactionBloc>().add(SearchTransactions(_searchController.text));
  }

  void _showDeleteConfirmation(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                _deleteTransaction(transactionId);
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(int transactionId) {
    setState(() {
      _deletingItems[transactionId] = true;
    });

    // This would be implemented with actual bloc
    // context.read<TransactionBloc>().add(DeleteTransaction(transactionId));
    
    // Simulate deletion for UI mockup
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _deletingItems[transactionId] = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giao dịch đã được xóa thành công'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _updateTransactionStatus(int transactionId, String status) {
    setState(() {
      _updatingItems[transactionId] = true;
    });

    // This would be implemented with actual bloc
    // context.read<TransactionBloc>().add(UpdateTransactionStatus(transactionId, status));
    
    // Simulate update for UI mockup
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _updatingItems[transactionId] = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trạng thái giao dịch đã được cập nhật'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterOption = value;
        });
        // This would be implemented with actual bloc
        // context.read<TransactionBloc>().add(FilterTransactions(value));
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

  Widget _buildTransactionList() {
    // This would be a BlocBuilder in a real app
    // return BlocBuilder<TransactionBloc, TransactionState>(
    //   builder: (context, state) {
    //     if (state.status == TransactionStatus.initial || 
    //         (state.status == TransactionStatus.loading && state.transactions.isEmpty)) {
    //       return const Center(child: CircularProgressIndicator());
    //     } else if (state.status == TransactionStatus.failure) {
    //       return _buildErrorState();
    //     }
        
    //     if (state.transactions.isEmpty) {
    //       return _buildEmptyState();
    //     }
        
    //     return ListView.separated(
    //       controller: _scrollController,
    //       itemCount: state.hasReachedMax
    //           ? state.transactions.length
    //           : state.transactions.length + 1,
    //       separatorBuilder: (context, index) => const Divider(height: 1),
    //       itemBuilder: (context, index) {
    //         if (index >= state.transactions.length) {
    //           return const Center(
    //             child: Padding(
    //               padding: EdgeInsets.symmetric(vertical: 16.0),
    //               child: CircularProgressIndicator(),
    //             ),
    //           );
    //         }
                
    //         return _buildTransactionItem(state.transactions[index]);
    //       },
    //     );
    //   },
    // );

    // For now, use dummy data    
    final dummyTransactions = _generateDummyTransactions();
    
    if (dummyTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: dummyTransactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = dummyTransactions[index];
        return _buildTransactionItem(transaction);
      },
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
            'Không thể tải danh sách giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // This would be implemented with actual bloc
              // context.read<TransactionBloc>().add(FetchTransactions());
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

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isDeleting = _deletingItems[transaction['id']] ?? false;
    final isUpdating = _updatingItems[transaction['id']] ?? false;
    
    // Show loading indicators if necessary
    if (isDeleting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
          _getWasteTypeIcon(transaction['wasteType']),
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${transaction['quantity']} ${transaction['unit']} ${transaction['wasteType']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(transaction['status']),
              style: TextStyle(
                color: _getStatusColor(transaction['status']),
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
            'Người dùng: ${transaction['username']}',
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
                transaction['date'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (transaction['status'] == 'completed')
                Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      color: AppColors.primaryGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${transaction['points']} điểm',
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
                    arguments: transaction['id'],
                  );
                } else if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    '/edit-transaction',
                    arguments: transaction['id'],
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, transaction['id']);
                } else if (value.startsWith('status_')) {
                  final status = value.substring(7);
                  _updateTransactionStatus(transaction['id'], status);
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

  List<Map<String, dynamic>> _generateDummyTransactions() {
    // Dummy data for UI mockup
    return [
      {
        'id': 1001,
        'username': 'user123',
        'wasteType': 'Chai nhựa',
        'quantity': 5.0,
        'unit': 'kg',
        'status': 'completed',
        'date': '15/11/2023',
        'points': 10,
      },
      {
        'id': 1002,
        'username': 'greenuser',
        'wasteType': 'Giấy vụn',
        'quantity': 3.5,
        'unit': 'kg',
        'status': 'processing',
        'date': '14/11/2023',
        'points': 0,
      },
      {
        'id': 1003,
        'username': 'recycle_hero',
        'wasteType': 'Pin điện',
        'quantity': 0.5,
        'unit': 'kg',
        'status': 'pending',
        'date': '13/11/2023',
        'points': 0,
      },
      {
        'id': 1004,
        'username': 'eco_friendly',
        'wasteType': 'Lon kim loại',
        'quantity': 2.0,
        'unit': 'kg',
        'status': 'rejected',
        'date': '12/11/2023',
        'points': 0,
      },
      {
        'id': 1005,
        'username': 'earth_lover',
        'wasteType': 'Thủy tinh',
        'quantity': 4.0,
        'unit': 'kg',
        'status': 'completed',
        'date': '11/11/2023',
        'points': 8,
      },
    ];
  }
} 