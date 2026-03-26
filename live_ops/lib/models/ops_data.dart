class JobRow {
  String region;
  String cluster; // MM
  String hood;    // NM

  int totalJobs;
  int completedJobs;
  int liveSupply;
  double pendingJobs;
  double attPercent; // <-- new
  double otHours; // <-- add this



  JobRow({
    required this.region,
    required this.cluster,
    required this.hood,
    required this.totalJobs,
    required this.completedJobs,
    required this.liveSupply,
    required this.pendingJobs,
    required this.attPercent,
    required this.otHours, // <-- add this
  });


  factory JobRow.fromJson(Map<String, dynamic> json) {
    return JobRow(
      region: json['Region']?.toString() ?? '',
      cluster: json['MM']?.toString() ?? '',
      hood: json['NM']?.toString() ?? '',
      totalJobs: safeInt(json['Total Jobs']),
      completedJobs: safeInt(json['Completed Jobs']),
      liveSupply: safeInt(json['Live Supply']),
      attPercent: safeDouble(json['Att%']),
      pendingJobs: safeDouble(json['Pending jobs/expert']), // <-- now double
      otHours: safeDouble(json['OT Hours']), // <-- add this
    );
  }
}


// ---------------- Safe parsers ----------------
int safeInt(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return 0;
  final v = value.toString().replaceAll('%', '').trim();
  return int.tryParse(v.split('.').first) ?? 0;
}

double safeDouble(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return 0.0;
  final v = value.toString().replaceAll('%', '').trim();
  return double.tryParse(v) ?? 0.0;
}
