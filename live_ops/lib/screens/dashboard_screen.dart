import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    if (provider.groupedData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final regionStats =
        provider.getRegionStats(provider.selectedRegion!);

    const primaryAccent = Color(0xFFE91E63);
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const textPrimary = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: primaryAccent,
        title: const Text("OPS DASHBOARD"),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await provider.refreshData();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // 🔥 REGION SELECTOR
            _sectionTitle("Select Region"),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: provider.selectedRegion,
                dropdownColor: cardColor,
                style: const TextStyle(color: textPrimary),
                decoration: const InputDecoration(border: InputBorder.none),
                items: provider.groupedData.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region,
                        style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) provider.selectRegion(value);
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SUMMARY
            _sectionTitle("Region Summary"),
            const SizedBox(height: 10),

            Row(
              children: [
                _bigMetricCard("Total Jobs", regionStats['totalJobs'],
                    Icons.work, Colors.blue),
                _bigMetricCard("Completed",
                    regionStats['completedJobs'], Icons.check, Colors.green),
                _bigMetricCard("Attendance %",
                    regionStats['attendancePercent'],
                    Icons.bar_chart, Colors.orange),
              ],
            ),

            const SizedBox(height: 24),

            // 🔥 CLUSTERS
            _sectionTitle("Clusters Overview"),
            const SizedBox(height: 10),

            ...provider.currentRegionData.entries.map((clusterEntry) {
              final clusterName = clusterEntry.key;
              final clusterStats = provider.getClusterStats(
                  provider.selectedRegion!, clusterName);

              final hoods = provider.getHoods(
                  provider.selectedRegion!, clusterName);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,

                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clusterName,
                          style: const TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 6),

                      // 🔥 SUBTITLE BACK
                      Row(
                        children: [
                          _miniTag("Total", clusterStats['totalJobs'], Colors.blue),
                          const SizedBox(width: 6),
                          _miniTag("Completed",
                              clusterStats['completedJobs'], Colors.green),
                          const SizedBox(width: 6),
                          _miniTag("Attendance",
                              clusterStats['attendancePercent'], Colors.orange),
                        ],
                      )
                    ],
                  ),

                  children: hoods.map((hood) {
                    final hoodStats = provider.getHoodStats(
                        provider.selectedRegion!, clusterName, hood);

                    return Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 🔥 HOOD TITLE
                          Text(hood,
                              style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),

                          const SizedBox(height: 12),

                          // 🔥 GRID STYLE (FIXED UI)
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5,

                            children: [
                              _statBox("Total Jobs",
                                  hoodStats['totalJobs'], Colors.blue),
                              _statBox("Completed",
                                  hoodStats['completedJobs'], Colors.green),
                              _statBox("Live Supply",
                                  hoodStats['liveSupply'], Colors.purple),
                              _statBox("Jobs/Expert",
                                  hoodStats['pendingJobs'], Colors.red),
                              _statBox("OT Hours",
                                  hoodStats['otHours'], Colors.orange),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bigMetricCard(
      String title, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text("$value",
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12))
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statBox(String title, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$value",
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}