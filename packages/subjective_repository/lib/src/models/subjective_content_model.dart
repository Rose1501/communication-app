// subjective_content_model.dart
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

/// 📚 نموذج يمثل المحتوى التعليمي الكامل لمجموعة
class SubjectiveContentModel extends Equatable {
  final List<CurriculumModel> curricula;
  final List<HomeworkModel> homeworks;
  final List<AdvertisementModel> advertisements;
  final List<ExamGradeModel> examGrades;
  final List<AttendanceRecordModel> attendanceRecords;

  const SubjectiveContentModel({
    required this.curricula,
    required this.homeworks,
    this.advertisements = const [],
    this.examGrades = const [],
    this.attendanceRecords = const [],
  });

  static const empty = SubjectiveContentModel(
    curricula: [],
    homeworks: [],
    advertisements: [],
    examGrades: [],
    attendanceRecords: [],
  );

  bool get isEmpty => this == SubjectiveContentModel.empty;
  bool get isNotEmpty => this != SubjectiveContentModel.empty;

  @override
  List<Object?> props() => [curricula, homeworks, advertisements, examGrades, attendanceRecords];
}