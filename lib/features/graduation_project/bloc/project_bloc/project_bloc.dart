import 'dart:io';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _projectRepository;

  ProjectBloc({required ProjectRepository projectRepository})
      : _projectRepository = projectRepository,
        super(ProjectInitial()) {
    on<CreateProject>(_onCreateProject);
    on<JoinProject>(_onJoinProject);
    on<LoadProjectsForUser>(_onLoadProjectsForUser);
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<AddSupervisor>(_onAddSupervisor);
    on<AddTask>(_onAddTask);
    on<AddAnnouncement>(_onAddAnnouncement);
    on<LoadAllProjects>(_onLoadAllProjects);
    on<UpdateJoinCode>(_onUpdateJoinCode);
    on<UpdateSupervisors>(_onUpdateSupervisors);
    on<GenerateJoinCodeEvent>(_onGenerateJoinCode);
    on<LoadAllTasks>(_onLoadAllTasks);
    on<LoadAllAnnouncements>(_onLoadAllAnnouncements);
    on<DeleteProject>(_onDeleteProject);
    on<UpdateProject>(_onUpdateProject);
    on<GetProjectSettings>(_onGetProjectSettings);
    on<UpdateProjectSettings>(_onUpdateProjectSettings);
    on<AddStudentToProjectList>(_onAddStudentToProjectList);
    on<RemoveStudentFromProjectList>(_onRemoveStudentFromProjectList);
    on<AddAdminUser>(_onAddAdminUser);
    on<RemoveAdminUser>(_onRemoveAdminUser);
    on<UpdateAnnouncement>(_onUpdateAnnouncement);
    on<DeleteAnnouncement>(_onDeleteAnnouncement);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<LoadTaskSubmissions>(_onLoadTaskSubmissions);
    on<SubmitTask>(_onSubmitTask);
    on<GradeTaskSubmission>(_onGradeTaskSubmission);
  }

  // إنشاء مشروع جديد
  Future<void> _onCreateProject(CreateProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      await _projectRepository.createProject(
        title: event.title,
        description: event.description,
        projectType: event.projectType,
        projectGoals: event.projectGoals,
        supervisors: event.supervisors,
        studentIds: event.studentIds,
        studentsName: event.studentsName,
        attachmentFile: event.attachmentFile ?? '',
      );
      emit(ProjectOperationSuccess(message: 'تم إنشاء المشروع بنجاح'));
      // إعادة تحميل قائمة المشاريع
      add(LoadAllProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // انضمام طالب إلى مشروع باستخدام كود الانضمام
  Future<void> _onJoinProject(JoinProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      // الحصول على إعدادات المشروع للتحقق من الكود
      final settings = await _projectRepository.getProjectSettings();
      
      // التحقق من كود الانضمام
      if (settings.joinCode != event.joinCode) {
        emit(ProjectError('كود الانضمام غير صحيح'));
        return;
      }
      
      // إضافة الطالب إلى قائمة المشروع
      await _projectRepository.addStudentToProjectList(event.studentId);
      
      emit(ProjectOperationSuccess(message: 'تم الانضمام للمشروع بنجاح'));
      add(LoadProjectsForUser(userId: event.studentId));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحميل المشاريع الخاصة بمستخدم معين
  Future<void> _onLoadProjectsForUser(LoadProjectsForUser event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final allProjects = await _projectRepository.getAllProjects();
      
      // تصفية المشاريع التي ينتمي إليها المستخدم
      final userProjects = allProjects.where((project) => 
        project.studentIds.contains(event.userId) || 
        project.supervisors.contains(event.userId)
      ).toList();
      
      emit(ProjectsLoaded(userProjects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحميل تفاصيل مشروع معين
  Future<void> _onLoadProjectDetails(LoadProjectDetails event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final project = await _projectRepository.getProjectById(event.projectId);
      final allTasks = await _projectRepository.getAllTasks();
      final allAnnouncements = await _projectRepository.getAllAnnouncements();
      
      // تصفية المهام والإعلانات الخاصة بالمشروع
      final projectTasks = allTasks.where((task) => task.id == event.projectId).toList();
      final projectAnnouncements = allAnnouncements.where((announcement) => announcement.id == event.projectId).toList();
      
      emit(ProjectDetailsLoaded(
        project: project,
        tasks: projectTasks,
        announcements: projectAnnouncements,
      ));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إضافة مشرف إلى مشروع
  Future<void> _onAddSupervisor(AddSupervisor event, Emitter<ProjectState> emit) async {
    try {
      final project = await _projectRepository.getProjectById(event.projectId);
      final updatedSupervisors = [...project.supervisors, event.supervisorId];
      
      final updatedProject = project.copyWith(supervisors: updatedSupervisors);
      await _projectRepository.updateProject(updatedProject);
      
      emit(ProjectOperationSuccess(message: 'تم إضافة المشرف بنجاح'));
      add(LoadProjectDetails(projectId: event.projectId));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إضافة مهمة جديدة
  Future<void> _onAddTask(AddTask event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.addTask(event.task);
      emit(ProjectOperationSuccess(message: 'تم إضافة المهمة بنجاح'));
      add(LoadAllTasks());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إضافة إعلان جديد
  Future<void> _onAddAnnouncement(AddAnnouncement event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.addAnnouncement(event.announcement); 
      emit(ProjectOperationSuccess(message: 'تم إضافة الإعلان بنجاح'));
      add(LoadAllAnnouncements());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحميل جميع المشاريع
  Future<void> _onLoadAllProjects(LoadAllProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projects = await _projectRepository.getAllProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحديث كود الانضمام
  Future<void> _onUpdateJoinCode(UpdateJoinCode event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.updateJoinCode(event.newJoinCode);
      emit(ProjectOperationSuccess(message: 'تم تحديث كود الانضمام'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحديث قائمة المشرفين
  Future<void> _onUpdateSupervisors(UpdateSupervisors event, Emitter<ProjectState> emit) async {
    try {
      final project = await _projectRepository.getProjectById(event.projectId);
      final updatedProject = project.copyWith(supervisors: event.newSupervisorIds);
      await _projectRepository.updateProject(updatedProject);
      
      emit(ProjectOperationSuccess(message: 'تم تحديث قائمة المشرفين'));
      add(LoadProjectDetails(projectId: event.projectId));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // توليد كود انضمام جديد
  Future<void> _onGenerateJoinCode(GenerateJoinCodeEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      // منطق توليد كود فريد من 8 أحرف
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rnd = Random.secure();
      final joinCode = String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      
      emit(JoinCodeGenerated(joinCode));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحميل جميع المهام
  Future<void> _onLoadAllTasks(LoadAllTasks event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final tasks = await _projectRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحميل جميع الإعلانات
  Future<void> _onLoadAllAnnouncements(LoadAllAnnouncements event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final announcements = await _projectRepository.getAllAnnouncements();
      emit(AnnouncementsLoaded(announcements));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // حذف مشروع
  Future<void> _onDeleteProject(DeleteProject event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.deleteProject(event.projectId);
      emit(ProjectOperationSuccess(message: 'تم حذف المشروع بنجاح'));
      add(LoadAllProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحديث مشروع
  Future<void> _onUpdateProject(UpdateProject event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.updateProject(event.project);
      emit(ProjectOperationSuccess(message: 'تم تحديث المشروع بنجاح'));
      add(LoadProjectDetails(projectId: event.project.id));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // الحصول على إعدادات المشروع
  Future<void> _onGetProjectSettings(GetProjectSettings event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    print('🔄 GetProjectSettings جلب إعدادات المشروع من المستودع');
    try {
      final settings = await _projectRepository.getProjectSettings();
      print('✅ تم جلب إعدادات المشروع: $settings');
      emit(ProjectSettingsLoaded(settings));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // تحديث إعدادات المشروع
  Future<void> _onUpdateProjectSettings(UpdateProjectSettings event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.updateProjectSettings(event.settings);
      emit(ProjectOperationSuccess(message: 'تم تحديث إعدادات المشروع بنجاح'));
      add(GetProjectSettings());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إضافة طالب إلى قائمة المشروع
  Future<void> _onAddStudentToProjectList(AddStudentToProjectList event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.addStudentToProjectList(event.studentId);
      emit(ProjectOperationSuccess(message: 'تم إضافة الطالب إلى القائمة بنجاح'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إزالة طالب من قائمة المشروع
  Future<void> _onRemoveStudentFromProjectList(RemoveStudentFromProjectList event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.removeStudentFromProjectList(event.studentId);
      emit(ProjectOperationSuccess(message: 'تم إزالة الطالب من القائمة بنجاح'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إضافة مستخدم إداري
  Future<void> _onAddAdminUser(AddAdminUser event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.addAdminUser(event.user);
      emit(ProjectOperationSuccess(message: 'تم إضافة المستخدم الإداري بنجاح'));
      add(GetProjectSettings());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // إزالة مستخدم إداري
  Future<void> _onRemoveAdminUser(RemoveAdminUser event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.removeAdminUser(event.userId);
      emit(ProjectOperationSuccess(message: 'تم إزالة المستخدم الإداري بنجاح'));
      add(GetProjectSettings());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج تحديث الإعلان
  Future<void> _onUpdateAnnouncement(UpdateAnnouncement event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.updateAnnouncement(event.announcement);
      emit(ProjectOperationSuccess(message: 'تم تحديث الإعلان بنجاح'));
      add(LoadAllAnnouncements());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج حذف الإعلان
  Future<void> _onDeleteAnnouncement(DeleteAnnouncement event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.deleteAnnouncement(event.announcementId);
      emit(ProjectOperationSuccess(message: 'تم حذف الإعلان بنجاح'));
      add(LoadAllAnnouncements());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج تحديث المهمة
  Future<void> _onUpdateTask(UpdateTask event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.updateTask(event.task);
      emit(ProjectOperationSuccess(message: 'تم تحديث المهمة بنجاح'));
      add(LoadAllTasks());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج حذف المهمة
  Future<void> _onDeleteTask(DeleteTask event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.deleteTask(event.taskId);
      emit(ProjectOperationSuccess(message: 'تم حذف المهمة بنجاح'));
      add(LoadAllTasks());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

   // معالج تحميل تسليمات المهمة
  Future<void> _onLoadTaskSubmissions(LoadTaskSubmissions event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final submissions = await _projectRepository.getTaskSubmissions(event.taskId);
      emit(TaskSubmissionsLoaded(submissions));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج تسليم المهمة
  Future<void> _onSubmitTask(SubmitTask event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.submitTask(event.submission);
      emit(TaskSubmissionOperationSuccess(message: 'تم تسليم المهمة بنجاح'));
      add(LoadTaskSubmissions(taskId: event.submission.taskId));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // معالج تقييم تسليم المهمة
  Future<void> _onGradeTaskSubmission(GradeTaskSubmission event, Emitter<ProjectState> emit) async {
    try {
      await _projectRepository.gradeTaskSubmission(
        submissionId: event.submissionId,
        grade: event.grade,
        feedback: event.feedback,
      );
      emit(TaskSubmissionOperationSuccess(message: 'تم تقييم التسليم بنجاح'));
      // لا نحتاج إلى إعادة تحميل التسليمات هنا لأننا سنقوم بذلك في الشاشة
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}