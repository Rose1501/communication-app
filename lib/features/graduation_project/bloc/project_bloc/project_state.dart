part of 'project_bloc.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object> props() => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<ProjectModel> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object> props() => [projects];
}

class ProjectDetailsLoaded extends ProjectState {
  final ProjectModel project;
  final List<TaskModel> tasks;
  final List<AnnouncementModel> announcements;

  const ProjectDetailsLoaded({
    required this.project,
    required this.tasks,
    required this.announcements,
  });

  @override
  List<Object> props() => [project, tasks, announcements];
}

class ProjectOperationSuccess extends ProjectState {
  final String message;

  const ProjectOperationSuccess({this.message = "تمت العملية بنجاح"});

  @override
  List<Object> props() => [message];
}

class ProjectError extends ProjectState {
  final String error;

  const ProjectError(this.error);

  @override
  List<Object> props() => [error];
}

class JoinCodeGenerated extends ProjectState {
  final String joinCode;
  const JoinCodeGenerated(this.joinCode);

  @override
  List<Object> props() => [joinCode];
}

class TasksLoaded extends ProjectState {
  final List<TaskModel> tasks;
  const TasksLoaded(this.tasks);

  @override
  List<Object> props() => [tasks];
}

class AnnouncementsLoaded extends ProjectState {
  final List<AnnouncementModel> announcements;
  const AnnouncementsLoaded(this.announcements);

  @override
  List<Object> props() => [announcements];
}

class ProjectSettingsLoaded extends ProjectState {
  final ProjectSettingsModel settings;
  const ProjectSettingsLoaded(this.settings);

  @override
  List<Object> props() => [settings];
}

class TaskSubmissionsLoaded extends ProjectState {
  final List<TaskSubmissionModel> submissions;

  const TaskSubmissionsLoaded(this.submissions);

  @override
  List<Object> props() => [submissions];
}

class TaskSubmissionOperationSuccess extends ProjectState {
  final String message;

  const TaskSubmissionOperationSuccess({required this.message});

  @override
  List<Object> props() => [message];
}