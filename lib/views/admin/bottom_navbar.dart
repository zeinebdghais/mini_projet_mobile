import 'package:flutter/material.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _navItem(IconData icon, int index) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF5F2EEA).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF5F2EEA) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard, 0), // Dashboard admin
          _navItem(Icons.people_alt, 1), // Gestion employés
          _navItem(Icons.assignment_turned_in, 2), // Demandes à accepter
          _navItem(Icons.folder_shared, 3), // Gérer documents
        ],
      ),
    );
  }
}

