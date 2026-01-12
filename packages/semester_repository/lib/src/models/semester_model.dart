import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class SemesterModel extends Equatable {
  final String id;
  final String typeSemester;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCredits;
  final int minCredits;
  final List<CoursesModel> courses;

  const SemesterModel({
    required this.id,
    required this.typeSemester,
    required this.startTime,
    required this.endTime,
    required this.maxCredits,
    required this.minCredits,
    this.courses = const [],
  });

  static final empty = SemesterModel(
    id: '',
    typeSemester: '',
    startTime: DateTime.now(),
    endTime: DateTime.now(),
    maxCredits: 0,
    minCredits: 0,
  );

  bool get isEmpty => this == SemesterModel.empty;
  bool get isNotEmpty => this != SemesterModel.empty;

  // التحقق إذا كان الفصل نشط حالياً
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  // الحصول على الفصل الحالي
  String get currentWeek {
    final now = DateTime.now();
    if (!isActive) return 'غير نشط';
    
    final difference = now.difference(startTime).inDays;
    final week = (difference / 7).floor() + 1;
    return 'الأسبوع $week';
  }

  SemesterModel copyWith({
    String? id,
    String? typeSemester,
    DateTime? startTime,
    DateTime? endTime,
    int? maxCredits,
    int? minCredits,
    List<CoursesModel>? courses,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      typeSemester: typeSemester ?? this.typeSemester,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxCredits: maxCredits ?? this.maxCredits,
      minCredits: minCredits ?? this.minCredits,
      courses: courses ?? this.courses,
    );
  }

  SemesterEntity toEntity() {
    return SemesterEntity(
      id: id,
      typeSemester: typeSemester,
      startTime: startTime,
      endTime: endTime,
      maxCredits: maxCredits,
      minCredits: minCredits,
    );
  }

  factory SemesterModel.fromEntity(SemesterEntity entity) {
    return SemesterModel(
      id: entity.id,
      typeSemester: entity.typeSemester,
      startTime: entity.startTime,
      endTime: entity.endTime,
      maxCredits: entity.maxCredits,
      minCredits: entity.minCredits,
    );
  }

  @override
  List<Object?> props() => [
        id,
        typeSemester,
        startTime,
        endTime,
        maxCredits,
        minCredits,
        courses,
      ];
}