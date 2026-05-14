import 'dart:ui';
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
  Map<String, String> _employeeNames = {}; // Pour stocker les noms des employés

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

      // Récupérer le nombre d'employés dans l'équipe
      final employees = await userController.getEmployeesByManager(manager.id);

      print('📊 Employés trouvés: ${employees.length}');
      for (var emp in employees) {
        print('  - ${emp.id}: ${emp.prenom} ${emp.nom}');
      }

      // Récupérer TOUS les congés du manager (pas juste ceux en attente!)
      final conges = await _congeController.getAllCongesForManager(manager.id);

      print('📋 TOUS les congés du manager trouvés: ${conges.length}');
      for (var conge in conges) {
        print('  - Employé: ${conge.employeId}, Statut: ${conge.statut}');
      }

      // Calculer les statistiques
      int demandesEnAttente = conges
          .where((c) => c.statut == StatutConge.enAttente)
          .length;

      int congesAcceptes = conges
          .where((c) => c.statut == StatutConge.approuve)
          .length;

      int congesRefuses = conges
          .where((c) => c.statut == StatutConge.refuse)
          .length;

      print(
        '✅ Acceptés: $congesAcceptes, ❌ Refusés: $congesRefuses, ⏳ En attente: $demandesEnAttente',
      );

      // Les 3 dernières demandes
      final derniersDemandes = conges.take(3).toList();

      // Charger les noms des employés pour les demandes
      _employeeNames.clear();

      // Créer un map des employés par ID pour un accès rapide
      final employeeMap = <String, String>{};
      for (var emp in employees) {
        employeeMap[emp.id] = "${emp.prenom} ${emp.nom}";
      }

      print('📋 Demandes: ${derniersDemandes.length}');
      for (var demande in derniersDemandes) {
        print('  - Demande de: ${demande.employeId}');

        if (employeeMap.containsKey(demande.employeId)) {
          _employeeNames[demande.employeId] = employeeMap[demande.employeId]!;
          print('    ✅ Trouvé: ${_employeeNames[demande.employeId]}');
        } else {
          // Si pas trouvé dans la liste des employés, essayer une recherche directe
          try {
            final employee = await userController.getUserById(
              demande.employeId,
            );
            if (employee != null) {
              _employeeNames[demande.employeId] =
                  "${employee.prenom} ${employee.nom}";
              print(
                '    ✅ Trouvé via recherche: ${_employeeNames[demande.employeId]}',
              );
            } else {
              _employeeNames[demande.employeId] =
                  "Employé inconnu (${demande.employeId})";
              print('    ❌ Non trouvé');
            }
          } catch (e) {
            _employeeNames[demande.employeId] = "Erreur chargement";
            print('    ❌ Erreur: $e');
          }
        }
      }

      return {
        'manager': manager,
        'demandesEnAttente': demandesEnAttente,
        'equipeSize': employees.length,
        'congesAcceptes': congesAcceptes,
        'congesRefuses': congesRefuses,
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
                final congesAcceptes = data['congesAcceptes'] ?? 0;
                final congesRefuses = data['congesRefuses'] ?? 0;
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
                                "Demandes\nen attente",
                                "$demandesEnAttente",
                                Icons.schedule,
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
                                "Congés\nacceptés",
                                "$congesAcceptes",
                                Icons.beach_access,
                                Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statCard(
                                "Congés\nrefusés",
                                "$congesRefuses",
                                Icons.cancel,
                                Colors.red,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// QUICK ITEM
  Widget _quickItem(String title, String subtitle) {
    IconData iconData;
    Color iconColor;

    if (title.contains("équipe")) {
      iconData = Icons.people;
      iconColor = Colors.pink;
    } else {
      iconData = Icons.check_circle;
      iconColor = Colors.deepPurple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: iconColor.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.black.withOpacity(0.3),
            size: 20,
          ),
        ],
      ),
    );
  }

  /// DEMANDE ITEM
  Widget _demandeItem(Conge conge) {
    final typeConge = conge.typeConge.toString().split('.').last;
    final statut = conge.statut.toString().split('.').last;
    final employeeName = _employeeNames[conge.employeId] ?? "Employé inconnu";
    final employeeInitials = employeeName
        .split(' ')
        .map((word) => word[0])
        .join('')
        .toUpperCase();

    Color statutColor = Colors.orange;
    IconData statutIcon = Icons.schedule;
    if (statut.contains('approuve')) {
      statutColor = Colors.green;
      statutIcon = Icons.check_circle;
    } else if (statut.contains('refuse')) {
      statutColor = Colors.red;
      statutIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          // Avatar de l'employé
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.deepPurple.withOpacity(0.15),
            child: Text(
              employeeInitials,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  typeConge.replaceFirst(
                    typeConge[0],
                    typeConge[0].toUpperCase(),
                  ),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statutColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statutColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statutIcon, size: 12, color: statutColor),
                const SizedBox(width: 4),
                Text(
                  statut.replaceFirst(statut[0], statut[0].toUpperCase()),
                  style: TextStyle(
                    color: statutColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
