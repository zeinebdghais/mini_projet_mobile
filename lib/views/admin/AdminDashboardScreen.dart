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

      int congesEnCours = allConges
          .where((c) => c.statut == StatutConge.approuve)
          .length;

      int demandesEnAttente = allConges
          .where((c) => c.statut == StatutConge.enAttente)
          .length;

      int congesRefuses = allConges
          .where((c) => c.statut == StatutConge.refuse)
          .length;

      // 📊 Calculer les absences par mois (6 derniers mois)
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

      for (int i = 5; i >= 0; i--) {
        int moisToCheck = now.month - i;
        int yearToCheck = now.year;

        if (moisToCheck <= 0) {
          moisToCheck += 12;
          yearToCheck -= 1;
        }

        final moisNom = moisNoms[moisToCheck - 1];
        int count = allConges
            .where(
              (c) =>
                  c.dateDebut.month == moisToCheck &&
                  c.dateDebut.year == yearToCheck &&
                  c.statut == StatutConge.approuve,
            )
            .length;

        absencesParMois[moisNom] = count;
      }

      // 📈 Répartition des congés par type
      int congesAnnuel = allConges
          .where((c) => c.typeConge == TypeConge.annuel)
          .length;
      int congesMaladie = allConges
          .where((c) => c.typeConge == TypeConge.maladie)
          .length;
      int congesSansSolde = allConges
          .where((c) => c.typeConge == TypeConge.sansSolde)
          .length;

      int totalConges = congesAnnuel + congesMaladie + congesSansSolde;

      // 📉 Taux d'absentéisme
      int totalDureeAbsences = allConges
          .where((c) => c.statut == StatutConge.approuve)
          .fold(0, (sum, c) => sum + c.duree);
      double tauxAbsenteisme = (allUsers.isNotEmpty)
          ? (totalDureeAbsences / (allUsers.length * 30)).clamp(0, 1) * 100
          : 0;

      // 📋 Dernières demandes
      final derniersDemandes = allConges
          .where((c) => c.statut == StatutConge.enAttente)
          .take(5)
          .toList();

      return {
        'admin': admin,
        'totalEmployes': allUsers.length,
        'congesEnCours': congesEnCours,
        'demandesEnAttente': demandesEnAttente,
        'congesRefuses': congesRefuses,
        'tauxAbsenteisme': tauxAbsenteisme,
        'absencesParMois': absencesParMois,
        'congesAnnuel': congesAnnuel,
        'congesMaladie': congesMaladie,
        'congesSansSolde': congesSansSolde,
        'totalConges': totalConges,
        'derniersDemandes': derniersDemandes,
        'allUsers': allUsers,
        'allConges': allConges,
      };
    } catch (e) {
      print('❌ Erreur dashboard admin: $e');
      return {'error': 'Erreur: $e'};
    }
  }

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
                final congesEnCours = data['congesEnCours'] ?? 0;
                final demandesEnAttente = data['demandesEnAttente'] ?? 0;
                final congesRefuses = data['congesRefuses'] ?? 0;
                final tauxAbsenteisme = data['tauxAbsenteisme'] ?? 0.0;
                final absencesParMois =
                    data['absencesParMois'] as Map<String, dynamic>? ?? {};
                final congesAnnuel = data['congesAnnuel'] ?? 0;
                final congesMaladie = data['congesMaladie'] ?? 0;
                final congesSansSolde = data['congesSansSolde'] ?? 0;
                final totalConges = data['totalConges'] ?? 0;
                final derniersDemandes =
                    data['derniersDemandes'] as List<dynamic>? ?? [];
                final allUsers = data['allUsers'] as List<dynamic>? ?? [];

                final maxAbsences = absencesParMois.values.isEmpty
                    ? 1
                    : absencesParMois.values.cast<int>().reduce(
                        (a, b) => a > b ? a : b,
                      );

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 HEADER
                      _buildHeader(admin),
                      const SizedBox(height: 25),

                      // 📊 STATISTIQUES PRINCIPALES (4 cartes)
                      _buildMainStats(
                        totalEmployes,
                        congesEnCours,
                        demandesEnAttente,
                        congesRefuses,
                      ),
                      const SizedBox(height: 25),

                      // 📈 GRAPHIQUE ABSENCES PAR MOIS
                      _buildAbsencesChart(absencesParMois, maxAbsences),
                      const SizedBox(height: 25),

                      // 🍰 RÉPARTITION DES CONGÉS
                      _buildCongesDistribution(
                        congesAnnuel,
                        congesMaladie,
                        congesSansSolde,
                        totalConges,
                      ),
                      const SizedBox(height: 25),

                      // 📋 TABLEAU DES DERNIÈRES DEMANDES
                      _buildRecentRequestsTable(derniersDemandes, allUsers),
                      const SizedBox(height: 25),

                      // 📊 STATISTIQUES SUPPLÉMENTAIRES
                      _buildAdditionalStats(tauxAbsenteisme),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

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

  /// 👤 HEADER
  Widget _buildHeader(dynamic admin) {
    return Row(
      children: [
        AvatarHelper.buildAvatarFromUser(user: admin, radius: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bonjour,',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                '${admin.prenom} ${admin.nom}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, size: 26),
          onPressed: () {
            userController.clearCurrentUser();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
      ],
    );
  }

  /// 📊 STATISTIQUES PRINCIPALES
  Widget _buildMainStats(
    int totalEmployes,
    int congesEnCours,
    int demandesEnAttente,
    int congesRefuses,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatBox(
              'Total Employés',
              '$totalEmployes',
              Icons.people,
              const Color(0xFF5F2EEA),
              0.1,
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              'Congés en cours',
              '$congesEnCours',
              Icons.calendar_month,
              Colors.green,
              0.1,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatBox(
              'Demandes en attente',
              '$demandesEnAttente',
              Icons.hourglass_bottom,
              Colors.orange,
              0.1,
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              'Demandes refusées',
              '$congesRefuses',
              Icons.cancel,
              Colors.red,
              0.1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    IconData icon,
    Color color,
    double opacity,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(opacity),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📈 GRAPHIQUE ABSENCES PAR MOIS
  Widget _buildAbsencesChart(
    Map<String, dynamic> absencesParMois,
    int maxValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Absences par mois (6 derniers mois)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: absencesParMois.entries.map((entry) {
                final mois = entry.key;
                final valeur = entry.value as int;
                final hauteur = maxValue > 0 ? (valeur / maxValue) * 150 : 10;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 35,
                      height: hauteur.toDouble(),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.7),
                            Colors.blue.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$valeur',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mois,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 🍰 RÉPARTITION DES CONGÉS
  Widget _buildCongesDistribution(
    int annuel,
    int maladie,
    int sansSolde,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des congés',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCongesBar('Annuel', annuel, total, Colors.pink),
                const SizedBox(width: 20),
                _buildCongesBar('Maladie', maladie, total, Colors.blue),
                const SizedBox(width: 20),
                _buildCongesBar('Sans Solde', sansSolde, total, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongesBar(String label, int value, int total, Color color) {
    final percent = total > 0 ? (value / total * 100) : 0;

    return Column(
      children: [
        Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 80,
                height: (120 * percent / 100),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 📋 TABLEAU DES DERNIÈRES DEMANDES
  Widget _buildRecentRequestsTable(
    List<dynamic> derniersDemandes,
    List<dynamic> allUsers,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernières demandes en attente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (derniersDemandes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucune demande en attente',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: derniersDemandes.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.withOpacity(0.2)),
              itemBuilder: (_, index) {
                final conge = derniersDemandes[index];
                dynamic employe;
                try {
                  employe = allUsers.isNotEmpty
                      ? allUsers.firstWhere((u) => u.id == conge.employeId)
                      : null;
                } catch (e) {
                  employe = null;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      AvatarHelper.buildAvatarFromUser(
                        user: employe,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employe != null
                                  ? '${employe.prenom} ${employe.nom}'
                                  : 'Employé',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              conge.typeConge.toString().split('.').last,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${conge.duree}j',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// 📊 STATISTIQUES SUPPLÉMENTAIRES
  Widget _buildAdditionalStats(double tauxAbsenteisme) {
    final statusColor = tauxAbsenteisme < 5
        ? Colors.green
        : tauxAbsenteisme < 10
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taux d\'absentéisme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${tauxAbsenteisme.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tauxAbsenteisme < 5
                              ? 'Bon'
                              : tauxAbsenteisme < 10
                              ? 'Modéré'
                              : 'Élevé',
                          style: TextStyle(fontSize: 14, color: statusColor),
                        ),
                      ],
                    ),
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
