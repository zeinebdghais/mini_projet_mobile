import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sirh_mobile/models/user.dart';

class AuthController {
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

      print('🔐 AUTH: Utilisateur trouvé - ${user.email}');
      print('🔐 AUTH: Rôle brut en base = ${userData['role']}');
      print('🔐 AUTH: Rôle converti = ${user.role}');

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

  /// 🔑 Récupérer l'utilisateur par numéro de téléphone
  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw Exception('Aucun utilisateur trouvé avec ce numéro de téléphone');
      }

      final userDoc = result.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;
      return User.fromJson({'id': userDoc.id, ...userData});
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// 🔑 Générer et envoyer un code SMS
  Future<String> sendVerificationCode(String phoneNumber) async {
    try {
      // Générer un code aléatoire à 6 chiffres
      final code = (100000 + DateTime.now().millisecond % 900000).toString();

      // Stocker le code avec un timestamp dans Firestore
      await _firestore.collection('verification_codes').doc(phoneNumber).set({
        'code': code,
        'timestamp': DateTime.now().toIso8601String(),
        'attempts': 0,
      });

      print('📱 CODE SMS: $code envoyé à $phoneNumber');
      return code; // En production, intégrer un service SMS réel
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }

  /// 🔑 Vérifier le code
  Future<bool> verifyCode(String phoneNumber, String enteredCode) async {
    try {
      final doc = await _firestore
          .collection('verification_codes')
          .doc(phoneNumber)
          .get();

      if (!doc.exists) {
        throw Exception('Code expiré ou invalide');
      }

      final data = doc.data() as Map<String, dynamic>;
      final storedCode = data['code'];

      if (storedCode == enteredCode) {
        print('✅ Code SMS vérifié');
        return true;
      } else {
        throw Exception('Code incorrect');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// 🔑 Réinitialiser le mot de passe
  Future<void> resetPassword(String phoneNumber, String newPassword) async {
    try {
      final user = await getUserByPhoneNumber(phoneNumber);
      if (user == null) {
        throw Exception('Utilisateur non trouvé');
      }

      // Mettre à jour le mot de passe
      await _firestore.collection('users').doc(user.id).update({
        'motDePasse': newPassword,
      });

      // Supprimer le code de vérification
      await _firestore
          .collection('verification_codes')
          .doc(phoneNumber)
          .delete();

      print('✅ Mot de passe réinitialisé');
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }
}
