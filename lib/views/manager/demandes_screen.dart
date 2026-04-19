import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/models/user.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});

  @override
  State<DemandesScreen> createState() => _Demandesviewstate();
}

class _Demandesviewstate extends State<DemandesScreen> {
  final CongeAbsenceController _congeController = CongeAbsenceController();
  late String _managerId;

  @override
  void initState() {
    super.initState();
    _managerId = userController.currentUser?.id ?? '';
  }

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

  // Approuver une demande
  Future<void> _approveConge(Conge conge) async {
    try {
      // Approuver la demande
      await _congeController.approveConge(conge.id);

      // Diminuer le solde de congé de l'employé
      final employee = await userController.getUserById(conge.employeId);
      if (employee != null) {
        double newSolde = employee.soldeCongeRestant - conge.duree.toDouble();
        // S'assurer que le solde ne descend pas en dessous de 0
        newSolde = newSolde < 0 ? 0 : newSolde;

        await userController.updateUser(
          employee.copyWith(soldeCongeRestant: newSolde),
        );

        print(
          '✅ Ancien solde: ${employee.soldeCongeRestant}, Nouveau solde: $newSolde',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande approuvée et solde mis à jour'),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // Refuser une demande
  Future<void> _refuseConge(Conge conge) async {
    try {
      await _congeController.refuseConge(conge.id);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Demande refusée')));
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  String _typeCongeLabel(TypeConge type) {
    switch (type) {
      case TypeConge.annuel:
        return 'Congé Annuel';
      case TypeConge.maladie:
        return 'Congé Maladie';
      case TypeConge.sansSolde:
        return 'Congé Sans Solde';
    }
  }

  Color _getStatusColor(StatutConge statut) {
    switch (statut) {
      case StatutConge.enAttente:
        return Colors.orange;
      case StatutConge.approuve:
        return Colors.green;
      case StatutConge.refuse:
        return Colors.red;
    }
  }

  String _getStatusLabel(StatutConge statut) {
    switch (statut) {
      case StatutConge.enAttente:
        return 'En attente';
      case StatutConge.approuve:
        return 'Approuvé';
      case StatutConge.refuse:
        return 'Refusé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          tooltip: 'Retour au dashboard',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/manager/dashboard');
          },
        ),
        title: const Text(
          "Demandes de congé",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            tooltip: 'Déconnexion',
            onPressed: () {
              userController.clearCurrentUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
          // --- BACKGROUND ---
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
            child: FutureBuilder<List<Conge>>(
              future: _congeController.getPendingCongesForManager(_managerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                final demandes = snapshot.data ?? [];

                if (demandes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Aucune demande en attente',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  itemCount: demandes.length,
                  itemBuilder: (context, index) {
                    final conge = demandes[index];
                    return _buildCongeCard(conge);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongeCard(Conge conge) {
    return FutureBuilder<User?>(
      future: userController.getUserById(conge.employeId),
      builder: (context, snapshot) {
        final employee = snapshot.data;
        final employeeName = '${employee?.prenom ?? ''} ${employee?.nom ?? ''}'
            .trim();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5F2EEA).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8FAFF)],
                ),
              ),
              child: Column(
                children: [
                  // Header avec info employé
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF5F2EEA).withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              employee?.photo != null &&
                                  employee!.photo.isNotEmpty
                              ? (employee.photo.startsWith('/')
                                    ? FileImage(File(employee.photo))
                                    : NetworkImage(employee.photo)
                                          as ImageProvider)
                              : const AssetImage('assets/images/profile.jpg'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employeeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                employee?.departement ?? 'Département',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
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
                            color: _getStatusColor(
                              conge.statut,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusLabel(conge.statut),
                            style: TextStyle(
                              color: _getStatusColor(conge.statut),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Détails de la demande
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Type et dates
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Type',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _typeCongeLabel(conge.typeConge),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Durée',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${conge.duree} jour(s)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dates
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5F2EEA).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xFF5F2EEA),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${conge.dateDebut.day}/${conge.dateDebut.month} - ${conge.dateFin.day}/${conge.dateFin.month}/${conge.dateFin.year}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Motif
                        if (conge.motif.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Motif',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conge.motif,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Actions
                  if (conge.statut == StatutConge.enAttente)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () => _refuseConge(conge),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Refuser'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () => _approveConge(conge),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Approuver'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
