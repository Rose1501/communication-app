import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

class ProjectSettingsEntity extends Equatable {
  final String joinCode;
  final List<String> studentList;
  final List<UserModels> adminUsers;

  const ProjectSettingsEntity({
    required this.joinCode,
    required this.studentList,
    required this.adminUsers,
  });

  Map<String, dynamic> toDocument() {
    return {
      'joinCode': joinCode,
      'studentList': studentList,
      'adminUsers': adminUsers.map((user) => user.toEntity().toDocument(),).toList(),
    };
  }

  factory ProjectSettingsEntity.fromDocument(Map<String, dynamic> doc) {
    print('🔍 ProjectSettingsEntity.fromDocument: بدء تحويل البيانات');
    print('🔍 البيانات الأصلية: $doc');
    // تحويل قائمة الطلاب
    final List<String> studentList = List<String>.from(doc['studentList'] ?? []);
    print('🔍 قائمة الطلاب: $studentList');
    // تحويل قائمة المشرفين
    final List<UserModels> adminUsers = [];
    if (doc['adminUsers'] != null) {
      final List<dynamic> adminUsersData = List<dynamic>.from(doc['adminUsers']);
      print('🔍 بيانات المشرفين الخام: $adminUsersData');
      
      for (final userData in adminUsersData) {
        if (userData is Map<String, dynamic>) {
          try {
            final userEntity = UserEntities.fromDocument(userData);
            final userModel = UserModels.fromEntity(userEntity);
            adminUsers.add(userModel);
            print('✅ تم تحويل مشرف: ${userModel.name}');
          } catch (e) {
            print('❌ خطأ في تحويل مشرف: $e');
          }
        }
      }
    }
    print('🔍 قائمة المشرفين المحولة: ${adminUsers.map((u) => u.name).toList()}');
    
    return ProjectSettingsEntity(
      joinCode: doc['joinCode'] as String,
      studentList: studentList,
      adminUsers: adminUsers,
    );
  }

  @override
  List<Object?> props() => [joinCode, studentList, adminUsers];
}