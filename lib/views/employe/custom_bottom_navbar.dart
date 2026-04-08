import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home
          _buildNavItem(Icons.home, 0, 'Accueil'),
          // Calendar
          _buildNavItem(Icons.calendar_today, 1, 'Congés'),
          // Add (Center with larger size)
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6C2BD9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C2BD9).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          // Documents
          _buildNavItem(Icons.insert_drive_file, 3, 'Documents'),
          // Profile
          _buildNavItem(Icons.person, 4, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF6C2BD9).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF6C2BD9)
                  : Colors.grey.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF6C2BD9),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

