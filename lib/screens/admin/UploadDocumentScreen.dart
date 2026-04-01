import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sirh_mobile/screens/admin/bottom_navbar.dart';
import 'package:sirh_mobile/services/api_service.dart';
import 'package:sirh_mobile/models/user.dart';
import 'package:sirh_mobile/models/document.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  int _currentIndex = 3; // On reste sur l'onglet documents

  // Variables d'état
  File? _selectedPDF;
  String? _selectedTypeDocument;
  String? _selectedEmployeeId;
  TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  List<User> _employees = [];

  // StreamController pour le progress
  late StreamController<double> _uploadProgressController;

  // Liste des types de document (const pour éviter les changements)
  static const List<String> _typeDocuments = [
    'Fiche de paie',
    'Contrat',
    'Attestation',
  ];

  // Max file size: 20MB
  static const int MAX_FILE_SIZE_MB = 20;

  @override
  void initState() {
    super.initState();
    _uploadProgressController = StreamController<double>();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _uploadProgressController.close();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    try {
      final employees = await ApiService().getNonAdminUsers();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      print('Erreur chargement employés: $e');
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileSizeMB = file.lengthSync() / (1024 * 1024);

        // Check file size
        if (fileSizeMB > MAX_FILE_SIZE_MB) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fichier trop volumineux! Max: ${MAX_FILE_SIZE_MB}MB, Votre fichier: ${fileSizeMB.toStringAsFixed(2)}MB',
                ),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedPDF = file;
        });

        // Show file size info
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fichier sélectionné: ${fileSizeMB.toStringAsFixed(2)}MB',
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _saveDocument() async {
    print('📋 === VALIDATION FORMULAIRE ===');
    print('📋 PDF sélectionné: ${_selectedPDF != null ? 'OUI' : 'NON'}');
    print('📋 Type document: $_selectedTypeDocument');
    print('📋 Employé: $_selectedEmployeeId');

    if (_selectedPDF == null ||
        _selectedTypeDocument == null ||
        _selectedEmployeeId == null) {
      print('❌ Formulaire incomplet!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
        ),
      );
      return;
    }

    print('✅ Formulaire complet - Démarrage upload');
    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Téléchargement du document...'),
            const SizedBox(height: 15),
            StreamBuilder<double>(
              stream: _uploadProgressController.stream,
              initialData: 0.0,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5F2EEA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );

    try {
      // Uploader le PDF avec suivi de progress
      final fileURL = await ApiService().uploadDocument(
        _selectedPDF!,
        onProgress: (progress) {
          if (!_uploadProgressController.isClosed) {
            _uploadProgressController.add(progress);
            print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
          }
        },
      );

      // Déterminer le type de document
      TypeDocument typeDoc;
      if (_selectedTypeDocument == 'Fiche de paie') {
        typeDoc = TypeDocument.fichepaie;
      } else if (_selectedTypeDocument == 'Contrat') {
        typeDoc = TypeDocument.contrat;
      } else {
        typeDoc = TypeDocument.attestation;
      }

      // Créer le document avec les bons champs
      final document = Document(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeId: _selectedEmployeeId!,
        typeDocument: typeDoc,
        fichierURL: fileURL,
        dateCreation: DateTime.now(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      // Sauvegarder dans Firestore
      await ApiService().addDocument(document);

      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue
        // Navigate to DocumentManagementScreen
        Navigator.pushReplacementNamed(context, '/admin/documents');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploadé avec succès')),
        );
      }
    } catch (e) {
      print('⚠️ ERREUR UPLOAD: $e');
      print('⚠️ Type erreur: ${e.runtimeType}');

      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue

        // Messages d'erreur détaillés
        String errorMessage = 'Erreur: $e';

        if (e.toString().contains('Permission')) {
          errorMessage =
              '❌ Erreur permission Firebase\n\nVérifiez les règles de sécurité Storage';
        } else if (e.toString().contains('PERMISSION_DENIED')) {
          errorMessage =
              '❌ Permission refusée par Firebase Storage\n\nContactez l\'administrateur';
        } else if (e.toString().contains('UNAUTHENTICATED')) {
          errorMessage = '❌ Non authentifié\n\nRéconnectez-vous';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      if (!_uploadProgressController.isClosed) {
        _uploadProgressController.add(0.0);
      }
    }
  }

  // Background commun
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Upload Document",
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone d'upload pointillée
                  GestureDetector(onTap: _pickPDF, child: _buildUploadArea()),

                  const SizedBox(height: 30),

                  // Sélecteur : Type de document
                  _buildLabel("Type de document"),
                  _buildDropdownField(
                    value: _selectedTypeDocument,
                    items: _typeDocuments,
                    onChanged: (value) =>
                        setState(() => _selectedTypeDocument = value),
                  ),

                  const SizedBox(height: 20),

                  // Sélecteur : Employé concerné
                  _buildLabel("Employé concerné"),
                  _buildEmployeeDropdown(),

                  const SizedBox(height: 20),

                  // Champ : Description
                  _buildLabel("Description (optionnel)"),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Précisez les détails du document..",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bouton Upload Final
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F2EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Upload",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // Widget pour la zone de dépôt de fichier
  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5F2EEA).withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedPDF == null)
            Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(text: "Drag & Drop or "),
                      TextSpan(
                        text: "Choose file",
                        style: TextStyle(
                          color: Color(0xFF5F2EEA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: " to upload"),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "PDF only",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 40, color: Colors.green),
                const SizedBox(height: 12),
                Text(
                  _selectedPDF!.path.split('/').last,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Taille: ${(_selectedPDF!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)}MB',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ne pas afficher de valeur invalide
    String? displayValue;
    if (value != null && items.contains(value)) {
      displayValue = value;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5F2EEA)),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          hint: const Text("Sélectionner"),
        ),
      ),
    );
  }

  Widget _buildEmployeeDropdown() {
    // Vérifier que la valeur sélectionnée existe dans la liste
    String? validValue = _selectedEmployeeId;
    if (validValue != null && !_employees.any((e) => e.id == validValue)) {
      validValue = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5F2EEA)),
          items: _employees.isEmpty
              ? []
              : _employees.map((User employee) {
                  return DropdownMenuItem(
                    value: employee.id,
                    child: Text('${employee.nom} ${employee.prenom}'),
                  );
                }).toList(),
          onChanged: (value) => setState(() => _selectedEmployeeId = value),
          hint: const Text("Sélectionner un employé"),
        ),
      ),
    );
  }
}
