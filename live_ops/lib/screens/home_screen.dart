import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_ops/models/Reassign_request_model.dart';
import 'package:live_ops/models/cx_request_model.dart';
import 'package:live_ops/models/breach_model.dart';
import 'package:live_ops/screens/request_menu_screen.dart';
import 'package:live_ops/services/sheet_service_reassign.dart';
import 'package:live_ops/services/sheet_service_cx.dart';
import 'package:live_ops/services/sheet_service_breach.dart';
import '../services/sheet_servicee.dart';
import '../models/ut_request_model.dart';
import 'dashboard_screen.dart';
import 'breaches_screen.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<UTRequest> utRequests = [];
  List<ReassignRequest> reassignRequest = [];
  List<CXRequest> cxRequests = [];
  List<Breach> breaches = []; // ✅ ADDED

  Timer? autoRefreshTimer;

  // 🎨 WHITE + PINK THEME
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);

  @override
  void initState() {
    super.initState();
    loadData();
    autoRefreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => loadData());
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    try {
      final utData = await SheetService.fetchUTRequests();
      final reassignData = await ReassignService.fetchReassign();

      List<CXRequest> cxData = [];
      try {
        cxData = await CXService.fetchCX();
      } catch (e) {
        print("❌ CX FETCH ERROR: $e");
      }

      List<Breach> breachData = []; // ✅ ADDED
      try {
        breachData = await BreachService.fetchBreaches();
      } catch (e) {
        print("❌ BREACH FETCH ERROR: $e");
      }

      if (!mounted) return;
      setState(() {
        utRequests = utData;
        reassignRequest = reassignData;
        cxRequests = cxData;
        breaches = breachData; // ✅ ADDED
      });
    } catch (e) {
      print("❌ LOAD DATA ERROR: $e");
      if (!mounted) return;
    }
  }

  Map<String, int> getUTByRegion() {
    Map<String, int> map = {};
    for (var r in utRequests) {
      map[r.region] = (map[r.region] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getReassignByRegion() {
    Map<String, int> map = {};
    for (var r in reassignRequest) {
      map[r.region] = (map[r.region] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getCXByRegion() {
    Map<String, int> map = {};
    for (var r in cxRequests) {
      map[r.region] = (map[r.region] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getBreachesByRegion() { // ✅ ADDED
    Map<String, int> map = {};
    for (var b in breaches) {
      map[b.region] = (map[b.region] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();

    int totalJobs = 0;
    int completedJobs = 0;

    for (var region in jobProvider.groupedData.keys) {
      final stats = jobProvider.getRegionStats(region);
      totalJobs += stats['totalJobs'] as int;
      completedJobs += stats['completedJobs'] as int;
    }

    final screens = [
      _homeUI(totalJobs, completedJobs),
      const DashboardScreen(),
      const RequestMenuScreen(),
      const BreachesScreen(),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _currentIndex == 0
          ? AppBar(
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
                    child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "OPS CONTROL PANEL",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : null,

      body: screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: primaryAccent,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_rounded), label: "Requests"),
            BottomNavigationBarItem(
                icon: Icon(Icons.warning_rounded), label: "Breaches"),
          ],
        ),
      ),
    );
  }

  // ================= HOME UI =================
  Widget _homeUI(int totalJobs, int completedJobs) {
    final utMap = getUTByRegion();
    final reassignMap = getReassignByRegion();
    final cxMap = getCXByRegion();
    final breachMap = getBreachesByRegion(); // ✅ ADDED

    // ✅ Critical breach count (45+ mins)
    final criticalBreaches = breaches.where((b) => b.minutes >= 45).length;

    return RefreshIndicator(
      color: primaryAccent,
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "LIVE OVERVIEW",
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),

          // 🔥 KPI ROW 1 — Jobs
          Row(
            children: [
              _bigCard("Total Jobs", totalJobs, const Color(0xFF2979FF),
                  Icons.work_rounded),
              _bigCard("Completed", completedJobs, const Color(0xFF00C853),
                  Icons.check_circle_rounded),
            ],
          ),

          // 🔥 KPI ROW 2 — Requests
          Row(
            children: [
              _bigCard("UT", utRequests.length, primaryAccent,
                  Icons.access_time_rounded),
              _bigCard("Reassign", reassignRequest.length,
                  const Color(0xFF9C27B0), Icons.swap_horiz_rounded),
              _bigCard("CX", cxRequests.length,
                  const Color(0xFF00897B), Icons.contact_support_rounded),
            ],
          ),

          // ✅ KPI ROW 3 — Breaches
          Row(
            children: [
              _bigCard("Breaches", breaches.length,
                  const Color(0xFFFF6D00), Icons.warning_amber_rounded),
              _bigCard("Critical", criticalBreaches,
                  const Color(0xFFD50000), Icons.local_fire_department_rounded),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("UT Requests by Region"),
          const SizedBox(height: 10),
          _modernGraph(utMap, primaryAccent),

          const SizedBox(height: 24),

          _sectionTitle("Reassign Requests by Region"),
          const SizedBox(height: 10),
          _modernGraph(reassignMap, const Color(0xFF9C27B0)),

          const SizedBox(height: 24),

          _sectionTitle("CX Requests by Region"),
          const SizedBox(height: 10),
          _modernGraph(cxMap, const Color(0xFF00897B)),

          const SizedBox(height: 24),

          // ✅ BREACH GRAPH ADDED
          _sectionTitle("Breaches by Region"),
          const SizedBox(height: 10),
          _modernGraph(breachMap, const Color(0xFFFF6D00)),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _bigCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              "$value",
              style: const TextStyle(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernGraph(Map<String, int> data, Color color) {
  int max = data.values.isEmpty
      ? 1
      : data.values.reduce((a, b) => a > b ? a : b);

  // ✅ Sort entries by value descending
  final sortedEntries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Container(
    height: 200,
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
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
    child: data.isEmpty
        ? const Center(
            child: Text("No data",
                style: TextStyle(color: textSecondary, fontSize: 13)),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sortedEntries.map((e) {  // ✅ use sortedEntries
              double height = (e.value / max) * 120;
              bool isMax = e.value == max;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${e.value}",
                        style: TextStyle(
                          color: isMax ? textPrimary : textSecondary,
                          fontSize: 10,
                          fontWeight:
                              isMax ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: height,
                        decoration: BoxDecoration(
                          color: isMax ? color : color.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                       _regionAbbr(e.key),
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
  );
}

String _regionAbbr(String region) {
  switch (region.trim().toLowerCase()) {
    case 'thane':        return 'THN';
    case 'pune':         return 'PNE';
    case 'mumbai':       return 'MUM';
    case 'delhi':        return 'DHL';
    case 'navi mumbai':  return 'N-MUM';
    case 'bangalore':    return 'BLR';
    case 'noida':        return 'NOD';
    case 'gurugram':     return 'GGN';
    case 'hyderabad':    return 'HYD';
    default:             return region.length >= 3 ? region.substring(0, 3).toUpperCase() : region.toUpperCase();
  }
}
}