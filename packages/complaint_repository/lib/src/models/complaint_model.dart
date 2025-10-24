import 'package:complaint_repository/complaint_repository.dart';
import 'package:equatable/equatable.dart';
class ComplaintModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status;
  final String studentID;
  final String studentName;
  final bool showStudentInfo; 
  final String targetRole; 
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminReply;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.studentID,
    required this.studentName,
    required this.showStudentInfo,
    required this.targetRole,
    required this.createdAt,
    this.updatedAt,
    this.adminReply,
  });

  static final empty = ComplaintModel(
    id: '',
    title: '',
    description: '',
    status: 'pending',
    studentID: '',
    studentName: '',
    showStudentInfo: true, 
    targetRole: 'Admin', 
    createdAt: DateTime.now(),
  );

  bool get isEmpty => this == ComplaintModel.empty;
  bool get isNotEmpty => this != ComplaintModel.empty;

  // دوال مساعدة للحالة
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isRejected => status == 'rejected';
  
  bool get hasAdminReply => adminReply != null && adminReply!.isNotEmpty;

  // نسخ الكائن مع تحديث بعض الخصائص
  ComplaintModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? studentID,
    String? studentName,
    bool? showStudentInfo,
    String? targetRole,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminReply,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      studentID: studentID ?? this.studentID,
      studentName: studentName ?? this.studentName,
      showStudentInfo: showStudentInfo ?? this.showStudentInfo,
      targetRole: targetRole ?? this.targetRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminReply: adminReply ?? this.adminReply,
    );
  }

  // التحويل إلى Entity
  ComplaintEntity toEntity() {
    return ComplaintEntity(
      id: id,
      title: title,
      description: description,
      status: status,
      studentID: studentID,
      studentName: studentName,
      showStudentInfo: showStudentInfo,
      targetRole: targetRole,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminReply: adminReply,
    );
  }

  // الإنشاء من Entity
  factory ComplaintModel.fromEntity(ComplaintEntity entity) {
    return ComplaintModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      studentID: entity.studentID,
      studentName: entity.studentName,
      showStudentInfo: entity.showStudentInfo,
      targetRole: entity.targetRole,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adminReply: entity.adminReply,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        studentID,
        studentName,
        showStudentInfo,
        targetRole,
        createdAt,
        updatedAt,
        adminReply,
      ];
}