import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final regionController = TextEditingController();

  String selectedRole = "TL";

  bool isLoading = false;

  // 🔥 YOUR DJANGO API URL
  final String apiUrl = "http://10.219.200.2:8000/api/signup/";

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "designation": selectedRole,
          "region": regionController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful ✅")),
        );

        Navigator.pop(context);
      } else {
        throw Exception(data.toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFFE91E63);
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const textPrimary = Colors.white;
    const textSecondary = Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryAccent,
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // 🔥 TITLE
                  const Text(
                    "Signup",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 NAME
                  _inputField(nameController, "Name"),

                  // 🔥 EMAIL
                  _inputField(emailController, "Email"),

                  // 🔥 PASSWORD
                  _inputField(passwordController, "Password", isPassword: true),

                  // 🔥 REGION
                  _inputField(regionController, "Region"),

                  const SizedBox(height: 12),

                  // 🔥 ROLE DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: cardColor,
                    style: const TextStyle(color: textPrimary),
                    decoration: _inputDecoration("Designation"),
                    items: ["TL", "RCLM", "CLM", "CITY_HEAD"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value!);
                    },
                  ),

                  const SizedBox(height: 20),

                  // 🔥 BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : signup,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Signup"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 INPUT FIELD
  Widget _inputField(TextEditingController controller, String hint,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        validator: (value) =>
            value!.isEmpty ? "$hint is required" : null,
        decoration: _inputDecoration(hint),
      ),
    );
  }

  // 🔥 INPUT STYLE
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF020617),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}