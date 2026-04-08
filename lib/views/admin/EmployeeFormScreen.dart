import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/admin/bottom_navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/user.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EmployeeFormScreen extends StatefulWidget {
  final bool isEditing; // true pour modifier, false pour ajouter
  const EmployeeFormScreen({super.key, this.isEditing = false});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormviewstate();
}

class _EmployeeFormviewstate extends State<EmployeeFormScreen> {
  int _currentIndex = 1;

  // Contrôleurs pour chaque champ
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _nationaliteController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _salaireController = TextEditingController();
  final TextEditingController _soldeCongeTotalController =
      TextEditingController();

  String? _selectedRole;
  String? _selectedDepartement;
  String? _selectedManagerId;
  DateTime? _dateNaissance;
  DateTime? _dateEmbauche;
  File? _selectedImage;
  bool _isLoading = false;

  final picker = ImagePicker();

  // Liste des managers (nom complet et id)
  List<User> _managers = [];

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    final snapshot = await UserController().getManagers();
    setState(() {
      _managers = snapshot;
    });
  }

  // Méthode de background identique
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      // Compression immédiate de l'image
      File originalFile = File(pickedFile.path);
      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        originalFile.absolute.path + '_compressed.jpg',
        quality: 30,
        minWidth: 600,
        minHeight: 600,
      );
      setState(() {
        _selectedImage = compressed != null
            ? File(compressed.path)
            : originalFile;
      });
    }
  }

  Future<void> _saveUser() async {
    setState(() => _isLoading = true);

    // Afficher un dialogue de progression
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Ajout en cours...'),
          ],
        ),
      ),
    );

    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _motDePasseController.text.trim(),
        role: _selectedRole == 'Manager'
            ? UserRole.manager
            : _selectedRole == 'Admin'
            ? UserRole.admin
            : UserRole.employe,
        telephone: _telephoneController.text.trim(),
        dateNaissance: _dateNaissance ?? DateTime.now(),
        salaire: double.tryParse(_salaireController.text) ?? 0.0,
        adresse: _adresseController.text.trim(),
        nationalite: _nationaliteController.text.trim(),
        photo: '',
        dateEmbauche: _dateEmbauche ?? DateTime.now(),
        cin: _cinController.text.trim(),
        departementId: _selectedDepartement ?? '',
        managerId: _selectedManagerId,
        soldeCongeTotal:
            double.tryParse(_soldeCongeTotalController.text) ?? 0.0,
        soldeCongeRestant:
            double.tryParse(_soldeCongeTotalController.text) ?? 0.0,
      );
      await UserController().addUser(user, photoFile: _selectedImage);
      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de progression
        Navigator.pop(context); // Fermer l'écran de formulaire
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé ajouté avec succès.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialogue de progression
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text(
          widget.isEditing ? "Modifier Employé" : "Ajouter un Employé",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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

          // --- FORMULAIRE ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              child: Column(
                children: [
                  // Section Photo (Style Profil)
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            image: DecorationImage(
                              image: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : const NetworkImage(
                                          'https://i.pravatar.cc/150?u=newuser',
                                        )
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5F2EEA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sync,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Upload Photo",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // Regroupement par sections pour plus de clarté
                  _buildSectionTitle("Informations Personnelles"),
                  _buildTextField(
                    "Nom",
                    Icons.person_outline,
                    controller: _nomController,
                  ),
                  _buildTextField(
                    "Prénom",
                    Icons.person_outline,
                    controller: _prenomController,
                  ),
                  _buildTextField(
                    "Email",
                    Icons.email_outlined,
                    controller: _emailController,
                  ),
                  _buildTextField(
                    "Mot de passe",
                    Icons.lock_outline,
                    obscure: true,
                    controller: _motDePasseController,
                  ),
                  _buildTextField(
                    "Téléphone",
                    Icons.phone_outlined,
                    controller: _telephoneController,
                  ),
                  _buildTextField(
                    "CIN",
                    Icons.badge_outlined,
                    controller: _cinController,
                  ),
                  _buildTextField(
                    "Nationalité",
                    Icons.flag_outlined,
                    controller: _nationaliteController,
                  ),
                  _buildTextField(
                    "Adresse",
                    Icons.location_on_outlined,
                    controller: _adresseController,
                  ),
                  _buildDatePicker("Date de Naissance", isNaissance: true),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Informations Professionnelles"),
                  _buildDropdown(
                    "Rôle Utilisateur",
                    ["Employé", "Manager", "Admin"],
                    value: _selectedRole,
                    onChanged: (val) => setState(() => _selectedRole = val),
                  ),
                  _buildTextField(
                    "Salaire",
                    Icons.payments_outlined,
                    isNumber: true,
                    controller: _salaireController,
                  ),
                  _buildDatePicker("Date d'Embauche", isNaissance: false),
                  _buildDropdown(
                    "Département",
                    [
                      "Ressources Humaines",
                      "Informatique",
                      "Finance",
                      "Marketing",
                      "Commercial",
                      "Production",
                      "Logistique",
                    ],
                    value: _selectedDepartement,
                    onChanged: (val) =>
                        setState(() => _selectedDepartement = val),
                  ),
                  if (_selectedRole == 'Employé')
                    _buildDropdown(
                      "Manager Direct",
                      _managers.map((u) => u.nom + ' ' + u.prenom).toList(),
                      value: _selectedManagerId != null
                          ? _managers
                                    .firstWhere(
                                      (u) => u.id == _selectedManagerId,
                                      orElse: () => User(
                                        id: '',
                                        nom: '',
                                        prenom: '',
                                        email: '',
                                        motDePasse: '',
                                        role: UserRole.manager,
                                        telephone: '',
                                        dateNaissance: DateTime.now(),
                                        salaire: 0.0,
                                        adresse: '',
                                        nationalite: '',
                                        photo: '',
                                        dateEmbauche: DateTime.now(),
                                        cin: '',
                                        departementId: '',
                                        soldeCongeTotal: 0.0,
                                        soldeCongeRestant: 0.0,
                                      ),
                                    )
                                    .nom +
                                ' ' +
                                _managers
                                    .firstWhere(
                                      (u) => u.id == _selectedManagerId,
                                      orElse: () => User(
                                        id: '',
                                        nom: '',
                                        prenom: '',
                                        email: '',
                                        motDePasse: '',
                                        role: UserRole.manager,
                                        telephone: '',
                                        dateNaissance: DateTime.now(),
                                        salaire: 0.0,
                                        adresse: '',
                                        nationalite: '',
                                        photo: '',
                                        dateEmbauche: DateTime.now(),
                                        cin: '',
                                        departementId: '',
                                        soldeCongeTotal: 0.0,
                                        soldeCongeRestant: 0.0,
                                      ),
                                    )
                                    .prenom
                          : null,
                      onChanged: (val) {
                        final selected = _managers.firstWhere(
                          (u) => (u.nom + ' ' + u.prenom) == val,
                          orElse: () => User(
                            id: '',
                            nom: '',
                            prenom: '',
                            email: '',
                            motDePasse: '',
                            role: UserRole.manager,
                            telephone: '',
                            dateNaissance: DateTime.now(),
                            salaire: 0.0,
                            adresse: '',
                            nationalite: '',
                            photo: '',
                            dateEmbauche: DateTime.now(),
                            cin: '',
                            departementId: '',
                            soldeCongeTotal: 0.0,
                            soldeCongeRestant: 0.0,
                          ),
                        );
                        setState(() {
                          _selectedManagerId = selected.id.isNotEmpty
                              ? selected.id
                              : null;
                        });
                      },
                    ),
                  _buildTextField(
                    "Solde Congé Total",
                    Icons.event_available,
                    isNumber: true,
                    controller: _soldeCongeTotalController,
                  ),

                  const SizedBox(height: 30),

                  // Bouton Valider
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F2EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isEditing
                                  ? "Mettre à jour"
                                  : "Enregistrer l'employé",
                              style: const TextStyle(
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

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF5F2EEA),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    bool obscure = false,
    bool isNumber = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF5F2EEA), size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items, {
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Sélectionner"),
                value: value,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, {required bool isNaissance}) {
    DateTime? selectedDate = isNaissance ? _dateNaissance : _dateEmbauche;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              DateTime initialDate = selectedDate ?? DateTime(2000, 1, 1);
              DateTime firstDate = DateTime(1900);
              DateTime lastDate = DateTime.now().add(
                const Duration(days: 365 * 10),
              );
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                locale: const Locale('fr', 'FR'),
              );
              if (picked != null) {
                setState(() {
                  if (isNaissance) {
                    _dateNaissance = picked;
                  } else {
                    _dateEmbauche = picked;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
                        : "Sélectionner une date",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF5F2EEA),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
