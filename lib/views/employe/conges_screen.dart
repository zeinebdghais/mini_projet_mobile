import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';

class CongesScreen extends StatefulWidget {
  const CongesScreen({super.key});

  @override
  State<CongesScreen> createState() => _Congesviewstate();
}

class _Congesviewstate extends State<CongesScreen> {
  int currentIndex = 1; // onglet calendrier actif

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

  void _onNavTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/employe/dashboard');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/employe/demande');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/employe/documents');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/employe/profile');
        break;
    }
  }

  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    children: const [
                      Icon(Icons.arrow_back),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Mes Congés",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.notifications),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// CARD SOLDE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F2EEA), Color(0xFF7F56D9)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Solde de congés",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.add, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "12 / 24 jours",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        /// PROGRESS BAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.5,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Utilisés : 12",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              "Restants : 12",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FILTERS
                  Row(
                    children: [
                      _filterChip("Toutes", 0),
                      _filterChip("Refusé", 1),
                      _filterChip("En attente", 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// LISTE
                  Expanded(
                    child: ListView(
                      children: [
                        _congeItem(
                          "Congé maladie",
                          "2 Février",
                          "Approuvée",
                          Colors.green,
                        ),
                        _congeItem(
                          "Congé annuel",
                          "15 Mars - 18 Mars",
                          "En attente",
                          Colors.orange,
                        ),
                        _congeItem(
                          "Congé maladie",
                          "2 Février",
                          "Refusé",
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER CHIP
  Widget _filterChip(String text, int index) {
    final isActive = selectedFilter == index;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5F2EEA)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// ITEM CONGE
  Widget _congeItem(String title, String date, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 5),
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

