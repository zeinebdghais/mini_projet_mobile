import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/models/user.dart';

class AvatarHelper {
  /// � Obtenir les initiales
  static String getInitials(String prenom, String nom) {
    String pInit = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    String nInit = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$pInit$nInit';
  }

  /// 👥 Construire avatar avec photo RÉELLE de la base
  static Widget buildAvatarFromUser({
    required User user,
    double radius = 24,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    final initials = getInitials(user.prenom, user.nom);
    final bgColor = backgroundColor ?? const Color(0xFF7C3AED);
    final style =
        textStyle ??
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        );

    // ✅ Si pas de photo, afficher les initiales
    if (user.photo.isEmpty || user.photo == 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(initials, style: style),
      );
    }

    // 🔍 Déterminer le type de chemin photo
    String photoPath = user.photo;

    // ✅ Convertir file:// URI en chemin local
    if (photoPath.startsWith('file://')) {
      photoPath = photoPath.replaceFirst('file://', '');
    }

    // ✅ Chemin fichier local
    if (photoPath.startsWith('/')) {
      final file = File(photoPath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          backgroundImage: FileImage(file),
          onBackgroundImageError: (exception, stackTrace) {
            print('❌ Erreur chargement fichier: $exception');
          },
        );
      } else {
        print('⚠️ Fichier non trouvé: $photoPath');
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          child: Text(initials, style: style),
        );
      }
    }

    // ✅ URL réseau (http/https)
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(photoPath),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Erreur chargement URL: $exception');
        },
      );
    }

    // Fallback : afficher initiales
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(initials, style: style),
    );
  }

  /// 👥 Créer un CircleAvatar avec photo ou initiales (méthode alternative)
  static CircleAvatar buildAvatar({
    required String photo,
    required String prenom,
    required String nom,
    double radius = 24,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    final initials = getInitials(prenom, nom);
    final bgColor = backgroundColor ?? const Color(0xFF7C3AED);
    final style =
        textStyle ??
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        );

    if (photo.isEmpty || photo == 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(initials, style: style),
      );
    }

    // 🔍 Gérer les chemins file://
    String photoPath = photo;
    if (photoPath.startsWith('file://')) {
      photoPath = photoPath.replaceFirst('file://', '');
    }

    // ✅ Chemin local
    if (photoPath.startsWith('/')) {
      final file = File(photoPath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          backgroundImage: FileImage(file),
          onBackgroundImageError: (exception, stackTrace) {
            print('❌ Erreur fichier: $exception');
          },
        );
      } else {
        // Fichier non trouvé
        print('⚠️ Fichier non trouvé: $photoPath');
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          child: Text(initials, style: style),
        );
      }
    }

    // ✅ URL réseau (http/https seulement)
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(photo),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Erreur URL: $exception');
        },
      );
    }

    // Fallback : afficher initiales pour les chemins inconnus
    print('⚠️ Type de chemin inconnu: $photo');
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(initials, style: style),
    );
  }
}
