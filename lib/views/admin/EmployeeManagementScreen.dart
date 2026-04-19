import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';
import 'package:sirh_mobile/views/admin/EmployeeFormScreen.dart';
import 'package:sirh_mobile/controllers/auth_controller.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/user.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementviewstate();
}

class _EmployeeManagementviewstate extends State<EmployeeManagementScreen> {
  late Future<List<User>> _usersFuture;
  List<User> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = AuthController().getAllUsers();
  }

  // Méthode de background réutilisée
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/admin/dashboard'),
        ),
        title: const Text(
          "Gestion des employés",
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
            child: Column(
              children: [
                // Barre de recherche + Bouton Ajouter
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Rechercher un membre...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployeeFormScreen(),
                            ),
                          );
                          setState(() {
                            _usersFuture = AuthController().getAllUsers();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F2EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Ajouter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des employés depuis Firebase
                Expanded(
                  child: FutureBuilder<List<User>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur: \\${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Aucun utilisateur trouvé.'),
                        );
                      }
                      _users = snapshot.data!;
                      final filteredUsers = _users.where((user) {
                        final search = _searchQuery.trim();
                        return user.nom.toLowerCase().contains(search) ||
                            user.prenom.toLowerCase().contains(search) ||
                            user.email.toLowerCase().contains(search);
                      }).toList();
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return EmployeeCard(
                            user: user,
                            screenContext: context,
                            onUserChanged: () {
                              setState(() {
                                _usersFuture = AuthController().getAllUsers();
                              });
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
      // --- APPEL DE TA NAVBAR ADMIN ---
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/admin/dashboard');
              break;
            case 1:
              // Déjà sur employés
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
}

class EmployeeCard extends StatelessWidget {
  final User user;
  final BuildContext screenContext;
  final VoidCallback onUserChanged;

  const EmployeeCard({
    super.key,
    required this.user,
    required this.screenContext,
    required this.onUserChanged,
  });

  // 🖼️ Obtenir le bon ImageProvider (local ou réseau)
  ImageProvider _getImageProvider() {
    if (user.photo.isEmpty) {
      return NetworkImage("https://i.pravatar.cc/150?u=${user.id}");
    }

    // Vérifier si c'est un chemin local (commence par /)
    if (user.photo.startsWith('/')) {
      final file = File(user.photo);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // Si le fichier n'existe pas, utiliser l'avatar par défaut
        return NetworkImage("https://i.pravatar.cc/150?u=${user.id}");
      }
    }

    // Sinon c'est une URL réseau
    return NetworkImage(user.photo);
  }

  void _viewUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("${user.nom} ${user.prenom}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _getImageProvider(),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Email", user.email),
              _buildDetailRow("Téléphone", user.telephone),
              _buildDetailRow("Rôle", user.role.toString().split('.').last),
              _buildDetailRow("Département", user.departement),
              _buildDetailRow("CIN", user.cin),
              _buildDetailRow("Nationalité", user.nationalite),
              _buildDetailRow("Adresse", user.adresse),
              _buildDetailRow("Salaire", "${user.salaire} DT"),
              _buildDetailRow(
                "Date Embauche",
                "${user.dateEmbauche.day}/${user.dateEmbauche.month}/${user.dateEmbauche.year}",
              ),
              _buildDetailRow(
                "Date Naissance",
                "${user.dateNaissance.day}/${user.dateNaissance.month}/${user.dateNaissance.year}",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _editUser(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (editContext) =>
            EmployeeFormScreen(isEditing: true, user: user),
      ),
    );
    onUserChanged();
  }

  void _deleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer ${user.nom} ${user.prenom} ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await UserController().deleteUser(user.id);
                Navigator.pop(dialogContext);
                onUserChanged();
                ScaffoldMessenger.of(screenContext).showSnackBar(
                  const SnackBar(content: Text("Employé supprimé avec succès")),
                );
              } catch (e) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(
                  screenContext,
                ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: ListTile(
        leading: CircleAvatar(radius: 25, backgroundImage: _getImageProvider()),
        title: Text(
          "${user.nom} ${user.prenom}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          user.role.toString().split('.').last,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onSelected: (value) {
            if (value == "view") {
              _viewUserDetails(context);
            } else if (value == "edit") {
              _editUser(context);
            } else if (value == "delete") {
              _deleteUser(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            _buildPopupItem("Consulter", Icons.visibility_outlined, "view"),
            _buildPopupItem("Modifier", Icons.edit_outlined, "edit"),
            _buildPopupItem(
              "Supprimer",
              Icons.delete_outline,
              "delete",
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    IconData icon,
    String value, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
