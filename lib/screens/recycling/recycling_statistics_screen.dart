import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wasteanmagement/models/recycling_report_model.dart';
import '../../blocs/recycling/recycling_bloc.dart';
import '../../blocs/recycling/recycling_event.dart';
import '../../blocs/recycling/recycling_state.dart';
import '../../repositories/recycling_repository.dart';
import '../../services/recycling_service.dart';
import '../../core/network/network_info.dart';
import '../../utils/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class RecyclingStatisticsScreen extends StatefulWidget {
  const RecyclingStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<RecyclingStatisticsScreen> createState() => _RecyclingStatisticsScreenState();
}

class _RecyclingStatisticsScreenState extends State<RecyclingStatisticsScreen> with SingleTickerProviderStateMixin {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedWasteTypeId;
  List<Map<String, dynamic>> _wasteTypes = [];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWasteTypes();
  }

  Future<void> _loadWasteTypes() async {
    // Simple mock data for waste types
    setState(() {
      _wasteTypes = [
        {
          'id': '1',
          'name': 'Nhựa',
          'description': 'Các loại nhựa'
        },
        {
          'id': '2',
          'name': 'Giấy',
          'description': 'Các loại giấy'
        },
        {
          'id': '3',
          'name': 'Kim loại',
          'description': 'Các loại kim loại'
        }
      ];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      });
      
      _fetchStatistics();
    }
  }

  void _fetchStatistics() {
    final fromDate = DateFormat('yyyy-MM-dd').format(_startDate);
    final toDate = DateFormat('yyyy-MM-dd').format(_endDate);
    
    context.read<RecyclingBloc>().add(GetRecyclingStatistics(
      fromDate: fromDate,
      toDate: toDate,
      wasteTypeId: _selectedWasteTypeId,
    ));
    
    context.read<RecyclingBloc>().add(GetRecyclingReport(
      fromDate: fromDate,
      toDate: toDate,
      wasteTypeId: _selectedWasteTypeId,
    ));
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
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Thống kê tái chế'),
              backgroundColor: AppColors.primaryGreen,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Báo cáo'),
                  Tab(text: 'Thống kê chi tiết'),
                ],
              ),
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<RecyclingBloc, RecyclingState>(
                  listener: (context, state) {
                    if (state is RecyclingReportLoaded) {
                      // Hook for when report is loaded
                    }
                  },
                ),
              ],
              child: Column(
                children: [
                  _buildFilters(context),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReportTab(context),
                        _buildStatisticsTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
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
          
          // Waste Type filter
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Loại rác',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: _selectedWasteTypeId,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả loại rác'),
              ),
              ..._wasteTypes.map((wasteType) {
                return DropdownMenuItem<String>(
                  value: wasteType['id'] as String,
                  child: Text(wasteType['name'] as String),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedWasteTypeId = value;
              });
              _fetchStatistics();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab(BuildContext context) {
    return BlocBuilder<RecyclingBloc, RecyclingState>(
      builder: (context, state) {
        if (state is RecyclingLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is RecyclingReportLoaded) {
          final report = state.report;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(report),
                const SizedBox(height: 24),
                _buildProgressionCard(report),
                const SizedBox(height: 24),
                _buildWasteTypeDistributionCard(report),
              ],
            ),
          );
        }
        
        return Center(
          child: ElevatedButton(
            onPressed: _fetchStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Tải dữ liệu báo cáo'),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab(BuildContext context) {
    return BlocBuilder<RecyclingBloc, RecyclingState>(
      builder: (context, state) {
        if (state is RecyclingLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is RecyclingStatisticsLoaded) {
          final statistics = state.statistics;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticCard(
                  title: 'Hiệu suất tái chế',
                  value: '${statistics['efficiency'] ?? 0}%',
                  icon: Icons.show_chart,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatisticCard(
                  title: 'Tổng lượng rác đã xử lý',
                  value: '${statistics['total_processed'] ?? 0} kg',
                  icon: Icons.scale,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatisticCard(
                  title: 'Tiết kiệm nhờ tái chế',
                  value: '${statistics['cost_saving'] ?? 0} VND',
                  icon: Icons.savings,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildStatisticCard(
                  title: 'Giảm phát thải CO2',
                  value: '${statistics['co2_reduction'] ?? 0} kg',
                  icon: Icons.eco,
                  color: Colors.teal,
                ),
                const SizedBox(height: 24),
                if (statistics['monthly_stats'] != null)
                  _buildMonthlyStatsCard(statistics['monthly_stats']),
              ],
            ),
          );
        }
        
        return Center(
          child: ElevatedButton(
            onPressed: _fetchStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Tải dữ liệu thống kê'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(RecyclingReport report) {
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
              'Tổng quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildSummaryItem(
                  title: 'Tổng số quy trình',
                  value: report.totalProcesses.toString(),
                  color: Colors.blue,
                  icon: Icons.recycling,
                ),
                _buildSummaryItem(
                  title: 'Đã hoàn thành',
                  value: report.completedProcesses.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                _buildSummaryItem(
                  title: 'Đang chờ xử lý',
                  value: report.pendingProcesses.toString(),
                  color: Colors.orange,
                  icon: Icons.hourglass_empty,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionCard(RecyclingReport report) {
    final double percentage = report.totalProcesses > 0
        ? (report.completedProcesses / report.totalProcesses) * 100
        : 0;
    
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
              'Tiến độ xử lý',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã xử lý ${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${report.completedProcesses} / ${report.totalProcesses} quy trình',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Khối lượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeightItem(
                        label: 'Tổng',
                        value: '${report.totalWeight.toStringAsFixed(1)} kg',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildWeightItem(
                        label: 'Đã xử lý',
                        value: '${report.processedWeight.toStringAsFixed(1)} kg',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWasteTypeDistributionCard(RecyclingReport report) {
    final processesByWasteType = report.processesByWasteType;
    final weightByWasteType = report.weightByWasteType;
    
    if (processesByWasteType.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
              'Phân bố theo loại rác',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _getPieChartSections(processesByWasteType),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _getPieChartLegends(processesByWasteType, weightByWasteType),
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

  List<PieChartSectionData> _getPieChartSections(Map<String, int> data) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    
    final List<PieChartSectionData> sections = [];
    int i = 0;
    int total = data.values.fold(0, (sum, item) => sum + item);
    
    data.forEach((key, value) {
      final double percentage = total > 0 ? (value / total * 100) : 0;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 90,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });
    
    return sections;
  }

  List<Widget> _getPieChartLegends(
    Map<String, int> processesData,
    Map<String, double> weightData,
  ) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    
    final List<Widget> legends = [];
    int i = 0;
    
    // Tìm tên loại rác dựa trên ID
    String getWasteTypeName(String id) {
      final wasteType = _wasteTypes.firstWhere(
        (element) => element['id'] == id,
        orElse: () => {'id': id, 'name': 'Unknown'},
      );
      return wasteType['name'].toString();
    }
    
    processesData.forEach((key, value) {
      legends.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getWasteTypeName(key),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$value quy trình, ${weightData[key]?.toStringAsFixed(1) ?? 0} kg',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      i++;
    });
    
    return legends;
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildMonthlyStatsCard(Map<String, dynamic> monthlyStats) {
    final List<String> months = monthlyStats.keys.toList();
    final List<double> values = monthlyStats.values.map((e) => (e as num).toDouble()).toList();
    
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
              'Thống kê theo tháng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: values.isEmpty ? 10 : values.reduce(math.max) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    months.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index],
                          color: AppColors.primaryGreen,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 