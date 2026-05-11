import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/models/user.dart';

class AvatarHelper {
  /// 🖼️ Obtenir le bon ImageProvider (local ou réseau)
  static ImageProvider getPhotoProvider(String photoPath) {
    if (photoPath.isEmpty) {
      return const NetworkImage("https://i.pravatar.cc/150?u=user");
    }

    if (photoPath.startsWith('/')) {
      final file = File(photoPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    return NetworkImage(photoPath);
  }

  /// 👤 Obtenir les initiales
  static String getInitials(String prenom, String nom) {
    String pInit = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    String nInit = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$pInit$nInit';
  }

  /// 👥 Créer un CircleAvatar avec photo ou initiales
  static CircleAvatar buildAvatar({
    required String photo,
    required String prenom,
    required String nom,
    double radius = 24,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    final initials = getInitials(prenom, nom);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      backgroundImage: photo.isNotEmpty ? getPhotoProvider(photo) : null,
      child: photo.isEmpty
          ? Text(
              initials,
              style:
                  textStyle ??
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          : null,
    );
  }

  /// 👥 Créer un CircleAvatar à partir d'un User
  static CircleAvatar buildAvatarFromUser({
    required User user,
    double radius = 24,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return buildAvatar(
      photo: user.photo,
      prenom: user.prenom,
      nom: user.nom,
      radius: radius,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
    );
  }
}
