import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/recycling_progress/recycling_progress_filter.dart';
import '../widgets/recycling_progress/recycling_record_item.dart';
import '../widgets/recycling_progress/recycling_statistics.dart';
import '../blocs/recycling_progress/recycling_progress_bloc.dart';
import '../blocs/recycling_progress/recycling_progress_event.dart';
import '../blocs/recycling_progress/recycling_progress_state.dart';
import '../repositories/recycling_progress_repository.dart';
import '../utils/app_colors.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../models/waste_type_model.dart';
import '../core/api/api_client.dart';
import '../utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class RecyclingProgressScreen extends StatelessWidget {
  const RecyclingProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecyclingProgressBloc(
        repository: RecyclingProgressRepository(
          remoteDataSource: RemoteDataSource(
            apiClient: ApiClient(
              client: http.Client(),
              secureStorage: SecureStorage(),
            ),
          ),
          localDataSource: LocalDataSource(),
          networkInfo: NetworkInfoImpl(),
        ),
      )..add(const LoadRecyclingProgress()),
      child: const RecyclingProgressView(),
    );
  }
}

class RecyclingProgressView extends StatefulWidget {
  const RecyclingProgressView({Key? key}) : super(key: key);

  @override
  State<RecyclingProgressView> createState() => _RecyclingProgressViewState();
}

class _RecyclingProgressViewState extends State<RecyclingProgressView> {
  List<WasteType> _wasteTypes = [];
  bool _isFilterExpanded = false;
  String? _selectedWasteTypeId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWasteTypes();
    _fetchStatistics();
  }

  Future<void> _loadWasteTypes() async {
    final repository = context.read<RecyclingProgressBloc>().repository;
    final types = await repository.getWasteTypes();
    setState(() {
      _wasteTypes = types;
    });
  }

  void _fetchStatistics() {
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate);
    
    context.read<RecyclingProgressBloc>().add(
      FetchRecyclingStatistics(
        fromDate: formattedStartDate,
        toDate: formattedEndDate,
        wasteTypeId: _selectedWasteTypeId,
      ),
    );
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _fetchStatistics();
  }

  void _onWasteTypeChanged(String? wasteTypeId) {
    setState(() {
      _selectedWasteTypeId = wasteTypeId;
    });
    _fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến trình tái chế'),
        elevation: 0,
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
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchStatistics();
        },
        child: BlocConsumer<RecyclingProgressBloc, RecyclingProgressState>(
          listener: (context, state) {
            if (state is RecyclingProgressError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecyclingProgressInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is RecyclingProgressLoading || state is RecyclingStatisticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is RecyclingProgressLoaded) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter section
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isFilterExpanded ? null : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isFilterExpanded ? 1.0 : 0.0,
                        child: _isFilterExpanded
                            ? RecyclingProgressFilter(
                                wasteTypes: _wasteTypes,
                                startDate: _startDate,
                                endDate: _endDate,
                                selectedWasteTypeId: _selectedWasteTypeId,
                                onDateRangeChanged: _onDateRangeChanged,
                                onWasteTypeChanged: _onWasteTypeChanged,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Statistics section
                    RecyclingStatistics(
                      wasteTypeQuantities: state.wasteTypeQuantities,
                      totalWeight: state.totalWeight,
                      apiStatistics: state.statistics,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Records section
                    const Text(
                      'Lịch sử tái chế',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (state.filteredRecords.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Không có bản ghi tái chế nào',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      ...state.filteredRecords.map((record) => 
                        RecyclingRecordItem(record: record),
                      ),
                  ],
                ),
              );
            }
            
            return const Center(
              child: Text('Có lỗi xảy ra khi tải dữ liệu'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add new recycling record screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng thêm bản ghi tái chế sẽ được phát triển sau'),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
} 