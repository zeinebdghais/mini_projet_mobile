import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';
import 'package:sirh_mobile/views/admin/UploadDocumentScreen.dart';
import 'package:sirh_mobile/controllers/document_controller.dart';
import 'package:sirh_mobile/models/document.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementviewstate();
}

class _DocumentManagementviewstate extends State<DocumentManagementScreen> {
  String _selectedFilter = 'Toutes';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text(
          "Gestion documents",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [Icon(Icons.notifications_none, color: Colors.black)],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH + UPLOAD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: "Rechercher un document...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadDocumentScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F2EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Upload"),
                ),
              ],
            ),
          ),

          // 🔘 FILTERS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip("Toutes"),
                _chip("Fiche de paie"),
                _chip("Attestation"),
                _chip("Contrat"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📄 LIST
          Expanded(
            child: FutureBuilder<List<Document>>(
              future: DocumentController().getAllDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun document"));
                }

                var docs = snapshot.data!;

                // FILTER
                if (_selectedFilter != "Toutes") {
                  docs = docs.where((doc) {
                    final type = doc.typeDocument.toString().split('.').last;

                    if (_selectedFilter == "Fiche de paie" &&
                        type == "fichepaie")
                      return true;
                    if (_selectedFilter == "Attestation" &&
                        type == "attestation")
                      return true;
                    if (_selectedFilter == "Contrat" && type == "contrat")
                      return true;

                    return false;
                  }).toList();
                }

                // SEARCH
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    return doc.typeDocument.toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                  }).toList();
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
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
                          "${docs.length} documents",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...docs.map((doc) {
                      String type = doc.typeDocument.toString().split('.').last;

                      String label = type == "fichepaie"
                          ? "Fiche de paie"
                          : type == "attestation"
                          ? "Attestation"
                          : "Contrat";

                      return DocumentCard(
                        document: doc,
                        title: label,
                        category: label,
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

      bottomNavigationBar: AdminBottomNavbar(currentIndex: 3, onTap: (i) {}),
    );
  }

  Widget _chip(String text) {
    final selected = _selectedFilter == text;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5F2EEA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontSize: 12,
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

  IconData _icon() {
    if (category.contains("Fiche")) return Icons.description_outlined;
    if (category.contains("Attestation")) return Icons.article_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _bg() {
    if (category.contains("Fiche")) return const Color(0xFFEDE9FE);
    if (category.contains("Attestation")) return const Color(0xFFFFE4E6);
    return const Color(0xFFFEF3C7);
  }

  Color _color() {
    if (category.contains("Fiche")) return const Color(0xFF5F2EEA);
    if (category.contains("Attestation")) return const Color(0xFFE11D48);
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    final file = File(document.fichierURL);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _bg(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon(), color: _color()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _bg(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(fontSize: 11, color: _color()),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${document.dateCreation.day}/${document.dateCreation.month}/${document.dateCreation.year}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (await file.exists()) {
                      OpenFile.open(file.path);
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text("Voir"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (await file.exists()) {
                      OpenFile.open(file.path);
                    }
                  },
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text("Télécharger"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F2EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
