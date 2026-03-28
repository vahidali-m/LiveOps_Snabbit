import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ut_request_model.dart';
import '../services/sheet_servicee.dart';

class UTRequestScreen extends StatefulWidget {
  const UTRequestScreen({super.key});

  @override
  State<UTRequestScreen> createState() => _UTRequestScreenState();
}

class _UTRequestScreenState extends State<UTRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController expertIdController = TextEditingController();
  final TextEditingController utHoursController = TextEditingController();
  final TextEditingController requestBYController = TextEditingController();
  String? selectUtHours;
  String? selectedRegion;
  String? selectedReason;
  String? hasJob;

  List<UTRequest> allRequests = [];
  List<UTRequest> filteredRequests = [];

  bool isSubmitting = false;

  Timer? autoRefreshTimer;
  late TabController tabController;

  // 🎨 WHITE + PINK THEME
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);
  static const inputFill = Color(0xFFF0F0F5);
  static const borderColor = Color(0xFFE0E0EA);

  @override
  void initState() {
    super.initState();
    loadRequests();

    tabController = TabController(length: 5, vsync: this);
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
    final data = await SheetService.fetchUTRequests();

    setState(() {
      allRequests = data.reversed.toList();
      applyFilters();
    });
  }

  void applyFilters() {
    String tab = ['All', 'Pending', 'Approved', 'Rejected', 'Incorrect_ID']
        [tabController.index];

    filteredRequests = allRequests.where((e) {
      return tab == 'All' || e.status == tab;
    }).toList();

    setState(() {});
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      await SheetService.submitUT(
        requestBy: requestBYController.text,
        expertId: expertIdController.text,
        region: selectedRegion!,
        utHours: selectUtHours!,
        reason: selectedReason!,
        hasJob: hasJob!,
      );

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted ✅')),
      );
      requestBYController.clear();
      expertIdController.clear();
      selectUtHours = null;
      selectedRegion = null;
      selectedReason = null;
      hasJob = null;

      await loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = allRequests.length;
    int pending = allRequests.where((e) => e.status == 'Pending').length;
    int approved = allRequests.where((e) => e.status == 'Approved').length;
    int rejected = allRequests.where((e) => e.status == 'Rejected').length;
    int incorrectid = allRequests.where((e) => e.status == 'Incorrect_ID').length;

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
              child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'UT OPS DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Wrong ID'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: primaryAccent,
        onRefresh: loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const SizedBox(height: 4),

            // 🔥 SUMMARY
            Row(
              children: [
                _summaryCard('Total', total, const Color(0xFF2979FF)),
                _summaryCard('Pending', pending, const Color(0xFFFF6D00)),
                _summaryCard('Approved', approved, const Color(0xFF00C853)),
                _summaryCard('Rejected', rejected, const Color(0xFFD50000)),
                _summaryCard('Wrong', incorrectid, const Color(0xFF9C27B0)),
              ],
            ),

            const SizedBox(height: 16),

            // 🔥 FORM
            _formCard(),

            const SizedBox(height: 16),

            // 📋 LIST
            ...filteredRequests.map((r) => _requestCard(r)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New UT Request",
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            _inputField(requestBYController, 'Requested By'),
            const SizedBox(height: 10),
            _inputField(expertIdController, 'Expert ID', isNumber: true),
            const SizedBox(height: 10),

            _dropdownField('Region', selectedRegion, _regions(),
                (v) => setState(() => selectedRegion = v)),
            const SizedBox(height: 10),

            
            _dropdownField('UtHours', selectUtHours, _utHours(),
                (v) => setState(() => selectUtHours = v)),
            const SizedBox(height: 10),


            _dropdownField('Reason', selectedReason, _reasons(),
                (v) => setState(() => selectedReason = v)),
            const SizedBox(height: 10),

            _dropdownField(
              'Has Job?',
              hasJob,
              ['Yes', 'No']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              (v) => setState(() => hasJob = v),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REQUEST CARD ----------------
  Widget _requestCard(UTRequest r) {
    Color color = r.status == 'Approved'
        ? const Color(0xFF00C853)
        : r.status == 'Rejected'
            ? const Color(0xFFD50000)
            : const Color(0xFFFF6D00);

    IconData statusIcon = r.status == 'Approved'
        ? Icons.check_circle_rounded
        : r.status == 'Rejected'
            ? Icons.cancel_rounded
            : Icons.access_time_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ID: ${r.expertId}",
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${r.region} • ${r.reason}",
                  style: const TextStyle(color: textSecondary, fontSize: 13),
                ),
                Text(
                  "UT: ${r.utHours}",
                  style: const TextStyle(color: textSecondary, fontSize: 13),
                ),
                if (r.hasJob == "Yes")
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD50000).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "⚠ Has Job - Risk of Delay",
                      style: TextStyle(
                        color: Color(0xFFD50000),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- INPUTS ----------------
  Widget _inputField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: textPrimary),
      decoration: _inputDecoration(label),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _dropdownField(String label, String? value,
      List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return DropdownButtonFormField(
      initialValue: value,
      dropdownColor: cardColor,
      style: const TextStyle(color: textPrimary),
      decoration: _inputDecoration(label),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textSecondary),
      filled: true,
      fillColor: inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryAccent, width: 1.5),
      ),
    );
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.circle, color: color, size: 8),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: textSecondary, fontSize: 10),
            ),
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

    List<DropdownMenuItem<String>> _utHours() {
    return [
      '-1',
      '-2',
      '-3',
      '-4',
      'Till End'
    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }


  List<DropdownMenuItem<String>> _reasons() {
    return [
      'Denying to do',
      'Health Issue',
      'Monthly cycle',
      'Family Problem',
      'Not Responding',
      'Battery Swap'
    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }
}

