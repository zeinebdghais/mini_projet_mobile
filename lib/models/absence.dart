enum TypeAbsence { nonJustifiee, justifiee, maladie }

enum StatutAbsence { enAttente, approuve, refuse }

class Absence {
  final String id;
  final String employeId;
  final String managerId;
  final TypeAbsence typeAbsence;
  final DateTime dateAbsence;
  final String motif;
  final String? justificatif;
  final StatutAbsence statut;
  final DateTime dateDemande;
  final DateTime? dateValidation;

  Absence({
    required this.id,
    required this.employeId,
    required this.managerId,
    required this.typeAbsence,
    required this.dateAbsence,
    required this.motif,
    this.justificatif,
    required this.statut,
    required this.dateDemande,
    this.dateValidation,
  });

  // Convertir Absence en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeId': employeId,
      'managerId': managerId,
      'typeAbsence': typeAbsence.toString().split('.').last,
      'dateAbsence': dateAbsence.toIso8601String(),
      'motif': motif,
      'justificatif': justificatif,
      'statut': statut.toString().split('.').last,
      'dateDemande': dateDemande.toIso8601String(),
      'dateValidation': dateValidation?.toIso8601String(),
    };
  }

  // Créer Absence à partir de JSON
  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id']?.toString() ?? '',
      employeId: json['employeId']?.toString() ?? '',
      managerId: json['managerId']?.toString() ?? '',
      typeAbsence: TypeAbsence.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['typeAbsence']?.toString() ?? ''),
        orElse: () => TypeAbsence.nonJustifiee,
      ),
      dateAbsence: json['dateAbsence'] != null
          ? DateTime.parse(json['dateAbsence'].toString())
          : DateTime.now(),
      motif: json['motif']?.toString() ?? '',
      justificatif: json['justificatif']?.toString(),
      statut: StatutAbsence.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['statut']?.toString() ?? ''),
        orElse: () => StatutAbsence.enAttente,
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
  Absence copyWith({
    String? id,
    String? employeId,
    String? managerId,
    TypeAbsence? typeAbsence,
    DateTime? dateAbsence,
    String? motif,
    String? justificatif,
    StatutAbsence? statut,
    DateTime? dateDemande,
    DateTime? dateValidation,
  }) {
    return Absence(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      managerId: managerId ?? this.managerId,
      typeAbsence: typeAbsence ?? this.typeAbsence,
      dateAbsence: dateAbsence ?? this.dateAbsence,
      motif: motif ?? this.motif,
      justificatif: justificatif ?? this.justificatif,
      statut: statut ?? this.statut,
      dateDemande: dateDemande ?? this.dateDemande,
      dateValidation: dateValidation ?? this.dateValidation,
    );
  }

  @override
  String toString() =>
      'Absence(id=$id, employeId=$employeId, typeAbsence=$typeAbsence)';
}
