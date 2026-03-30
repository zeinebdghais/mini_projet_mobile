import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/screens/employe/custom_bottom_navbar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  int currentIndex = 2;
  int selectedFilter = 0;

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

          /// CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: const [
                      Icon(Icons.arrow_back),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Mes Documents",
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

                  /// SEARCH
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un document...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip("Toutes", 0),
                        _filterChip("Fiche de paie", 1),
                        _filterChip("Attestation", 2),
                        _filterChip("Contrat", 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Liste des documents",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "6 documents",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// LIST
                  Expanded(
                    child: ListView(
                      children: [
                        _docItem(
                          "Fiche de paie – Février 2026",
                          "Fiche de paie",
                          "28 Fév 2026 • 245 Ko",
                          Colors.deepPurple,
                        ),
                        _docItem(
                          "Attestation de travail",
                          "Attestation",
                          "15 Jan 2026 • 120 Ko",
                          Colors.pink,
                        ),
                        _docItem(
                          "Attestation de salaire",
                          "Attestation",
                          "10 Déc 2025 • 98 Ko",
                          Colors.pink,
                        ),
                        _docItem(
                          "Contrat CDI",
                          "Contrat",
                          "01 Sep 2024 • 1.2 Mo",
                          Colors.orange,
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

  /// DOCUMENT ITEM
  Widget _docItem(String title, String type, String date, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insert_drive_file, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TYPE + DATE
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(type, style: TextStyle(color: color, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            children: [
              _actionBtn(Icons.remove_red_eye, "Voir"),
              const SizedBox(width: 10),
              _actionBtn(Icons.download, "Télécharger"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5F2EEA)),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF5F2EEA), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
