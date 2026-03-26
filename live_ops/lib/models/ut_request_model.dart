class UTRequest {
  final DateTime createdAt;
  final String requestBy;
  final String expertId;
  final String region;
  final String utHours;
  final String reason;
  final String hasJob;
  String status; // Pending / Accepted

  UTRequest({
    required this. requestBy,
    required this.expertId,
    required this.region,
    required this.utHours,
    required this.reason,
    required this.hasJob,
    this.status = 'Pending', required this.createdAt,
  });
}