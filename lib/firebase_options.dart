// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
/*
Remplacer les valeurs par celles de ton google-controllers.json :
current_key → apiKey
mobilesdk_app_id → appId
project_id → projectId
storage_bucket → storageBucket
project_number → messagingSenderId*/

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyCcATbojI5rZmywc3BPTydP2psl0lb2GAA',
    appId: '1:312998283435:android:c9ff148ea7de320a160fee',
    messagingSenderId: '312998283435',
    projectId: 'sirhmobile',
    storageBucket: 'sirhmobile.firebasestorage.app',
  );
}

