class Departement {
  final String id;
  final String nom;
  final String description;
  final int nombreEmployes;

  Departement({
    required this.id,
    required this.nom,
    required this.description,
    required this.nombreEmployes,
  });

  // Convertir Departement en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'nombreEmployes': nombreEmployes,
    };
  }

  // Créer Departement à partir de JSON
  factory Departement.fromJson(Map<String, dynamic> json) {
    return Departement(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      nombreEmployes: (json['nombreEmployes'] as int?) ?? 0,
    );
  }

  // Copier avec modifications
  Departement copyWith({
    String? id,
    String? nom,
    String? description,
    int? nombreEmployes,
  }) {
    return Departement(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      nombreEmployes: nombreEmployes ?? this.nombreEmployes,
    );
  }

  @override
  String toString() {
    return 'Departement(id: $id, nom: $nom, nombreEmployes: $nombreEmployes)';
  }
}

