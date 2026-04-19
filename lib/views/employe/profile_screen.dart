import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/views/employe/profile_edit_screen.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _Profileviewstate();
}

class _Profileviewstate extends State<ProfileScreen> {
  int currentIndex = 4;

  // 🖼️ Obtenir le bon ImageProvider (local ou réseau)
  ImageProvider _getPhotoProvider(String photoPath) {
    if (photoPath.isEmpty) {
      return const NetworkImage("https://i.pravatar.cc/150?u=user");
    }

    // Vérifier si c'est un chemin local (commence par /)
    if (photoPath.startsWith('/')) {
      final file = File(photoPath);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // Si le fichier n'existe pas, utiliser l'avatar par défaut
        return const NetworkImage("https://i.pravatar.cc/150?u=user");
      }
    }

    // Sinon c'est une URL réseau
    return NetworkImage(photoPath);
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
        Navigator.pushReplacementNamed(context, '/employe/dashboard');
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
        // Navigator.pushReplacementNamed(context, '/employe/profile');
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        const Icon(Icons.arrow_back),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Profil",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
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
                        // Notification icon removed
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// PROFILE TOP
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              userController.currentUser?.photo != null &&
                                  userController.currentUser!.photo.isNotEmpty
                              ? _getPhotoProvider(
                                  userController.currentUser!.photo,
                                )
                              : null,
                          child:
                              userController.currentUser == null ||
                                  userController.currentUser!.photo.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
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
                                userController.currentUser?.role
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase() ??
                                    'Employé',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userController.currentUser?.departement ??
                                    'Département',
                                style: const TextStyle(
                                  color: Color(0xFF5F2EEA),
                                ),
                              ),
                            ],
                          ),
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
                      userController.currentUser != null
                          ? "${userController.currentUser!.dateNaissance.day}/${userController.currentUser!.dateNaissance.month}/${userController.currentUser!.dateNaissance.year}"
                          : "N/A",
                    ),
                    _infoRow("CIN", userController.currentUser?.cin ?? "N/A"),
                    _infoRow(
                      "Nationalité",
                      userController.currentUser?.nationalite ?? "N/A",
                    ),

                    _divider(),

                    _sectionTitle("Coordonnées"),
                    _infoRow(
                      "Email pro",
                      userController.currentUser?.email ?? "N/A",
                    ),
                    _infoRow(
                      "Téléphone",
                      userController.currentUser?.telephone ?? "N/A",
                    ),
                    _infoRow(
                      "Adresse",
                      userController.currentUser?.adresse ?? "N/A",
                    ),

                    _divider(),

                    _sectionTitle("Informations professionnelles"),
                    _infoRow("Type de contrat", "CDI"),
                    _infoRow(
                      "Date d'embauche",
                      userController.currentUser != null
                          ? "${userController.currentUser!.dateEmbauche.day}/${userController.currentUser!.dateEmbauche.month}/${userController.currentUser!.dateEmbauche.year}"
                          : "N/A",
                    ),
                    _infoRow(
                      "Salaire",
                      "${userController.currentUser?.salaire ?? 0} DT",
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditScreen(),
                            ),
                          );
                          // Rafraîchir si l'édition a réussi
                          if (result == true) {
                            setState(() {});
                          }
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
