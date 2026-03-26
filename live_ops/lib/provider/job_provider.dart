import 'package:flutter/material.dart';
import '../models/ops_data.dart';
import '../services/sheet_service.dart';

class JobProvider extends ChangeNotifier {
  List<JobRow> allRows = [];
  String? selectedRegion;

  Map<String, Map<String, List<JobRow>>> groupedData = {};

  // ---------------- Load initial data ----------------
  Future<void> loadData() async {
    allRows = await SheetService.fetchData();
    _groupData();
    selectedRegion ??= groupedData.keys.first;
    notifyListeners();
  }

  // ---------------- Refresh data for pull-to-refresh ----------------
  Future<void> refreshData() async {
    // Re-fetch data from the source
    await loadData();
    // No need to notifyListeners again because loadData already does it
  }

  void _groupData() {
    groupedData.clear();

    for (var row in allRows) {
      groupedData.putIfAbsent(row.region, () => {});
      groupedData[row.region]!
          .putIfAbsent(row.cluster, () => [])
          .add(row);
    }
  }

  void selectRegion(String region) {
    selectedRegion = region;
    notifyListeners();
  }

  Map<String, List<JobRow>> get currentRegionData =>
      groupedData[selectedRegion] ?? {};

  // ----------------- Stats Helpers -----------------

  // Region Level Stats
  // Region Level Stats based on Excel Att% column
Map<String, dynamic> getRegionStats(String region) {
  final clusters = groupedData[region] ?? {};
  int totalJobs = 0;
  int completedJobs = 0;
  double attendanceSum = 0;
  int rowCount = 0; // count how many rows to calculate average

  for (var clusterRows in clusters.values) {
    for (var row in clusterRows) {
      totalJobs += row.totalJobs;
      completedJobs += row.completedJobs;
      attendanceSum += row.attPercent; // sum Att% from Excel
      rowCount++;
    }
  }

  double attendancePercent = rowCount > 0
      ? attendanceSum / rowCount // average of Att% across region
      : 0;

  return {
    'totalJobs': totalJobs,
    'completedJobs': completedJobs,
    'attendancePercent': attendancePercent.toStringAsFixed(1),
  };
}


  // Cluster Level Stats
  Map<String, dynamic> getClusterStats(String region, String cluster) {
    final rows = groupedData[region]?[cluster] ?? [];
    int totalJobs = 0;
    int completedJobs = 0;
    double attendanceSum = 0;


    for (var row in rows) {
      totalJobs += row.totalJobs;
      completedJobs += row.completedJobs;
      attendanceSum += row.attPercent; // sum all Att%
    }

double attendancePercent = rows.isNotEmpty
      ? attendanceSum / rows.length // average Att% for cluster
      : 0;

    return {
      'totalJobs': totalJobs,
      'completedJobs': completedJobs,
     'attendancePercent': attendancePercent.toStringAsFixed(1),
  };
}


  // Hood Level Stats
  Map<String, dynamic> getHoodStats(String region, String cluster, String hood) {
    final rows = groupedData[region]?[cluster]
            ?.where((row) => row.hood == hood)
            .toList() ??
        [];

    int totalJobs = 0;
    int completedJobs = 0;
    int liveSupply = 0;
    double pendingJobs = 0;
    double otHours = 0;

    for (var row in rows) {
      totalJobs += row.totalJobs;
      completedJobs += row.completedJobs;
      liveSupply += row.liveSupply;
      pendingJobs += row.pendingJobs;
      otHours += row.otHours;
    }

    return {
      'totalJobs': totalJobs,
      'completedJobs': completedJobs,
      'liveSupply': liveSupply,
      'pendingJobs': pendingJobs,
      'otHours': otHours.toStringAsFixed(1),
    };
  }

  // Get all hoods under a cluster
  List<String> getHoods(String region, String cluster) {
    final rows = groupedData[region]?[cluster] ?? [];
    final hoods = rows.map((row) => row.hood).toSet().toList();
    return hoods;
  }
}
