import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String idDoctor;
  final String nameDoctor;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.idDoctor,
    required this.nameDoctor,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'id_doctor': idDoctor,
      'name_doctor': nameDoctor,
    };
  }

  factory GroupEntity.fromDocument(Map<String, dynamic> doc) {
    return GroupEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      idDoctor: doc['id_doctor'] as String,
      nameDoctor: doc['name_doctor'] as String,
    );
  }

  @override
  List<Object?> props() => [id, name, idDoctor, nameDoctor];
}