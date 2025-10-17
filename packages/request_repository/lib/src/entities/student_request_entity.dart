import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudentRequestEntity extends Equatable {
  final String id;
  final String studentID;
  final String name;
  final DateTime dateTime;
  final String status;
  final String requestType;
  final String description;
  final String? adminReply;

  const StudentRequestEntity({
    required this.id,
    required this.studentID,
    required this.name,
    required this.dateTime,
    required this.status,
    required this.requestType,
    required this.description,
    this.adminReply,
  });

  // تحويل Entity إلى Map لـ Firebase
  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'studentID': studentID,
      'name': name,
      'dateTime': dateTime,
      'status': status,
      'requestType': requestType,
      'description': description,
      'adminReply': adminReply,
    };
  }

  // إنشاء Entity من Map من Firebase
  factory StudentRequestEntity.fromDocument(Map<String, dynamic> doc) {
    return StudentRequestEntity(
      id: doc['id'] as String,
      studentID: doc['studentID'] as String,
      name: doc['name'] as String,
      dateTime: (doc['dateTime'] as Timestamp).toDate(),
      status: doc['status'] as String,
      requestType: doc['requestType'] as String,
      description: doc['description'] as String,
      adminReply: doc['adminReply'] as String?,
    );
  }

  // دوال مساعدة للتحقق من الحالة
  bool get isPending => status == 'انتظار';
  bool get isApproved => status == 'موافق';
  bool get isRejected => status == 'مرفوض';

  bool get hasAdminReply => adminReply != null && adminReply!.isNotEmpty;


  @override
  List<Object?> get props => [
        id,
        studentID,
        name,
        dateTime,
        status,
        requestType,
        description,
        adminReply,
      ];

  @override
  String toString() {
    return 'StudentRequestEntity('
        'id: $id, '
        'studentID: $studentID, '
        'name: $name, '
        'dateTime: $dateTime, '
        'status: $status, '
        'requestType: $requestType, '
        'description: $description, '
        'adminReply: $adminReply)'; 
  }
}