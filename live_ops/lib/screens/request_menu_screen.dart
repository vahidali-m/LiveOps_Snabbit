import 'package:flutter/material.dart';
import 'package:live_ops/models/cx_request_model.dart';
import 'package:live_ops/screens/cx_request_screen.dart';
import 'package:live_ops/screens/reassign_request_screen.dart.dart';
import 'ut_request_screen.dart';

class RequestMenuScreen extends StatelessWidget {
  const RequestMenuScreen({super.key});

  // 🎨 SAME THEME
  final bgColor = const Color(0xFF0F172A);
  final cardColor = const Color(0xFF1E293B);
  final textPrimary = Colors.white;
  final textSecondary = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: const Text('OPS REQUEST'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 UT REQUEST CARD
            _menuCard(
              context,
              title: "UT Requests",
              subtitle: "Manage UT hours & approvals",
              icon: Icons.access_time,
              color: Colors.cyanAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UTRequestScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔥 REASSIGN CARD
            _menuCard(
              context,
              title: "Reassign Requests",
              subtitle: "Reassign jobs to experts",
              icon: Icons.swap_horiz,
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReassignRequestScreen(),
                  ),
                );

                
              },
            ),
            const SizedBox(height: 20),

            // 🔥 UT REQUEST CARD
            _menuCard(
              context,
              title: "Cx issue request",
              subtitle: "Share Cx related issue",
              icon: Icons.access_time,
              color: const Color.fromARGB(255, 236, 255, 24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CXRequestScreen(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  // 🔥 REUSABLE CARD UI
  Widget _menuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 16),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ARROW
            Icon(Icons.arrow_forward_ios,
                color: textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}