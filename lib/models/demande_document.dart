enum TypeDemandeDocument { fichepaie, attestation, contrat }

enum StatutDemandeDocument { enAttente, approuve, refuse }

class DemandeDocument {
  final String id;
  final String employeId;
  final String managerId;
  final TypeDemandeDocument typeDocument;
  final String motif;
  final StatutDemandeDocument statut;
  final DateTime dateDemande;
  final DateTime? dateValidation;
  final String? notes;

  DemandeDocument({
    required this.id,
    required this.employeId,
    required this.managerId,
    required this.typeDocument,
    required this.motif,
    required this.statut,
    required this.dateDemande,
    this.dateValidation,
    this.notes,
  });

  // Convertir DemandeDocument en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeId': employeId,
      'managerId': managerId,
      'typeDocument': typeDocument.toString().split('.').last,
      'motif': motif,
      'statut': statut.toString().split('.').last,
      'dateDemande': dateDemande.toIso8601String(),
      'dateValidation': dateValidation?.toIso8601String(),
      'notes': notes,
    };
  }

  // Créer DemandeDocument à partir de JSON
  factory DemandeDocument.fromJson(Map<String, dynamic> json) {
    return DemandeDocument(
      id: json['id']?.toString() ?? '',
      employeId: json['employeId']?.toString() ?? '',
      managerId: json['managerId']?.toString() ?? '',
      typeDocument: TypeDemandeDocument.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['typeDocument']?.toString() ?? ''),
        orElse: () => TypeDemandeDocument.contrat,
      ),
      motif: json['motif']?.toString() ?? '',
      statut: StatutDemandeDocument.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['statut']?.toString() ?? ''),
        orElse: () => StatutDemandeDocument.enAttente,
      ),
      dateDemande: json['dateDemande'] != null
          ? DateTime.parse(json['dateDemande'].toString())
          : DateTime.now(),
      dateValidation: json['dateValidation'] != null
          ? DateTime.parse(json['dateValidation'].toString())
          : null,
      notes: json['notes']?.toString(),
    );
  }

  // Copier avec modifications
  DemandeDocument copyWith({
    String? id,
    String? employeId,
    String? managerId,
    TypeDemandeDocument? typeDocument,
    String? motif,
    StatutDemandeDocument? statut,
    DateTime? dateDemande,
    DateTime? dateValidation,
    String? notes,
  }) {
    return DemandeDocument(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      managerId: managerId ?? this.managerId,
      typeDocument: typeDocument ?? this.typeDocument,
      motif: motif ?? this.motif,
      statut: statut ?? this.statut,
      dateDemande: dateDemande ?? this.dateDemande,
      dateValidation: dateValidation ?? this.dateValidation,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'DemandeDocument(id: $id, employeId: $employeId, typeDocument: $typeDocument)';
  }
}
