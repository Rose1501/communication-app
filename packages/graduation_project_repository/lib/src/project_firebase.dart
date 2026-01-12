import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:math';

class FirebaseProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final DocumentReference _projectSettingsDoc;

  FirebaseProjectRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _projectSettingsDoc = (firestore ?? FirebaseFirestore.instance)
            .collection('projects')
            .doc('projects1'); // document name projects1

  // === PROJECT SETTINGS IMPLEMENTATION ===
  @override
  Future<ProjectSettingsModel> getProjectSettings() async {
    try {
      print('🔄 جلب إعدادات المشروع من Firestore');
      final doc = await _projectSettingsDoc.get();
      
      if (!doc.exists) {
        print('⚠️ FirebaseProjectRepository: المستند غير موجود، إنشاء إعدادات افتراضية...');
        return await _createDefaultProjectSettings();
      }
      print('✅ FirebaseProjectRepository: تم جلب المستند بنجاح');
      print('🔍 FirebaseProjectRepository: بيانات المستند: ${doc.data()}');
      print('${ProjectSettingsEntity.fromDocument(doc.data() as Map<String, dynamic>).toDocument()}');
      final entity = ProjectSettingsEntity.fromDocument(
          doc.data() as Map<String, dynamic>);
      
      print('✅ FirebaseProjectRepository: تم تحويل البيانات إلى Entity');
    final model = ProjectSettingsModel.fromEntity(entity);
    print('✅ FirebaseProjectRepository: تم تحويل البيانات إلى Model');
    print('🔍 FirebaseProjectRepository: كود الانضمام: ${model.joinCode}');
    print('🔍 FirebaseProjectRepository: عدد الطلاب: ${model.studentList.length}');
    print('🔍 FirebaseProjectRepository: عدد المشرفين: ${model.adminUsers.length}');
    return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProjectSettings(ProjectSettingsModel settings) async {
    try {
      await _projectSettingsDoc.set(settings.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getJoinCode() async {
    try {
      final settings = await getProjectSettings();
      return settings.joinCode;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateJoinCode(String newCode) async {
    try {
      final currentSettings = await getProjectSettings();
      final updatedSettings = currentSettings.copyWith(joinCode: newCode);
      await updateProjectSettings(updatedSettings);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addStudentToProjectList(String studentId) async {
    try {
      final currentSettings = await getProjectSettings();
      if (!currentSettings.studentList.contains(studentId)) {
        final updatedStudentList = [...currentSettings.studentList, studentId];
        final updatedSettings = currentSettings.copyWith(
          studentList: updatedStudentList,
        );
        await updateProjectSettings(updatedSettings);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeStudentFromProjectList(String studentId) async {
    try {
      final currentSettings = await getProjectSettings();
      if (currentSettings.studentList.contains(studentId)) {
        final updatedStudentList = List<String>.from(currentSettings.studentList)
          ..remove(studentId);
        final updatedSettings = currentSettings.copyWith(
          studentList: updatedStudentList,
        );
        await updateProjectSettings(updatedSettings);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getStudentsInProjectList() async {
    try {
      final settings = await getProjectSettings();
      return settings.studentList;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addAdminUser(UserModels user) async {
    try {
      final currentSettings = await getProjectSettings();
      final userExists = currentSettings.adminUsers
          .any((admin) => admin.userID == user.userID);
      
      if (!userExists) {
        final updatedAdminUsers = [...currentSettings.adminUsers, user];
        final updatedSettings = currentSettings.copyWith(
          adminUsers: updatedAdminUsers,
        );
        await updateProjectSettings(updatedSettings);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserModels>> getAdminUsers() async {
    try {
      final settings = await getProjectSettings();
      return settings.adminUsers;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeAdminUser(String userId) async {
    try {
      final currentSettings = await getProjectSettings();
      final userExists = currentSettings.adminUsers
          .any((user) => user.userID == userId);
      
      if (userExists) {
        final updatedAdminUsers = currentSettings.adminUsers
            .where((user) => user.userID != userId)
            .toList();
        final updatedSettings = currentSettings.copyWith(
          adminUsers: updatedAdminUsers,
        );
        await updateProjectSettings(updatedSettings);
      }
    } catch (e) {
      rethrow;
    }
  }

  // إنشاء إعدادات مشروع افتراضية
  Future<ProjectSettingsModel> _createDefaultProjectSettings() async {
    final defaultSettings = ProjectSettingsModel(
      joinCode: _generateJoinCode(),
      studentList: [],
      adminUsers: [],
    );
    
    await _projectSettingsDoc.set(defaultSettings.toEntity().toDocument());
    
    return defaultSettings;
  }
  // =====================================

  @override
  Future<ProjectModel> createProject({
    required String title,
    required String description,
    required String projectType,
    required String projectGoals,
    required List<String> supervisors,
    required List<String> studentIds,
    required List<String> studentsName,
    required String attachmentFile,
  }) async {
    try {
      final newProjectRef = _projectSettingsDoc.collection('project').doc();
      final project = ProjectModel(
        id: newProjectRef.id,
        title: title,
        description: description,
        projectType: projectType,
        projectGoals: projectGoals,
        supervisors: supervisors,
        studentIds: studentIds,
        studentsName: studentsName,
        attachmentFile: attachmentFile,
        createdAt: DateTime.now(),
      );

      // 1. إنشاء وثيقة المشروع
      await newProjectRef.set(project.toEntity().toDocument());

      // 2. إضافة جميع الطلاب في هذا المشروع إلى القائمة العامة
      for (final studentId in studentIds) {
        await addStudentToProjectList(studentId);
      }

      return project;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final querySnapshot = await _projectSettingsDoc.collection('project').get();
      return querySnapshot.docs
          .map((doc) => ProjectModel.fromEntity(ProjectEntity.fromDocument(doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProjectModel> getProjectById(String projectId) async {
    try {
      final doc = await _projectSettingsDoc.collection('project').doc(projectId).get();
      if (!doc.exists) {
        throw Exception('المشروع غير موجود');
      }
      return ProjectModel.fromEntity(ProjectEntity.fromDocument(doc.data() as Map<String, dynamic>));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    try {
      // الحصول على المشروع الحالي لمعرفة الطلاب القدامى
      final oldProject = await getProjectById(project.id);
      final oldStudentIds = oldProject.studentIds;
      final newStudentIds = project.studentIds;

      // تحديث المشروع
      await _projectSettingsDoc
          .collection('project')
          .doc(project.id)
          .update(project.toEntity().toDocument());

      // تحديث القائمة العامة للطلاب
      // إضافة الطلاب الجدد
      for (final studentId in newStudentIds) {
        if (!oldStudentIds.contains(studentId)) {
          await addStudentToProjectList(studentId);
        }
      }
      
      // إزالة الطلاب الذين لم يعودوا في المشروع
      for (final studentId in oldStudentIds) {
        if (!newStudentIds.contains(studentId)) {
          // تحقق إذا كان الطالب موجود في مشاريع أخرى قبل إزالته
          final projectsWithStudent = await _projectSettingsDoc
              .collection('project')
              .where('studentIds', arrayContains: studentId)
              .get();
          
          if (projectsWithStudent.docs.isEmpty) {
            await removeStudentFromProjectList(studentId);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      // الحصول على المشروع لمعرفة الطلاب
      final project = await getProjectById(projectId);
      final studentIds = project.studentIds;

      // حذف جميع المهام المرتبطة بالمشروع
      final tasksSnapshot = await _projectSettingsDoc
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (var taskDoc in tasksSnapshot.docs) {
        final submissionsSnapshot = await taskDoc.reference.collection('submissions').get();
        for (var submissionDoc in submissionsSnapshot.docs) {
          await submissionDoc.reference.delete();
        }
        await taskDoc.reference.delete();
      }
      
      // حذف جميع الإعلانات المرتبطة بالمشروع
      final announcementsSnapshot = await _projectSettingsDoc
          .collection('announcements')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (var announcementDoc in announcementsSnapshot.docs) {
        await announcementDoc.reference.delete();
      }
      
      // حذف المشروع نفسه
      await _projectSettingsDoc.collection('project').doc(projectId).delete();

      // تحديث القائمة العامة للطلاب
      for (final studentId in studentIds) {
        // تحقق إذا كان الطالب موجود في مشاريع أخرى قبل إزالته
        final projectsWithStudent = await _projectSettingsDoc
            .collection('project')
            .where('studentIds', arrayContains: studentId)
            .get();
        
        if (projectsWithStudent.docs.isEmpty) {
          await removeStudentFromProjectList(studentId);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await _projectSettingsDoc
          .collection('tasks')
          .doc(task.id)
          .set(task.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final querySnapshot = await _projectSettingsDoc.collection('tasks').get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromEntity(TaskEntity.fromDocument(doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final doc = await _projectSettingsDoc.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        throw Exception('المهمة غير موجودة');
      }
      return TaskModel.fromEntity(TaskEntity.fromDocument(doc.data() as Map<String, dynamic>));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _projectSettingsDoc
          .collection('tasks')
          .doc(task.id)
          .update(task.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final taskRef = _projectSettingsDoc.collection('tasks').doc(taskId);
      final submissionsSnapshot = await taskRef.collection('submissions').get();
      
      for (var submissionDoc in submissionsSnapshot.docs) {
        await submissionDoc.reference.delete();
      }
      
      await taskRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitTask(TaskSubmissionModel submission) async {
    try {
      // التأكد من وجود taskId في النموذج
      if (submission.id.isEmpty) {
        throw Exception('taskId مطلوب لتسليم المهمة');
      }
      
      await _projectSettingsDoc
          .collection('tasks')
          .doc(submission.taskId)
          .collection('submissions')
          .doc(submission.studentId)
          .set(submission.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TaskSubmissionModel>> getTaskSubmissions(String taskId) async {
    try {
      final querySnapshot = await _projectSettingsDoc
          .collection('tasks')
          .doc(taskId)
          .collection('submissions')
          .get();
      return querySnapshot.docs
          .map((doc) => TaskSubmissionModel.fromEntity(TaskSubmissionEntity.fromDocument(doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> gradeTaskSubmission({
  required String submissionId,
  required int grade,
  required String feedback,
}) async {
  try {
    // تقسيم معرف التسليم للحصول على معرف المهمة ومعرف الطالب
    final parts = submissionId.split('_');
    if (parts.length < 2) return;
    
    final taskId = parts.sublist(0, parts.length - 1).join('_');
    final studentId = parts.last;
    
    await _projectSettingsDoc
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(studentId)
        .update({
          'isGraded': true,
          'grade': grade,
          'feedback': feedback,
        });
  } catch (e) {
    rethrow;
  }
}

  @override
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _projectSettingsDoc
          .collection('announcements')
          .doc(announcement.id)
          .set(announcement.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final querySnapshot = await _projectSettingsDoc.collection('announcements').get();
      return querySnapshot.docs
          .map((doc) => AnnouncementModel.fromEntity(AnnouncementEntity.fromDocument(doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnnouncementModel> getAnnouncementById(String announcementId) async {
    try {
      final doc = await _projectSettingsDoc.collection('announcements').doc(announcementId).get();
      if (!doc.exists) {
        throw Exception('الإعلان غير موجود');
      }
      return AnnouncementModel.fromEntity(AnnouncementEntity.fromDocument(doc.data() as Map<String, dynamic>));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _projectSettingsDoc
          .collection('announcements')
          .doc(announcement.id)
          .update(announcement.toEntity().toDocument());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _projectSettingsDoc.collection('announcements').doc(announcementId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // دالة مساعدة لإنشاء كود انضمام عشوائي
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}