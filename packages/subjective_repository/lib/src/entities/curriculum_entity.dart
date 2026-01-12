import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CurriculumEntity extends Equatable {
  final String id;
  final String description;
  final DateTime time;
  final String file;

  const CurriculumEntity({
    required this.id,
    required this.description,
    required this.time,
    required this.file,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'description': description,
      'time': Timestamp.fromDate(time),
      'file': file,
    };
  }

  factory CurriculumEntity.fromDocument(Map<String, dynamic> doc) {
  try {
    print('🏗️ بناء CurriculumEntity من المستند: ${doc['id']}');
    
    // معالجة حقل الوقت
    Timestamp timestamp;
    if (doc['time'] is Timestamp) {
      timestamp = doc['time'] as Timestamp;
    } else if (doc['time'] is Map) {
      // إذا كان الوقت مخزناً كـ Map (من Firestore)
      final timeMap = doc['time'] as Map<String, dynamic>;
      timestamp = Timestamp(timeMap['_seconds'] as int, timeMap['_nanoseconds'] as int);
    } else {
      print('❌ نوع غير معروف لحقل time: ${doc['time'].runtimeType}');
      timestamp = Timestamp.now();
    }
    
    return CurriculumEntity(
      id: doc['id'] as String? ?? '',
      description: doc['description'] as String? ?? '',
      time: timestamp.toDate(),
      file: doc['file'] as String? ?? '',
    );
  } catch (e) {
    print('❌ خطأ في fromDocument: $e');
    print('📋 بيانات المستند: $doc');
    rethrow;
  }
}

  @override
  List<Object?> props() => [id, description, time, file];
}