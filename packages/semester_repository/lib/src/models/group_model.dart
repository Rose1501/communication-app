import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String idDoctor;
  final String nameDoctor;
  final List<StudentModel> students;

  const GroupModel({
    required this.id,
    required this.name,
    required this.idDoctor,
    required this.nameDoctor,
    this.students = const [],
  });

  static final empty = GroupModel(
    id: '',
    name: '',
    idDoctor: '',
    nameDoctor: '',
  );

  bool get isEmpty => this == GroupModel.empty;
  bool get isNotEmpty => this != GroupModel.empty;

  GroupModel copyWith({
    String? id,
    String? name,
    String? idDoctor,
    String? nameDoctor,
    List<StudentModel>? students,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      idDoctor: idDoctor ?? this.idDoctor,
      nameDoctor: nameDoctor ?? this.nameDoctor,
      students: students ?? this.students,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      idDoctor: idDoctor,
      nameDoctor: nameDoctor,
    );
  }

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      idDoctor: entity.idDoctor,
      nameDoctor: entity.nameDoctor,
    );
  }

  @override
  List<Object?> props() => [id, name, idDoctor, nameDoctor ,students];
}