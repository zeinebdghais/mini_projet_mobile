import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/models/conge.dart';

class CongesScreen extends StatefulWidget {
  const CongesScreen({super.key});

  @override
  State<CongesScreen> createState() => _Congesviewstate();
}

class _Congesviewstate extends State<CongesScreen> {
  int currentIndex = 2;
  final CongeAbsenceController _congeController = CongeAbsenceController();
  List<Conge> _conges = [];
  bool _loading = true;

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
  void initState() {
    super.initState();
    _fetchConges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchConges();
  }

  Future<void> _fetchConges() async {
    final user = userController.currentUser;
    print('🔍 DEBUG Conges: user = $user');
    if (user == null) {
      print('❌ Utilisateur non trouvé!');
      setState(() => _loading = false);
      return;
    }
    print('✅ User ID: ${user.id}');
    setState(() => _loading = true);
    try {
      final conges = await _congeController.getEmployeeConges(user.id);
      print('✅ Congés récupérés: ${conges.length}');
      setState(() {
        _conges = conges;
        _loading = false;
      });
    } catch (e) {
      print('❌ Erreur récupération congés: $e');
      setState(() => _loading = false);
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

          /// CONTENU
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  /// HEADER
                  Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      const Expanded(
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// CARD SOLDE
                  _buildSoldeCard(),
                  const SizedBox(height: 20),

                  /// FILTERS
                  Row(
                    children: [
                      _filterChip("Toutes", 0),
                      _filterChip("Refusé", 1),
                      _filterChip("En attente", 2),
                      _filterChip("Approuvé", 3),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// LISTE
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _conges.isEmpty
                        ? const Center(child: Text('Aucun congé trouvé'))
                        : ListView(
                            children: _conges
                                .where(
                                  (c) =>
                                      selectedFilter == 0 ||
                                      (selectedFilter == 1 &&
                                          c.statut.toString().contains(
                                            'refuse',
                                          )) ||
                                      (selectedFilter == 2 &&
                                          c.statut.toString().contains(
                                            'enAttente',
                                          )) ||
                                      (selectedFilter == 3 &&
                                          c.statut.toString().contains(
                                            'approuve',
                                          )),
                                )
                                .map(
                                  (c) => _congeItem(
                                    c.typeConge.toString().split('.').last,
                                    '${c.dateDebut.day}/${c.dateDebut.month}/${c.dateDebut.year} - ${c.dateFin.day}/${c.dateFin.month}/${c.dateFin.year}',
                                    c.statut.toString().split('.').last,
                                    c.statut == StatutConge.approuve
                                        ? Colors.green
                                        : c.statut == StatutConge.enAttente
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                )
                                .toList(),
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

  Widget _buildSoldeCard() {
    final user = userController.currentUser;
    final soldeRestant = user?.soldeCongeRestant ?? 0;
    final soldeTotal = user?.soldeCongeTotal ?? 0;
    final soldeUtilise = soldeTotal - soldeRestant;
    final progress = soldeTotal > 0 ? soldeUtilise / soldeTotal : 0.0;
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Solde de congés",
                style: TextStyle(color: Colors.white),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/employe/demande');
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "$soldeRestant / $soldeTotal jours",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Utilisés : $soldeUtilise",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                "Restants : $soldeRestant",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
