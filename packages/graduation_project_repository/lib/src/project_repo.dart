// lib/src/project_repository.dart
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:user_repository/user_repository.dart';

abstract class ProjectRepository {
  // === PROJECT SETTINGS METHODS ===
  /// جلب جميع إعدادات المشروع (الكود، قائمة الطلاب، المديرين)
  Future<ProjectSettingsModel> getProjectSettings();
  
  /// تحديث إعدادات المشروع
  Future<void> updateProjectSettings(ProjectSettingsModel settings);
  
  /// جلب كود الانضمام فقط
  Future<String> getJoinCode();
  
  /// تحديث كود الانضمام فقط
  Future<void> updateJoinCode(String newCode);
  
  /// إضافة طالب إلى القائمة العامة للطلاب
  Future<void> addStudentToProjectList(String studentId);
  
  /// إزالة طالب من القائمة العامة للطلاب
  Future<void> removeStudentFromProjectList(String studentId);
  
  /// جلب قائمة الطلاب في المشروع
  Future<List<String>> getStudentsInProjectList();
  
  /// إضافة مستخدم إداري
  Future<void> addAdminUser(UserModels user);
  
  /// جلب قائمة المستخدمين الإداريين
  Future<List<UserModels>> getAdminUsers();
  
  /// إزالة مستخدم إداري
  Future<void> removeAdminUser(String userId);
  // ================================

  // إدارة المشاريع
  Future<ProjectModel> createProject({
    required String title,
    required String description,
    required String projectType,
    required String projectGoals,
    required List<String> supervisors,
    required List<String> studentIds,
    required List<String> studentsName,
    required String attachmentFile,
  });

  Future<List<ProjectModel>> getAllProjects();
  Future<ProjectModel> getProjectById(String projectId);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId);

  // إدارة المهام
  Future<void> addTask(TaskModel task);
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> getTaskById(String taskId);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);

  // إدارة تسليمات المهام
  Future<void> submitTask(TaskSubmissionModel submission);
  Future<List<TaskSubmissionModel>> getTaskSubmissions(String taskId);
  Future<void> gradeTaskSubmission({
  required String submissionId,
  required int grade,
  required String feedback,
  }); 

  // إدارة الإعلانات
  Future<void> addAnnouncement(AnnouncementModel announcement);
  Future<List<AnnouncementModel>> getAllAnnouncements();
  Future<AnnouncementModel> getAnnouncementById(String announcementId);
  Future<void> updateAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String announcementId);
}