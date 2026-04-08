import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardviewstate();
}

class _AdminDashboardviewstate extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // Réutilisation de ta méthode de background
  Widget buildBlurCircle({
    required Color color,
    required double size,
    required double top,
    required double left,
  }) {
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
              color: color.withOpacity(0.35),
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // --- BACKGROUND COMMUN ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FAFF), Colors.white],
              ),
            ),
          ),
          buildBlurCircle(
            color: Colors.greenAccent,
            size: 150,
            top: 60,
            left: 20,
          ),
          buildBlurCircle(
            color: Colors.yellowAccent,
            size: 140,
            top: 0,
            left: size.width - 160,
          ),
          buildBlurCircle(
            color: Colors.blueAccent,
            size: 170,
            top: 400,
            left: size.width - 140,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          // --- CONTENU ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=zeineb',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Bonjour!",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "Zeineb Dghais",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none_rounded, size: 28),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Grille de statistiques
                  Row(
                    children: [
                      _buildStatCard(
                        "Total employés",
                        "130",
                        Icons.people,
                        const Color(0xFFF0EFFF),
                        const Color(0xFF6C2BD9),
                      ),
                      const SizedBox(width: 15),
                      _buildStatCard(
                        "Congés en cours",
                        "12",
                        Icons.calendar_month,
                        const Color(0xFFFFE8F2),
                        const Color(0xFFFF69B4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatCard(
                        "Demandes en attente",
                        "3",
                        Icons.hourglass_empty,
                        const Color(0xFFFFF4E5),
                        const Color(0xFFFFAB2D),
                      ),
                      const SizedBox(width: 15),
                      _buildStatCard(
                        "Taux absentéisme",
                        "4.1%",
                        Icons.trending_down,
                        const Color(0xFFFFEBEB),
                        const Color(0xFFFF5E5E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Graphique Absences (Barres)
                  _buildChartSection(
                    "Absences par mois",
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar("Janvier", 60),
                          _buildBar("Février", 80),
                          _buildBar("Mars", 60),
                          _buildBar("Avril", 110),
                          _buildBar("Mai", 100),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Graphique Répartition (Donut)
                  _buildChartSection(
                    "Répartition des congés",
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 20,
                                  color: Colors.pinkAccent.withOpacity(0.6),
                                  backgroundColor: Colors.lightBlue.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              const Text(
                                "100%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Légendes
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildLegend("Annuel", Colors.pinkAccent),
                            _buildLegend("Maladie", Colors.blueAccent),
                            _buildLegend("Sans solde", Colors.purple),
                            _buildLegend("Autre", Colors.greenAccent),
                          ],
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

      // --- APPEL DE VOTRE ADMIN NAVBAR ---
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/admin/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/employees');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/admin/demandes');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/admin/documents');
              break;
          }
        },
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildBar(String month, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month.substring(0, 3),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

