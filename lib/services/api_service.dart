import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sirh_mobile/models/user.dart';
import 'package:sirh_mobile/models/document.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserPhoto(File imageFile) async {
    final fileName = 'user_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('user_photos').child(fileName);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
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

  // Uploader un document PDF avec progress tracking
  Future<String> uploadDocument(
    File pdfFile, {
    required Function(double) onProgress,
  }) async {
    try {
      print('📁 === DÉMARRAGE UPLOAD PDF ===');
      print('📁 Chemin: ${pdfFile.path}');
      print(
        '📁 Taille: ${(await pdfFile.length() / 1024 / 1024).toStringAsFixed(2)}MB',
      );

      final fileName =
          'documents/doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final ref = _storage.ref().child(fileName);

      print('📁 Destination: $fileName');
      print('📁 Bucket: sirhmobile.firebasestorage.app');

      print('📁 ⏳ Démarrage upload...');

      // Start progress at 0%
      onProgress(0.0);
      print('📤 Progress: 0%');

      // Start the upload
      final uploadTask = ref.putFile(pdfFile);

      // Create a timer to simulate realistic progress
      var progressValue = 0.0;
      final progressTimer = Timer.periodic(Duration(milliseconds: 200), (
        timer,
      ) {
        if (progressValue < 0.99) {
          progressValue += 0.02;
          progressValue = progressValue.clamp(0.0, 0.99);
          onProgress(progressValue);
          print('📤 Progress: ${(progressValue * 100).toStringAsFixed(0)}%');
        }
      });

      try {
        // Wait for upload to actually complete
        print('📁 ⏳ Attente fin upload....');
        final TaskSnapshot result = await uploadTask.timeout(
          Duration(minutes: 10),
        );

        // Stop the timer
        progressTimer.cancel();

        // Force 100% when done
        onProgress(1.0);
        print('📤 Progress: 100%');
        print('📁 ✅ Upload terminé: ${result.state}');
      } catch (e) {
        progressTimer.cancel();
        print('❌ Upload failed: $e');
        print('❌ Error type: ${e.runtimeType}');
        rethrow;
      }

      // Get download URL
      print('📁 ⏳ Récupération URL...');
      final downloadUrl = await ref.getDownloadURL();
      print('📁 ✅ URL obtenue: ${downloadUrl.substring(0, 50)}...');

      return downloadUrl;
    } catch (e) {
      print('❌ === ERREUR UPLOAD ===');
      print('❌ Message: $e');
      print('❌ Type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Ajouter un document dans Firestore
  Future<void> addDocument(Document document) async {
    await _firestore
        .collection('documents')
        .doc(document.id)
        .set(document.toJson());
  }

  // Récupérer tous les documents
  Future<List<Document>> getAllDocuments() async {
    final querySnapshot = await _firestore
        .collection('documents')
        .orderBy('dateCreation', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Document.fromJson(doc.data()))
        .toList();
  }
}
