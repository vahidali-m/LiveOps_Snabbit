import 'package:flutter/material.dart';

class BreachesScreen extends StatelessWidget {
  const BreachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breaches'),
        backgroundColor: Color(0xFFE91E63),
      ),
      body: const Center(
        child: Text(
          'Breaches Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}