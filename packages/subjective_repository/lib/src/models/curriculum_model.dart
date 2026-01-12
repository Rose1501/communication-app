import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class CurriculumModel extends Equatable {
  final String id;
  final String description;
  final DateTime time;
  final String file;
  

  const CurriculumModel({
    required this.id,
    required this.description,
    required this.time,
    required this.file,
  });

  static final empty = CurriculumModel(
    id: '',
    description: '',
    time: DateTime.now(),
    file: '',
  );

  bool get isEmpty => this == CurriculumModel.empty;
  bool get isNotEmpty => this != CurriculumModel.empty;

  CurriculumModel copyWith({
    String? id,
    String? description,
    DateTime? time,
    String? file,
  }) {
    return CurriculumModel(
      id: id ?? this.id,
      description: description ?? this.description,
      time: time ?? this.time,
      file: file ?? this.file,
    );
  }

  CurriculumEntity toEntity() {
    return CurriculumEntity(
      id: id,
      description: description,
      time: time,
      file: file,
    );
  }

  factory CurriculumModel.fromEntity(CurriculumEntity entity) {
    return CurriculumModel(
      id: entity.id,
      description: entity.description,
      time: entity.time,
      file: entity.file,
    );
  }

  @override
  List<Object?> props() => [id, description, time, file];
}