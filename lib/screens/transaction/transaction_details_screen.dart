import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailsScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // In a real app, we would load the transaction data here
    // loadTransactionDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Dummy transaction data for UI mockup
    final transaction = _getDummyTransaction(widget.transactionId);

    final statusColor = _getStatusColor(transaction['status']);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: statusColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit-transaction',
                      arguments: widget.transactionId,
                    ).then((value) {
                      if (value == true) {
                        // Reload details after edit
                        setState(() {
                          // This would be replaced with actual API call
                        });
                      }
                    });
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Giao dịch #${widget.transactionId}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Icon overlay with some transparency
                    Positioned(
                      right: -50,
                      bottom: -20,
                      child: Icon(
                        _getStatusIcon(transaction['status']),
                        size: 200,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Status badge
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(transaction['status']),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(transaction['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Date badge
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              transaction['date'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Thông tin giao dịch'),
                  Tab(text: 'Lịch sử giao dịch'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Transaction Information
            _buildTransactionInfoTab(transaction),
            
            // Tab 2: Transaction History
            _buildTransactionHistoryTab(transaction),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showStatusUpdateDialog(context, transaction);
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.update),
        label: const Text('Cập nhật trạng thái'),
      ),
    );
  }

  Widget _buildTransactionInfoTab(Map<String, dynamic> transaction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin chung'),
          _buildInfoCard([
            _buildInfoRow('Mã giao dịch', '#${transaction['id']}'),
            _buildInfoRow('Ngày tạo', transaction['date']),
            _buildInfoRow('Trạng thái', _getStatusText(transaction['status'])),
            if (transaction['status'] == 'completed')
              _buildInfoRow('Điểm thưởng', '+${transaction['points']} điểm'),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin người dùng'),
          _buildInfoCard([
            _buildInfoRow('Người dùng', transaction['username']),
            _buildInfoRow('Email', '${transaction['username']}@example.com'),
            _buildInfoRow('Số điện thoại', '0123456789'),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Chi tiết rác thải'),
          _buildInfoCard([
            _buildInfoRow('Loại rác', transaction['wasteType']),
            _buildInfoRow('Số lượng', '${transaction['quantity']} ${transaction['unit']}'),
            _buildInfoRow('Đơn giá', '${transaction['unitPrice']} đ/${transaction['unit']}'),
            _buildInfoRow('Tổng giá trị', '${transaction['quantity'] * transaction['unitPrice']} đ'),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Địa điểm thu gom'),
          _buildInfoCard([
            _buildInfoRow('Điểm thu gom', transaction['collectionPoint']),
            _buildInfoRow('Địa chỉ', transaction['address']),
          ]),

          const SizedBox(height: 24),
          if (transaction['notes'] != null && transaction['notes'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Ghi chú'),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      transaction['notes'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryTab(Map<String, dynamic> transaction) {
    final List<Map<String, dynamic>> history = [
      {
        'status': 'pending',
        'timestamp': '12/11/2023 09:00',
        'description': 'Giao dịch được tạo',
        'user': 'user123',
      },
      {
        'status': 'processing',
        'timestamp': '12/11/2023 10:30',
        'description': 'Giao dịch đang được xử lý',
        'user': 'admin',
      },
      {
        'status': 'completed',
        'timestamp': '12/11/2023 15:45',
        'description': 'Giao dịch hoàn thành thành công',
        'user': 'admin',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final historyItem = history[index];
        final isLast = index == history.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getStatusColor(historyItem['status']),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getStatusIcon(historyItem['status']),
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historyItem['timestamp'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    historyItem['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bởi: ${historyItem['user']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cập nhật trạng thái'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.pending_outlined, color: Colors.orange),
                title: const Text('Chờ xử lý'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _updateTransactionStatus('pending');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_top, color: Colors.blue),
                title: const Text('Đang xử lý'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _updateTransactionStatus('processing');
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Hoàn thành'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _updateTransactionStatus('completed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text('Đã hủy'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _updateTransactionStatus('rejected');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTransactionStatus(String status) {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trạng thái đã được cập nhật thành: ${_getStatusText(status)}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Map<String, dynamic> _getDummyTransaction(int id) {
    // Dummy data for UI mockup
    return {
      'id': id,
      'username': 'user123',
      'wasteType': 'Chai nhựa',
      'quantity': 5.0,
      'unit': 'kg',
      'unitPrice': 2000,
      'status': 'completed',
      'date': '15/11/2023',
      'points': 10,
      'collectionPoint': 'Điểm thu gom An Phú',
      'address': '123 Đường Phạm Văn Đồng, Phường An Phú, Quận 2, TP.HCM',
      'notes': 'Khách hàng sẽ giao rác vào buổi sáng từ 7h-9h. Vui lòng liên hệ trước khi đến.',
    };
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