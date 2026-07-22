class PdfFolderModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const PdfFolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  PdfFolderModel copyWith({String? name}) {
    return PdfFolderModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PdfFolderModel.fromMap(Map<dynamic, dynamic> map) {
    return PdfFolderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
