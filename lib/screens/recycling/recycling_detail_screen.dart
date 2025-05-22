import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/recycling/recycling_bloc.dart';
import '../../blocs/recycling/recycling_event.dart';
import '../../blocs/recycling/recycling_state.dart';
import '../../models/recycling_process_model.dart';
import '../../repositories/recycling_repository.dart';
import '../../services/recycling_service.dart';
import '../../core/network/network_info.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../core/api/api_client.dart';
import '../../utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'recycling_edit_screen.dart';

class RecyclingDetailScreen extends StatefulWidget {
  final String processId;

  const RecyclingDetailScreen({
    Key? key,
    required this.processId,
  }) : super(key: key);

  @override
  State<RecyclingDetailScreen> createState() => _RecyclingDetailScreenState();
}

class _RecyclingDetailScreenState extends State<RecyclingDetailScreen> {
  bool _isAdmin = false;
  final TextEditingController _notificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final authService = AuthService();
    final isAdmin = await authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  void _showNotificationDialog(BuildContext context, String processId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi thông báo'),
        content: TextField(
          controller: _notificationController,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung thông báo',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_notificationController.text.isNotEmpty) {
                context.read<RecyclingBloc>().add(
                  SendRecyclingNotification(
                    id: processId,
                    message: _notificationController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecyclingBloc(
        repository: RecyclingRepository(
          recyclingService: RecyclingService(
            apiClient: ApiClient(
              client: http.Client(),
              secureStorage: SecureStorage(),
            ),
          ),
          networkInfo: NetworkInfoImpl(),
        ),
      )..add(GetRecyclingProcessDetail(widget.processId)),
      child: BlocConsumer<RecyclingBloc, RecyclingState>(
        listener: (context, state) {
          if (state is RecyclingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state is RecyclingNotificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã gửi thông báo thành công'),
                backgroundColor: Colors.green,
              ),
            );
            _notificationController.clear();
          }
        },
        builder: (context, state) {
          if (state is RecyclingInitial || state is RecyclingLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết quy trình tái chế'),
                backgroundColor: AppColors.primaryGreen,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          
          if (state is RecyclingProcessLoaded) {
            final process = state.process;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết quy trình tái chế'),
                backgroundColor: AppColors.primaryGreen,
                actions: [
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecyclingEditScreen(process: process),
                          ),
                        ).then((_) {
                          context.read<RecyclingBloc>().add(
                            GetRecyclingProcessDetail(widget.processId),
                          );
                        });
                      },
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(process),
                    const SizedBox(height: 16),
                    _buildInfoCard(process),
                    const SizedBox(height: 16),
                    if (process.notes != null && process.notes!.isNotEmpty)
                      _buildNotesCard(process),
                    if (_isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _showNotificationDialog(context, process.id);
                              },
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Gửi thông báo cập nhật'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết quy trình tái chế'),
              backgroundColor: AppColors.primaryGreen,
            ),
            body: const Center(
              child: Text('Có lỗi xảy ra khi tải dữ liệu'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(RecyclingProcess process) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (process.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Đang chờ xử lý';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
        statusIcon = Icons.recycling;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.7),
              statusColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              statusIcon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(process.endDate ?? process.startDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RecyclingProcess process) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin quy trình',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Mã giao dịch', process.transactionId),
            _buildInfoRow('Loại rác', process.wasteTypeName),
            _buildInfoRow('Số lượng ban đầu', '${process.quantity ?? 0} kg'),
            if (process.processedQuantity != null)
              _buildInfoRow('Số lượng đã xử lý', '${process.processedQuantity} kg'),
            _buildInfoRow('Ngày bắt đầu', DateFormat('dd/MM/yyyy').format(process.startDate)),
            if (process.endDate != null)
              _buildInfoRow('Ngày kết thúc', DateFormat('dd/MM/yyyy').format(process.endDate!)),
            if (process.processedBy != null)
              _buildInfoRow('Người xử lý', process.processedBy!),
            _buildInfoRow('Mã người dùng', process.userId ?? 'Không có'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(RecyclingProcess process) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text(
              process.notes!,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
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
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 