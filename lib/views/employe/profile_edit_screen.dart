import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🖼️ PHOTO SECTION
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (userController.currentUser?.photo != null &&
                                      userController
                                          .currentUser!
                                          .photo
                                          .isNotEmpty
                                  ? FileImage(
                                      File(userController.currentUser!.photo),
                                    )
                                  : null),
                        child:
                            (_selectedImage == null &&
                                (userController.currentUser?.photo == null ||
                                    userController.currentUser!.photo.isEmpty))
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF5F2EEA),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 📝 FORM FIELDS
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
                  icon: Icons.badge,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Nationalité',
                  controller: _nationaliteController,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Adresse',
                  controller: _adresseController,
                  icon: Icons.home,
                  maxLines: 2,
                ),
                const SizedBox(height: 15),

                // 📅 DATE NAISSANCE
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date de naissance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dateNaissance != null
                                    ? "${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}"
                                    : "Sélectionner une date",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 💾 SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEdit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5F2EEA), Color(0xFF7F56D9)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                'Enregistrer les modifications',
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 HELPER: Build TextField
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF5F2EEA), size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 45),
        ),
      ),
    );
  }
}
