// lib/src/models/project_settings_model.dart
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

class ProjectSettingsModel extends Equatable {
  final String joinCode;
  final List<String> studentList;
  final List<UserModels> adminUsers;

  const ProjectSettingsModel({
    required this.joinCode,
    required this.studentList,
    required this.adminUsers,
  });

  ProjectSettingsModel copyWith({
    String? joinCode,
    List<String>? studentList,
    List<UserModels>? adminUsers,
  }) {
    return ProjectSettingsModel(
      joinCode: joinCode ?? this.joinCode,
      studentList: studentList ?? this.studentList,
      adminUsers: adminUsers ?? this.adminUsers,
    );
  }

  ProjectSettingsEntity toEntity() {
    return ProjectSettingsEntity(
      joinCode: joinCode,
      studentList: studentList,
      adminUsers: adminUsers,
    );
  }

  factory ProjectSettingsModel.fromEntity(ProjectSettingsEntity entity) {
    print('🔍 ProjectSettingsModel.fromEntity: بدء تحويل الكيان');
    print('🔍 الكيان الأصلي: joinCode=${entity.joinCode}, studentList=${entity.studentList}, adminUsers=${entity.adminUsers.map((u) => u.name).toList()}');
    
    return ProjectSettingsModel(
      joinCode: entity.joinCode,
      studentList: entity.studentList,
      adminUsers: entity.adminUsers,
    );
  }

  @override
  List<Object?> props() => [joinCode, studentList, adminUsers];
}