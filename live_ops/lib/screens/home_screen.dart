import 'package:flutter/material.dart';
import 'package:live_ops/models/Reassign_request_model.dart';
import 'package:live_ops/screens/request_menu_screen.dart';
import 'package:live_ops/services/sheet_service_reassign.dart';
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
    final utData = await SheetService.fetchUTRequests();
    final reassignData = await ReassignService.fetchReassign();

    setState(() {
      utRequests = utData;
      reassignRequest = reassignData;
    });
  }

  // 🔥 UT REGION
  Map<String, int> getUTByRegion() {
    Map<String, int> map = {};
    for (var r in utRequests) {
      map[r.region] = (map[r.region] ?? 0) + 1;
    }
    return map;
  }

  // 🔥 REASSIGN REGION
  Map<String, int> getReassignByRegion() {
    Map<String, int> map = {};
    for (var r in reassignRequest) {
      map[r.region] = (map[r.region] ?? 0) + 1;
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

  // 🔥 CONDITIONAL APP BAR
  appBar: _currentIndex == 0
      ? AppBar(
          backgroundColor: primaryAccent,
          title: const Text("OPS CONTROL PANEL"),
        )
      : null,

  body: screens[_currentIndex],

  bottomNavigationBar: BottomNavigationBar(
    backgroundColor: cardColor,
    currentIndex: _currentIndex,
    onTap: (i) => setState(() => _currentIndex = i),
    selectedItemColor: Colors.cyanAccent,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Requests"),
      BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Breaches"),
    ],
  ),
);
  }

  // ================= HOME UI =================
  Widget _homeUI(int totalJobs, int completedJobs) {
    final utMap = getUTByRegion();
    final reassignMap = getReassignByRegion();

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔥 KPI
          Row(
            children: [
              _bigCard("Total Jobs", totalJobs, Colors.blue),
              _bigCard("Completed", completedJobs, Colors.green),
            ],
          ),

          Row(
            children: [
              _bigCard("UT", utRequests.length, Colors.orange),
              _bigCard("Reassign", reassignRequest.length, Colors.purple),
            ],
          ),

          const SizedBox(height: 20),

          // 🔥 UT GRAPH
          _sectionTitle("UT Requests"),
          _modernGraph(utMap, Colors.cyanAccent),

          const SizedBox(height: 20),

          // 🔥 REASSIGN GRAPH
          _sectionTitle("Reassign Requests"),
          _modernGraph(reassignMap, Colors.purpleAccent),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _bigCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text("$value",
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: textSecondary)),
          ],
        ),
      ),
    );
  }

  // 🔥 MODERN GRAPH (BETTER LOOK)
  Widget _modernGraph(Map<String, int> data, Color color) {
    int max = data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((e) {
          double height = (e.value / max) * 120;

          return Expanded(
  child: Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("${e.value}",
            style: TextStyle(color: textSecondary, fontSize: 10)),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: height,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          e.key.substring(0, 3),
          style: TextStyle(color: textSecondary, fontSize: 10),
        ),
      ],
    ),
  ),
);
        }).toList(),
      ),
    );
  }
}