import 'package:flutter/material.dart';
import 'package:live_ops/screens/cx_request_screen.dart';
import 'package:live_ops/screens/reassign_request_screen.dart.dart';
import 'ut_request_screen.dart';

class RequestMenuScreen extends StatelessWidget {
  const RequestMenuScreen({super.key});

  // 🎨 WHITE + PINK THEME
  static const bgColor = Color(0xFFF5F5F7);
  static const cardColor = Colors.white;
  static const primaryAccent = Color(0xFFE91E63);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A9A);

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'OPS REQUEST',
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
              color: const Color(0xFF2979FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UTRequestScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 🔥 REASSIGN CARD
            _menuCard(
              context,
              title: "Reassign Requests",
              subtitle: "Reassign jobs to experts",
              icon: Icons.swap_horiz,
              color: primaryAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReassignRequestScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 🔥 CX REQUEST CARD
            _menuCard(
              context,
              title: "Cx Issue Request",
              subtitle: "Share Cx related issue",
              icon: Icons.contact_support,
              color: const Color(0xFF9C27B0),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ARROW
            const Icon(Icons.arrow_forward_ios_rounded,
                color: textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}