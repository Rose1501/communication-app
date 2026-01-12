import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class CoursesModel extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final int numOfStudent;
  final String president;
  final List<GroupModel> groups;

  const CoursesModel({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.numOfStudent,
    required this.president,
    this.groups = const [],
  });

  static final empty = CoursesModel(
    id: '',
    name: '',
    codeCs: '',
    numOfStudent: 0,
    president: '',
  );

  bool get isEmpty => this == CoursesModel.empty;
  bool get isNotEmpty => this != CoursesModel.empty;

  CoursesModel copyWith({
    String? id,
    String? name,
    String? codeCs,
    int? numOfStudent,
    String? president,
    List<GroupModel>? groups,
  }) {
    return CoursesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      codeCs: codeCs ?? this.codeCs,
      numOfStudent: numOfStudent ?? this.numOfStudent,
      president: president ?? this.president,
      groups: groups ?? this.groups,
    );
  }

  CoursesEntity toEntity() {
    return CoursesEntity(
      id: id,
      name: name,
      codeCs: codeCs,
      numOfStudent: numOfStudent,
      president: president,
    );
  }

  factory CoursesModel.fromEntity(CoursesEntity entity) {
    return CoursesModel(
      id: entity.id,
      name: entity.name,
      codeCs: entity.codeCs,
      numOfStudent: entity.numOfStudent,
      president: entity.president,
    );
  }

  @override
  List<Object?> props() => [
        id,
        name,
        codeCs,
        numOfStudent,
        president,
        groups,
      ];
}