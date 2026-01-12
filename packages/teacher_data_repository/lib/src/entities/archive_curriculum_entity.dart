import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ArchivedCurriculumEntity extends Equatable {
  final String id;
  final String fileUrl;
  final DateTime archivedAt;
  final String courseName;
  final String? archiveDescription;

  const ArchivedCurriculumEntity({
    required this.id,
    required this.fileUrl,
    required this.archivedAt,
    required this.courseName,
    this.archiveDescription,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'archivedAt': Timestamp.fromDate(archivedAt),
      'courseName': courseName,
      if (archiveDescription != null) 'archiveDescription': archiveDescription,
    };
  }

  factory ArchivedCurriculumEntity.fromDocument(Map<String, dynamic> doc) {
    return ArchivedCurriculumEntity(
      id: doc['id'] as String,
      fileUrl: doc['fileUrl'] as String,
      archivedAt: (doc['archivedAt'] as Timestamp).toDate(),
      courseName: doc['courseName'] as String,
      archiveDescription: doc['archiveDescription'] as String?,
    );
  }

  @override
  List<Object?> props() => [
        id,
        fileUrl,
        archivedAt,
        courseName,
        archiveDescription,
      ];
}