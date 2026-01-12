import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:equatable/equatable.dart';

class OfficeHoursModel extends Equatable {
  final String id;            // 1. المعرف الفريد
  final String dayOfWeek;     // 2. يوم الأسبوع
  final String startTime;     // 3. وقت البدء
  final String endTime;       // 4. وقت الانتهاء
  final DateTime createdAt;   // 5. تاريخ الإنشاء

  const OfficeHoursModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  static final empty = OfficeHoursModel(
    id: '',
    dayOfWeek: '',
    startTime: '',
    endTime: '',
    createdAt: DateTime.now(),
  );

  bool get isEmpty => this == OfficeHoursModel.empty;
  bool get isNotEmpty => this != OfficeHoursModel.empty;

  String get timeRange => '$startTime - $endTime';

  OfficeHoursModel copyWith({
    String? id,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) {
    return OfficeHoursModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  OfficeHoursEntity toEntity() {
    return OfficeHoursEntity(
      id: id,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
    );
  }

  factory OfficeHoursModel.fromEntity(OfficeHoursEntity entity) {
    return OfficeHoursModel(
      id: entity.id,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      createdAt: entity.createdAt,
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