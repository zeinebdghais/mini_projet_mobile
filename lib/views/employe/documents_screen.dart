import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/controllers/document_controller.dart';
import 'package:sirh_mobile/models/document.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _Documentsviewstate();
}

class _Documentsviewstate extends State<DocumentsScreen> {
  int currentIndex = 3;
  int selectedFilter = 0;
  final DocumentController _documentController = DocumentController();
  List<Document> _documents = [];
  bool _loading = true;

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
        // Navigator.pushReplacementNamed(context, '/employe/documents');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/employe/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final user = userController.currentUser;
    print('🔍 DEBUG Documents: user = $user');
    if (user == null) {
      print('❌ Utilisateur non trouvé!');
      setState(() => _loading = false);
      return;
    }
    print('✅ User ID: ${user.id}');
    setState(() => _loading = true);
    try {
      final documents = await _documentController.getEmployeeDocuments(user.id);
      print('✅ Documents récupérés: ${documents.length}');
      setState(() {
        _documents = documents;
        _loading = false;
      });
    } catch (e) {
      print('❌ Erreur récupération documents: $e');
      setState(() => _loading = false);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Accueil',
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/employe/dashboard',
                          );
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Mes Documents",
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un document...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip("Toutes", 0),
                        _filterChip("Fiche de paie", 1),
                        _filterChip("Attestation", 2),
                        _filterChip("Contrat", 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Liste des documents",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${_documents.length} document${_documents.length > 1 ? 's' : ''}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// LIST
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _documents.isEmpty
                        ? const Center(child: Text('Aucun document trouvé'))
                        : ListView(
                            children: _documents
                                .where(
                                  (d) =>
                                      selectedFilter == 0 ||
                                      (selectedFilter == 1 &&
                                          d.typeDocument ==
                                              TypeDocument.fichepaie) ||
                                      (selectedFilter == 2 &&
                                          d.typeDocument ==
                                              TypeDocument.attestation) ||
                                      (selectedFilter == 3 &&
                                          d.typeDocument ==
                                              TypeDocument.contrat),
                                )
                                .map(
                                  (d) => _docItem(
                                    d.description ??
                                        d.typeDocument
                                            .toString()
                                            .split('.')
                                            .last,
                                    d.typeDocument.toString().split('.').last,
                                    '${d.dateCreation.day}/${d.dateCreation.month}/${d.dateCreation.year}',
                                    _getColorForType(d.typeDocument),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER CHIP
  Widget _filterChip(String text, int index) {
    final isActive = selectedFilter == index;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5F2EEA)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(TypeDocument type) {
    switch (type) {
      case TypeDocument.fichepaie:
        return Colors.deepPurple;
      case TypeDocument.attestation:
        return Colors.pink;
      case TypeDocument.contrat:
        return Colors.orange;
    }
  }

  /// DOCUMENT ITEM
  Widget _docItem(String title, String type, String date, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insert_drive_file, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TYPE + DATE
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(type, style: TextStyle(color: color, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            children: [
              _actionBtn(Icons.remove_red_eye, "Voir"),
              const SizedBox(width: 10),
              _actionBtn(Icons.download, "Télécharger"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5F2EEA)),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF5F2EEA), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
