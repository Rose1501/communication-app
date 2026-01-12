part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> props() => [];
}

class CreateProject extends ProjectEvent {
  final String title;
  final String description;
  final String projectType;
  final String projectGoals;
  final List<String> supervisors;
  final List<String> studentIds;
  final List<String> studentsName;
  final String? attachmentFile;

  const CreateProject({
    required this.title,
    required this.description,
    required this.projectType,
    required this.projectGoals,
    required this.supervisors,
    required this.studentIds,
    required this.studentsName,
    this.attachmentFile,
  });

  @override
  List<Object> props() => [
        title,
        description,
        projectType,
        projectGoals,
        supervisors,
        studentIds,
        studentsName,
        attachmentFile ?? '',
      ];
}

class JoinProject extends ProjectEvent {
  final String joinCode;
  final String studentId;

  const JoinProject({
    required this.joinCode,
    required this.studentId,
  });

  @override
  List<Object> props() => [joinCode, studentId];
}

class LoadProjectsForUser extends ProjectEvent {
  final String userId;

  const LoadProjectsForUser({required this.userId});

  @override
  List<Object> props() => [userId];
}

class LoadProjectDetails extends ProjectEvent {
  final String projectId;

  const LoadProjectDetails({required this.projectId});

  @override
  List<Object> props() => [projectId];
}

class AddSupervisor extends ProjectEvent {
  final String projectId;
  final String supervisorId;

  const AddSupervisor({
    required this.projectId,
    required this.supervisorId,
  });

  @override
  List<Object> props() => [projectId, supervisorId];
}

class AddTask extends ProjectEvent {
  final TaskModel task;

  const AddTask({required this.task});

  @override
  List<Object> props() => [task];
}

class AddAnnouncement extends ProjectEvent {
  final AnnouncementModel announcement;

  const AddAnnouncement({required this.announcement});

  @override
  List<Object> props() => [announcement];
}

class LoadAllProjects extends ProjectEvent {}

class UpdateJoinCode extends ProjectEvent {
  final String newJoinCode;

  const UpdateJoinCode({required this.newJoinCode});

  @override
  List<Object> props() => [newJoinCode];
}

class UpdateSupervisors extends ProjectEvent {
  final String projectId;
  final List<String> newSupervisorIds;

  const UpdateSupervisors({required this.projectId, required this.newSupervisorIds});

  @override
  List<Object> props() => [projectId, newSupervisorIds];
}

class GenerateJoinCodeEvent extends ProjectEvent {
  const GenerateJoinCodeEvent();
}

class LoadAllTasks extends ProjectEvent {
  const LoadAllTasks();
}

class LoadAllAnnouncements extends ProjectEvent {
  const LoadAllAnnouncements();
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  const DeleteProject({required this.projectId});

  @override
  List<Object> props() => [projectId];
}

class UpdateProject extends ProjectEvent {
  final ProjectModel project;

  const UpdateProject({required this.project});

  @override
  List<Object> props() => [project];
}

class GetProjectSettings extends ProjectEvent {
  const GetProjectSettings();
}

class UpdateProjectSettings extends ProjectEvent {
  final ProjectSettingsModel settings;

  const UpdateProjectSettings({required this.settings});

  @override
  List<Object> props() => [settings];
}

class AddStudentToProjectList extends ProjectEvent {
  final String studentId;

  const AddStudentToProjectList({required this.studentId});

  @override
  List<Object> props() => [studentId];
}

class RemoveStudentFromProjectList extends ProjectEvent {
  final String studentId;

  const RemoveStudentFromProjectList({required this.studentId});

  @override
  List<Object> props() => [studentId];
}

class AddAdminUser extends ProjectEvent {
  final UserModels user;

  const AddAdminUser({required this.user});

  @override
  List<Object> props() => [user];
}

class RemoveAdminUser extends ProjectEvent {
  final String userId;

  const RemoveAdminUser({required this.userId});

  @override
  List<Object> props() => [userId];
}

// تعديل إعلان
class UpdateAnnouncement extends ProjectEvent {
  final AnnouncementModel announcement;

  const UpdateAnnouncement({required this.announcement});

  @override
  List<Object> props() => [announcement];
}

// حذف إعلان
class DeleteAnnouncement extends ProjectEvent {
  final String announcementId;

  const DeleteAnnouncement({required this.announcementId});

  @override
  List<Object> props() => [announcementId];
}

// تعديل مهمة
class UpdateTask extends ProjectEvent {
  final TaskModel task;

  const UpdateTask({required this.task});

  @override
  List<Object> props() => [task];
}

// حذف مهمة
class DeleteTask extends ProjectEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object> props() => [taskId];
}

// تحميل تسليمات المهمة
class LoadTaskSubmissions extends ProjectEvent {
  final String taskId;

  const LoadTaskSubmissions({required this.taskId});

  @override
  List<Object> props() => [taskId];
}

// تسليم مهمة
class SubmitTask extends ProjectEvent {
  final TaskSubmissionModel submission;

  const SubmitTask({required this.submission});

  @override
  List<Object> props() => [submission];
}

// تقييم تسليم المهمة
class GradeTaskSubmission extends ProjectEvent {
  final String submissionId;
  final int grade;
  final String feedback;

  const GradeTaskSubmission({
    required this.submissionId,
    required this.grade,
    required this.feedback,
  });

  @override
  List<Object> props() => [submissionId, grade, feedback];
}