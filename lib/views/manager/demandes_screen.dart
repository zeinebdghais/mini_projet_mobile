import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});

  @override
  State<DemandesScreen> createState() => _Demandesviewstate();
}

class _Demandesviewstate extends State<DemandesScreen> {
  // int _currentIndex = 0; // plus utilisé

  // Réutilisation de votre méthode de background
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          tooltip: 'Retour au dashboard',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/manager/dashboard');
          },
        ),
        title: const Text(
          "Demandes à valider",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/manager/dashboard');
              break;
            case 1:
              // Déjà sur demandes
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/manager/team');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/manager/profile');
              break;
          }
        },
      ),
      body: Stack(
        children: [
          // --- BACKGROUND (Identique à votre Login) ---
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
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Onglets (Filtres)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterTab("Tout", true),
                      _buildFilterTab("En attente (3)", false),
                      _buildFilterTab("Approuvées (2)", false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des demandes
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      100,
                    ), // Padding bas pour la navbar
                    children: const [
                      RequestCard(
                        status: "En attente",
                        statusColor: Color(0xFFFFE5D9),
                        textColor: Color(0xFFFA6419),
                      ),
                      RequestCard(
                        status: "Approuvée",
                        statusColor: Color(0xFFE2FBE7),
                        textColor: Color(0xFF2ECC71),
                      ),
                      RequestCard(
                        status: "Approuvée",
                        statusColor: Color(0xFFFFE8E8),
                        textColor: Color(0xFFFF5E5E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C2BD9) : const Color(0xFFF0EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF6C2BD9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Color textColor;

  const RequestCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=32',
                ), // Image test
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Yasmine Alaoui",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Congé annuel",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn("Début", "15 Mars"),
              _infoColumn("Fin", "17 Mars"),
              _infoColumn("Durée", "3 jours"),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Motif",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Text(
            "Vacances familiales",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          if (status == "En attente") ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.green,
                    ),
                    label: const Text(
                      "Approuver",
                      style: TextStyle(color: Colors.green),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text(
                      "Refuser",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

