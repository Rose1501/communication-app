import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SemesterEntity extends Equatable {
  final String id;
  final String typeSemester;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCredits;
  final int minCredits;

  const SemesterEntity({
    required this.id,
    required this.typeSemester,
    required this.startTime,
    required this.endTime,
    required this.maxCredits,
    required this.minCredits,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'type_semester': typeSemester,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'max_credits': maxCredits,
      'min_credits': minCredits,
    };
  }

  factory SemesterEntity.fromDocument(Map<String, dynamic> doc) {
    return SemesterEntity(
      id: doc['id'] as String,
      typeSemester: doc['type_semester'] as String,
      startTime: (doc['start_time'] as Timestamp).toDate(),
      endTime: (doc['end_time'] as Timestamp).toDate(),
      maxCredits: doc['max_credits'] as int,
      minCredits: doc['min_credits'] as int,
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
      ];
}