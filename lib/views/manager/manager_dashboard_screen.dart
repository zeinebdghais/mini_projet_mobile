import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/utils/avatar_helper.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardviewstate();
}

class _ManagerDashboardviewstate extends State<ManagerDashboardScreen>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final CongeAbsenceController _congeController = CongeAbsenceController();

  late Future<Map<String, dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dashboardDataFuture = _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔄 Rafraîchir quand l'app revient au focus
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 Dashboard Manager - App au focus - Rafraîchissement');
      if (mounted) {
        setState(() {
          _dashboardDataFuture = _loadDashboardData();
        });
      }
    }
  }

  // 📊 Charger toutes les données du dashboard
  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final manager = userController.currentUser;
      if (manager == null) {
        return {'error': 'Manager non connecté'};
      }

      // Récupérer les demandes de l'équipe
      final conges = await _congeController.getAllCongesForManager(manager.id);

      // Récupérer le nombre d'employés dans l'équipe
      final employees = await userController.getEmployeesByManager(manager.id);

      // Calculer les statistiques
      int demandesEnAttente = conges
          .where((c) => c.statut == StatutConge.enAttente)
          .length;

      int congesEnCours = conges
          .where((c) => c.statut == StatutConge.approuve)
          .length;

      // Les 3 dernières demandes
      final derniersDemandes = conges.take(3).toList();

      return {
        'manager': manager,
        'demandesEnAttente': demandesEnAttente,
        'equipeSize': employees.length,
        'congesEnCours': congesEnCours,
        'absences': 0, // À calculer selon vos besoins
        'derniersDemandes': derniersDemandes,
      };
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      return {'error': 'Erreur: $e'};
    }
  }

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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _dashboardDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data?['error'] != null) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error ?? snapshot.data?['error']}',
                    ),
                  );
                }

                final data = snapshot.data ?? {};
                final manager = data['manager'];
                final demandesEnAttente = data['demandesEnAttente'] ?? 0;
                final equipeSize = data['equipeSize'] ?? 0;
                final congesEnCours = data['congesEnCours'] ?? 0;
                final derniersDemandes = data['derniersDemandes'] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        /// HEADER
                        Row(
                          children: [
                            AvatarHelper.buildAvatarFromUser(user: manager!),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bonjour!",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  "${manager.prenom} ${manager.nom}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                              onPressed: () {
                                userController.clearCurrentUser();
                                Navigator.pushReplacementNamed(context, '/');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// STATS
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                "Demandes en attente",
                                "$demandesEnAttente",
                                Icons.access_time,
                                Colors.pink,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard(
                                "Mon équipe",
                                "$equipeSize",
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
                                "$congesEnCours",
                                Icons.work,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard(
                                "Absences",
                                "0",
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

                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/manager/team',
                          ),
                          child: _quickItem(
                            "Mon équipe",
                            "$equipeSize membres",
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/manager/demandes',
                          ),
                          child: _quickItem(
                            "Demandes à valider",
                            "$demandesEnAttente en attente",
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// DERNIERES DEMANDES
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Dernières demandes",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/manager/demandes',
                              ),
                              child: const Text(
                                "Voir tout",
                                style: TextStyle(
                                  color: Color(0xFF5F2EEA),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        if (derniersDemandes.isNotEmpty)
                          ...derniersDemandes
                              .map((demande) => _demandeItem(demande))
                              .toList()
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('Aucune demande')),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
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
  Widget _demandeItem(Conge conge) {
    final typeConge = conge.typeConge.toString().split('.').last;
    final statut = conge.statut.toString().split('.').last;

    Color statutColor = Colors.orange;
    if (statut.contains('approuve')) {
      statutColor = Colors.green;
    } else if (statut.contains('refuse')) {
      statutColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar de l'employé - récupérer depuis Firestore
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(
              '${conge.employeId[0].toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeConge.replaceFirst(
                    typeConge[0],
                    typeConge[0].toUpperCase(),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${conge.dateDebut.day}/${conge.dateDebut.month} - ${conge.dateFin.day}/${conge.dateFin.month} • ${conge.duree} jour${conge.duree > 1 ? 's' : ''}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statutColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statut.replaceFirst(statut[0], statut[0].toUpperCase()),
              style: TextStyle(color: statutColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
