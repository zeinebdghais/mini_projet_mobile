import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirh_mobile/models/document.dart';

class DocumentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uploader un document PDF avec stockage local
  Future<String> uploadDocument(
    File pdfFile, {
    required Function(double) onProgress,
  }) async {
    try {
      print('📁 === DÉMARRAGE STOCKAGE LOCAL PDF ===');
      print('📁 Chemin source: ${pdfFile.path}');
      print(
        '📁 Taille: ${(await pdfFile.length() / 1024 / 1024).toStringAsFixed(2)}MB',
      );

      // Obtenir le répertoire local de l'application
      final appDocDir = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${appDocDir.path}/documents');

      // Créer le répertoire s'il n'existe pas
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
        print('📁 ✅ Répertoire créé: ${documentsDir.path}');
      }

      // Générer un nom de fichier unique
      final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final localFilePath = '${documentsDir.path}/$fileName';

      print('📁 Destination locale: $localFilePath');

      print('📁 ⏳ Démarrage copie fichier...');

      // Start progress at 0%
      onProgress(0.0);
      print('📤 Progress: 0%');

      // Create a timer to simulate realistic progress
      var progressValue = 0.0;
      final progressTimer = Timer.periodic(Duration(milliseconds: 100), (
        timer,
      ) {
        if (progressValue < 0.95) {
          progressValue += 0.05;
          progressValue = progressValue.clamp(0.0, 0.95);
          onProgress(progressValue);
          print('📤 Progress: ${(progressValue * 100).toStringAsFixed(0)}%');
        }
      });

      try {
        // Copier le fichier localement (opération rapide)
        print('📁 DEBUG: Avant copie fichier');
        await pdfFile.copy(localFilePath);
        print('📁 DEBUG: Fichier copié avec succès');

        progressTimer.cancel();
        onProgress(1.0);
        print('📤 Progress: 100%');
        print('📁 ✅ Fichier stocké localement: $localFilePath');

        return localFilePath;
      } catch (e) {
        progressTimer.cancel();
        print('❌ Erreur copie fichier: $e');
        print('❌ Error type: ${e.runtimeType}');
        rethrow;
      }
    } catch (e) {
      print('❌ === ERREUR STOCKAGE LOCAL ===');
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

  // Récupérer les documents d'un employé spécifique
  Future<List<Document>> getEmployeeDocuments(String employeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('documents')
          .where('employeId', isEqualTo: employeId)
          .get();

      final documents = querySnapshot.docs
          .map((doc) => Document.fromJson(doc.data()))
          .toList();

      // Trier localement par date de création (plus récent en premier)
      documents.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      return documents;
    } catch (e) {
      print('❌ Erreur récupération documents: $e');
      return [];
    }
  }
}
