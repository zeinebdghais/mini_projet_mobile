enum TypeDocument { fichepaie, attestation, contrat }

enum FormatDocument { pdf }

class Document {
  final String id;
  final String employeId;
  final TypeDocument typeDocument;
  final String fichierURL;
  final DateTime dateCreation;
  final String? description;

  Document({
    required this.id,
    required this.employeId,
    required this.typeDocument,
    required this.fichierURL,
    required this.dateCreation,
    this.description,
  });

  // Convertir Document en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeId': employeId,
      'typeDocument': typeDocument.toString().split('.').last,
      'fichierURL': fichierURL,
      'dateCreation': dateCreation.toIso8601String(),
      'description': description,
    };
  }

  // Créer Document à partir de JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id']?.toString() ?? '',
      employeId: json['employeId']?.toString() ?? '',
      typeDocument: TypeDocument.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['typeDocument']?.toString() ?? ''),
        orElse: () => TypeDocument.contrat,
      ),
      fichierURL: json['fichierURL']?.toString() ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'].toString())
          : DateTime.now(),

      description: json['description']?.toString(),
    );
  }

  // Copier avec modifications
  Document copyWith({
    String? id,
    String? employeId,
    TypeDocument? typeDocument,

    String? fichierURL,
    DateTime? dateCreation,
    String? description,
  }) {
    return Document(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      typeDocument: typeDocument ?? this.typeDocument,

      fichierURL: fichierURL ?? this.fichierURL,
      dateCreation: dateCreation ?? this.dateCreation,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Document(id: $id, employeId: $employeId, typeDocument: $typeDocument)';
  }
}
