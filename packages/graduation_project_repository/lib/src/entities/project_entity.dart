import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String projectGoals;
  final List<String> supervisors;
  final List<String> studentIds;
  final List<String> studentsName;
  final DateTime createdAt;
  final String? attachmentFile;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.projectGoals,
    required this.supervisors,
    required this.studentIds,
    required this.studentsName,
    required this.createdAt,
    this.attachmentFile,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectType': projectType,
      'projectGoals': projectGoals,
      'supervisors': supervisors,
      'studentIds': studentIds,
      'studentsName': studentsName,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachmentFile': attachmentFile,
    };
  }

  factory ProjectEntity.fromDocument(Map<String, dynamic> doc) {
    return ProjectEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String,
      projectType: doc['projectType'] as String,
      projectGoals: doc['projectGoals'] as String,
      supervisors: List<String>.from(doc['supervisors'] ?? []),
      studentIds: List<String>.from(doc['studentIds'] ?? []),
      studentsName: List<String>.from(doc['studentsName'] ?? []),
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      attachmentFile: doc['attachmentFile'] as String?,
    );
  }

  @override
  List<Object?> props() => [
        id,
        title,
        description,
        projectType,
        projectGoals,
        supervisors,
        studentIds,
        studentsName,
        createdAt,
      ];
}