class RecyclingReport {
  final int totalProcesses;
  final int completedProcesses;
  final int pendingProcesses;
  final double totalWeight;
  final double processedWeight;
  final Map<String, int> processesByWasteType;
  final Map<String, double> weightByWasteType;

  RecyclingReport({
    required this.totalProcesses,
    required this.completedProcesses,
    required this.pendingProcesses,
    required this.totalWeight,
    required this.processedWeight,
    required this.processesByWasteType,
    required this.weightByWasteType,
  });

  factory RecyclingReport.fromJson(Map<String, dynamic> json) {
    Map<String, int> processesByWasteType = {};
    Map<String, double> weightByWasteType = {};
    
    if (json['processes_by_waste_type'] != null) {
      json['processes_by_waste_type'].forEach((key, value) {
        processesByWasteType[key] = value as int;
      });
    }
    
    if (json['weight_by_waste_type'] != null) {
      json['weight_by_waste_type'].forEach((key, value) {
        weightByWasteType[key] = (value as num).toDouble();
      });
    }
    
    return RecyclingReport(
      totalProcesses: json['total_processes'] ?? 0,
      completedProcesses: json['completed_processes'] ?? 0,
      pendingProcesses: json['pending_processes'] ?? 0,
      totalWeight: (json['total_weight'] ?? 0.0).toDouble(),
      processedWeight: (json['processed_weight'] ?? 0.0).toDouble(),
      processesByWasteType: processesByWasteType,
      weightByWasteType: weightByWasteType,
    );
  }
} 