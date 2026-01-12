import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final DateTime date;
  final String lectureTitle;
  final Map<String, String> presentStudentIds; // studentId -> studentName
  final Map<String, String> absentStudentIds;  // studentId -> studentName
  final Map<String, String> studentNotes;      // studentId -> note
  final DateTime createdAt;

  const AttendanceEntity({
    required this.id,
    required this.date,
    required this.lectureTitle,
    required this.presentStudentIds,
    required this.absentStudentIds,
    required this.studentNotes,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'lectureTitle': lectureTitle,
      'presentStudentIds': presentStudentIds,
      'absentStudentIds': absentStudentIds,
      'studentNotes': studentNotes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AttendanceEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      // معالجة الحقول التي قد تكون null
      Map<String, String> presentStudentIds = {};
      if (doc['presentStudentIds'] != null) {
        final presentMap = doc['presentStudentIds'] as Map<String, dynamic>;
        presentStudentIds = presentMap.map((key, value) => MapEntry(key, value.toString()));
      }

      Map<String, String> absentStudentIds = {};
      if (doc['absentStudentIds'] != null) {
        final absentMap = doc['absentStudentIds'] as Map<String, dynamic>;
        absentStudentIds = absentMap.map((key, value) => MapEntry(key, value.toString()));
      }

      Map<String, String> studentNotes = {};
      if (doc['studentNotes'] != null) {
        final notesMap = doc['studentNotes'] as Map<String, dynamic>;
        studentNotes = notesMap.map((key, value) => MapEntry(key, value.toString()));
      }

      return AttendanceEntity(
        id: doc['id'] as String? ?? '',
        date: (doc['date'] as Timestamp).toDate(),
        lectureTitle: doc['lectureTitle'] as String? ?? '',
        presentStudentIds: presentStudentIds,
        absentStudentIds: absentStudentIds,
        studentNotes: studentNotes,
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('❌ خطأ في fromDocument لسجل الحضور: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
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