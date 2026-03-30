import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sirh_mobile/models/user.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Vérifier les identifiants et retourner l'utilisateur
  Future<User?> login(String email, String motDePasse) async {
    try {
      // Chercher l'utilisateur dans Firestore par email
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Vérifier si un utilisateur a été trouvé
      if (result.docs.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }

      final userDoc = result.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;

      // Vérifier le mot de passe
      if (userData['motDePasse'] != motDePasse) {
        throw Exception('Mot de passe incorrect');
      }

      // Convertir les données en objet User
      final user = User.fromJson({'id': userDoc.id, ...userData});

      return user;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupérer un utilisateur par son ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final userData = doc.data() as Map<String, dynamic>;
      return User.fromJson({'id': doc.id, ...userData});
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  /// Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    try {
      final QuerySnapshot result = await _firestore.collection('users').get();

      return result.docs.map((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        return User.fromJson({'id': doc.id, ...userData});
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  /// Créer un nouvel utilisateur
  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }
}
