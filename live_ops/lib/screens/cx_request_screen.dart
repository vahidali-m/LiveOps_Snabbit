import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_ops/models/cx_request_model.dart';
import '../services/sheet_service_cx.dart';

class CXRequestScreen extends StatefulWidget {
  const CXRequestScreen({super.key});

  @override
  State<CXRequestScreen> createState() => _CXRequestScreenState();
}

class _CXRequestScreenState extends State<CXRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final jobIdController = TextEditingController();
  final expertIdController = TextEditingController();

  String selectedRegion = "Delhi";
  String selectedReason = "Cx not responding";

  bool isLoading = false;

  // 🔥 REQUESTS LIST
  List<CXRequest> allRequests = [];
  bool isLoadingRequests = false;
  Timer? autoRefreshTimer;

  // 🎨 WHITE + PINK THEME
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);
  static const inputFill = Color(0xFFF0F0F5);
  static const borderColor = Color(0xFFE0E0EA);

  final reasons = [
    "Cx not responding",
    "Approval pending",
    "Commercial order",
    "Cx wants to cancel",
    "Cx asking different location",
    "Cx denying COD"
  ];

  final regions = ["Delhi", "Mumbai", "Thane", "Bangalore"];

  @override
  void initState() {
    super.initState();
    loadRequests();
    autoRefreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => loadRequests());
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    jobIdController.dispose();
    expertIdController.dispose();
    super.dispose();
  }

  Future<void> loadRequests() async {
    setState(() => isLoadingRequests = true);
    try {
      final data = await CXService.fetchCX();
      setState(() {
        allRequests = data.reversed.toList();
      });
    } catch (e) {
      // silently fail
    }
    setState(() => isLoadingRequests = false);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await CXService.submitCX(
        jobId: jobIdController.text,
        region: selectedRegion,
        reason: selectedReason,
        expertId: expertIdController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Submitted ✅")),
      );

      jobIdController.clear();
      expertIdController.clear();

      await loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= STATUS HELPERS =================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'approved':
        return const Color(0xFF00C853);
      case 'rejected':
        return const Color(0xFFD50000);
      case 'pending':
        return const Color(0xFFFF6D00);
      default:
        return const Color(0xFF2979FF);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      default:
        return Icons.contact_support_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = allRequests.length;
    int pending = allRequests.where((r) => r.status.toLowerCase() == 'pending').length;
    int resolved = allRequests.where((r) =>
        r.status.toLowerCase() == 'resolved' ||
        r.status.toLowerCase() == 'approved').length;

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
              child: const Icon(Icons.contact_support_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'CX REQUEST',
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
        onRefresh: loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // 🔥 SUMMARY CARDS
            Row(
              children: [
                _summaryCard('Total', total, const Color(0xFF2979FF)),
                _summaryCard('Pending', pending, const Color(0xFFFF6D00)),
                _summaryCard('Resolved', resolved, const Color(0xFF00C853)),
              ],
            ),

            const SizedBox(height: 16),

            // 🔥 FORM CARD
            Container(
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
                      "New CX Request",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _input(jobIdController, "Job ID"),
                    const SizedBox(height: 10),

                    _dropdown("Region", regions, selectedRegion, (v) {
                      setState(() => selectedRegion = v!);
                    }),
                    const SizedBox(height: 10),

                    _dropdown("Reason", reasons, selectedReason, (v) {
                      setState(() => selectedReason = v!);
                    }),
                    const SizedBox(height: 10),

                    _input(expertIdController, "Expert ID", isNumber: true),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Submit Request",
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
            ),

            const SizedBox(height: 20),

            // 🔥 SUBMITTED REQUESTS
            const Text(
              "Submitted Requests",
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            if (isLoadingRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: primaryAccent),
                ),
              )
            else if (allRequests.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "No requests yet",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                ),
              )
            else
              ...allRequests.map((r) => _requestCard(r)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================

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
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(CXRequest r) {
    final color = _statusColor(r.status);
    final icon = _statusIcon(r.status);

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
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Job: ${r.jobId}",
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
                if (r.expertId.isNotEmpty)
                  Text(
                    "Expert: ${r.expertId}",
                    style: const TextStyle(color: textSecondary, fontSize: 13),
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

  Widget _input(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: textPrimary),
      validator: (v) => v!.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardColor,
      style: const TextStyle(color: textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryAccent),
      decoration: InputDecoration(
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
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}