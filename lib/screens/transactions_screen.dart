import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/models/transaction.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/utils/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionBloc>().add(
        FetchMyTransactions(
          page: context.read<TransactionBloc>().state.currentPage + 1,
          limit: 10,
        ),
      );
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
    return BlocProvider(
      create: (context) {
        final apiClient = context.read<ApiClient>();
        final transactionRepository = TransactionRepository(apiClient: apiClient);
        final bloc = TransactionBloc(transactionRepository: transactionRepository);
        bloc.add(FetchMyTransactions(limit: 10));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giao dịch của bạn'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state.status == TransactionStatus.initial || 
                (state.status == TransactionStatus.loading && state.transactions.isEmpty)) {
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
                  ],
                ),
              );
            }
            
            if (state.transactions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryGreen,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Không có giao dịch nào',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bạn chưa có giao dịch nào trong hệ thống',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
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
            );
          },
        ),
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