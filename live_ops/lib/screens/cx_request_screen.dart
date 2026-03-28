import 'package:flutter/material.dart';
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

  static const primaryAccent = Color(0xFFE91E63);

  final reasons = [
    "Cx not responding",
    "Approval pending",
    "Commercial order",
    "Cx wants to cancel",
    "Cx asking different location",
    "Cx denying COD"
  ];

  final regions = ["Delhi", "Mumbai", "Thane", "Bangalore"];

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
        const SnackBar(content: Text("Request Submitted")),
      );

      jobIdController.clear();
      expertIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CX REQUEST"),
        backgroundColor: primaryAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _input(jobIdController, "Job ID"),

              const SizedBox(height: 12),

              _dropdown("Region", regions, selectedRegion, (v) {
                setState(() => selectedRegion = v!);
              }),

              const SizedBox(height: 12),

              _dropdown("Reason", reasons, selectedReason, (v) {
                setState(() => selectedReason = v!);
              }),

              const SizedBox(height: 12),

              _input(expertIdController, "Expert ID", isNumber: true),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _input(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}