import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/screens/admin/bottom_navbar.dart';
import 'package:sirh_mobile/screens/admin/UploadDocumentScreen.dart';
import 'package:sirh_mobile/services/api_service.dart';
import 'package:sirh_mobile/models/document.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  // int _currentIndex =3; // Index correspondant aux documents dans ta AdminBottomNavbar
  String _selectedFilter = 'Toutes'; // Track selected filter
  String _searchQuery = ''; // Track search query

  // Réutilisation du fond flou
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
            color: Colors.black,
            size: 20,
          ),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/admin/dashboard'),
        ),
        title: const Text(
          "Gestion documents",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- BACKGROUND ---
          Container(decoration: const BoxDecoration(color: Color(0xFFF8FAFF))),
          buildBlurCircle(
            color: Colors.greenAccent,
            size: 150,
            top: 60,
            left: 20,
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
                // Barre de recherche + Bouton Upload
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "Rechercher un document...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UploadDocumentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F2EEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Upload",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip("Toutes", _selectedFilter == "Toutes"),
                      _buildFilterChip(
                        "Fiche de paie",
                        _selectedFilter == "Fiche de paie",
                      ),
                      _buildFilterChip(
                        "Attestation",
                        _selectedFilter == "Attestation",
                      ),
                      _buildFilterChip("Contrat", _selectedFilter == "Contrat"),
                    ],
                  ),
                ),

                // Liste des documents
                Expanded(
                  child: FutureBuilder<List<Document>>(
                    future: ApiService().getAllDocuments(),
                    builder: (context, snapshot) {
                      // Chargement
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Erreur
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 15),
                              Text('Erreur: ${snapshot.error}'),
                            ],
                          ),
                        );
                      }

                      // Pas de données
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_open_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Aucun document trouvé',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filtrer et rechercher
                      var documents = snapshot.data!;

                      // Filtrer par type
                      if (_selectedFilter != "Toutes") {
                        documents = documents.where((doc) {
                          String typeStr = doc.typeDocument
                              .toString()
                              .split('.')
                              .last;
                          if (_selectedFilter == "Fiche de paie" &&
                              typeStr == "fichepaie")
                            return true;
                          if (_selectedFilter == "Attestation" &&
                              typeStr == "attestation")
                            return true;
                          if (_selectedFilter == "Contrat" &&
                              typeStr == "contrat")
                            return true;
                          return false;
                        }).toList();
                      }

                      // Filtrer par recherche
                      if (_searchQuery.isNotEmpty) {
                        documents = documents.where((doc) {
                          String typeStr = doc.typeDocument
                              .toString()
                              .split('.')
                              .last;
                          return typeStr.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                        }).toList();
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Liste des documents",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${documents.length} document${documents.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...documents.map((doc) {
                            String typeStr = doc.typeDocument
                                .toString()
                                .split('.')
                                .last;
                            String displayType = typeStr == "fichepaie"
                                ? "Fiche de paie"
                                : (typeStr == "attestation"
                                      ? "Attestation"
                                      : "Contrat");

                            return DocumentCard(
                              document: doc,
                              title: doc.typeDocument
                                  .toString()
                                  .split('.')
                                  .last,
                              category: displayType,
                              description: doc.description ?? '',
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/admin/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/employees');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/admin/demandes');
              break;
            case 3:
              // Déjà sur documents
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5F2EEA)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF5F2EEA),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final Document document;
  final String title;
  final String category;
  final String description;

  const DocumentCard({
    super.key,
    required this.document,
    required this.title,
    required this.category,
    required this.description,
  });

  String _formatFileSize(double bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getIcon(String category) {
    if (category.contains('Fiche')) return Icons.description;
    if (category.contains('Attestation')) return Icons.article;
    return Icons.assignment;
  }

  Color _getIconColor(String category) {
    if (category.contains('Fiche')) return const Color(0xFFE0E7FF);
    if (category.contains('Attestation')) return const Color(0xFFFFE4E6);
    return const Color(0xFFFEF3C7);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(category), color: const Color(0xFF5F2EEA)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF5F2EEA),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${document.dateCreation.day}/${document.dateCreation.month}/${document.dateCreation.year} • ${_formatFileSize(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Color(0xFF5F2EEA)),
                onPressed: () {
                  // TODO: Implémenter le téléchargement
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Téléchargement en cours...')),
                  );
                },
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
