import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/utils/avatar_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardviewstate();
}

class _AdminDashboardviewstate extends State<AdminDashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _dashboardDataFuture = _loadDashboardData();
        });
      }
    }
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final admin = userController.currentUser;
      if (admin == null) {
        return {'error': 'Admin non connecté'};
      }

      final allUsers = await userController.getAllUsers();
      final allConges = await _congeController.getAllConges();

      print('🔍 DEBUG: Total congés récupérés: ${allConges.length}');

      int congesAcceptes = allConges
          .where((c) => c.statut == StatutConge.approuve)
          .length;

      int congesRefuses = allConges
          .where((c) => c.statut == StatutConge.refuse)
          .length;

      int demandesEnAttente = allConges
          .where((c) => c.statut == StatutConge.enAttente)
          .length;

      // 📊 Calculer les absences par mois (5 derniers mois)
      final now = DateTime.now();
      final absencesParMois = <String, int>{};
      final moisNoms = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];

      // Calculer les 5 derniers mois correctement
      for (int i = 4; i >= 0; i--) {
        int moisToCheck = now.month - i;
        int yearToCheck = now.year;

        // Ajuster si le mois est négatif
        if (moisToCheck <= 0) {
          moisToCheck += 12;
          yearToCheck -= 1;
        }

        final moisNom = moisNoms[moisToCheck - 1];

        int count = allConges
            .where(
              (c) =>
                  c.dateDebut.month == moisToCheck &&
                  c.dateDebut.year == yearToCheck,
            )
            .length;

        print('📅 $moisNom $yearToCheck: $count absences');
        absencesParMois[moisNom] = count;
      }

      // 📈 Calculer la répartition des congés par type (tous les statuts)
      int congesAnnuel = allConges
          .where((c) => c.typeConge == TypeConge.annuel)
          .length;
      int congesMaladie = allConges
          .where((c) => c.typeConge == TypeConge.maladie)
          .length;
      int congesSansSolde = allConges
          .where((c) => c.typeConge == TypeConge.sansSolde)
          .length;

      print(
        '📊 Congés - Annuel: $congesAnnuel, Maladie: $congesMaladie, SansSolde: $congesSansSolde',
      );

      int totalConges = congesAnnuel + congesMaladie + congesSansSolde;
      double ratioAnnuel = totalConges > 0 ? congesAnnuel / totalConges : 0;

      // 📉 Taux d'absentéisme basé sur les congés approuvés
      int totalDureeAbsences = allConges
          .where((c) => c.statut == StatutConge.approuve)
          .fold(0, (sum, c) => sum + c.duree);
      double tauxAbsenteisme = (allUsers.isNotEmpty)
          ? (totalDureeAbsences / (allUsers.length * 30)).clamp(0, 1) * 100
          : 0;

      print('📉 Taux de congé: $tauxAbsenteisme%');

      return {
        'admin': admin,
        'totalEmployes': allUsers.length,
        'congesAcceptes': congesAcceptes,
        'congesRefuses': congesRefuses,
        'demandesEnAttente': demandesEnAttente,
        'tauxAbsenteisme': tauxAbsenteisme,
        'absencesParMois': absencesParMois,
        'congesAnnuel': congesAnnuel,
        'congesMaladie': congesMaladie,
        'congesSansSolde': congesSansSolde,
        'ratioAnnuel': ratioAnnuel,
        'allConges': allConges,
      };
    } catch (e) {
      print('❌ Erreur chargement dashboard admin: $e');
      return {'error': 'Erreur: $e'};
    }
  }

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
                final admin = data['admin'];
                final totalEmployes = data['totalEmployes'] ?? 0;
                final congesAcceptes = data['congesAcceptes'] ?? 0;
                final congesRefuses = data['congesRefuses'] ?? 0;
                final demandesEnAttente = data['demandesEnAttente'] ?? 0;
                final tauxAbsenteisme = data['tauxAbsenteisme'] ?? 0.0;
                final absencesParMois =
                    data['absencesParMois'] as Map<String, dynamic>? ?? {};
                final congesAnnuel = data['congesAnnuel'] ?? 0;
                final congesMaladie = data['congesMaladie'] ?? 0;
                final congesSansSolde = data['congesSansSolde'] ?? 0;
                final ratioAnnuel = data['ratioAnnuel'] ?? 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          AvatarHelper.buildAvatarFromUser(user: admin!),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Bonjour!",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${admin.prenom} ${admin.nom}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout, size: 28),
                            onPressed: () {
                              userController.clearCurrentUser();
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Grille de statistiques
                      Row(
                        children: [
                          _buildStatCard(
                            "Total employés",
                            "$totalEmployes",
                            Icons.people,
                            const Color(0xFFF0EFFF),
                            const Color(0xFF6C2BD9),
                          ),
                          const SizedBox(width: 15),
                          _buildStatCard(
                            "Congés acceptés",
                            "$congesAcceptes",
                            Icons.calendar_month,
                            const Color(0xFFFFE8F2),
                            const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildStatCard(
                            "Demandes en attente",
                            "$demandesEnAttente",
                            Icons.hourglass_empty,
                            const Color(0xFFFFF4E5),
                            const Color(0xFFFFAB2D),
                          ),
                          const SizedBox(width: 15),
                          _buildStatCard(
                            "Congés refusés",
                            "$congesRefuses",
                            Icons.cancel,
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
                            children: absencesParMois.entries.map((e) {
                              return _buildBar(
                                e.key,
                                (e.value as num).toDouble(),
                              );
                            }).toList(),
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
                                      value: ratioAnnuel,
                                      strokeWidth: 20,
                                      color: Colors.pinkAccent.withOpacity(0.6),
                                      backgroundColor: Colors.lightBlue
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  Text(
                                    "${(ratioAnnuel * 100).toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Légendes avec vraies données
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildLegend(
                                  "Annuel ($congesAnnuel)",
                                  Colors.pinkAccent,
                                ),
                                _buildLegend(
                                  "Maladie ($congesMaladie)",
                                  Colors.blueAccent,
                                ),
                                _buildLegend(
                                  "Sans solde ($congesSansSolde)",
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
