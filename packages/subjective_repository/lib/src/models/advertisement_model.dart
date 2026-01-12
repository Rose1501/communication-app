import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AdvertisementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String file;
  final bool isImportant;
  final DateTime? expiryDate;

  const AdvertisementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.file,
    this.isImportant = false,
    this.expiryDate,
  });

  static final empty = AdvertisementModel(
    id: '',
    title: '',
    description: '',
    time: DateTime(0),
    file: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  AdvertisementModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? time,
    String? file,
    bool? isImportant,
    DateTime? expiryDate,
  }) {
    return AdvertisementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      file: file ?? this.file,
      isImportant: isImportant ?? this.isImportant,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  AdvertisementEntity toEntity() {
    return AdvertisementEntity(
      id: id,
      title: title,
      description: description,
      time: time,
      file: file,
      isImportant: isImportant,
      expiryDate: expiryDate,
    );
  }
  factory AdvertisementModel.fromEntity(AdvertisementEntity entity) {
    return AdvertisementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      time: entity.time,
      file: entity.file,
      isImportant: entity.isImportant,
      expiryDate: entity.expiryDate,
    );
  }

  @override
  List<Object?> props() => [id, title, description, time, file, isImportant, expiryDate];
}