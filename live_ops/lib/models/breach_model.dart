class Breach {
  final String region;
  final String cluster;
  final String hood;
  final String jobId;
  final String runnerName;
  final String acceptedAt;
  final int minutes;

  Breach({
    required this.region,
    required this.cluster,
    required this.hood,
    required this.jobId,
    required this.runnerName,
    required this.acceptedAt,
    required this.minutes,
  });
}