import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:equatable/equatable.dart';

class ArchivedCurriculumModel extends Equatable {
  final String id;                    // 1. المعرف الفريد للسجل الأرشيفي
  final String fileUrl;              // 2. رابط ملف المنهج (إجباري)
  final DateTime archivedAt;         // 3. تاريخ الأرشفة
  final String courseName;           // 4. اسم المادة الدراسية
  final String? archiveDescription;  // 5. وصف الأرشفة (اختياري)

  const ArchivedCurriculumModel({
    required this.id,
    required this.fileUrl,
    required this.archivedAt,
    required this.courseName,
    this.archiveDescription,
  });

  static final empty = ArchivedCurriculumModel(
    id: '',
    fileUrl: '',
    archivedAt: DateTime.now(),
    courseName: '',
  );

  bool get isEmpty => this == ArchivedCurriculumModel.empty;
  bool get isNotEmpty => this != ArchivedCurriculumModel.empty;

  ArchivedCurriculumModel copyWith({
    String? id,
    String? fileUrl,
    DateTime? archivedAt,
    String? courseName,
    String? archiveDescription,
  }) {
    return ArchivedCurriculumModel(
      id: id ?? this.id,
      fileUrl: fileUrl ?? this.fileUrl,
      archivedAt: archivedAt ?? this.archivedAt,
      courseName: courseName ?? this.courseName,
      archiveDescription: archiveDescription ?? this.archiveDescription,
    );
  }

  ArchivedCurriculumEntity toEntity() {
    return ArchivedCurriculumEntity(
      id: id,
      fileUrl: fileUrl,
      archivedAt: archivedAt,
      courseName: courseName,
      archiveDescription: archiveDescription,
    );
  }

  factory ArchivedCurriculumModel.fromEntity(ArchivedCurriculumEntity entity) {
    return ArchivedCurriculumModel(
      id: entity.id,
      fileUrl: entity.fileUrl,
      archivedAt: entity.archivedAt,
      courseName: entity.courseName,
      archiveDescription: entity.archiveDescription,
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