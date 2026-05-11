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
  late Future<List<Conge>> _demandesFuture;
  final CongeAbsenceController _congeController = CongeAbsenceController();
  final UserController _userController = UserController();
  late String _managerId;

  // Cache des utilisateurs pour afficher les noms
  Map<String, User> _usersCache = {};

  // Filtre sélectionné
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _managerId = userController.currentUser?.id ?? '';
    _demandesFuture = _loadDemandesWithUsers();
  }

  Future<List<Conge>> _loadDemandesWithUsers() async {
    final demandes = await _congeController.getAllCongesForManager(_managerId);

    // Charger les infos des employés pour afficher leurs noms
    for (final demande in demandes) {
      if (!_usersCache.containsKey(demande.employeId)) {
        try {
          final user = await _userController.getUserById(demande.employeId);
          if (user != null) {
            _usersCache[demande.employeId] = user;
          }
        } catch (e) {
          print('Erreur chargement utilisateur: $e');
        }
      }
    }

    return demandes;
  }

  // Filtrer les demandes selon le filtre sélectionné
  List<Conge> _filterDemandes(List<Conge> demandes) {
    if (_selectedFilter == 'Tous') {
      return demandes;
    } else if (_selectedFilter == 'En attente') {
      return demandes.where((d) => d.statut == StatutConge.enAttente).toList();
    } else if (_selectedFilter == 'Accepté') {
      return demandes.where((d) => d.statut == StatutConge.approuve).toList();
    } else if (_selectedFilter == 'Refusé') {
      return demandes.where((d) => d.statut == StatutConge.refuse).toList();
    }
    return demandes;
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
              Navigator.pushReplacementNamed(context, '/');
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
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Titre
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Demandes de congé",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Filtres
                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterTab('Tous', 'Tous'),
                      const SizedBox(width: 10),
                      _buildFilterTab('En attente', 'En attente'),
                      const SizedBox(width: 10),
                      _buildFilterTab('Accepté', 'Accepté'),
                      const SizedBox(width: 10),
                      _buildFilterTab('Refusé', 'Refusé'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Liste des demandes
                Expanded(
                  child: FutureBuilder<List<Conge>>(
                    future: _demandesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Aucune demande'));
                      }

                      final demandes = _filterDemandes(snapshot.data!);

                      if (demandes.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucune demande ${_selectedFilter.toLowerCase()}',
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: demandes.length,
                        itemBuilder: (context, index) {
                          final demande = demandes[index];
                          final employe = _usersCache[demande.employeId];

                          return DemandeCard(
                            demande: demande,
                            employe: employe,
                            onApprove: () async {
                              try {
                                await _congeController
                                    .approveCongeAndUpdateBalance(
                                      demande.id,
                                      demande.employeId,
                                      demande.duree,
                                    );

                                if (mounted) {
                                  setState(() {
                                    _demandesFuture = _loadDemandesWithUsers();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Demande approuvée et solde mis à jour',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                }
                              }
                            },
                            onRefuse: () async {
                              try {
                                await _congeController.refuseConge(demande.id);

                                if (mounted) {
                                  setState(() {
                                    _demandesFuture = _loadDemandesWithUsers();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('❌ Demande refusée'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                }
                              }
                            },
                          );
                        },
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

  Widget _buildFilterTab(String label, String value) {
    final isActive = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5F2EEA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF5F2EEA)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class DemandeCard extends StatefulWidget {
  final Conge demande;
  final User? employe;
  final VoidCallback onApprove;
  final VoidCallback onRefuse;

  const DemandeCard({
    super.key,
    required this.demande,
    required this.employe,
    required this.onApprove,
    required this.onRefuse,
  });

  @override
  State<DemandeCard> createState() => _DemandeCardState();
}

class _DemandeCardState extends State<DemandeCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final employe = widget.employe;
    final nomEmploye = employe != null
        ? '${employe.nom} ${employe.prenom}'
        : 'Employé ${widget.demande.employeId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec photo et info de base
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    employe?.photo.isNotEmpty == true &&
                        !employe!.photo.startsWith('/')
                    ? NetworkImage(employe.photo) as ImageProvider
                    : (employe?.photo.isNotEmpty == true &&
                          employe!.photo.startsWith('/'))
                    ? FileImage(File(employe.photo)) as ImageProvider
                    : null,
                backgroundColor: Colors.grey[300],
                child: employe?.photo.isEmpty == true
                    ? Text(
                        '${employe!.nom.isNotEmpty ? employe!.nom[0].toUpperCase() : ""}${employe!.prenom.isNotEmpty ? employe!.prenom[0].toUpperCase() : ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomEmploye,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.demande.typeConge
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Statut badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.demande.statut == StatutConge.enAttente
                      ? const Color(0xFFFFE5D9)
                      : widget.demande.statut == StatutConge.approuve
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.demande.statut == StatutConge.enAttente
                      ? 'En attente'
                      : widget.demande.statut == StatutConge.approuve
                      ? 'Accepté'
                      : 'Refusé',
                  style: TextStyle(
                    color: widget.demande.statut == StatutConge.enAttente
                        ? const Color(0xFFFA6419)
                        : widget.demande.statut == StatutConge.approuve
                        ? Colors.green
                        : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dates et durée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                'Début',
                '${widget.demande.dateDebut.day}/${widget.demande.dateDebut.month}/${widget.demande.dateDebut.year}',
              ),
              _buildInfoColumn(
                'Fin',
                '${widget.demande.dateFin.day}/${widget.demande.dateFin.month}/${widget.demande.dateFin.year}',
              ),
              _buildInfoColumn('Durée', '${widget.demande.duree} jour(s)'),
            ],
          ),
          const SizedBox(height: 15),

          // Motif
          const Text(
            'Motif',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.demande.motif,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Boutons Approuver/Refuser (seulement si en attente)
          if (widget.demande.statut == StatutConge.enAttente)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _handleApprove(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe8f5e9),
                      foregroundColor: Colors.green,
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
                    onPressed: _isLoading ? null : () => _handleRefuse(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFffebee),
                      foregroundColor: Colors.red,
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
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Future<void> _handleApprove(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      widget.onApprove();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefuse(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      widget.onRefuse();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
