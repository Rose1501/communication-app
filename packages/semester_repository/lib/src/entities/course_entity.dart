import 'package:equatable/equatable.dart';

class CoursesEntity extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final int numOfStudent;
  final String president;

  const CoursesEntity({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.numOfStudent,
    required this.president,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'code_cs': codeCs,
      'num_of_student': numOfStudent,
      'president': president,
    };
  }

  factory CoursesEntity.fromDocument(Map<String, dynamic> doc) {
    return CoursesEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      codeCs: doc['code_cs'] as String,
      numOfStudent: doc['num_of_student'] as int,
      president: doc['president'] as String,
    );
  }

  @override
  List<Object?> props() => [
        id,
        name,
        codeCs,
        numOfStudent,
        president,
      ];
}