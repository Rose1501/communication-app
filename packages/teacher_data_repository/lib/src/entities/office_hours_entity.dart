import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class OfficeHoursEntity extends Equatable {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final DateTime createdAt;

  const OfficeHoursEntity({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OfficeHoursEntity.fromDocument(Map<String, dynamic> doc) {
    return OfficeHoursEntity(
      id: doc['id'] as String,
      dayOfWeek: doc['dayOfWeek'] as String,
      startTime: doc['startTime'] as String,
      endTime: doc['endTime'] as String,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> props() => [
        id,
        dayOfWeek,
        startTime,
        endTime,
        createdAt,
      ];
}