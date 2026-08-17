class PdfDocumentModel {
  final String id;
  final String fileName;
  final String displayName;
  final String path;
  final DateTime createdAt;
  final bool isFavorite;
  final String? folderId;

  /// Número de páginas do PDF no momento em que foi gerado. `0` para
  /// documentos registrados antes deste campo existir, ou reconciliados a
  /// partir do disco (ver `PdfDocumentsRepository._reconciliarComDisco`),
  /// já que nesses casos não temos como saber sem abrir o arquivo.
  final int pageCount;

  const PdfDocumentModel({
    required this.id,
    required this.fileName,
    required this.displayName,
    required this.path,
    required this.createdAt,
    this.isFavorite = false,
    this.folderId,
    this.pageCount = 0,
  });

  PdfDocumentModel copyWith({
    String? displayName,
    bool? isFavorite,
    String? folderId,
    bool clearFolderId = false,
  }) {
    return PdfDocumentModel(
      id: id,
      fileName: fileName,
      displayName: displayName ?? this.displayName,
      path: path,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'displayName': displayName,
      'path': path,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'folderId': folderId,
      'pageCount': pageCount,
    };
  }

  factory PdfDocumentModel.fromMap(Map<dynamic, dynamic> map) {
    return PdfDocumentModel(
      id: map['id'] as String,
      fileName: map['fileName'] as String,
      displayName: map['displayName'] as String,
      path: map['path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isFavorite: map['isFavorite'] as bool? ?? false,
      folderId: map['folderId'] as String?,
      pageCount: map['pageCount'] as int? ?? 0,
    );
  }
}
