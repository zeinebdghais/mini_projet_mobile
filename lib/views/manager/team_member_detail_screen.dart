import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class TeamMemberDetailScreen extends StatefulWidget {
  final User member;

  const TeamMemberDetailScreen({super.key, required this.member});

  @override
  State<TeamMemberDetailScreen> createState() => _TeamMemberDetailScreenState();
}

class _TeamMemberDetailScreenState extends State<TeamMemberDetailScreen> {
  late Future<List<Map<String, dynamic>>> _congesFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _congesFuture = _fetchConges();
  }

  // 📋 Récupérer l'historique de congés
  Future<List<Map<String, dynamic>>> _fetchConges() async {
    try {
      final snapshot = await _firestore
          .collection('conges')
          .where('userId', isEqualTo: widget.member.id)
          .orderBy('dateDebut', descending: true)
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('❌ Erreur récupération congés: $e');
      return [];
    }
  }

  // 🖼️ Obtenir le bon ImageProvider
  ImageProvider _getPhotoProvider(String photoPath) {
    if (photoPath.isEmpty) {
      return const NetworkImage("https://i.pravatar.cc/150?u=user");
    }

    if (photoPath.startsWith('/')) {
      final file = File(photoPath);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        return const NetworkImage("https://i.pravatar.cc/150?u=user");
      }
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          blurCircle(Colors.greenAccent, 150, 60, 20),
          blurCircle(Colors.yellowAccent, 120, 300, -50),
          blurCircle(Colors.blueAccent, 140, 500, 200),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // HEADER
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Détails du membre",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Équilibre avec le btn retour
                  ],
                ),
                const SizedBox(height: 20),

                // PHOTO & NOM
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _getPhotoProvider(widget.member.photo),
                    child: widget.member.photo.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${widget.member.prenom} ${widget.member.nom}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.member.role.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.member.departement,
                  style: const TextStyle(
                    color: Color(0xFF5F2EEA),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // INFOS PERSONNELLES
                _buildSectionTitle("Infos personnelles"),
                _infoRow("CIN", widget.member.cin),
                _infoRow(
                  "Date de naissance",
                  "${widget.member.dateNaissance.day}/${widget.member.dateNaissance.month}/${widget.member.dateNaissance.year}",
                ),
                _infoRow("Nationalité", widget.member.nationalite),

                _divider(),

                // COORDONNÉES
                _buildSectionTitle("Coordonnées"),
                _infoRow("Email", widget.member.email),
                _infoRow("Téléphone", widget.member.telephone),
                _infoRow("Adresse", widget.member.adresse),

                _divider(),

                // INFOS PROFESSIONNELLES
                _buildSectionTitle("Infos professionnelles"),
                _infoRow(
                  "Date d'embauche",
                  "${widget.member.dateEmbauche.day}/${widget.member.dateEmbauche.month}/${widget.member.dateEmbauche.year}",
                ),
                _infoRow("Salaire", "${widget.member.salaire} DT"),
                _infoRow(
                  "Solde de congé restant",
                  "${widget.member.soldeCongeRestant} jour(s)",
                ),

                _divider(),

                // HISTORIQUE CONGÉS
                _buildSectionTitle("Historique de congés"),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _congesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Erreur: ${snapshot.error}'),
                      );
                    }

                    final conges = snapshot.data ?? [];

                    if (conges.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Aucun historique de congé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: conges.map((conge) {
                        final dateDebut = DateTime.parse(
                          conge['dateDebut'].toString(),
                        );
                        final dateFin = DateTime.parse(
                          conge['dateFin'].toString(),
                        );
                        final duree = conge['duree'] ?? 0;
                        final statut = conge['statut'] ?? 'en attente';
                        final motif = conge['motif'] ?? 'Non spécifié';

                        Color statutColor = Colors.orange;
                        if (statut == 'approuve') {
                          statutColor = Colors.green;
                        } else if (statut == 'refuse') {
                          statutColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: statutColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${dateDebut.day}/${dateDebut.month}/${dateDebut.year} → ${dateFin.day}/${dateFin.month}/${dateFin.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statutColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statut.toUpperCase(),
                                      style: TextStyle(
                                        color: statutColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Durée: $duree jour(s)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Motif: $motif',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION TITLE
  Widget _buildSectionTitle(String title) {
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
