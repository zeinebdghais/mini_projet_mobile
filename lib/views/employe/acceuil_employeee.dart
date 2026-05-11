import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/controllers/document_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/utils/avatar_helper.dart';

class AcceuilEmployeee extends StatefulWidget {
  const AcceuilEmployeee({super.key});

  @override
  State<AcceuilEmployeee> createState() => _AcceuilEmployeeeState();
}

class _AcceuilEmployeeeState extends State<AcceuilEmployeee>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final CongeAbsenceController _congeController = CongeAbsenceController();
  final DocumentController _docController = DocumentController();

  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dataFuture = _loadDashboardData();
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
      print('🔄 Dashboard - App au focus - Rafraîchissement');
      if (mounted) {
        setState(() {
          _dataFuture = _loadDashboardData();
        });
      }
    }
  }

  // 📊 Charger toutes les données du dashboard
  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final user = userController.currentUser;
      if (user == null) {
        return {'error': 'Utilisateur non connecté'};
      }

      // Récupérer les congés de l'employé
      final conges = await _congeController.getEmployeeConges(user.id);
      final documents = await _docController.getEmployeeDocuments(user.id);

      // Calculer les statistiques
      int congesPris = conges
          .where((c) => c.statut == StatutConge.approuve)
          .fold(0, (sum, c) => sum + c.duree);

      int demandesEnAttente = conges
          .where((c) => c.statut == StatutConge.enAttente)
          .length;

      return {
        'user': user,
        'conges': conges,
        'documents': documents,
        'congesPris': congesPris,
        'demandesEnAttente': demandesEnAttente,
        'soldeRestant': user.soldeCongeRestant,
        'soldeTotal': user.soldeCongeTotal,
      };
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      return {'error': 'Erreur: $e'};
    }
  }

  //  Calculer le pourcentage du solde
  double _calculatePercentage(double restant, double total) {
    if (total == 0) return 0;
    return (restant / total).clamp(0.0, 1.0);
  }

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
          FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
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
              final user = data['user'];
              final conges = data['conges'] ?? [];
              final congesPris = data['congesPris'] ?? 0;
              final demandesEnAttente = data['demandesEnAttente'] ?? 0;
              final soldeRestant = data['soldeRestant'] ?? 0;
              final soldeTotal = data['soldeTotal'] ?? 1;
              final documents = data['documents'] ?? [];

              return SafeArea(
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
                          AvatarHelper.buildAvatarFromUser(user: user!),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Bonjour!",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                "${user.prenom} ${user.nom}",
                                style: const TextStyle(
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      /// SOLDE CONGÉS
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
                                  Text(
                                    "$soldeRestant jour${soldeRestant > 1 ? 's' : ''} restant${soldeRestant > 1 ? 's' : ''}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const _SmallButton(),
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
                                    value: _calculatePercentage(
                                      soldeRestant,
                                      soldeTotal,
                                    ),
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${(_calculatePercentage(soldeRestant, soldeTotal) * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
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

                      /// DEMANDES RÉCENTES
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
                            child: Text(
                              "${conges.length > 2 ? 2 : conges.length}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5F2EEA),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      if (conges.isNotEmpty)
                        Row(
                          children: [
                            for (
                              int i = 0;
                              i < (conges.length > 2 ? 2 : conges.length);
                              i++
                            )
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i == 0 ? 10 : 0,
                                  ),
                                  child: buildRequestCard(
                                    conges[i].typeConge
                                        .toString()
                                        .split('.')
                                        .last,
                                    "${conges[i].dateDebut.day}/${conges[i].dateDebut.month} - ${conges[i].dateFin.day}/${conges[i].dateFin.month}",
                                    conges[i].statut.toString().split('.').last,
                                    conges[i].statut == StatutConge.approuve
                                        ? const Color(0xFFD1FAE5)
                                        : conges[i].statut == StatutConge.refuse
                                        ? const Color(0xFFFDE2E2)
                                        : const Color(0xFFFEF3C7),
                                  ),
                                ),
                              ),
                          ],
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Aucune demande de congé')),
                        ),

                      const SizedBox(height: 25),

                      /// RÉSUMÉ RH
                      const Text(
                        "Résumé RH",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _infoTile(
                        "Congés pris",
                        "$congesPris jour${congesPris > 1 ? 's' : ''}",
                      ),
                      _infoTile(
                        "Solde total",
                        "$soldeTotal jour${soldeTotal > 1 ? 's' : ''}",
                      ),
                      _infoTile(
                        "Demandes en attente",
                        "$demandesEnAttente demande${demandesEnAttente > 1 ? 's' : ''}",
                      ),
                      _infoTile(
                        "Documents disponibles",
                        "${documents.length} document${documents.length > 1 ? 's' : ''}",
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
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
