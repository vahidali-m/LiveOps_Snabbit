class ReassignRequest {
  final DateTime createdAt;
  final String jobId;
  final String reason;
  final String freeExpertId;
  final String region;
  final String status;

  ReassignRequest({
    required this.jobId,
    required this.reason,
    required this.freeExpertId,
    required this.region,
    required this.status, required this.createdAt,
  });
}