class PdfDocumentModel {
  final String id;
  final String fileName;
  final String displayName;
  final String path;
  final DateTime createdAt;
  final bool isFavorite;
  final String? folderId;

  const PdfDocumentModel({
    required this.id,
    required this.fileName,
    required this.displayName,
    required this.path,
    required this.createdAt,
    this.isFavorite = false,
    this.folderId,
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
    );
  }
}
