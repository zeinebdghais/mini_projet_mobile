import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sirh_mobile/models/user.dart';

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
}
