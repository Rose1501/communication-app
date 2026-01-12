import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final List<String> requestCourses;
  final int credits;

  const CourseEntity({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.requestCourses,
    required this.credits,
  });

  // تحويل Entity إلى Map لـ Firebase
  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'code_cs': codeCs,
      'requset_courses': requestCourses,
      'credits': credits,
    };
  }

  // إنشاء Entity من Map من Firebase
  factory CourseEntity.fromDocument(Map<String, dynamic> doc) {
    // 🔥 إصلاح تحويل المتطلبات
  List<String> requestCourses = [];
  if (doc['request_courses'] != null) {
    if (doc['request_courses'] is List) {
      requestCourses = (doc['request_courses'] as List)
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
  }
    return CourseEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      codeCs: doc['code_cs'] as String,
      requestCourses: requestCourses,
      credits: doc['credits'] as int,
    );
  }

  @override
  List<Object?> props() => [
        id,
        name,
        codeCs,
        requestCourses,
        credits,
      ];

  CourseEntity copyWith({
    String? id,
    String? name,
    String? codeCs,
    List<String>? requestCourses,
    int? credits,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      codeCs: codeCs ?? this.codeCs,
      requestCourses: requestCourses ?? this.requestCourses,
      credits: credits ?? this.credits,
    );
  }
}