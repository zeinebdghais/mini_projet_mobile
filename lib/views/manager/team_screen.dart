import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _Teamviewstate();
}

class _Teamviewstate extends State<TeamScreen> {
  // Réutilisation de ta méthode pour le background
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
          "Mon équipe",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/manager/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/manager/demandes');
              break;
            case 2:
              // Déjà sur team
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/manager/profile');
              break;
          }
        },
      ),
      body: Stack(
        children: [
          // --- MÊME BACKGROUND ---
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
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un membre...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),
                ),

                // Liste des membres
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      // Simuler un membre "en congé" pour l'exemple
                      bool isOff = index == 1;
                      return TeamMemberCard(
                        name: "Nadia Fassi",
                        role: "Chef de projet",
                        status: isOff ? "En congé" : "Présente",
                        isAvailable: !isOff,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String status;
  final bool isAvailable;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.status,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=nadia'),
          ),
          const SizedBox(width: 15),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Badge Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFE5D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isAvailable ? Colors.green : const Color(0xFFFA6419),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

