import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class StudentHomeworkModel extends Equatable {
  final String idStudent;
  final String name;
  final String file;
  final String title;
  final double fromMark;
  final DateTime? submitTime;

  const StudentHomeworkModel({
    required this.idStudent,
    required this.name,
    required this.file,
    required this.title,
    required this.fromMark,
    this.submitTime,
  });

  static final empty = StudentHomeworkModel(
    idStudent: '',
    name: '',
    file: '',
    title: '',
    fromMark: 0.0,
    submitTime: null,
  );

  bool get isEmpty => this == StudentHomeworkModel.empty;
  bool get isNotEmpty => this != StudentHomeworkModel.empty;
  // ✅ التحقق إذا تم التسليم
  bool get isSubmitted => file.isNotEmpty && submitTime != null;
  // ✅ التحقق إذا تم التقييم
  bool get isGraded => fromMark > 0;

  StudentHomeworkModel copyWith({
    String? idStudent,
    String? name,
    String? file,
    String? title,
    double? fromMark,
    DateTime? submitTime,
  }) {
    return StudentHomeworkModel(
      idStudent: idStudent ?? this.idStudent,
      name: name ?? this.name,
      file: file ?? this.file,
      title: title ?? this.title,
      fromMark: fromMark ?? this.fromMark,
      submitTime: submitTime ?? this.submitTime,
    );
  }

  StudentHomeworkEntity toEntity() {
    return StudentHomeworkEntity(
      idStudent: idStudent,
      name: name,
      file: file,
      title: title,
      fromMark: fromMark,
      submitTime: submitTime,
    );
  }

  factory StudentHomeworkModel.fromEntity(StudentHomeworkEntity entity) {
    return StudentHomeworkModel(
      idStudent: entity.idStudent,
      name: entity.name,
      file: entity.file,
      title: entity.title,
      fromMark: entity.fromMark,
      submitTime: entity.submitTime,
    );
  }

  @override
  List<Object?> props() => [idStudent, name, file, title, fromMark , submitTime];
}

class HomeworkModel extends Equatable {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String file;
  final double maxMark;
  final List<StudentHomeworkModel> students;

  const HomeworkModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.file,
    required this.maxMark,
    this.students = const [],
  });

  static final empty = HomeworkModel(
    id: '',
    title: '',
    start: DateTime.now(),
    end: DateTime.now(),
    description: '',
    file: '',
    maxMark: 0.0,
  );

  bool get isEmpty => this == HomeworkModel.empty;
  bool get isNotEmpty => this != HomeworkModel.empty;

  // التحقق إذا كان الواجب نشط (قبل تاريخ الانتهاء)
  bool get isActive => DateTime.now().isBefore(end);

  // التحقق إذا كان الواجب منتهي
  bool get isExpired => DateTime.now().isAfter(end);

  // الحصول على الوقت المتبقي
  Duration get timeRemaining => end.difference(DateTime.now());

   // ✅ إحصائيات التسليمات
  int get totalStudents => students.length;
  int get submittedCount => students.where((s) => s.isSubmitted).length;
  int get gradedCount => students.where((s) => s.isGraded).length;
  double get submissionRate => totalStudents > 0 ? submittedCount / totalStudents : 0.0;

  HomeworkModel copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    String? file,
    double? maxMark,
    List<StudentHomeworkModel>? students,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      file: file ?? this.file,
      maxMark: maxMark ?? this.maxMark,
      students: students ?? this.students,
    );
  }

  HomeworkEntity toEntity() {
    return HomeworkEntity(
      id: id,
      title: title,
      start: start,
      end: end,
      description: description,
      file: file,
      maxMark: maxMark,
      students: students.map((student) => student.toEntity()).toList(),
    );
  }

  factory HomeworkModel.fromEntity(HomeworkEntity entity) {
    return HomeworkModel(
      id: entity.id,
      title: entity.title,
      start: entity.start,
      end: entity.end,
      description: entity.description,
      file: entity.file,
      maxMark: entity.maxMark,
      students: entity.students.map((student) => StudentHomeworkModel.fromEntity(student)).toList(),
    );
  }

  @override
  List<Object?> props() => [id, title, start, end, description, file, maxMark, students];
}