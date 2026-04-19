import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';
import 'package:sirh_mobile/views/manager/team_member_detail_screen.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _Teamviewstate();
}

class _Teamviewstate extends State<TeamScreen> {
  late Future<List<User>> _teamMembersFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredMembers = [];
  List<User> _allMembers = [];

  @override
  void initState() {
    super.initState();
    _teamMembersFuture = _fetchTeamMembers();
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 Filtrer les membres selon la recherche
  void _filterMembers() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        final query = _searchController.text.toLowerCase();
        _filteredMembers = _allMembers
            .where(
              (member) =>
                  member.nom.toLowerCase().contains(query) ||
                  member.prenom.toLowerCase().contains(query) ||
                  member.email.toLowerCase().contains(query) ||
                  member.departement.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  // 👥 Récupérer l'équipe du manager
  Future<List<User>> _fetchTeamMembers() async {
    try {
      final managerId = userController.currentUser?.id;
      if (managerId == null) {
        print('❌ Manager ID non disponible');
        return [];
      }

      print('📋 Récupération de l\'équipe pour manager: $managerId');

      final snapshot = await _firestore
          .collection('users')
          .where('managerId', isEqualTo: managerId)
          .get();

      final employees = snapshot.docs
          .map((doc) => User.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      print('✅ ${employees.length} employés trouvés');

      // Mettre à jour les listes
      setState(() {
        _allMembers = employees;
        _filteredMembers = employees;
      });

      return employees;
    } catch (e) {
      print('❌ Erreur récupération équipe: $e');
      return [];
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
          "Mon équipe",
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
      extendBodyBehindAppBar: true,
      extendBody: true,
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
            top: false,
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher un membre...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                            )
                          : null,
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
                  child: FutureBuilder<List<User>>(
                    future: _teamMembersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      if (_filteredMembers.isEmpty && _allMembers.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucun membre dans votre équipe',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      if (_filteredMembers.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucun résultat pour "${_searchController.text}"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = _filteredMembers[index];
                          return TeamMemberCard(
                            member: member,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeamMemberDetailScreen(member: member),
                                ),
                              );
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
}

class TeamMemberCard extends StatelessWidget {
  final User member;
  final VoidCallback onTap;

  const TeamMemberCard({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            CircleAvatar(
              radius: 25,
              backgroundImage:
                  member.photo.isNotEmpty && member.photo.startsWith('/')
                  ? FileImage(File(member.photo)) as ImageProvider
                  : NetworkImage('https://i.pravatar.cc/150?u=${member.email}'),
              child: member.photo.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 15),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${member.prenom} ${member.nom}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    member.departement,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Solde congé
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${member.soldeCongeRestant} jour(s)",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
