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

    String? selectedRegion;
    String? selectedReason;
    String? hasJob;

    List<UTRequest> allRequests = [];
    List<UTRequest> filteredRequests = [];

    bool isSubmitting = false;

    Timer? autoRefreshTimer;
    late TabController tabController;

    // 🎨 DARK THEME COLORS
    final bgColor = const Color(0xFF0F172A); // dark navy
    final cardColor = const Color(0xFF1E293B);
    final borderColor = const Color(0xFF334155);
    final textPrimary = Colors.white;
    final textSecondary = Colors.grey;

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
          utHours: utHoursController.text,
          reason: selectedReason!,
          hasJob: hasJob!,
        );

        setState(() => isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted ✅')),
        );
        requestBYController.clear();
        expertIdController.clear();
        utHoursController.clear();
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
  const primaryAccent = Color(0xFFE91E63); // Magenta
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: primaryAccent,
          elevation: 0,
          title: const Text('UT Ops Dashboard'),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.cyanAccent,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
              Tab(text: 'Incorrect_ID',)
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
                  _summaryCard('Rejected', rejected, Colors.red),
                  _summaryCard('Wrong_ID', incorrectid, Colors.red),
                  
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
              _inputField(requestBYController, 'Requested BY'),
              const SizedBox(height: 10),
              _inputField(expertIdController, 'Expert ID', isNumber: true),
              const SizedBox(height: 10),

              _dropdownField('Region', selectedRegion, _regions(),
                  (v) => setState(() => selectedRegion = v)),
              const SizedBox(height: 10),

              _inputField(utHoursController, 'UT Hours'),
              const SizedBox(height: 10),

              _dropdownField('Reason', selectedReason, _reasons(),
                  (v) => setState(() => selectedReason = v)),
              const SizedBox(height: 10),

              _dropdownField('Has Job?', hasJob, ['Yes', 'No']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(), (v) => setState(() => hasJob = v)),

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

    // ---------------- REQUEST CARD ----------------
    Widget _requestCard(UTRequest r) {
      Color color = r.status == 'Approved'
          ? Colors.green
          : r.status == 'Rejected'
              ? Colors.red
              : Colors.amber;
      


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
            Icon(
              r.status == 'Approved'
                  ? Icons.check_circle
                  : r.status == 'Rejected'
                      ? Icons.cancel
                      : Icons.access_time,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("ID: ${r.expertId}",
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold)),
                  Text("${r.region} • ${r.reason}",
                      style: TextStyle(color: textSecondary)),
                  Text("UT: ${r.utHours}",
                      style: TextStyle(color: textSecondary)),
                      if (r.hasJob == "Yes")
    Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "⚠ Has Job - Risk of Delay",
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    ),
                ],
              ),
            ),
            Text(
              r.status,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }

    // ---------------- INPUTS ----------------
    Widget _inputField(TextEditingController controller, String label,
        {bool isNumber = false}) {
      return TextFormField(
        controller: controller,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textPrimary),
        decoration: _inputDecoration(label),
        validator: (v) => v!.isEmpty ? 'Required' : null,
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
        'Denying to do',
        'Health Issue',
        'Monthly cycle',
        'Family Problem',
        'Not Responding',
        'Battery Swap'
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
    }
  }