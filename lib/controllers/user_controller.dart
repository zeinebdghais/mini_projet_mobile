import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirh_mobile/models/user.dart';

class UserController {
  static final UserController _instance = UserController._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // 💾 Utilisateur connecté en mémoire

  // Constructeur privé pour singleton
  UserController._internal();

  // Factory pour accéder à l'instance unique
  factory UserController() {
    return _instance;
  }

  /// Récupère l'utilisateur connecté
  User? get currentUser => _currentUser;

  /// Sauvegarde l'utilisateur connecté après login
  void setCurrentUser(User user) {
    _currentUser = user;
    print('✅ Utilisateur sauvegardé: ${user.email} (${user.role})');
  }

  /// Efface l'utilisateur (logout)
  void clearCurrentUser() {
    _currentUser = null;
    print('🚪 Utilisateur déconnecté');
  }

  /// Vérifie si un utilisateur est connecté
  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<String> uploadUserPhoto(File imageFile) async {
    try {
      print('📸 === STOCKAGE LOCAL PHOTO ===');
      print('📸 Chemin source: ${imageFile.path}');

      // Obtenir le répertoire local de l'application
      final appDocDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDocDir.path}/photos');

      // Créer le répertoire s'il n'existe pas
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
        print('📸 ✅ Répertoire créé: ${photosDir.path}');
      }

      // Générer un nom de fichier unique
      final fileName = 'user_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localFilePath = '${photosDir.path}/$fileName';

      print('📸 Destination locale: $localFilePath');

      // Copier le fichier localement
      await imageFile.copy(localFilePath);
      print('📸 ✅ Photo stockée localement: $localFilePath');

      return localFilePath;
    } catch (e) {
      print('❌ Erreur stockage photo: $e');
      rethrow;
    }
  }

  Future<void> addUser(User user, {File? photoFile}) async {
    String photoUrl = user.photo;
    if (photoFile != null) {
      // L'image est déjà comprimée lors du choix
      photoUrl = await uploadUserPhoto(photoFile);
    }
    final userWithPhoto = user.copyWith(photo: photoUrl);
    await _firestore
        .collection('users')
        .doc(userWithPhoto.id)
        .set(userWithPhoto.toJson());
  }

  Future<List<User>> getManagers() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'manager')
        .get();
    return querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  // Récupérer les employés et managers (sauf admin)
  Future<List<User>> getNonAdminUsers() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', whereIn: ['employe', 'manager'])
        .get();
    return querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  Future<List<User>> getAllUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }
}

// Instance singleton globale
final userController = UserController();
