part of 'teacher_data_bloc.dart';

abstract class TeacherDataEvent extends Equatable {
  const TeacherDataEvent();

  @override
  List<Object> props() => [];
}

// تحديث بيانات الأستاذ
class UpdateTeacherDataEvent extends TeacherDataEvent {
  final TeacherDataModel teacherData;
  const UpdateTeacherDataEvent(this.teacherData);

  @override
  List<Object> props() => [teacherData];
}

// إضافة ساعات مكتبية متعددة
class AddOfficeHoursEvent extends TeacherDataEvent {
  final String teacherId;
  final List<OfficeHoursModel> officeHoursList;
  const AddOfficeHoursEvent({
    required this.teacherId,
    required this.officeHoursList,
  });

  @override
  List<Object> props() => [teacherId, officeHoursList];
}

class LoadOfficeHoursEvent extends TeacherDataEvent {
  final String teacherId;
  const LoadOfficeHoursEvent(this.teacherId);

  @override
  List<Object> props() => [teacherId];
}

// تحديث ساعة مكتبية
class UpdateOfficeHoursEvent extends TeacherDataEvent {
  final String teacherId;
  final OfficeHoursModel officeHours;
  const UpdateOfficeHoursEvent({
    required this.teacherId,
    required this.officeHours,
  });

  @override
  List<Object> props() => [teacherId, officeHours];
}

// حذف ساعة مكتبية
class DeleteOfficeHoursEvent extends TeacherDataEvent {
  final String teacherId;
  final String officeHoursId;
  const DeleteOfficeHoursEvent({
    required this.teacherId,
    required this.officeHoursId,
  });

  @override
  List<Object> props() => [teacherId, officeHoursId];
}

// إضافة مواد دراسية متعددة
class AddTeachingCoursesEvent extends TeacherDataEvent {
  final String teacherId;
  final List<TeachingCourseModel> courses;
  const AddTeachingCoursesEvent({
    required this.teacherId,
    required this.courses,
  });

  @override
  List<Object> props() => [teacherId, courses];
}

// 🔥جلب المواد الدراسية
class LoadTeachingCoursesEvent extends TeacherDataEvent {
  final String teacherId;
  const LoadTeachingCoursesEvent(this.teacherId);

  @override
  List<Object> props() => [teacherId];
}

// حذف مادة دراسية
class DeleteTeachingCourseEvent extends TeacherDataEvent {
  final String teacherId;
  final String courseId;
  const DeleteTeachingCourseEvent({
    required this.teacherId,
    required this.courseId,
  });

  @override
  List<Object> props() => [teacherId, courseId];
}

// أرشفة مناهج متعددة
class ArchiveCurriculaEvent extends TeacherDataEvent {
  final String teacherId;
  final String teacherName;
  final List<ArchivedCurriculumModel> curricula;
  const ArchiveCurriculaEvent({
    required this.teacherId,
    required this.teacherName,
    required this.curricula,
  });

  @override
  List<Object> props() => [teacherId,teacherName, curricula];
}

// جلب المناهج المؤرشفة
class LoadArchivedCurriculaEvent extends TeacherDataEvent {
  final String teacherId;
  const LoadArchivedCurriculaEvent(this.teacherId);

  @override
  List<Object> props() => [teacherId];
}

// استعادة منهج من الأرشيف
class RestoreCurriculumEvent extends TeacherDataEvent {
  final String teacherId;
  final String archiveId;
  const RestoreCurriculumEvent({
    required this.teacherId,
    required this.archiveId,
  });

  @override
  List<Object> props() => [teacherId, archiveId];
}

// حذف منهج من الأرشيف
class DeleteArchivedCurriculumEvent extends TeacherDataEvent {
  final String teacherId;
  final String archiveId;
  const DeleteArchivedCurriculumEvent({
    required this.teacherId,
    required this.archiveId,
  });

  @override
  List<Object> props() => [teacherId, archiveId];
}

// البحث في المناهج المؤرشفة
class SearchArchivedCurriculaEvent extends TeacherDataEvent {
  final String teacherId;
  final String query;
  const SearchArchivedCurriculaEvent({
    required this.teacherId,
    required this.query,
  });

  @override
  List<Object> props() => [teacherId, query];
}

// حذف جميع المواد الدراسية السابقة
class DeleteAllTeachingCoursesEvent extends TeacherDataEvent {
  final String teacherId;
  const DeleteAllTeachingCoursesEvent(this.teacherId);

  @override
  List<Object> props() => [teacherId];
}

// تحديث المواد الدراسية (حذف السابقة وإضافة الجديدة)
class UpdateTeachingCoursesEvent extends TeacherDataEvent {
  final String teacherId;
  final List<TeachingCourseModel> courses;
  const UpdateTeachingCoursesEvent({
    required this.teacherId,
    required this.courses,
  });

  @override
  List<Object> props() => [teacherId, courses];
}

// حدث واحد لتحميل جميع البيانات
class LoadTeacherProfileDataEvent extends TeacherDataEvent {
  final String teacherId;
  const LoadTeacherProfileDataEvent(this.teacherId);

  @override
  List<Object> props() => [teacherId];
}