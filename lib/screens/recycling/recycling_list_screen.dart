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
import 'recycling_detail_screen.dart';
import 'recycling_form_screen.dart';
import '../../services/auth_service.dart';

class RecyclingListScreen extends StatefulWidget {
  const RecyclingListScreen({Key? key}) : super(key: key);

  @override
  State<RecyclingListScreen> createState() => _RecyclingListScreenState();
}

class _RecyclingListScreenState extends State<RecyclingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isFilterExpanded = false;
  bool _isAdmin = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final authService = AuthService();
    final isAdmin = await authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final bloc = context.read<RecyclingBloc>();
      final state = bloc.state;
      if (state is RecyclingProcessesLoaded && state.page < state.totalPages) {
        _loadMoreData();
      }
    }
  }

  void _loadMoreData() {
    setState(() {
      _currentPage++;
    });
    
    _fetchRecyclingProcesses();
  }

  void _fetchRecyclingProcesses() {
    final fromDate = DateFormat('yyyy-MM-dd').format(_startDate);
    final toDate = DateFormat('yyyy-MM-dd').format(_endDate);
    
    context.read<RecyclingBloc>().add(GetRecyclingProcesses(
      page: _currentPage,
      limit: _itemsPerPage,
      status: _selectedStatus,
      fromDate: fromDate,
      toDate: toDate,
    ));
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
      _currentPage = 1;
    });
    
    _fetchRecyclingProcesses();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _currentPage = 1;
      });
      
      _fetchRecyclingProcesses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecyclingBloc(
        repository: RecyclingRepository(
          recyclingService: RecyclingService(),
          networkInfo: NetworkInfoImpl(),
        ),
      )..add(GetRecyclingProcesses(
          page: _currentPage,
          limit: _itemsPerPage,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý tái chế'),
          backgroundColor: AppColors.primaryGreen,
          actions: [
            IconButton(
              icon: Icon(
                _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter section
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isFilterExpanded ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isFilterExpanded ? 1.0 : 0.0,
                child: _isFilterExpanded
                    ? _buildFilterSection()
                    : const SizedBox.shrink(),
              ),
            ),
            
            // List section
            Expanded(
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
                },
                builder: (context, state) {
                  if (state is RecyclingInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is RecyclingLoading && _currentPage == 1) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is RecyclingProcessesLoaded) {
                    final processes = state.processes;
                    
                    if (processes.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có quy trình tái chế nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _currentPage = 1;
                        });
                        _fetchRecyclingProcesses();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: processes.length + 1,
                        itemBuilder: (context, index) {
                          if (index == processes.length) {
                            return _currentPage < state.totalPages
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          
                          final process = processes[index];
                          return _buildRecyclingProcessCard(process);
                        },
                      ),
                    );
                  }
                  
                  return const Center(
                    child: Text('Có lỗi xảy ra khi tải dữ liệu'),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _isAdmin ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecyclingFormScreen(),
              ),
            ).then((_) {
              setState(() {
                _currentPage = 1;
              });
              _fetchRecyclingProcesses();
            });
          },
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.add),
        ) : null,
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc quy trình tái chế',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Status filter
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Trạng thái',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Tất cả trạng thái'),
              ),
              DropdownMenuItem(
                value: 'pending',
                child: Text('Đang chờ xử lý'),
              ),
              DropdownMenuItem(
                value: 'in_progress',
                child: Text('Đang xử lý'),
              ),
              DropdownMenuItem(
                value: 'completed',
                child: Text('Hoàn thành'),
              ),
              DropdownMenuItem(
                value: 'cancelled',
                child: Text('Đã hủy'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _currentPage = 1;
              });
              _fetchRecyclingProcesses();
            },
          ),
          const SizedBox(height: 16),
          
          // Date range filter
          InkWell(
            onTap: () => _selectDateRange(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Khoảng thời gian',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Reset button
          Center(
            child: ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại bộ lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecyclingProcessCard(RecyclingProcess process) {
    Color statusColor;
    String statusText;
    
    switch (process.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Đang chờ xử lý';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecyclingDetailScreen(processId: process.id),
            ),
          ).then((_) {
            if (_currentPage == 1) {
              _fetchRecyclingProcesses();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mã giao dịch: ${process.transactionId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Loại rác: ${process.wasteTypeName}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Số lượng: ${process.quantity} kg',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(process.startDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (process.endDate != null)
                    Text(
                      'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(process.endDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 