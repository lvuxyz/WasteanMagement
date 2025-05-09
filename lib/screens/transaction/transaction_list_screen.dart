import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);
  
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _filterOption = 'all';
  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredTransactions = [];
  
  final List<Map<String, dynamic>> _dummyTransactions = [
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _filteredTransactions = List.from(_dummyTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = _filterTransactions(_dummyTransactions, _filterOption);
      } else {
        _filteredTransactions = _dummyTransactions.where((transaction) {
          return transaction['username'].toLowerCase().contains(query) ||
                 transaction['wasteType'].toLowerCase().contains(query) ||
                 transaction['id'].toString().contains(query);
        }).toList();
        
        _filteredTransactions = _filterTransactions(_filteredTransactions, _filterOption);
      }
    });
  }

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> transactions, String filter) {
    if (filter == 'all') {
      return transactions;
    }
    return transactions.where((transaction) => transaction['status'] == filter).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterOption = filter;
      _filteredTransactions = _filterTransactions(_dummyTransactions, filter);
      
      // Also apply any existing search filter
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
    });
  }

  void _navigateToDetails(int transactionId) {
    Navigator.pushNamed(
      context,
      '/transaction-details',
      arguments: transactionId,
    ).then((_) {
      // Refresh the list when returning from details
      // In a real app, this would fetch updated data from the backend
    });
  }

  void _navigateToEdit(int transactionId) {
    Navigator.pushNamed(
      context,
      '/edit-transaction',
      arguments: transactionId,
    ).then((_) {
      // Refresh the list when returning from edit
      // In a real app, this would fetch updated data from the backend
    });
  }

  void _refreshTransactions() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call with a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        // Refresh the filtered transactions
        _filteredTransactions = _filterTransactions(_dummyTransactions, _filterOption);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Danh sách giao dịch đã được làm mới'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _showDeleteConfirmation(int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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
      _isLoading = true;
    });
    
    // Simulate API call with a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _dummyTransactions.removeWhere((transaction) => transaction['id'] == transactionId);
        _filteredTransactions = _filterTransactions(_dummyTransactions, _filterOption);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giao dịch đã được xóa thành công'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
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
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _refreshTransactions();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction').then((_) {
            // Refresh the list when returning from add
            // In a real app, this would fetch updated data from the backend
          });
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'Tất cả'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Chờ xử lý'),
            const SizedBox(width: 8),
            _buildFilterChip('processing', 'Đang xử lý'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Hoàn thành'),
            const SizedBox(width: 8),
            _buildFilterChip('rejected', 'Đã hủy'),
          ],
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(transaction['id']),
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
                      color: _getStatusColor(transaction['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(transaction['status']),
                      color: _getStatusColor(transaction['status']),
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
                          'Mã: #${transaction['id']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Người dùng: ${transaction['username']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loại rác: ${transaction['wasteType']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số lượng: ${transaction['quantity']} ${transaction['unit']}',
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
                          color: _getStatusColor(transaction['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(transaction['status']),
                          style: TextStyle(
                            color: _getStatusColor(transaction['status']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (String value) {
                          if (value == 'view') {
                            _navigateToDetails(transaction['id']);
                          } else if (value == 'edit') {
                            _navigateToEdit(transaction['id']);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(transaction['id']);
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
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Xóa giao dịch'),
                              ],
                            ),
                          ),
                        ],
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
                    'Ngày: ${transaction['date']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Points for completed transactions
                  if (transaction['status'] == 'completed')
                    Row(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${transaction['points']} điểm',
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
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