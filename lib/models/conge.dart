enum TypeConge { annuel, maladie, sansSolde }

enum StatutConge { enAttente, approuve, refuse }

class Conge {
  final String id;
  final String employeId;
  final String managerId;
  final TypeConge typeConge;
  final DateTime dateDebut;
  final DateTime dateFin;
  final int duree;
  final String motif;
  final StatutConge statut;
  final DateTime dateDemande;
  final DateTime? dateValidation;

  Conge({
    required this.id,
    required this.employeId,
    required this.managerId,
    required this.typeConge,
    required this.dateDebut,
    required this.dateFin,
    required this.duree,
    required this.motif,
    required this.statut,
    required this.dateDemande,
    this.dateValidation,
  });

  // Convertir Conge en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeId': employeId,
      'managerId': managerId,
      'typeConge': typeConge.toString().split('.').last,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'duree': duree,
      'motif': motif,
      'statut': statut.toString().split('.').last,
      'dateDemande': dateDemande.toIso8601String(),
      'dateValidation': dateValidation?.toIso8601String(),
    };
  }

  // Créer Conge à partir de JSON
  factory Conge.fromJson(Map<String, dynamic> json) {
    return Conge(
      id: json['id']?.toString() ?? '',
      employeId: json['employeId']?.toString() ?? '',
      managerId: json['managerId']?.toString() ?? '',
      typeConge: TypeConge.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['typeConge']?.toString() ?? ''),
        orElse: () => TypeConge.annuel,
      ),
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'].toString())
          : DateTime.now(),
      dateFin: json['dateFin'] != null
          ? DateTime.parse(json['dateFin'].toString())
          : DateTime.now(),
      duree: (json['duree'] as int?) ?? 0,
      motif: json['motif']?.toString() ?? '',
      statut: StatutConge.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['statut']?.toString() ?? ''),
        orElse: () => StatutConge.enAttente,
      ),
      dateDemande: json['dateDemande'] != null
          ? DateTime.parse(json['dateDemande'].toString())
          : DateTime.now(),
      dateValidation: json['dateValidation'] != null
          ? DateTime.parse(json['dateValidation'].toString())
          : null,
    );
  }

  // Copier avec modifications
  Conge copyWith({
    String? id,
    String? employeId,
    String? managerId,
    TypeConge? typeConge,
    DateTime? dateDebut,
    DateTime? dateFin,
    int? duree,
    String? motif,
    StatutConge? statut,
    DateTime? dateDemande,
    DateTime? dateValidation,
  }) {
    return Conge(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      managerId: managerId ?? this.managerId,
      typeConge: typeConge ?? this.typeConge,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      duree: duree ?? this.duree,
      motif: motif ?? this.motif,
      statut: statut ?? this.statut,
      dateDemande: dateDemande ?? this.dateDemande,
      dateValidation: dateValidation ?? this.dateValidation,
    );
  }

  @override
  String toString() {
    return 'Conge(id: $id, employeId: $employeId, typeConge: $typeConge, statut: $statut)';
  }
}
