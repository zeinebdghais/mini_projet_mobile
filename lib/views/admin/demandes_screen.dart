import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/models/user.dart';

class DemandesAdminScreen extends StatefulWidget {
  const DemandesAdminScreen({super.key});

  @override
  State<DemandesAdminScreen> createState() => _DemandesAdminviewstate();
}

class _DemandesAdminviewstate extends State<DemandesAdminScreen> {
  late Future<List<Conge>> _demandesFuture;
  final CongeAbsenceController _congeController = CongeAbsenceController();
  final UserController _userController = UserController();

  // Cache des utilisateurs pour afficher les noms
  Map<String, User> _usersCache = {};

  // Filtre sélectionné
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _demandesFuture = _loadDemandesWithUsers();
  }

  Future<List<Conge>> _loadDemandesWithUsers() async {
    final demandes = await _congeController.getAllConges();

    // Charger les infos des employés pour afficher leurs noms
    for (final demande in demandes) {
      if (!_usersCache.containsKey(demande.employeId)) {
        try {
          final users = await _userController.getAllUsers();
          final user = users.firstWhere(
            (u) => u.id == demande.employeId,
            orElse: () => User(
              id: '',
              nom: 'Inconnu',
              prenom: '',
              email: '',
              motDePasse: '',
              role: UserRole.employe,
              telephone: '',
              dateNaissance: DateTime.now(),
              salaire: 0,
              adresse: '',
              nationalite: '',
              photo: '',
              dateEmbauche: DateTime.now(),
              cin: '',
              departement: '',
              managerId: null,
              soldeCongeTotal: 0,
              soldeCongeRestant: 0,
            ),
          );
          _usersCache[demande.employeId] = user;
        } catch (e) {
          print('Erreur chargement utilisateur: $e');
        }
      }
    }

    // Trier: en attente en haut, puis par date
    demandes.sort((a, b) {
      if (a.statut == StatutConge.enAttente &&
          b.statut != StatutConge.enAttente) {
        return -1;
      } else if (a.statut != StatutConge.enAttente &&
          b.statut == StatutConge.enAttente) {
        return 1;
      }
      return b.dateDemande.compareTo(a.dateDemande);
    });

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
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          },
        ),
        title: const Text(
          "Toutes les demandes",
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
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/admin/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/employees');
              break;
            case 2:
              // Déjà sur demandes
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/admin/documents');
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
                // Titre
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Toutes les demandes",
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
    IconData? icon;
    Color activeColor = Colors.deepPurple;

    if (value == 'Tous') {
      icon = Icons.format_list_bulleted;
      activeColor = Colors.deepPurple;
    } else if (value == 'En attente') {
      icon = Icons.schedule;
      activeColor = Colors.orange;
    } else if (value == 'Accepté') {
      icon = Icons.check_circle;
      activeColor = Colors.green;
    } else if (value == 'Refusé') {
      icon = Icons.cancel;
      activeColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [activeColor, activeColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.withOpacity(0.2),
            width: isActive ? 0 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
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
                backgroundImage: employe?.photo.isNotEmpty == true
                    ? NetworkImage(employe!.photo)
                    : null,
                backgroundColor: Colors.deepPurple,
                child: employe?.photo.isEmpty == true
                    ? Text(
                        '${employe?.nom.isNotEmpty ?? false ? employe!.nom[0].toUpperCase() : ""}${employe?.prenom.isNotEmpty ?? false ? employe!.prenom[0].toUpperCase() : ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
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
