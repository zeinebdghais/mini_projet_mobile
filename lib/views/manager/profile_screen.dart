import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/manager/bottom_navbar.dart';
import 'package:sirh_mobile/views/manager/manager_profile_edit_screen.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';

class ProfileScreenManager extends StatefulWidget {
  const ProfileScreenManager({super.key});

  @override
  State<ProfileScreenManager> createState() => _ProfileScreenManagerState();
}

class _ProfileScreenManagerState extends State<ProfileScreenManager> {
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
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
          "Profil",
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
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/manager/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/manager/demandes');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/manager/team');
              break;
            case 3:
              // Déjà sur profil
              break;
          }
        },
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
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

          /// CONTENT
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// PROFILE TOP
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              userController.currentUser?.photo != null &&
                                  userController.currentUser!.photo.isNotEmpty
                              ? (userController.currentUser!.photo.startsWith(
                                      '/',
                                    )
                                    ? FileImage(
                                        File(userController.currentUser!.photo),
                                      )
                                    : NetworkImage(
                                            userController.currentUser!.photo,
                                          )
                                          as ImageProvider)
                              : const AssetImage('assets/images/profile.jpg'),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${userController.currentUser?.prenom ?? ''} ${userController.currentUser?.nom ?? ''}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manager',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userController.currentUser?.departement ?? 'N/A',
                              style: const TextStyle(color: Color(0xFF5F2EEA)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// SECTION
                    _sectionTitle("Infos personnelles"),
                    _infoRow(
                      "Nom complet",
                      "${userController.currentUser?.prenom ?? ''} ${userController.currentUser?.nom ?? ''}",
                    ),
                    _infoRow(
                      "Date de naissance",
                      _formatDate(userController.currentUser?.dateNaissance),
                    ),
                    _infoRow("CIN", userController.currentUser?.cin ?? 'N/A'),
                    _infoRow(
                      "Nationalité",
                      userController.currentUser?.nationalite ?? 'N/A',
                    ),

                    _divider(),

                    _sectionTitle("Coordonnées"),
                    _infoRow(
                      "Email pro",
                      userController.currentUser?.email ?? 'N/A',
                    ),
                    _infoRow(
                      "Téléphone",
                      userController.currentUser?.telephone ?? 'N/A',
                    ),
                    _infoRow(
                      "Adresse",
                      userController.currentUser?.adresse ?? 'N/A',
                    ),

                    _divider(),

                    _sectionTitle("Informations professionnelles"),
                    _infoRow(
                      "Date d'embauche",
                      _formatDate(userController.currentUser?.dateEmbauche),
                    ),
                    _infoRow(
                      "Salaire",
                      userController.currentUser?.salaire != null
                          ? "${userController.currentUser!.salaire} DT"
                          : 'N/A',
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManagerProfileEditScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5F2EEA), Color(0xFF7F56D9)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              "Modifier profil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// INFO ROW
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5F2EEA), fontSize: 13),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// DIVIDER
  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: const Color(0xFF5F2EEA).withOpacity(0.3),
    );
  }
}
