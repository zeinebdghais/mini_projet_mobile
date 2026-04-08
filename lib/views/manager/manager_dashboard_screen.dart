import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardviewstate();
}

class _ManagerDashboardviewstate extends State<ManagerDashboardScreen> {
  int currentIndex = 0;

  /// BACKGROUND BLUR
  Widget blurCircle(Color color, double size, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  /// NAVIGATION
  void _onNavTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Dashboard manager
        Navigator.pushReplacementNamed(context, '/manager/dashboard');
        break;
      case 1:
        // Demandes
        Navigator.pushReplacementNamed(context, '/manager/demandes');
        break;
      case 2:
        // Team
        Navigator.pushReplacementNamed(context, '/manager/team');
        break;
      case 3:
        // Profil
        Navigator.pushReplacementNamed(context, '/manager/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,

      // FAB supprimé

      /// NAVBAR
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),

      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F8FC), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          blurCircle(Colors.greenAccent, 160, 80, 20),
          blurCircle(Colors.yellowAccent, 140, 0, size.width - 150),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          /// CONTENU
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    /// HEADER
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(
                            'assets/images/profile.jpg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bonjour!",
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              "Zeineb Dghais",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.notifications),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// STATS
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "Demandes en attente",
                            "4",
                            Icons.access_time,
                            Colors.pink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            "Mon équipe",
                            "12",
                            Icons.group,
                            Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "Congés en cours",
                            "3",
                            Icons.work,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            "Absences",
                            "2",
                            Icons.close,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// ACCES RAPIDE
                    const Text(
                      "Accès rapide",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _quickItem("Mon équipe", "12 membres"),
                    _quickItem("Demandes à valider", "4 en attente"),

                    const SizedBox(height: 25),

                    /// DERNIERES DEMANDES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Dernières demandes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Voir tout",
                          style: TextStyle(
                            color: Color(0xFF5F2EEA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _demandeItem(),
                    _demandeItem(),
                    _demandeItem(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STAT CARD
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// QUICK ITEM
  Widget _quickItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_forward, color: Color(0xFF5F2EEA)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  /// DEMANDE ITEM
  Widget _demandeItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yasmine Alaoui",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Congé annuel • 3 jours",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "En attente",
              style: TextStyle(color: Colors.orange, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

