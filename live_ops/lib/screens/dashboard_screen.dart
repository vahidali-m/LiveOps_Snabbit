import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // 🎨 WHITE + PINK THEME
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    if (provider.groupedData.isEmpty) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryAccent)),
      );
    }

    final regionStats = provider.getRegionStats(provider.selectedRegion!);

    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: primaryAccent,
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
              child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "OPS DASHBOARD",
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: provider.selectedRegion,
                dropdownColor: cardColor,
                style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryAccent),
                decoration: const InputDecoration(border: InputBorder.none),
                items: provider.groupedData.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(
                      region,
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) provider.selectRegion(value);
                },
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 SUMMARY
            _sectionTitle("Region Summary"),
            const SizedBox(height: 12),

            Row(
              children: [
                _bigMetricCard("Total Jobs", regionStats['totalJobs'],
                    Icons.work_rounded, const Color(0xFF2979FF)),
                _bigMetricCard("Completed", regionStats['completedJobs'],
                    Icons.check_circle_rounded, const Color(0xFF00C853)),
                _bigMetricCard("Attendance %", regionStats['attendancePercent'],
                    Icons.bar_chart_rounded, const Color(0xFFFF6D00)),
              ],
            ),

            const SizedBox(height: 28),

            // 🔥 CLUSTERS
            _sectionTitle("Clusters Overview"),
            const SizedBox(height: 12),

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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ExpansionTile(
                    collapsedIconColor: primaryAccent,
                    iconColor: primaryAccent,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clusterName,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _miniTag("Total", clusterStats['totalJobs'], const Color(0xFF2979FF)),
                            const SizedBox(width: 6),
                            _miniTag("Done", clusterStats['completedJobs'], const Color(0xFF00C853)),
                            const SizedBox(width: 6),
                            _miniTag("Att%", clusterStats['attendancePercent'], const Color(0xFFFF6D00)),
                          ],
                        ),
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
                            Row(
                              children: [
                                const Icon(Icons.place_rounded, color: primaryAccent, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  hood,
                                  style: const TextStyle(
                                    color: textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 🔥 GRID STYLE
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.5,
                              children: [
                                _statBox("Total Jobs", hoodStats['totalJobs'], const Color(0xFF2979FF)),
                                _statBox("Completed", hoodStats['completedJobs'], const Color(0xFF00C853)),
                                _statBox("Live Supply", hoodStats['liveSupply'], const Color(0xFF9C27B0)),
                                _statBox("Jobs/Expert", hoodStats['pendingJobs'], primaryAccent),
                                _statBox("OT Hours", hoodStats['otHours'], const Color(0xFFFF6D00)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
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
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _bigMetricCard(String title, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              "$value",
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statBox(String title, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(height: 4),
          Text(
            "$value",
            style: const TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}