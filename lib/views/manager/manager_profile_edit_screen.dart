import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ManagerProfileEditScreen extends StatefulWidget {
  const ManagerProfileEditScreen({super.key});

  @override
  State<ManagerProfileEditScreen> createState() =>
      _ManagerProfileEditScreenState();
}

class _ManagerProfileEditScreenState extends State<ManagerProfileEditScreen> {
  late TextEditingController _prenomController;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _cinController;
  late TextEditingController _nationaliteController;
  late TextEditingController _adresseController;

  DateTime? _dateNaissance;
  File? _selectedImage;
  bool _isLoading = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final current = userController.currentUser;
    _prenomController = TextEditingController(text: current?.prenom ?? '');
    _nomController = TextEditingController(text: current?.nom ?? '');
    _emailController = TextEditingController(text: current?.email ?? '');
    _telephoneController = TextEditingController(
      text: current?.telephone ?? '',
    );
    _cinController = TextEditingController(text: current?.cin ?? '');
    _nationaliteController = TextEditingController(
      text: current?.nationalite ?? '',
    );
    _adresseController = TextEditingController(text: current?.adresse ?? '');
    _dateNaissance = current?.dateNaissance;
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _cinController.dispose();
    _nationaliteController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  // 🖼️ Récupérer une image de la galerie
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 🖼️ Compresser l'image
  Future<File?> _compressImage(File imageFile) async {
    final filePath = imageFile.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      outPath,
      quality: 88,
    );

    return result != null ? File(result.path) : null;
  }

  // 📅 Sélectionner la date de naissance
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }

  // 💾 Soumettre la modification
  Future<void> _submitEdit() async {
    if (_prenomController.text.isEmpty || _nomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      File? photoFile;
      if (_selectedImage != null) {
        photoFile = await _compressImage(_selectedImage!);
      }

      final updatedUser = userController.currentUser!.copyWith(
        prenom: _prenomController.text,
        nom: _nomController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        cin: _cinController.text,
        nationalite: _nationaliteController.text,
        adresse: _adresseController.text,
        dateNaissance:
            _dateNaissance ?? userController.currentUser!.dateNaissance,
      );

      await userController.updateUser(updatedUser, photoFile: photoFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
        Navigator.pop(context, true); // Retourner avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final current = userController.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Modifier profil",
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

          /// BLUR CIRCLES
          Positioned(
            top: 80,
            left: 20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: size.width - 150,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellowAccent.withOpacity(0.4),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  /// PHOTO SECTION
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5F2EEA),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (current?.photo != null &&
                                          current!.photo.isNotEmpty &&
                                          current.photo.startsWith('/')
                                      ? FileImage(File(current.photo))
                                      : (current != null &&
                                                    current.photo.isNotEmpty
                                                ? NetworkImage(current.photo)
                                                : const AssetImage(
                                                    'assets/images/profile.jpg',
                                                  ))
                                            as ImageProvider),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF5F2EEA),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// FORM FIELDS
                  _buildTextField(
                    label: 'Prénom',
                    controller: _prenomController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Nom',
                    controller: _nomController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Téléphone',
                    controller: _telephoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'CIN',
                    controller: _cinController,
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Nationalité',
                    controller: _nationaliteController,
                    icon: Icons.public,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Adresse',
                    controller: _adresseController,
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 15),

                  /// DATE PICKER
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF5F2EEA).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF5F2EEA),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateNaissance != null
                                  ? 'Né(e) le ${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                                  : 'Sélectionner date naissance',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF5F2EEA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                color: Color(0xFF5F2EEA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F2EEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5F2EEA).withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF5F2EEA), size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF5F2EEA), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
