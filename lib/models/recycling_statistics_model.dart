class RecyclingStatisticsData {
  final List<WasteStatistic> statistics;
  final StatisticsTotals totals;
  final StatisticsFilters filters;

  RecyclingStatisticsData({
    required this.statistics,
    required this.totals,
    required this.filters,
  });

  factory RecyclingStatisticsData.fromJson(Map<String, dynamic> json) {
    return RecyclingStatisticsData(
      statistics: (json['statistics'] as List)
          .map((stat) => WasteStatistic.fromJson(stat))
          .toList(),
      totals: StatisticsTotals.fromJson(json['totals']),
      filters: StatisticsFilters.fromJson(json['filters']),
    );
  }
}

class WasteStatistic {
  final int wasteTypeId;
  final String wasteTypeName;
  final int totalProcesses;
  final double totalProcessed;
  final int completedProcesses;
  final int inProgressProcesses;
  final int pendingProcesses;

  WasteStatistic({
    required this.wasteTypeId,
    required this.wasteTypeName,
    required this.totalProcesses,
    required this.totalProcessed,
    required this.completedProcesses,
    required this.inProgressProcesses,
    required this.pendingProcesses,
  });

  factory WasteStatistic.fromJson(Map<String, dynamic> json) {
    return WasteStatistic(
      wasteTypeId: json['waste_type_id'],
      wasteTypeName: json['waste_type_name'],
      totalProcesses: json['total_processes'],
      totalProcessed: double.parse(json['total_processed']),
      completedProcesses: json['completed_processes'],
      inProgressProcesses: json['in_progress_processes'],
      pendingProcesses: json['pending_processes'],
    );
  }
}

class StatisticsTotals {
  final int totalProcesses;
  final double totalProcessed;
  final int completedProcesses;
  final int inProgressProcesses;
  final int pendingProcesses;

  StatisticsTotals({
    required this.totalProcesses,
    required this.totalProcessed,
    required this.completedProcesses,
    required this.inProgressProcesses,
    required this.pendingProcesses,
  });

  factory StatisticsTotals.fromJson(Map<String, dynamic> json) {
    return StatisticsTotals(
      totalProcesses: json['totalProcesses'],
      totalProcessed: json['totalProcessed'] is double 
          ? json['totalProcessed'] 
          : double.parse(json['totalProcessed'].toString()),
      completedProcesses: json['completedProcesses'],
      inProgressProcesses: json['inProgressProcesses'],
      pendingProcesses: json['pendingProcesses'],
    );
  }
}

class StatisticsFilters {
  final String from;
  final String to;
  final String? wasteTypeId;
  final String timezone;

  StatisticsFilters({
    required this.from,
    required this.to,
    this.wasteTypeId,
    required this.timezone,
  });

  factory StatisticsFilters.fromJson(Map<String, dynamic> json) {
    return StatisticsFilters(
      from: json['from'],
      to: json['to'],
      wasteTypeId: json['wasteTypeId'],
      timezone: json['timezone'],
    );
  }
} 