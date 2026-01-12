import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AttendanceRecordModel extends Equatable {
  final String id;
  final DateTime date;
  final String lectureTitle;
  final Map<String, String> presentStudentIds;
  final Map<String, String> absentStudentIds;
  final Map<String, String> studentNotes;
  final DateTime createdAt;

  const AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.lectureTitle,
    required this.presentStudentIds,
    required this.absentStudentIds,
    required this.studentNotes,
    required this.createdAt,
  });

  static final empty = AttendanceRecordModel(
    id: '',
    date: DateTime.now(),
    lectureTitle: '',
    presentStudentIds: {},
    absentStudentIds: {},
    studentNotes: {},
    createdAt: DateTime.now(),
  );

  bool get isEmpty => this == AttendanceRecordModel.empty;
  bool get isNotEmpty => this != AttendanceRecordModel.empty;

  AttendanceRecordModel copyWith({
    String? id,
    DateTime? date,
    String? lectureTitle,
    Map<String, String>? presentStudentIds,
    Map<String, String>? absentStudentIds,
    Map<String, String>? studentNotes,
    DateTime? createdAt,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      lectureTitle: lectureTitle ?? this.lectureTitle,
      presentStudentIds: presentStudentIds ?? this.presentStudentIds,
      absentStudentIds: absentStudentIds ?? this.absentStudentIds,
      studentNotes: studentNotes ?? this.studentNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      id: id,
      date: date,
      lectureTitle: lectureTitle,
      presentStudentIds: presentStudentIds,
      absentStudentIds: absentStudentIds,
      studentNotes: studentNotes,
      createdAt: createdAt,
    );
  }

  factory AttendanceRecordModel.fromEntity(AttendanceEntity entity) {
    return AttendanceRecordModel(
      id: entity.id,
      date: entity.date,
      lectureTitle: entity.lectureTitle,
      presentStudentIds: entity.presentStudentIds,
      absentStudentIds: entity.absentStudentIds,
      studentNotes: entity.studentNotes,
      createdAt: entity.createdAt,
    );
  }

  @override
  List<Object?> props() => [
        id,
        date,
        lectureTitle,
        presentStudentIds,
        absentStudentIds,
        studentNotes,
        createdAt,
      ];
}