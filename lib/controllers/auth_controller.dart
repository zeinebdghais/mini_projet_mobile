import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:sirh_mobile/models/user.dart';

class AuthController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 Connexion - Authentification directe via Firestore (sans Firebase Auth)
  Future<User?> login(String email, String motDePasse) async {
    try {
      // Chercher l'utilisateur dans Firestore par email et mot de passe
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('motDePasse', isEqualTo: motDePasse)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Email ou mot de passe incorrect');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;
      final user = User.fromJson({'id': userDoc.id, ...userData});

      print('✅ LOGIN: Email=$email, Rôle=${user.role}');
      return user;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// 📝 Inscription - Sauvegarde directe dans Firestore (sans Firebase Auth)
  Future<User?> registerUser({
    required String email,
    required String motDePasse,
    required String prenom,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    try {
      // Générer un ID unique pour l'utilisateur
      final uid = _firestore.collection('users').doc().id;

      // Créer directement le profil dans Firestore (sans Firebase Auth)
      final newUser = {
        'id': uid,
        'email': email,
        'motDePasse': motDePasse,
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'role': role,
        'photo': '',
        'dateCreation': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(uid).set(newUser);

      print('✅ REGISTER: Nouvel utilisateur créé - $email (ID: $uid)');
      return User.fromJson(newUser);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// 🚪 Déconnexion

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

      // Mettre à jour dans Firestore
      await _firestore.collection('users').doc(user.id).update({
        'motDePasse': newPassword,
      });

      // Mettre à jour dans Firebase Auth
      try {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          await firebaseUser.updatePassword(newPassword);
        }
      } catch (e) {
        print(
          '⚠️ Impossible de mettre à jour le mot de passe Firebase Auth: $e',
        );
      }

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

  /// 🚪 Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('✅ Déconnecté');
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }
}
