import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudentHomeworkEntity extends Equatable {
  final String idStudent;
  final String name;
  final String file;
  final String title;
  final double fromMark;
  final DateTime? submitTime;

  const StudentHomeworkEntity({
    required this.idStudent,
    required this.name,
    required this.file,
    required this.title,
    required this.fromMark,
    this.submitTime,
  });

  Map<String, dynamic> toDocument() {
    return {
      'idStudent': idStudent,
      'name': name,
      'file': file,
      'title': title,
      'fromMark': fromMark,
      'submitTime': submitTime != null ? Timestamp.fromDate(submitTime!) : null,
    };
  }

  factory StudentHomeworkEntity.fromDocument(Map<String, dynamic> doc) {
    return StudentHomeworkEntity(
      idStudent: doc['idStudent'] as String,
      name: doc['name'] as String,
      file: doc['file'] as String,
      title: doc['title'] as String,
      fromMark: (doc['fromMark'] as num).toDouble(),
      submitTime: doc['submitTime'] != null ? (doc['submitTime'] as Timestamp).toDate() : null,
    );
  }

  @override
  List<Object?> props() => [idStudent, name, file, title, fromMark , submitTime];
}

class HomeworkEntity extends Equatable {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String file;
  final double maxMark;
  final List<StudentHomeworkEntity> students;

  const HomeworkEntity({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.file,
    required this.maxMark,
    this.students = const [],
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'description': description,
      'file': file,
      'maxMark': maxMark,
    };
  }

  factory HomeworkEntity.fromDocument(Map<String, dynamic> doc) {
    return HomeworkEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      start: (doc['start'] as Timestamp).toDate(),
      end: (doc['end'] as Timestamp).toDate(),
      description: doc['description'] as String,
      file: doc['file'] as String,
      maxMark: (doc['maxMark'] as num).toDouble(),
      students: [],
    );
  }

  @override
  List<Object?> props() => [id, title, start, end, description, file, maxMark, students];
}