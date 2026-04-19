enum UserRole { employe, manager, rh, admin }

class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final UserRole role;
  final String telephone;
  final DateTime dateNaissance;
  final double salaire;
  final String adresse;
  final String nationalite;
  final String photo;
  final DateTime dateEmbauche;
  final String cin;
  final String departement;
  final String? managerId;
  final double soldeCongeTotal;
  final double soldeCongeRestant;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.role,
    required this.telephone,
    required this.dateNaissance,
    required this.salaire,
    required this.adresse,
    required this.nationalite,
    required this.photo,
    required this.dateEmbauche,
    required this.cin,
    required this.departement,
    this.managerId,
    required this.soldeCongeTotal,
    required this.soldeCongeRestant,
  });

  // Convertir User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.toString().split('.').last,
      'telephone': telephone,
      'dateNaissance': dateNaissance.toIso8601String(),
      'salaire': salaire,
      'adresse': adresse,
      'nationalite': nationalite,
      'photo': photo,
      'dateEmbauche': dateEmbauche.toIso8601String(),
      'cin': cin,
      'departement': departement,
      'managerId': managerId,
      'soldeCongeTotal': soldeCongeTotal,
      'soldeCongeRestant': soldeCongeRestant,
    };
  }

  // Créer User à partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    String roleString = (json['role']?.toString() ?? '').toLowerCase().trim();
    UserRole role;
    switch (roleString) {
      case 'manager':
        role = UserRole.manager;
        break;
      case 'rh':
        role = UserRole.rh;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        role = UserRole.employe;
    }
    return User(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      motDePasse: json['motDePasse']?.toString() ?? '',
      role: role,
      telephone: json['telephone']?.toString() ?? '',
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.parse(json['dateNaissance'].toString())
          : DateTime.now(),
      salaire: (json['salaire'] as num?)?.toDouble() ?? 0.0,
      adresse: json['adresse']?.toString() ?? '',
      nationalite: json['nationalite']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      dateEmbauche: json['dateEmbauche'] != null
          ? DateTime.parse(json['dateEmbauche'].toString())
          : DateTime.now(),
      cin: json['cin']?.toString() ?? '',
      departement: json['departement']?.toString() ?? '',
      managerId: json['managerId']?.toString(),
      soldeCongeTotal: (json['soldeCongeTotal'] as num?)?.toDouble() ?? 0.0,
      soldeCongeRestant: (json['soldeCongeRestant'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Copier avec modifications
  User copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
    UserRole? role,
    String? telephone,
    DateTime? dateNaissance,
    double? salaire,
    String? adresse,
    String? nationalite,
    String? photo,
    DateTime? dateEmbauche,
    String? cin,
    String? departement,
    String? managerId,
    double? soldeCongeTotal,
    double? soldeCongeRestant,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      role: role ?? this.role,
      telephone: telephone ?? this.telephone,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      salaire: salaire ?? this.salaire,
      adresse: adresse ?? this.adresse,
      nationalite: nationalite ?? this.nationalite,
      photo: photo ?? this.photo,
      dateEmbauche: dateEmbauche ?? this.dateEmbauche,
      cin: cin ?? this.cin,
      departement: departement ?? this.departement,
      managerId: managerId ?? this.managerId,
      soldeCongeTotal: soldeCongeTotal ?? this.soldeCongeTotal,
      soldeCongeRestant: soldeCongeRestant ?? this.soldeCongeRestant,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role)';
  }
}
