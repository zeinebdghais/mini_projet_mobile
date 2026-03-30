enum TypeDocument { fichepaie, attestation, contrat }

enum FormatDocument { pdf }

class Document {
  final String id;
  final String employeId;
  final TypeDocument typeDocument;
  final String nomDocument;
  final String fichierURL;
  final DateTime dateCreation;
  final double tailleFichier;
  final FormatDocument format;

  Document({
    required this.id,
    required this.employeId,
    required this.typeDocument,
    required this.nomDocument,
    required this.fichierURL,
    required this.dateCreation,
    required this.tailleFichier,
    required this.format,
  });

  // Convertir Document en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeId': employeId,
      'typeDocument': typeDocument.toString().split('.').last,
      'nomDocument': nomDocument,
      'fichierURL': fichierURL,
      'dateCreation': dateCreation.toIso8601String(),
      'tailleFichier': tailleFichier,
      'format': format.toString().split('.').last,
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
      nomDocument: json['nomDocument']?.toString() ?? '',
      fichierURL: json['fichierURL']?.toString() ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'].toString())
          : DateTime.now(),
      tailleFichier: (json['tailleFichier'] as num?)?.toDouble() ?? 0.0,
      format: FormatDocument.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (json['format']?.toString() ?? ''),
        orElse: () => FormatDocument.pdf,
      ),
    );
  }

  // Copier avec modifications
  Document copyWith({
    String? id,
    String? employeId,
    TypeDocument? typeDocument,
    String? nomDocument,
    String? fichierURL,
    DateTime? dateCreation,
    double? tailleFichier,
    FormatDocument? format,
  }) {
    return Document(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      typeDocument: typeDocument ?? this.typeDocument,
      nomDocument: nomDocument ?? this.nomDocument,
      fichierURL: fichierURL ?? this.fichierURL,
      dateCreation: dateCreation ?? this.dateCreation,
      tailleFichier: tailleFichier ?? this.tailleFichier,
      format: format ?? this.format,
    );
  }

  @override
  String toString() {
    return 'Document(id: $id, employeId: $employeId, nomDocument: $nomDocument, typeDocument: $typeDocument)';
  }
}
