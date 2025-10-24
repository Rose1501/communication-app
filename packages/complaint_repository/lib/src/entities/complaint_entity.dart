import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ComplaintEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, resolved, rejected
  final String studentID;
  final String studentName;
  final bool showStudentInfo; // عرض بيانات الطالب أم لا
  final String targetRole; //  الموجهة لأي دور (Admin, Manager)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminReply;

  const ComplaintEntity({
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

  // تحويل Entity إلى Map لـ Firebase
  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'studentID': studentID,
      'studentName': studentName,
      'showStudentInfo': showStudentInfo, 
      'targetRole': targetRole, 
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'adminReply': adminReply,
    };
  }

  // إنشاء Entity من Map من Firebase
  factory ComplaintEntity.fromDocument(Map<String, dynamic> doc) {
    return ComplaintEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String,
      status: doc['status'] as String,
      studentID: doc['studentID'] as String,
      studentName: doc['studentName'] as String,
      showStudentInfo: doc['showStudentInfo'] as bool, // 🔥 جديد
      targetRole: doc['targetRole'] as String, // 🔥 جديد
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      updatedAt: doc['updatedAt'] != null ? (doc['updatedAt'] as Timestamp).toDate() : null,
      adminReply: doc['adminReply'] as String?,
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