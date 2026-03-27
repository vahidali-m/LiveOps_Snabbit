import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_ops/models/Reassign_request_model.dart';
import '../services/sheet_service_reassign.dart';

class ReassignRequestScreen extends StatefulWidget {
  const ReassignRequestScreen({super.key});

  @override
  State<ReassignRequestScreen> createState() =>
      _ReassignRequestScreenState();
}

class _ReassignRequestScreenState extends State<ReassignRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController jobIdController = TextEditingController();
  final TextEditingController freeExpertController = TextEditingController();

  String? selectedRegion;
  String? selectedReason;

  List<ReassignRequest> allRequests = [];
  List<ReassignRequest> filteredRequests = [];

  bool isSubmitting = false;

  Timer? autoRefreshTimer;
  late TabController tabController;

  // 🎨 SAME DARK THEME
  final bgColor = const Color(0xFF0F172A);
  final cardColor = const Color(0xFF1E293B);
  final borderColor = const Color(0xFF334155);
  final textPrimary = Colors.white;
  final textSecondary = Colors.grey;

  @override
  void initState() {
    super.initState();
    loadRequests();

    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(applyFilters);

    autoRefreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => loadRequests());
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    tabController.dispose();
    super.dispose();
  }

  Future<void> loadRequests() async {
    final data = await ReassignService.fetchReassign();

    setState(() {
      allRequests = data.reversed.toList();
      applyFilters();
    });
  }

  void applyFilters() {
    String tab = ['All', 'Pending', 'Approved'][tabController.index];

    filteredRequests = allRequests.where((e) {
      return tab == 'All' || e.status == tab;
    }).toList();

    setState(() {});
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      await ReassignService.submitReassign(
        jobId: jobIdController.text,
        reason: selectedReason!,
        freeExpertId: freeExpertController.text,
        region: selectedRegion!,
      );

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted ✅')),
      );

      jobIdController.clear();
      freeExpertController.clear();
      selectedRegion = null;
      selectedReason = null;

      await loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = allRequests.length;
    int pending = allRequests.where((e) => e.status == 'Pending').length;
    int approved = allRequests.where((e) => e.status == 'Approved').length;

    const primaryAccent = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryAccent,
        title: const Text('Reassign Dashboard'),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.cyanAccent,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // 🔥 SUMMARY
            Row(
              children: [
                _summaryCard('Total', total, Colors.blue),
                _summaryCard('Pending', pending, Colors.amber),
                _summaryCard('Approved', approved, Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            // 🔥 FORM
            _formCard(),

            const SizedBox(height: 16),

            // 📋 LIST
            ...filteredRequests.map((r) => _requestCard(r)),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _inputField(jobIdController, 'Job ID', isNumber: true),
            const SizedBox(height: 10),

            _dropdownField('Reason', selectedReason, _reasons(),
                (v) => setState(() => selectedReason = v)),
            const SizedBox(height: 10),

            _inputField(freeExpertController, 'Free Expert ID (Optional)',
                isNumber: true, required: false),
            const SizedBox(height: 10),

            _dropdownField('Region', selectedRegion, _regions(),
                (v) => setState(() => selectedRegion = v)),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget _requestCard(ReassignRequest r) {
    Color color =
        r.status == 'Approved' ? Colors.green : Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Job: ${r.jobId}",
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold)),
                Text("${r.region} • ${r.reason}",
                    style: TextStyle(color: textSecondary)),
                Text("Free Ex: ${r.freeExpertId}",
                    style: TextStyle(color: textSecondary)),
              ],
            ),
          ),
          Text(r.status,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------- INPUT ----------------
  Widget _inputField(TextEditingController controller, String label,
      {bool isNumber = false, bool required = true}) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textPrimary),
      decoration: _inputDecoration(label),
      validator: (v) =>
          required && v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _dropdownField(String label, String? value,
      List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return DropdownButtonFormField(
      initialValue: value,
      dropdownColor: cardColor,
      style: TextStyle(color: textPrimary),
      decoration: _inputDecoration(label),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textSecondary),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(title, style: TextStyle(color: textSecondary)),
          ],
        ),
      ),
    );
  }

  // ---------------- DATA ----------------
  List<DropdownMenuItem<String>> _regions() {
    return [
      'Thane',
      'Bangalore',
      'Delhi',
      'Pune',
      'Noida',
      'Gurugram',
      'Mumbai',
      'Navi Mumbai',
      'Hyderabad'
    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }

  List<DropdownMenuItem<String>> _reasons() {
    return [
      'Denying to go',
      'Fav expert',
      'Cross Cluster',
      'Customer Request',
      'Behaviour issue',
      'Need pet friendly ex',
      'Not Responding',
      'Logged Out'
      'Poor Quality of Work'
    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }
}