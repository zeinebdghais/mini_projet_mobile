import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';

class AcceuilEmployeee extends StatefulWidget {
  const AcceuilEmployeee({super.key});

  @override
  State<AcceuilEmployeee> createState() => _AcceuilEmployeeeState();
}

class _AcceuilEmployeeeState extends State<AcceuilEmployeee> {
  int currentIndex = 0;

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
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/employe/conges');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      /// NAVBAR
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),

      /// BODY
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
          blurCircle(Colors.blueAccent, 160, 220, size.width - 140),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
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
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.deepPurple,
                        ),
                        tooltip: 'Déconnexion',
                        onPressed: () {
                          userController.clearCurrentUser();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                      const SizedBox(width: 8),
                      // Notification icon removed
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F2EEA), Color(0xFF7F56D9)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Solde de congés restant",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "12 jours restants",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _SmallButton(),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: 0.85,
                                strokeWidth: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const Text(
                              "85%",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// DEMANDES
                  Row(
                    children: [
                      const Text(
                        "Mes demandes récentes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDE9FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "6",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5F2EEA),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: buildRequestCard(
                          "Congé maladie",
                          "2 Février",
                          "Approuvé",
                          const Color(0xFFD1FAE5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildRequestCard(
                          "Congé annuel",
                          "15 Mars - 18 Mars",
                          "En attente",
                          const Color(0xFFFDE2E2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// RESUME
                  const Text(
                    "Résumé RH",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  _infoTile("Congés pris", "8 jours"),
                  _infoTile("Absences", "2 absences"),
                  _infoTile("Demandes en attente", "1 demande"),
                  _infoTile("Documents disponibles", "5 documents"),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PETIT BOUTON
class _SmallButton extends StatelessWidget {
  const _SmallButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/employe/demande');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Demandes de congé",
          style: TextStyle(
            color: Color(0xFF5F2EEA),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// CARD DEMANDE
Widget buildRequestCard(String title, String date, String status, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text("Statut: $status", style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

/// INFO TILE
Widget _infoTile(String title, String subtitle) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5F2EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_today,
            size: 18,
            color: Color(0xFF5F2EEA),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    ),
  );
}
