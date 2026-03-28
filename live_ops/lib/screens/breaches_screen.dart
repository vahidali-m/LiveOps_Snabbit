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

  // 🎨 WHITE + PINK THEME (matching CXRequestScreen)
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);

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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFAD1457), Color(0xFFE91E63)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'BREACHES (30+ mins)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: primaryAccent,
        onRefresh: loadData,
        child: breaches.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(
                    child: CircularProgressIndicator(color: primaryAccent),
                  ),
                ],
              )
            : ListView(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        collapsedIconColor: primaryAccent,
        iconColor: primaryAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  region.toUpperCase(),
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            _countBadge(list.length),
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(left: 16, top: 2),
          child: Text(
            "Top clusters shown first",
            style: const TextStyle(color: textSecondary, fontSize: 11),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 CLUSTER HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: primaryAccent, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    cluster,
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              _countBadge(list.length),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFFFFD6E7), height: 1),
          const SizedBox(height: 8),

          // 🔥 JOB LIST
          ...list.map((b) => _jobTile(b)),
        ],
      ),
    );
  }

  // ================= JOB =================
  Widget _jobTile(Breach b) {
    final isHighBreach = b.minutes >= 45;
    final breachColor =
        isHighBreach ? const Color(0xFFD50000) : const Color(0xFFFF6D00);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: breachColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // LEFT ACCENT BAR
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: breachColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Job: ${b.jobId}",
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${b.runnerName} • ${b.hood}",
                  style: const TextStyle(color: textSecondary, fontSize: 12),
                ),
                Text(
                  "Accepted: ${b.acceptedAt}",
                  style: const TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          // BREACH BADGE
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: breachColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: breachColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  "${b.minutes}m",
                  style: TextStyle(
                    color: breachColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isHighBreach ? "CRITICAL" : "WARNING",
                  style: TextStyle(
                    color: breachColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BADGE =================
  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryAccent.withOpacity(0.3)),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
          color: primaryAccent,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}