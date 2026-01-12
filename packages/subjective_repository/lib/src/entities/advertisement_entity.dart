import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AdvertisementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String file;
  final bool isImportant;
  final DateTime? expiryDate;

  const AdvertisementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.file,
    this.isImportant = false,
    this.expiryDate,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': Timestamp.fromDate(time),
      'file': file,
      'isImportant': isImportant,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  factory AdvertisementEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      // معالجة حقل الوقت
      Timestamp timestamp;
      if (doc['time'] is Timestamp) {
        timestamp = doc['time'] as Timestamp;
      } else if (doc['time'] is Map) {
        final timeMap = doc['time'] as Map<String, dynamic>;
        timestamp = Timestamp(timeMap['_seconds'] as int, timeMap['_nanoseconds'] as int);
      } else {
        timestamp = Timestamp.now();
      }

      // معالجة تاريخ الانتهاء
      Timestamp? expiryTimestamp;
      if (doc['expiryDate'] is Timestamp) {
        expiryTimestamp = doc['expiryDate'] as Timestamp;
      } else if (doc['expiryDate'] is Map) {
        final expiryMap = doc['expiryDate'] as Map<String, dynamic>;
        expiryTimestamp = Timestamp(expiryMap['_seconds'] as int, expiryMap['_nanoseconds'] as int);
      }

      return AdvertisementEntity(
        id: doc['id'] as String? ?? '',
        title: doc['title'] as String? ?? '',
        description: doc['description'] as String? ?? '',
        time: timestamp.toDate(),
        file: doc['file'] as String? ?? '',
        isImportant: doc['isImportant'] as bool? ?? false,
        expiryDate: expiryTimestamp?.toDate(),
      );
    } catch (e) {
      print('❌ خطأ في fromDocument للإعلان: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
  }

  @override
  List<Object?> props() => [id, title, description, time, file, isImportant, expiryDate];
}