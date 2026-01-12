import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

class StudentRequestModel extends Equatable {
  final String id;
  final String studentID;
  final String name;
  final String requestType;
  final String description;
  final String status;
  final DateTime dateTime;
  final String? adminReply;

  const StudentRequestModel({
    required this.id,
    required this.studentID,
    required this.name,
    required this.requestType,
    required this.description,
    required this.status,
    required this.dateTime,
    this.adminReply, 
  });

  static final empty = StudentRequestModel(
    id: '',
    studentID: '',
    name: '',
    requestType: '',
    description: '',
    status: 'انتظار',
    dateTime: DateTime.now(),
    adminReply: null,
  );

  bool get isEmpty => this == StudentRequestModel.empty;
  bool get isNotEmpty => this != StudentRequestModel.empty;

  // دالة لتحويل التاريخ إلى تنسيق مقروء
  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // دالة للحصول على تاريخ بدون وقت
  String get formattedDateOnly {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  StudentRequestModel copyWith({
    String? id,
    String? studentID,
    String? name,
    String? requestType,
    String? description,
    String? status,
    DateTime? dateTime,
    String? adminReply,
  }) {
    return StudentRequestModel(
      id: id ?? this.id,
      studentID: studentID ?? this.studentID,
      name: name ?? this.name,
      requestType: requestType ?? this.requestType,
      description: description ?? this.description,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      adminReply: adminReply ?? this.adminReply, 
    );
  }

  bool get isWaiting => status == 'انتظار';
  bool get isApproved => status == 'موافق';
  bool get isRejected => status == 'مرفوض';

  bool get hasAdminReply => adminReply != null && adminReply!.isNotEmpty;

  StudentRequestEntity toEntity() {
    return StudentRequestEntity(
      id: id ,
      studentID: studentID,
      name: name,
      dateTime: dateTime,
      status: status,
      requestType: requestType,
      description: description,
      adminReply: adminReply,
    );
  }

  factory StudentRequestModel.fromEntity(StudentRequestEntity entity) {
    return StudentRequestModel(
      id: entity.id,
      studentID: entity.studentID,
      name: entity.name,
      requestType: entity.requestType,
      description: entity.description,
      status: entity.status,
      dateTime: entity.dateTime,
      adminReply: entity.adminReply,
    );
  }

  @override
  List<Object?> props() => [
        id,
        studentID,
        name,
        requestType,
        description,
        status,
        dateTime,
        adminReply,
      ];

  @override
  String toString() {
    return 'StudentRequestModel{'
        'id: $id, '
        'studentID: $studentID, '
        'name: $name, '
        'requestType: $requestType, '
        'description: $description, '
        'status: $status, '
        'dateTime: $dateTime,'
        'adminReply: $adminReply}';
  }
}