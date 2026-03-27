import 'package:flutter/material.dart';
import '../models/breach_model.dart';
import '../services/sheet_service_breach.dart';

class BreachesScreen extends StatefulWidget {
  const BreachesScreen({super.key});

  @override
  State<BreachesScreen> createState() => _BreachesScreenState();
}

class _BreachesScreenState extends State<BreachesScreen> {
  List<Breach> breaches = [];

  final bgColor = const Color(0xFF0F172A);
  final cardColor = const Color(0xFF1E293B);
  final textPrimary = Colors.white;
  final textSecondary = Colors.grey;
  static const primaryAccent = Color(0xFFE91E63);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await BreachService.fetchBreaches();
    setState(() => breaches = data);
  }

  // ================= GROUP =================
  Map<String, List<Breach>> groupByRegion() {
    Map<String, List<Breach>> map = {};
    for (var b in breaches) {
      map.putIfAbsent(b.region, () => []).add(b);
    }
    return map;
  }

  Map<String, List<Breach>> groupByCluster(List<Breach> list) {
    Map<String, List<Breach>> map = {};
    for (var b in list) {
      map.putIfAbsent(b.cluster, () => []).add(b);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final regionMap = groupByRegion();

    // 🔥 SORT REGION BY COUNT DESC
    final sortedRegions = regionMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryAccent,
        title: const Text("BREACHES (30+ mins)"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: sortedRegions.map((regionEntry) {
            return _regionTile(regionEntry.key, regionEntry.value);
          }).toList(),
        ),
      ),
    );
  }

  // ================= REGION =================
  Widget _regionTile(String region, List<Breach> list) {
    final clusterMap = groupByCluster(list);

    // 🔥 SORT CLUSTERS
    final sortedClusters = clusterMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(region.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            _countBadge(list.length)
          ],
        ),

        subtitle: Text(
          "Top clusters shown first",
          style: TextStyle(color: textSecondary, fontSize: 12),
        ),

        children: sortedClusters.map((c) {
          return _clusterTile(c.key, c.value);
        }).toList(),
      ),
    );
  }

  // ================= CLUSTER =================
  Widget _clusterTile(String cluster, List<Breach> list) {
    // 🔥 SORT JOBS BY MINUTES DESC
    list.sort((a, b) => b.minutes.compareTo(a.minutes));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 CLUSTER HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cluster,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              _countBadge(list.length)
            ],
          ),

          const SizedBox(height: 8),

          // 🔥 JOB LIST (NO EXTRA EXPANSION)
          ...list.map((b) => _jobTile(b)),
        ],
      ),
    );
  }

  // ================= JOB =================
  Widget _jobTile(Breach b) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Job: ${b.jobId}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),

                const SizedBox(height: 4),

                Text("${b.runnerName} • ${b.hood}",
                    style: TextStyle(color: textSecondary)),

                Text("Accepted: ${b.acceptedAt}",
                    style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),

          // RIGHT (BREACH LEVEL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: b.minutes >= 45
                  ? Colors.red.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${b.minutes}m",
              style: TextStyle(
                color: b.minutes >= 45 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= BADGE =================
  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}