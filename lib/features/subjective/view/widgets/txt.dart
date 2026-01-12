/*
lib/
└── features/
    └── subjective/                    # ✅ الحزمة الجديدة كاملة
        ├── bloc/                      # إدارة الحالة
        │   ├── subjective_bloc.dart   # ✅ البلوك الرئيسي
        │   ├── subjective_event.dart  # ✅ الأحداث
        │   └── subjective_state.dart  # ✅ الحالات
        └── view/
            ├── screens/               # الشاشات الرئيسية
            │   └── 
            └── widgets/               # المكونات المساعدة
                └── 
packages/
├── subjective_repository/
│   ├── lib/
│   │   ├── src/
│   │   │   ├── models/
│   │   │   │   ├── attendance_model.dart
│   │   │   │   ├── advertisement_model.dart
│   │   │   │   ├── curriculum_model.dart
│   │   │   │   ├── exam_grade_model.dart
│   │   │   │   ├── homework_model.dart
│   │   │   │   └── subjective_content_model.dart
│   │   │   ├── entities/
│   │   │   │   ├── homework_entity.dart
│   │   │   │   ├── attendance_entity.dart
│   │   │   │   ├── exam_grade_entity.dart
│   │   │   │   ├── advertisement_entity.dart
│   │   │   │   └── curriculum_entity.dart
│   │   │   ├── subjective_firebase.dart
│   │   │   └── subjective_repo.dart
│   │   └── subjective_repository.dart
│   └── pubspec.yaml
└──semester_repository/
    ├── lib/
    │   ├── src/
    │   │   ├── models/
    │   │   │   ├── course_model.dart
    │   │   │   ├── group_model.dart
    │   │   │   ├── exam_grade_model.dart
    │   │   │   ├── semester_model.dart
    │   │   │   └── student_content_model.dart
    │   │   ├── entities/
    │   │   │   ├── course_entity.dart
    │   │   │   ├── group_entity.dart
    │   │   │   ├── semester_entity.dart
    │   │   │   └── student_entity.dart
    │   │   ├── semester_firebase.dart
    │   │   └── semester_repo.dart
    │   └── semester_repository.dart
    └── pubspec.yaml
pubspec.yaml              # pubspec الرئيسية

 */

/*
semester (collection)
│
├── semester1 (document)
│   ├── type_semester: "فصل خريف"
│   ├── start_time: "2024-09-01"
│   ├── end_time: "2024-12-20"
│   ├── max_credits: 18
│   ├── min_credits: 12
│   └── courses (subcollection)
│       └── course1 (document)
│           ├── id: "CS101"
│           ├── name: "برمجة متقدمة"
│           ├── num_of_student: 45
│           ├── code_cs: "CS101"
│           ├── president: "د. محمد أحمد"
│           └── group (subcollection)
│               └── group1 (document)
│                   ├── id: "G1"
│                   ├── name: "المجموعة أ"
│                   ├── id_doctor: "DOC001"
│                   ├── name_doctor: "د. علي حسين"
│                   ├── student (subcollection)          // ✅ طلاب المجموعة
│                   │   ├── student1 (document)
│                   │   │   ├── id: "STU001"
│                   │   │   ├── name: "أحمد محمد"
│                   │   │   ├── student_id: "2024001"
│                   │   │   ├── email: "ahmed@university.edu"
│                   │   │   └── phone: "0512345678"
│                   │   ├── student2 (document)
│                   │   │   ├── id: "STU002"
│                   │   │   ├── name: "فاطمة عبدالله"
│                   │   │   ├── student_id: "2024002"
│                   │   │   ├── email: "fatima@university.edu"
│                   │   │   └── phone: "0512345679"
│                   │   └── student3 (document)
│                   │       ├── id: "STU003"
│                   │       ├── name: "خالد سعيد"
│                   │       ├── student_id: "2024003"
│                   │       ├── email: "khaled@university.edu"
│                   │       └── phone: "0512345680"
│                   └── subjective (subcollection)
│                       ├── curricula  (subcollection)
│                       │   ├── curriculum1 (document)
│                       │   │   ├── id: "CUR001"
│                       │   │   ├── description: "شرح مفاهيم البرمجة الكائنية"
│                       │   │   ├── time: "2024-10-01T10:00:00"
│                       │   │   └── file: "https://example.com/files/oop.pdf"
│                       │   ├── curriculum2 (document)
│                       │   │   ├── id: "CUR002"
│                       │   │   ├── description: "تمارين على الوراثة"
│                       │   │   ├── time: "2024-10-08T10:00:00"
│                       │   │   └── file: "https://example.com/files/inheritance.pdf"
│                       │   └── curriculum3 (document)
│                       │       ├── id: "CUR003"
│                       │       ├── description: "الإعلان عن الامتحان النصفي"
│                       │       ├── time: "2024-10-15T09:00:00"
│                       │       └── file: ""
│                       ├── advcurricula (subcollection)
│                       │   ├── advcurriculum1 (document)
│                       │   │   ├── id: "ADV001"
│                       │   │   ├── description: "مراجعة شاملة للبرمجة الكائنية"
│                       │   │   ├── time: "2024-10-20T15:00:00"
│                       │   │   └── file: "https://example.com/files/oop_review.pdf"
│                       │   └── advcurriculum2 (document)
│                       │       ├── id: "ADV002"
│                       │       ├── description: "نصائح للامتحان النهائي"
│                       │       ├── time: "2024-12-10T14:00:00"
│                       │       └── file: "https://example.com/files/final_tips.pdf"
│                       ├── homework (subcollection)
│                       │    ├── homework1 (document)
│                       │    │   ├── id: "HW001"
│                       │    │   ├── title: "الواجب الأول - البرمجة الكائنية"
│                       │    │   ├── start: "2024-10-01T00:00:00"
│                       │    │   ├── end: "2024-10-07T23:59:59"
│                       │    │   ├── description: "قم بحل التمارين في الصفحة 45"
│                       │    │   ├── file: "https://example.com/files/homework1.pdf"
│                       │    │   ├── max_mark: 20
│                       │    │   └── student (subcollection)          // ✅ تسليمات الطلاب للواجب 1
│                       │    │       ├── STU001 (document)            // استخدام student id كمستند
│                       │    │       │   ├── idStudent: "STU001"
│                       │    │       │   ├── name: "أحمد محمد"
│                       │    │       │   ├── file: "https://example.com/submissions/ahmed_hw1.pdf"
│                       │    │       │   ├── title: "حل التمارين - أحمد"
│                       │    │       │   ├── submit_time: "2024-10-05T14:30:00"
│                       │    │       │   └── from_mark: 18.5
│                       │    │       ├── STU002 (document)
│                       │    │       │   ├── idStudent: "STU002"
│                       │    │       │   ├── name: "فاطمة عبدالله"
│                       │    │       │   ├── file: "https://example.com/submissions/fatima_hw1.pdf"
│                       │    │       │   ├── title: "إجابتي على الواجب"
│                       │    │       │   ├── submit_time: "2024-10-06T10:15:00"
│                       │    │       │   └── from_mark: 17.0
│                       │    │       └── STU003 (document)
│                       │    │           ├── idStudent: "STU003"
│                       │    │           ├── name: "خالد سعيد"
│                       │    │           ├── file: "https://example.com/submissions/khaled_hw1.pdf"
│                       │    │           ├── title: "الحل النهائي"
│                       │    │           ├── submit_time: "2024-10-07T23:30:00"
│                       │    │           └── from_mark: 16.0
│                       │    ├── homework2 (document)
│                       │    │   ├── id: "HW002"
│                       │    │   ├── title: "مشروع البرمجة الكائنية"
│                       │    │   ├── start: "2024-10-15T00:00:00"
│                       │    │   ├── end: "2024-10-22T23:59:59"
│                       │    │   ├── description: "مشروع البرمجة الكائنية"
│                       │    │   ├── file: "https://example.com/files/project_requirements.pdf"
│                       │    │   ├── max_mark: 30
│                       │    │   └── student (subcollection)          // ✅ تسليمات الطلاب للواجب 2
│                       │    │       ├── STU001 (document)
│                       │    │       │   ├── idStudent: "STU001"
│                       │    │       │   ├── name: "أحمد محمد"
│                       │    │       │   ├── file: "https://example.com/submissions/ahmed_project.zip"
│                       │    │       │   ├── title: "مشروع نظام إدارة المكتبة"
│                       │    │       │   ├── submit_time: "2024-10-20T16:45:00"
│                       │    │       │   └── from_mark: 28.0
│                       │    │       ├── STU002 (document)
│                       │    │       │   ├── idStudent: "STU002"
│                       │    │       │   ├── name: "فاطمة عبدالله"
│                       │    │       │   ├── file: "https://example.com/submissions/fatima_project.zip"
│                       │    │       │   ├── title: "نظام إدارة المستشفى"
│                       │    │       │   ├── submit_time: "2024-10-22T22:00:00"
│                       │    │       │   └── from_mark: 0.0
│                       │    │       └── STU003 (document)
│                       │    │           ├── idStudent: "STU003"
│                       │    │           ├── name: "خالد سعيد"
│                       │    │           ├── file: ""
│                       │    │           ├── title: ""
│                       │    │           ├── submit_time: null
│                       │    │           └── from_mark: 0.0
│                       │    └── homework3 (document)
│                       │        ├── id: "HW003"
│                       │        ├── title: "تمارين القوائم المترابطة"
│                       │        ├── start: "2024-11-01T00:00:00"
│                       │        ├── end: "2024-11-10T23:59:59"
│                       │        ├── description: "تمارين على القوائم المترابطة"
│                       │        ├── file: "https://example.com/files/linked_list_exercises.pdf"
│                       │        ├── max_mark: 15
│                       │        └── student (subcollection)          // ✅ لم يسلم أحد بعد
│                       │            └── (لا توجد إجابات بعد)
│                       ├── attendance_records (subcollection)
│                       │    ├── {attendanceId1} (document)
│                       │    │   ├── id: "attendance_123456789"
│                       │    │   ├── date: "2024-11-15T10:00:00"
│                       │    │   ├── lectureTitle: "المحاضرة 1"
│                       │    │   ├── presentStudentIds: {"STU001":"محمد علي "}, {"STU003":"سارة خالد"}
│                       │    │   ├── absentStudentIds: {"STU002":"سمية علي"}, {"STU004":"ليلى حسن"}
│                       │    │   └── studentNotes: {"STU001" : "حضر متأخراً", "STU002": "إجازة مرضية"}
│                       │    └── {attendanceId2} (document)
│                       │        ├── id: "attendance_123456790"
│                       │        ├── date: "2024-11-17T10:00:00"
│                       │        ├── lectureTitle: "المحاضرة 2"
│                       │        ├── presentStudentIds: {"STU001":"محمد علي "}, {"STU002":"سمية علي"}, {"STU004":"ليلى حسن"}
│                       │        ├── absentStudentIds: {"STU003":"سارة خالد"}
│                       │        └── studentNotes: {"STU003": "سفر"}
هذا هيكل الداتا بيز ويجب ان يكون مسار subjective (subcollection) ب الشكل 
/semester/semester_1762185935132/courses/course_1762635223526/group/group_1763468825427_1/subjective 
ولكن مساره في الداتا 
/semester/current/courses/course_1762635223526/group/group_1762981301864_0/attendance
و /semester/current/courses/course_1762635223526/group/group_1763468825427_1/subjective/content/advertisements علي مسارين وكل واحد فيهم خطاء 
اريد تعديل مسار التخزين 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
semester/{semesterId}
├── courses/{courseId}
│   └── group/{groupId}
│       ├── student/ (طلاب المجموعة)
│       └── subjective/
│           └── content/
│               ├── curricula/ (المناهج)
│               ├── homework/ (الواجبات)
│               ├── advertisements/ (الإعلانات)
│               ├── exam_grades/ (درجات الامتحانات)
│               ├── attendance_records/ (سجلات الحضور)
│               └── archived_curricula/ (المناهج المؤرشفة)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SemesterEntity extends Equatable {
  final String id;
  final String typeSemester;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCredits;
  final int minCredits;

  const SemesterEntity({
    required this.id,
    required this.typeSemester,
    required this.startTime,
    required this.endTime,
    required this.maxCredits,
    required this.minCredits,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'type_semester': typeSemester,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'max_credits': maxCredits,
      'min_credits': minCredits,
    };
  }

  factory SemesterEntity.fromDocument(Map<String, dynamic> doc) {
    return SemesterEntity(
      id: doc['id'] as String,
      typeSemester: doc['type_semester'] as String,
      startTime: (doc['start_time'] as Timestamp).toDate(),
      endTime: (doc['end_time'] as Timestamp).toDate(),
      maxCredits: doc['max_credits'] as int,
      minCredits: doc['min_credits'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        typeSemester,
        startTime,
        endTime,
        maxCredits,
        minCredits,
      ];
}
import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String idDoctor;
  final String nameDoctor;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.idDoctor,
    required this.nameDoctor,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'id_doctor': idDoctor,
      'name_doctor': nameDoctor,
    };
  }

  factory GroupEntity.fromDocument(Map<String, dynamic> doc) {
    return GroupEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      idDoctor: doc['id_doctor'] as String,
      nameDoctor: doc['name_doctor'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, idDoctor, nameDoctor];
}
import 'package:equatable/equatable.dart';

class CoursesEntity extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final int numOfStudent;
  final String president;

  const CoursesEntity({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.numOfStudent,
    required this.president,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'code_cs': codeCs,
      'num_of_student': numOfStudent,
      'president': president,
    };
  }

  factory CoursesEntity.fromDocument(Map<String, dynamic> doc) {
    return CoursesEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      codeCs: doc['code_cs'] as String,
      numOfStudent: doc['num_of_student'] as int,
      president: doc['president'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        codeCs,
        numOfStudent,
        president,
      ];
}
import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final String id;
  final String name;
  final String studentId;

  const StudentEntity({
    required this.id,
    required this.name,
    required this.studentId,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
    };
  }

  factory StudentEntity.fromDocument(Map<String, dynamic> doc) {
    return StudentEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      studentId: doc['student_id'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, studentId];
}
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class CoursesModel extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final int numOfStudent;
  final String president;
  final List<GroupModel> groups;

  const CoursesModel({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.numOfStudent,
    required this.president,
    this.groups = const [],
  });

  static final empty = CoursesModel(
    id: '',
    name: '',
    codeCs: '',
    numOfStudent: 0,
    president: '',
  );

  bool get isEmpty => this == CoursesModel.empty;
  bool get isNotEmpty => this != CoursesModel.empty;

  CoursesModel copyWith({
    String? id,
    String? name,
    String? codeCs,
    int? numOfStudent,
    String? president,
    List<GroupModel>? groups,
  }) {
    return CoursesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      codeCs: codeCs ?? this.codeCs,
      numOfStudent: numOfStudent ?? this.numOfStudent,
      president: president ?? this.president,
      groups: groups ?? this.groups,
    );
  }

  CoursesEntity toEntity() {
    return CoursesEntity(
      id: id,
      name: name,
      codeCs: codeCs,
      numOfStudent: numOfStudent,
      president: president,
    );
  }

  factory CoursesModel.fromEntity(CoursesEntity entity) {
    return CoursesModel(
      id: entity.id,
      name: entity.name,
      codeCs: entity.codeCs,
      numOfStudent: entity.numOfStudent,
      president: entity.president,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        codeCs,
        numOfStudent,
        president,
        groups,
      ];
}
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String idDoctor;
  final String nameDoctor;
  final List<StudentModel> students;

  const GroupModel({
    required this.id,
    required this.name,
    required this.idDoctor,
    required this.nameDoctor,
    this.students = const [],
  });

  static final empty = GroupModel(
    id: '',
    name: '',
    idDoctor: '',
    nameDoctor: '',
  );

  bool get isEmpty => this == GroupModel.empty;
  bool get isNotEmpty => this != GroupModel.empty;

  GroupModel copyWith({
    String? id,
    String? name,
    String? idDoctor,
    String? nameDoctor,
    List<StudentModel>? students,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      idDoctor: idDoctor ?? this.idDoctor,
      nameDoctor: nameDoctor ?? this.nameDoctor,
      students: students ?? this.students,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      idDoctor: idDoctor,
      nameDoctor: nameDoctor,
    );
  }

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      idDoctor: entity.idDoctor,
      nameDoctor: entity.nameDoctor,
    );
  }

  @override
  List<Object?> get props => [id, name, idDoctor, nameDoctor ,students];
}
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class SemesterModel extends Equatable {
  final String id;
  final String typeSemester;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCredits;
  final int minCredits;
  final List<CoursesModel> courses;

  const SemesterModel({
    required this.id,
    required this.typeSemester,
    required this.startTime,
    required this.endTime,
    required this.maxCredits,
    required this.minCredits,
    this.courses = const [],
  });

  static final empty = SemesterModel(
    id: '',
    typeSemester: '',
    startTime: DateTime.now(),
    endTime: DateTime.now(),
    maxCredits: 0,
    minCredits: 0,
  );

  bool get isEmpty => this == SemesterModel.empty;
  bool get isNotEmpty => this != SemesterModel.empty;

  // التحقق إذا كان الفصل نشط حالياً
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  // الحصول على الفصل الحالي
  String get currentWeek {
    final now = DateTime.now();
    if (!isActive) return 'غير نشط';
    
    final difference = now.difference(startTime).inDays;
    final week = (difference / 7).floor() + 1;
    return 'الأسبوع $week';
  }

  SemesterModel copyWith({
    String? id,
    String? typeSemester,
    DateTime? startTime,
    DateTime? endTime,
    int? maxCredits,
    int? minCredits,
    List<CoursesModel>? courses,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      typeSemester: typeSemester ?? this.typeSemester,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxCredits: maxCredits ?? this.maxCredits,
      minCredits: minCredits ?? this.minCredits,
      courses: courses ?? this.courses,
    );
  }

  SemesterEntity toEntity() {
    return SemesterEntity(
      id: id,
      typeSemester: typeSemester,
      startTime: startTime,
      endTime: endTime,
      maxCredits: maxCredits,
      minCredits: minCredits,
    );
  }

  factory SemesterModel.fromEntity(SemesterEntity entity) {
    return SemesterModel(
      id: entity.id,
      typeSemester: entity.typeSemester,
      startTime: entity.startTime,
      endTime: entity.endTime,
      maxCredits: entity.maxCredits,
      minCredits: entity.minCredits,
    );
  }

  @override
  List<Object?> get props => [
        id,
        typeSemester,
        startTime,
        endTime,
        maxCredits,
        minCredits,
        courses,
      ];
}
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class StudentModel extends Equatable {
  final String id;
  final String name;
  final String studentId;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
  });

  static final empty = StudentModel(
    id: '',
    name: '',
    studentId: '',
  );

  bool get isEmpty => this == StudentModel.empty;
  bool get isNotEmpty => this != StudentModel.empty;

  StudentModel copyWith({
    String? id,
    String? name,
    String? studentId,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
    );
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      name: name,
      studentId: studentId,
    );
  }

  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      name: entity.name,
      studentId: entity.studentId,
    );
  }

  // لاستيراد من Excel
  factory StudentModel.fromExcel(Map<String, dynamic> excelRow) {
    return StudentModel(
      id: excelRow['id']?.toString() ?? '',
      name: excelRow['name']?.toString() ?? '',
      studentId: excelRow['student_id']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, studentId];
}
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semester_repository/semester_repository.dart';
import 'semester_repo.dart';

class FirebaseSemesterRepository implements SemesterRepository {
  final CollectionReference semestersCollection =
      FirebaseFirestore.instance.collection('semester');

  SemesterModel _documentToSemester(DocumentSnapshot doc) {
  try {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('❌ المستند فارغ: ${doc.id}');
      return SemesterModel.empty;
    }

    // ✅ معالجة الحقول التي قد تكون null
    final safeData = <String, dynamic>{
      'id': doc.id,
      'type_semester': data['type_semester'] ?? 'غير محدد',
      'start_time': data['start_time'] ?? Timestamp.now(),
      'end_time': data['end_time'] ?? Timestamp.now(),
      'max_credits': data['max_credits'] ?? 18,
      'min_credits': data['min_credits'] ?? 12,
    };

    print('🔍 تحويل الفصل: ${safeData['type_semester']}');
    
    final entity = SemesterEntity.fromDocument(safeData);
    return SemesterModel.fromEntity(entity);
  } catch (e) {
    print('❌ خطأ في تحويل مستند الفصل ${doc.id}: $e');
    print('📋 بيانات المستند: ${doc.data()}');
    return SemesterModel.empty;
  }
}

  CoursesModel _documentToCourse(DocumentSnapshot doc) {
  try {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('❌ مستند المادة فارغ: ${doc.id}');
      return CoursesModel.empty;
    }

    // ✅ معالجة الحقول التي قد تكون null
    final safeData = <String, dynamic>{
      'id': doc.id,
      'name': data['name'] ?? 'مادة غير محددة',
      'code_cs': data['code_cs'] ?? 'CODE000',
      'num_of_student': data['num_of_student'] ?? 0,
      'president': data['president'] ?? 'غير محدد',
    };

    print('🔍 تحويل المادة: ${safeData['name']} (${safeData['code_cs']})');
    
    final entity = CoursesEntity.fromDocument(safeData);
    return CoursesModel.fromEntity(entity);
  } catch (e) {
    print('❌ خطأ في تحويل مستند المادة ${doc.id}: $e');
    print('📋 بيانات المستند: ${doc.data()}');
    return CoursesModel.empty;
  }
}

  GroupModel _documentToGroup(DocumentSnapshot doc) {
  try {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('❌ مستند المجموعة فارغ: ${doc.id}');
      return GroupModel.empty;
    }

    // ✅ معالجة الحقول التي قد تكون null
    final safeData = <String, dynamic>{
      'id': doc.id,
      'name': data['name'] ?? 'مجموعة غير محددة',
      'id_doctor': data['id_doctor'] ?? '',
      'name_doctor': data['name_doctor'] ?? 'غير محدد',
    };

    final entity = GroupEntity.fromDocument(safeData);
    return GroupModel.fromEntity(entity);
  } catch (e) {
    print('❌ خطأ في تحويل مستند المجموعة ${doc.id}: $e');
    return GroupModel.empty;
  }
}

  StudentModel _documentToStudent(DocumentSnapshot doc) {
  try {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('❌ مستند الطالب فارغ: ${doc.id}');
      return StudentModel.empty;
    }

    // ✅ معالجة الحقول التي قد تكون null
    final safeData = <String, dynamic>{
      'id': doc.id,
      'name': data['name'] ?? 'طالب غير محدد',
      'email': data['email'] ?? '',
      'student_id': data['student_id'] ?? '000000',
      'phone': data['phone'],
      'department': data['department'],
    };

    final entity = StudentEntity.fromDocument(safeData);
    return StudentModel.fromEntity(entity);
  } catch (e) {
    print('❌ خطأ في تحويل مستند الطالب ${doc.id}: $e');
    return StudentModel.empty;
  }
}/******************************************************************************* */
 @override
  Future<List<CoursesModel>> getCoursesByGroupDoctor(String doctorId) async {
    try {
      print('🔍 جلب مواد الدكتور المشرف: $doctorId');

      final currentSemester = await getCurrentSemester();
      if (currentSemester == null) {
        throw Exception('لا يوجد فصل دراسي نشط');
      }

      // جلب جميع المواد في الفصل الحالي
      final allCourses = await getSemesterCourses(currentSemester.id);
      final doctorCourses = <CoursesModel>[];

      for (final course in allCourses) {
        try {
          // جلب مجموعات المادة مع فلترة حسب الدكتور
          final courseGroups = await _getGroupsByDoctor(
            currentSemester.id, 
            course.id, 
            doctorId
          );
          
          if (courseGroups.isNotEmpty) {
            final courseWithGroups = course.copyWith(groups: courseGroups);
            doctorCourses.add(courseWithGroups);
          }
        } catch (e) {
          print('❌ خطأ في معالجة المادة ${course.id}: $e');
        }
      }

      print('✅ تم جلب ${doctorCourses.length} مادة للدكتور المشرف: $doctorId');
      return doctorCourses;
    } catch (e) {
      print('❌ خطأ في جلب مواد الدكتور المشرف: $e');
      rethrow;
    }
  }

  @override
  Future<List<CoursesModel>> getCoursesByStudent(String studentId) async {
    try {
      print('🔍 جلب مواد الطالب: $studentId');

      final currentSemester = await getCurrentSemester();
      if (currentSemester == null) {
        throw Exception('لا يوجد فصل دراسي نشط');
      }

      // جلب جميع المواد في الفصل الحالي
      final allCourses = await getSemesterCourses(currentSemester.id);
      final studentCourses = <CoursesModel>[];

      for (final course in allCourses) {
        try {
          // جلب مجموعات المادة التي يوجد فيها الطالب
          final studentGroups = await _getGroupsByStudent(
            currentSemester.id, 
            course.id, 
            studentId
          );
          
          if (studentGroups.isNotEmpty) {
            final courseWithGroups = course.copyWith(groups: studentGroups);
            studentCourses.add(courseWithGroups);
          }
        } catch (e) {
          print('❌ خطأ في معالجة المادة ${course.id}: $e');
        }
      }

      print('✅ تم جلب ${studentCourses.length} مادة للطالب: $studentId');
      return studentCourses;
    } catch (e) {
      print('❌ خطأ في جلب مواد الطالب: $e');
      rethrow;
    }
  }
  
  // ✅ دوال مساعدة جديدة
  Future<List<GroupModel>> _getGroupsByDoctor(
    String semesterId, String courseId, String doctorId
  ) async {
    try {
      final querySnapshot = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .where('id_doctor', isEqualTo: doctorId)
          .get();

      final groups = <GroupModel>[];
      
      for (final doc in querySnapshot.docs) {
        try {
          final group = _documentToGroup(doc);
          if (!group.isEmpty) {
            // جلب الطلاب فقط إذا كانت المجموعة تابعة للدكتور
            final students = await getGroupStudents(semesterId, courseId, group.id);
            groups.add(group.copyWith(students: students));
          }
        } catch (e) {
          print('❌ خطأ في جلب المجموعة ${doc.id}: $e');
        }
      }

      return groups;
    } catch (e) {
      print('❌ خطأ في جلب مجموعات الدكتور: $e');
      return [];
    }
  }

  Future<List<GroupModel>> _getGroupsByStudent(
    String semesterId, String courseId, String studentId
  ) async {
    try {
      // جلب جميع مجموعات المادة
      final allGroups = await getCourseGroups(semesterId, courseId);
      final studentGroups = <GroupModel>[];

      for (final group in allGroups) {
        try {
          // التحقق من وجود الطالب في المجموعة
          final isStudentInGroup = await _isStudentInGroup(
            semesterId, courseId, group.id, studentId
          );
          
          if (isStudentInGroup) {
            // جلب جميع طلاب المجموعة
            final students = await getGroupStudents(semesterId, courseId, group.id);
            studentGroups.add(group.copyWith(students: students));
          }
        } catch (e) {
          print('❌ خطأ في التحقق من المجموعة ${group.id}: $e');
        }
      }

      return studentGroups;
    } catch (e) {
      print('❌ خطأ في جلب مجموعات الطالب: $e');
      return [];
    }
  }

  Future<bool> _isStudentInGroup(
    String semesterId, String courseId, String groupId, String studentId
  ) async {
    try {
      final studentDoc = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      return studentDoc.docs.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق من وجود الطالب: $e');
      return false;
    }
  }
  /************************************************************************************** */
  @override
Future<List<SemesterModel>> getAllSemesters() async {
  try {
    print('🔍 جلب جميع الفصول الدراسية');

    final querySnapshot = await semestersCollection.get();

    final semesters = querySnapshot.docs
        .map(_documentToSemester)
        .where((semester) => !semester.isEmpty) // ✅ تصفية الفصول الفارغة
        .toList();
    
    // ترتيب الفصول من الأحدث إلى الأقدم
    semesters.sort((a, b) => b.startTime.compareTo(a.startTime));

    print('✅ تم جلب ${semesters.length} فصل دراسي (تم تصفية ${querySnapshot.docs.length - semesters.length} فصل تالف)');
    return semesters;
  } catch (e) {
    print('❌ خطأ في جلب الفصول الدراسية: $e');
    rethrow;
  }
}
//جلب الفصل الدراسي الحالي (النشط)
  @override
Future<SemesterModel?> getCurrentSemester() async {
  try {
    print('🔍 جلب الفصل الدراسي الحالي ');

    // جلب جميع الفصول وفرزها من الأحدث إلى الأقدم
    final allSemesters = await getAllSemesters();
    
    if (allSemesters.isEmpty) {
      print('⚠️ لا توجد فصول دراسية في النظام');
      return null;
    }

    final now = DateTime.now();
    print('🕒 الوقت الحالي: $now');
    
    // البحث عن الفصل النشط (يحتوي الوقت الحالي)
    SemesterModel? activeSemester;
    for (final semester in allSemesters) {
      print('📅 فحص الفصل: ${semester.typeSemester}');
      print('   من: ${semester.startTime}');
      print('   إلى: ${semester.endTime}');
      print('   النشط: ${semester.startTime.isBefore(now) && semester.endTime.isAfter(now)}');
      
      if (semester.startTime.isBefore(now) && semester.endTime.isAfter(now)) {
        activeSemester = semester;
        break;
      }
    }

    if (activeSemester != null) {
      print('✅ تم العثور على الفصل النشط: ${activeSemester.typeSemester}');
      return activeSemester;
    } else {
      print('⚠️ لا يوجد فصل دراسي نشط حالياً');
      
      // استخدام أحدث فصل دراسي كبديل
      final latestSemester = allSemesters.first;
      print('🔄 استخدام أحدث فصل كبديل: ${latestSemester.typeSemester}');
      return latestSemester;
    }
  } catch (e) {
    print('❌ خطأ في جلب الفصل الحالي: $e');
    return null;
  }
}
//إنشاء فصل جديد
  @override
  Future<SemesterModel> createSemester(SemesterModel semester) async {
    try {
      print('🚀 إنشاء فصل دراسي جديد: ${semester.typeSemester}');

      final docRef = semester.copyWith(
        id: semester.id.isEmpty ? _generateSemesterId() : semester.id,
      );

      await semestersCollection
          .doc(docRef.id)
          .set(docRef.toEntity().toDocument());

      print('✅ تم إنشاء الفصل الدراسي بنجاح: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إنشاء الفصل الدراسي: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSemester(SemesterModel semester) async {
    try {
      print('✏️ تحديث الفصل الدراسي: ${semester.id}');

      await semestersCollection
          .doc(semester.id)
          .update(semester.toEntity().toDocument());

      print('✅ تم تحديث الفصل الدراسي بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الفصل الدراسي: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSemester(String semesterId) async {
    try {
      print('🗑️ حذف الفصل الدراسي: $semesterId');
      
      // حذف جميع المواد أولاً
      final courses = await getSemesterCourses(semesterId);
      for (final course in courses) {
        await deleteCourse(semesterId, course.id);
      }
      
      await semestersCollection.doc(semesterId).delete();
      print('✅ تم حذف الفصل الدراسي بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الفصل الدراسي: $e');
      rethrow;
    }
  }

  @override
Future<List<CoursesModel>> getSemesterCourses(String semesterId) async {
  try {
    print('🔍 جلب مواد الفصل الدراسي: $semesterId');
    // التحقق من هيكل البيانات أولاً
    await checkDataStructure(semesterId);

    final querySnapshot = await semestersCollection
        .doc(semesterId)
        .collection('courses')
        .get();

    final courses = <CoursesModel>[];
    
    for (final doc in querySnapshot.docs) {
      try {
        // جلب المادة الأساسية
        final course = _documentToCourse(doc);
        
        if (course.isEmpty) continue;
        
        // جلب المجموعات الخاصة بهذه المادة
        final groups = await getCourseGroups(semesterId, course.id);
        
        // إنشاء المادة مع المجموعات
        final courseWithGroups = course.copyWith(groups: groups);
        courses.add(courseWithGroups);
        
        print('✅ تم جلب المادة: ${course.name} مع ${groups.length} مجموعة');
      } catch (e) {
        print('❌ خطأ في جلب المادة ${doc.id}: $e');
      }
    }
    
    courses.sort((a, b) => a.name.compareTo(b.name));

    print('✅ تم جلب ${courses.length} مادة للفصل: $semesterId');
    return courses;
  } catch (e) {
    print('❌ خطأ في جلب مواد الفصل: $e');
    rethrow;
  }
}

// ✅ دالة لتنظيف البيانات التالفة
Future<void> cleanupCorruptedData() async {
  try {
    print('🧹 بدء تنظيف البيانات التالفة...');
    
    int deletedCount = 0;
    
    // تنظيف الفصول التالفة
    final semestersSnapshot = await semestersCollection.get();
    for (final doc in semestersSnapshot.docs) {
      try {
        final semester = _documentToSemester(doc);
        if (semester.isEmpty) {
          await semestersCollection.doc(doc.id).delete();
          deletedCount++;
          print('🗑️ تم حذف الفصل التالف: ${doc.id}');
        }
      } catch (e) {
        // إذا فشل التحويل، احذف المستند
        await semestersCollection.doc(doc.id).delete();
        deletedCount++;
        print('🗑️ تم حذف الفصل التالف (خطأ في التحويل): ${doc.id}');
      }
    }
    
    print('✅ تم الانتهاء من تنظيف البيانات. تم حذف $deletedCount سجل تالف');
  } catch (e) {
    print('❌ خطأ في تنظيف البيانات التالفة: $e');
  }
}

  @override
  Future<CoursesModel> getCourse(String semesterId, String courseId) async {
    try {
      print('🔍 جلب المادة: $courseId من الفصل: $semesterId');

      final doc = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (!doc.exists) {
        throw Exception('المادة غير موجودة');
      }

      final course = _documentToCourse(doc);
      
      // جلب المجموعات التابعة للمادة
      final groups = await getCourseGroups(semesterId, courseId);
      final courseWithGroups = course.copyWith(groups: groups);

      print('✅ تم جلب المادة بنجاح: ${course.name}');
      return courseWithGroups;
    } catch (e) {
      print('❌ خطأ في جلب المادة: $e');
      rethrow;
    }
  }

  @override
  Future<CoursesModel> addCourse(String semesterId, CoursesModel course) async {
    try {
      print('🚀 إضافة مادة جديدة: ${course.name}');

      final docRef = course.copyWith(
        id: course.id.isEmpty ? _generateCourseId() : course.id,
      );

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(docRef.id)
          .set(docRef.toEntity().toDocument());

      print('✅ تم إضافة المادة بنجاح: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إضافة المادة: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCourse(String semesterId, CoursesModel course) async {
    try {
      print('✏️ تحديث المادة: ${course.id}');

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(course.id)
          .update(course.toEntity().toDocument());

      print('✅ تم تحديث المادة بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث المادة: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCourse(String semesterId, String courseId) async {
    try {
      print('🗑️ حذف المادة: $courseId');
      
      // حذف جميع المجموعات أولاً
      final groups = await getCourseGroups(semesterId, courseId);
      for (final group in groups) {
        await deleteGroup(semesterId, courseId, group.id);
      }
      
      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .delete();

      print('✅ تم حذف المادة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المادة: $e');
      rethrow;
    }
  }

  @override
  Future<List<GroupModel>> getCourseGroups(String semesterId, String courseId) async {
    try {
      print('🔍 جلب مجموعات المادة: $courseId');

      final querySnapshot = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .get();

      final groups = <GroupModel>[];
    
    for (final doc in querySnapshot.docs) {
      try {
        final group = _documentToGroup(doc);
        if (!group.isEmpty) {
          groups.add(group);
          
          // جلب الطلاب للمجموعة
          final students = await getGroupStudents(semesterId, courseId, group.id);
          print('   📋 المجموعة: ${group.name} - الدكتور: ${group.nameDoctor} - الطلاب: ${students.length}');
        }
      } catch (e) {
        print('❌ خطأ في جلب المجموعة ${doc.id}: $e');
      }
    }
      groups.sort((a, b) => a.name.compareTo(b.name));

      print('✅ تم جلب ${groups.length} مجموعة للمادة: $courseId');
      // طباعة تفاصيل كل مجموعة
    for (final group in groups) {
      print('   📋 المجموعة: ${group.name} - الدكتور: ${group.nameDoctor}');
      
      // جلب الطلاب إذا أردت
      final students = await getGroupStudents(semesterId, courseId, group.id);
      print('   👥 عدد الطلاب: ${students.length}');
    }
      return groups;
    } catch (e) {
      print('❌ خطأ في جلب مجموعات المادة: $e');
      rethrow;
    }
  }

  @override
  Future<GroupModel> addGroup(String semesterId, String courseId, GroupModel group) async {
    try {
      print('🚀 إضافة مجموعة جديدة: ${group.name}');

      final docRef = group.copyWith(
        id: group.id.isEmpty ? _generateGroupId() : group.id,
      );

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(docRef.id)
          .set(docRef.toEntity().toDocument());

      print('✅ تم إضافة المجموعة بنجاح: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إضافة المجموعة: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGroup(String semesterId, String courseId, GroupModel group) async {
    try {
      print('✏️ تحديث المجموعة: ${group.id}');

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(group.id)
          .update(group.toEntity().toDocument());

      print('✅ تم تحديث المجموعة بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث المجموعة: $e');
      rethrow;
    }
  }

  // إدارة الطلاب
  @override
  Future<List<StudentModel>> getGroupStudents(String semesterId, String courseId, String groupId) async {
    try {
      print('🔍 جلب طلاب المجموعة: $groupId');

      final querySnapshot = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .get();

      final students = querySnapshot.docs.map(_documentToStudent).toList();
      students.sort((a, b) => a.name.compareTo(b.name));

      print('✅ تم جلب ${students.length} طالب في المجموعة: $groupId');
      return students;
    } catch (e) {
      print('❌ خطأ في جلب طلاب المجموعة: $e');
      rethrow;
    }
  }

  @override
  Future<StudentModel> addStudent(String semesterId, String courseId, String groupId, StudentModel student) async {
    try {
      print('🚀 إضافة طالب جديد: ${student.name}');

      // التحقق من عدم وجود طالب بنفس الرقم الجامعي
      final existingStudent = await _findStudentByStudentId(
        semesterId, courseId, groupId, student.studentId
      );
      
      if (existingStudent != null) {
        throw Exception('الطالب موجود مسبقاً بالرقم الجامعي: ${student.studentId}');
      }

      final docRef = student.copyWith(
        id: student.id.isEmpty ? _generateStudentId() : student.id,
      );

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .doc(docRef.id)
          .set(docRef.toEntity().toDocument());

      print('✅ تم إضافة الطالب بنجاح: ${docRef.name}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إضافة الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStudent(String semesterId, String courseId, String groupId, StudentModel student) async {
    try {
      print('✏️ تحديث بيانات الطالب: ${student.name}');

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .doc(student.id)
          .update(student.toEntity().toDocument());

      print('✅ تم تحديث بيانات الطالب بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث بيانات الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteStudent(String semesterId, String courseId, String groupId, String studentId) async {
    try {
      print('🗑️ حذف الطالب: $studentId');

      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .doc(studentId)
          .delete();

      print('✅ تم حذف الطالب بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentModel>> importStudentsFromExcel({
    required String semesterId,
    required String courseId,
    required String groupId,
    required List<Map<String, dynamic>> excelData,
  }) async {
    try {
      print('📊 بدء استيراد ${excelData.length} طالب من Excel');
      print('📍 الفصل: $semesterId, المادة: $courseId, المجموعة: $groupId');

      final List<StudentModel> importedStudents = [];
      final List<String> errors = [];
      int successCount = 0;

      for (int i = 0; i < excelData.length; i++) {
        try {
          final row = excelData[i];

        // ✅ تحويل البيانات من Excel إلى StudentModel
        final student = _createStudentFromExcel(row);

          // التحقق من البيانات الأساسية
          if (student.name.isEmpty || student.studentId.isEmpty ) {
            errors.add('صف ${i + 1}: بيانات ناقصة (الاسم، الرقم الجامعي، )');
            continue;
          }

          // التحقق من عدم التكرار
          final existingStudent = await _findStudentByStudentId(
            semesterId, courseId, groupId, student.studentId
          );

          if (existingStudent != null) {
            errors.add('صف ${i + 1}: الطالب موجود مسبقاً ${student.studentId}');
            continue;
          }

          // إضافة الطالب
          final addedStudent = await _addStudentToGroup(
          semesterId, courseId, groupId, student
        );

        importedStudents.add(addedStudent);
        successCount++;
        
        print('✅ تم إضافة الطالب: ${student.name} (${student.studentId})');

        } catch (e) {
          errors.add('صف ${i + 1}: خطأ - ${e.toString()}');
          print('❌ خطأ في معالجة الصف ${i + 1}: $e');
        }
      }

      print('🎉 تم استيراد $successCount طالب بنجاح');
      if (errors.isNotEmpty) {
        print('⚠️ ${errors.length} خطأ خلال الاستيراد:');
        errors.forEach(print);
      }

      return importedStudents;
    } catch (e) {
      print('❌ خطأ في استيراد الطلاب من Excel: $e');
      rethrow;
    }
  }

  // ✅ دالة لإنشاء طالب من بيانات Excel (بدون تفعيل حساب)
StudentModel _createStudentFromExcel(Map<String, dynamic> excelRow) {
  return StudentModel(
    id: '', // سيتم توليده تلقائياً
    name: excelRow['name']?.toString().trim() ?? '',
    studentId: excelRow['student_id']?.toString().trim() ?? '',
  );
}

// ✅ دالة لإضافة طالب إلى المجموعة (بدون تفعيل حساب)
Future<StudentModel> _addStudentToGroup(
  String semesterId, 
  String courseId, 
  String groupId, 
  StudentModel student
) async {
  try {
    print('🚀 إضافة طالب جديد: ${student.name}');

    final docRef = student.copyWith(
      id: student.id.isEmpty ? _generateStudentId() : student.id,
    );

    await semestersCollection
        .doc(semesterId)
        .collection('courses')
        .doc(courseId)
        .collection('group')
        .doc(groupId)
        .collection('student')
        .doc(docRef.id)
        .set(docRef.toEntity().toDocument());

    print('✅ تم إضافة الطالب بنجاح: ${docRef.name}');
    return docRef;
  } catch (e) {
    print('❌ خطأ في إضافة الطالب: $e');
    rethrow;
  }
}

  @override
  Future<void> copyStudentsToGroup({
    required String sourceSemesterId,
    required String sourceCourseId,
    required String sourceGroupId,
    required String targetSemesterId,
    required String targetCourseId,
    required String targetGroupId,
  }) async {
    try {
      print('📋 نسخ الطلاب من مجموعة إلى أخرى');

      final sourceStudents = await getGroupStudents(
        sourceSemesterId, sourceCourseId, sourceGroupId
      );

      print('🔍 تم جلب ${sourceStudents.length} طالب من المجموعة المصدر');

      for (final student in sourceStudents) {
        try {
          // إنشاء نسخة جديدة من الطالب بنفس البيانات
          final newStudent = student.copyWith(id: _generateStudentId());
          
          // التحقق من عدم التكرار في المجموعة الهدف
          final existingStudent = await _findStudentByStudentId(
            targetSemesterId, targetCourseId, targetGroupId, newStudent.studentId
          );

          if (existingStudent == null) {
            await addStudent(
              targetSemesterId, targetCourseId, targetGroupId, newStudent
            );
          }
        } catch (e) {
          print('⚠️ خطأ في نسخ الطالب ${student.name}: $e');
        }
      }

      print('✅ تم نسخ الطلاب بنجاح');
    } catch (e) {
      print('❌ خطأ في نسخ الطلاب: $e');
      rethrow;
    }
  }

  // دالة مساعدة للبحث عن طالب بالرقم الجامعي
  Future<StudentModel?> _findStudentByStudentId(
    String semesterId, String courseId, String groupId, String studentId
  ) async {
    try {
      final querySnapshot = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .where('student_id', isEqualTo: studentId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return _documentToStudent(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // تحديث دالة حذف المجموعة لحذف الطلاب أولاً
  @override
  Future<void> deleteGroup(String semesterId, String courseId, String groupId) async {
    try {
      print('🗑️ حذف المجموعة: $groupId');
      
      // حذف جميع الطلاب أولاً
      final students = await getGroupStudents(semesterId, courseId, groupId);
      for (final student in students) {
        await deleteStudent(semesterId, courseId, groupId, student.id);
      }
      
      await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .delete();

      print('✅ تم حذف المجموعة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المجموعة: $e');
      rethrow;
    }
  }

  Future<void> checkDataStructure(String semesterId) async {
  try {
    print('🔍 التحقق من هيكل البيانات للفصل: $semesterId');
    
    final semesterDoc = await semestersCollection.doc(semesterId).get();
    if (!semesterDoc.exists) {
      print('❌ الفصل غير موجود: $semesterId');
      return;
    }
    
    final coursesSnapshot = await semestersCollection
        .doc(semesterId)
        .collection('courses')
        .get();
    
    print('📊 عدد المواد في الفصل: ${coursesSnapshot.docs.length}');
    
    for (final courseDoc in coursesSnapshot.docs) {
      print('📚 المادة: ${courseDoc.id} - ${courseDoc['name']}');
      
      final groupsSnapshot = await semestersCollection
          .doc(semesterId)
          .collection('courses')
          .doc(courseDoc.id)
          .collection('group')
          .get();
      
      print('   👥 عدد المجموعات: ${groupsSnapshot.docs.length}');
      
      for (final groupDoc in groupsSnapshot.docs) {
        print('      🎯 المجموعة: ${groupDoc.id} - ${groupDoc['name']}');
        
        final studentsSnapshot = await semestersCollection
            .doc(semesterId)
            .collection('courses')
            .doc(courseDoc.id)
            .collection('group')
            .doc(groupDoc.id)
            .collection('student')
            .get();
        
        print('         👤 عدد الطلاب: ${studentsSnapshot.docs.length}');
      }
    }
  } catch (e) {
    print('❌ خطأ في التحقق من هيكل البيانات: $e');
  }
}

  String _generateStudentId() {
    return 'student_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateSemesterId() {
    return 'semester_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateCourseId() {
    return 'course_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateGroupId() {
    return 'group_${DateTime.now().millisecondsSinceEpoch}';
  }
}
import 'package:semester_repository/semester_repository.dart';
/*
 * 📅 مسؤول عن عمليات الفصول والمواد المضافَة
 * 
 * الهيكل:
 * الفصول → المواد → المجموعات → الطلاب
 * 
 * العمليات المتسلسلة:
 * 1. حذف الفصل ← حذف جميع مواده
 * 2. حذف المادة ← حذف جميع مجموعاتها
 * 3. حذف المجموعة ← حذف جميع طلابها
 */
abstract class SemesterRepository {
  /// جلب المواد التي يشرف عليها دكتور محدد في الفصل الحالي
  Future<List<CoursesModel>> getCoursesByGroupDoctor(String doctorId);

  /// جلب المواد التي يوجد بها طالب محدد في الفصل الحالي
  Future<List<CoursesModel>> getCoursesByStudent(String studentId);

  // جلب جميع الفصول الدراسية
  Future<List<SemesterModel>> getAllSemesters();
  
  // جلب الفصل الحالي
  Future<SemesterModel?> getCurrentSemester();
  
  // إنشاء فصل دراسي جديد
  Future<SemesterModel> createSemester(SemesterModel semester);
  
  // تحديث فصل دراسي
  Future<void> updateSemester(SemesterModel semester);
  
  // حذف فصل دراسي
  Future<void> deleteSemester(String semesterId);
  
  // جلب جميع المواد في فصل دراسي
  Future<List<CoursesModel>> getSemesterCourses(String semesterId);
  
  // جلب مادة محددة
  Future<CoursesModel> getCourse(String semesterId, String courseId);
  
  // إضافة مادة جديدة
  Future<CoursesModel> addCourse(String semesterId, CoursesModel course);
  
  // تحديث مادة
  Future<void> updateCourse(String semesterId, CoursesModel course);
  
  // حذف مادة
  Future<void> deleteCourse(String semesterId, String courseId);
  
  // جلب المجموعات في مادة
  Future<List<GroupModel>> getCourseGroups(String semesterId, String courseId);
  
  // إضافة مجموعة جديدة
  Future<GroupModel> addGroup(String semesterId, String courseId, GroupModel group);
  
  // تحديث مجموعة
  Future<void> updateGroup(String semesterId, String courseId, GroupModel group);
  
  // حذف مجموعة
  Future<void> deleteGroup(String semesterId, String courseId, String groupId);
  // إدارة الطلاب
  Future<List<StudentModel>> getGroupStudents(String semesterId, String courseId, String groupId);
  Future<StudentModel> addStudent(String semesterId, String courseId, String groupId, StudentModel student);
  Future<void> updateStudent(String semesterId, String courseId, String groupId, StudentModel student);
  Future<void> deleteStudent(String semesterId, String courseId, String groupId, String studentId);
  
  // استيراد الطلاب من Excel
  Future<List<StudentModel>> importStudentsFromExcel({
    required String semesterId,
    required String courseId,
    required String groupId,
    required List<Map<String, dynamic>> excelData,
  });
  
  // نسخ الطلاب من مجموعة إلى أخرى
  Future<void> copyStudentsToGroup({
    required String sourceSemesterId,
    required String sourceCourseId,
    required String sourceGroupId,
    required String targetSemesterId,
    required String targetCourseId,
    required String targetGroupId,
  });
  // ✅ دالة لتنظيف البيانات التالفة
Future<void> cleanupCorruptedData() ;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AdvertisementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String file;
  final bool isImportant;
  final DateTime? expiryDate;

  const AdvertisementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.file,
    this.isImportant = false,
    this.expiryDate,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': Timestamp.fromDate(time),
      'file': file,
      'isImportant': isImportant,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  factory AdvertisementEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      // معالجة حقل الوقت
      Timestamp timestamp;
      if (doc['time'] is Timestamp) {
        timestamp = doc['time'] as Timestamp;
      } else if (doc['time'] is Map) {
        final timeMap = doc['time'] as Map<String, dynamic>;
        timestamp = Timestamp(timeMap['_seconds'] as int, timeMap['_nanoseconds'] as int);
      } else {
        timestamp = Timestamp.now();
      }

      // معالجة تاريخ الانتهاء
      Timestamp? expiryTimestamp;
      if (doc['expiryDate'] is Timestamp) {
        expiryTimestamp = doc['expiryDate'] as Timestamp;
      } else if (doc['expiryDate'] is Map) {
        final expiryMap = doc['expiryDate'] as Map<String, dynamic>;
        expiryTimestamp = Timestamp(expiryMap['_seconds'] as int, expiryMap['_nanoseconds'] as int);
      }

      return AdvertisementEntity(
        id: doc['id'] as String? ?? '',
        title: doc['title'] as String? ?? '',
        description: doc['description'] as String? ?? '',
        time: timestamp.toDate(),
        file: doc['file'] as String? ?? '',
        isImportant: doc['isImportant'] as bool? ?? false,
        expiryDate: expiryTimestamp?.toDate(),
      );
    } catch (e) {
      print('❌ خطأ في fromDocument للإعلان: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [id, title, description, time, file, isImportant, expiryDate];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final DateTime date;
  final String studentId;
  final String studentName;
  final bool isPresent;
  final String? notes;

  const AttendanceEntity({
    required this.id,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.isPresent,
    this.notes,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'student_id': studentId,
      'student_name': studentName,
      'is_present': isPresent,
      'notes': notes,
    };
  }

  factory AttendanceEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      return AttendanceEntity(
        id: doc['id'] as String? ?? '',
        date: (doc['date'] as Timestamp).toDate(),
        studentId: doc['student_id'] as String? ?? '',
        studentName: doc['student_name'] as String? ?? '',
        isPresent: doc['is_present'] as bool? ?? false,
        notes: doc['notes'] as String?,
      );
    } catch (e) {
      print('❌ خطأ في fromDocument للحضور: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [id, date, studentId, studentName, isPresent, notes];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CurriculumEntity extends Equatable {
  final String id;
  final String description;
  final DateTime time;
  final String file;

  const CurriculumEntity({
    required this.id,
    required this.description,
    required this.time,
    required this.file,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'description': description,
      'time': Timestamp.fromDate(time),
      'file': file,
    };
  }

  factory CurriculumEntity.fromDocument(Map<String, dynamic> doc) {
  try {
    print('🏗️ بناء CurriculumEntity من المستند: ${doc['id']}');
    
    // معالجة حقل الوقت
    Timestamp timestamp;
    if (doc['time'] is Timestamp) {
      timestamp = doc['time'] as Timestamp;
    } else if (doc['time'] is Map) {
      // إذا كان الوقت مخزناً كـ Map (من Firestore)
      final timeMap = doc['time'] as Map<String, dynamic>;
      timestamp = Timestamp(timeMap['_seconds'] as int, timeMap['_nanoseconds'] as int);
    } else {
      print('❌ نوع غير معروف لحقل time: ${doc['time'].runtimeType}');
      timestamp = Timestamp.now();
    }
    
    return CurriculumEntity(
      id: doc['id'] as String? ?? '',
      description: doc['description'] as String? ?? '',
      time: timestamp.toDate(),
      file: doc['file'] as String? ?? '',
    );
  } catch (e) {
    print('❌ خطأ في fromDocument: $e');
    print('📋 بيانات المستند: $doc');
    rethrow;
  }
}

  @override
  List<Object?> get props => [id, description, time, file];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExamGradeEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String examType; // نصفي، نهائي، عملي
  final double grade;
  final double maxGrade;
  final DateTime examDate;

  const ExamGradeEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examType,
    required this.grade,
    required this.maxGrade,
    required this.examDate,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'exam_type': examType,
      'grade': grade,
      'max_grade': maxGrade,
      'exam_date': Timestamp.fromDate(examDate),
    };
  }

  factory ExamGradeEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      return ExamGradeEntity(
        id: doc['id'] as String? ?? '',
        studentId: doc['student_id'] as String? ?? '',
        studentName: doc['student_name'] as String? ?? '',
        examType: doc['exam_type'] as String? ?? 'نهائي',
        grade: (doc['grade'] as num?)?.toDouble() ?? 0.0,
        maxGrade: (doc['max_grade'] as num?)?.toDouble() ?? 100.0,
        examDate: (doc['exam_date'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('❌ خطأ في fromDocument لدرجة الامتحان: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [id, studentId, studentName, examType, grade, maxGrade, examDate];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudentHomeworkEntity extends Equatable {
  final String idStudent;
  final String name;
  final String file;
  final String title;
  final double fromMark;
  final DateTime? submitTime;

  const StudentHomeworkEntity({
    required this.idStudent,
    required this.name,
    required this.file,
    required this.title,
    required this.fromMark,
    this.submitTime,
  });

  Map<String, dynamic> toDocument() {
    return {
      'idStudent': idStudent,
      'name': name,
      'file': file,
      'title': title,
      'fromMark': fromMark,
      'submitTime': submitTime != null ? Timestamp.fromDate(submitTime!) : null,
    };
  }

  factory StudentHomeworkEntity.fromDocument(Map<String, dynamic> doc) {
    return StudentHomeworkEntity(
      idStudent: doc['idStudent'] as String,
      name: doc['name'] as String,
      file: doc['file'] as String,
      title: doc['title'] as String,
      fromMark: (doc['fromMark'] as num).toDouble(),
      submitTime: doc['submitTime'] != null ? (doc['submitTime'] as Timestamp).toDate() : null,
    );
  }

  @override
  List<Object?> get props => [idStudent, name, file, title, fromMark , submitTime];
}

class HomeworkEntity extends Equatable {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String file;
  final double maxMark;
  final List<StudentHomeworkEntity> students;

  const HomeworkEntity({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.file,
    required this.maxMark,
    this.students = const [],
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'description': description,
      'file': file,
      'maxMark': maxMark,
    };
  }

  factory HomeworkEntity.fromDocument(Map<String, dynamic> doc) {
    return HomeworkEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      start: (doc['start'] as Timestamp).toDate(),
      end: (doc['end'] as Timestamp).toDate(),
      description: doc['description'] as String,
      file: doc['file'] as String,
      maxMark: (doc['maxMark'] as num).toDouble(),
      students: [],
    );
  }

  @override
  List<Object?> get props => [id, title, start, end, description, file, maxMark, students];
}
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AdvertisementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String file;
  final bool isImportant;
  final DateTime? expiryDate;

  const AdvertisementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.file,
    this.isImportant = false,
    this.expiryDate,
  });

  static final empty = AdvertisementModel(
    id: '',
    title: '',
    description: '',
    time: DateTime(0),
    file: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  AdvertisementModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? time,
    String? file,
    bool? isImportant,
    DateTime? expiryDate,
  }) {
    return AdvertisementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      file: file ?? this.file,
      isImportant: isImportant ?? this.isImportant,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  AdvertisementEntity toEntity() {
    return AdvertisementEntity(
      id: id,
      title: title,
      description: description,
      time: time,
      file: file,
      isImportant: isImportant,
      expiryDate: expiryDate,
    );
  }
  factory AdvertisementModel.fromEntity(AdvertisementEntity entity) {
    return AdvertisementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      time: entity.time,
      file: entity.file,
      isImportant: entity.isImportant,
      expiryDate: entity.expiryDate,
    );
  }

  @override
  List<Object?> get props => [id, title, description, time, file, isImportant, expiryDate];
}
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AttendanceRecordModel extends Equatable {
  final String id;
  final DateTime date;
  final String studentId;
  final String studentName;
  final bool isPresent;
  final String? notes;

  const AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.isPresent,
    this.notes,
  });

  static final empty = AttendanceRecordModel(
    id: '',
    date: DateTime.now(),
    studentId: '',
    studentName: '',
    isPresent: false,
  );

  bool get isEmpty => this == AttendanceRecordModel.empty;
  bool get isNotEmpty => this != AttendanceRecordModel.empty;

  AttendanceRecordModel copyWith({
    String? id,
    DateTime? date,
    String? studentId,
    String? studentName,
    bool? isPresent,
    String? notes,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      isPresent: isPresent ?? this.isPresent,
      notes: notes ?? this.notes,
    );
  }

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      id: id,
      date: date,
      studentId: studentId,
      studentName: studentName,
      isPresent: isPresent,
      notes: notes,
    );
  }

  factory AttendanceRecordModel.fromEntity(AttendanceEntity entity) {
    return AttendanceRecordModel(
      id: entity.id,
      date: entity.date,
      studentId: entity.studentId,
      studentName: entity.studentName,
      isPresent: entity.isPresent,
      notes: entity.notes,
    );
  }

  @override
  List<Object?> get props => [id, date, studentId, studentName, isPresent, notes];
}
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class CurriculumModel extends Equatable {
  final String id;
  final String description;
  final DateTime time;
  final String file;
  

  const CurriculumModel({
    required this.id,
    required this.description,
    required this.time,
    required this.file,
  });

  static final empty = CurriculumModel(
    id: '',
    description: '',
    time: DateTime.now(),
    file: '',
  );

  bool get isEmpty => this == CurriculumModel.empty;
  bool get isNotEmpty => this != CurriculumModel.empty;

  CurriculumModel copyWith({
    String? id,
    String? description,
    DateTime? time,
    String? file,
  }) {
    return CurriculumModel(
      id: id ?? this.id,
      description: description ?? this.description,
      time: time ?? this.time,
      file: file ?? this.file,
    );
  }

  CurriculumEntity toEntity() {
    return CurriculumEntity(
      id: id,
      description: description,
      time: time,
      file: file,
    );
  }

  factory CurriculumModel.fromEntity(CurriculumEntity entity) {
    return CurriculumModel(
      id: entity.id,
      description: entity.description,
      time: entity.time,
      file: entity.file,
    );
  }

  @override
  List<Object?> get props => [id, description, time, file];
}
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class ExamGradeModel extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String examType; // نصفي، نهائي، عملي
  final double grade;
  final double maxGrade;
  final DateTime examDate;

  const ExamGradeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examType,
    required this.grade,
    required this.maxGrade,
    required this.examDate,
  });

  static final empty = ExamGradeModel(
    id: '',
    studentId: '',
    studentName: '',
    examType: '',
    grade: 0.0,
    maxGrade: 100.0,
    examDate: DateTime.now(),
  );

  bool get isEmpty => this == ExamGradeModel.empty;
  bool get isNotEmpty => this != ExamGradeModel.empty;

  double get percentage => (grade / maxGrade) * 100;

  ExamGradeModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? examType,
    double? grade,
    double? maxGrade,
    DateTime? examDate,
  }) {
    return ExamGradeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      examType: examType ?? this.examType,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      examDate: examDate ?? this.examDate,
    );
  }

  ExamGradeEntity toEntity() {
    return ExamGradeEntity(
      id: id,
      studentId: studentId,
      studentName: studentName,
      examType: examType,
      grade: grade,
      maxGrade: maxGrade,
      examDate: examDate,
    );
  }

  factory ExamGradeModel.fromEntity(ExamGradeEntity entity) {
    return ExamGradeModel(
      id: entity.id,
      studentId: entity.studentId,
      studentName: entity.studentName,
      examType: entity.examType,
      grade: entity.grade,
      maxGrade: entity.maxGrade,
      examDate: entity.examDate,
    );
  }

  @override
  List<Object?> get props => [id, studentId, studentName, examType, grade, maxGrade, examDate];
}
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class StudentHomeworkModel extends Equatable {
  final String idStudent;
  final String name;
  final String file;
  final String title;
  final double fromMark;
  final DateTime? submitTime;

  const StudentHomeworkModel({
    required this.idStudent,
    required this.name,
    required this.file,
    required this.title,
    required this.fromMark,
    this.submitTime,
  });

  static final empty = StudentHomeworkModel(
    idStudent: '',
    name: '',
    file: '',
    title: '',
    fromMark: 0.0,
    submitTime: null,
  );

  bool get isEmpty => this == StudentHomeworkModel.empty;
  bool get isNotEmpty => this != StudentHomeworkModel.empty;
  // ✅ التحقق إذا تم التسليم
  bool get isSubmitted => file.isNotEmpty && submitTime != null;
  // ✅ التحقق إذا تم التقييم
  bool get isGraded => fromMark > 0;

  StudentHomeworkModel copyWith({
    String? idStudent,
    String? name,
    String? file,
    String? title,
    double? fromMark,
    DateTime? submitTime,
  }) {
    return StudentHomeworkModel(
      idStudent: idStudent ?? this.idStudent,
      name: name ?? this.name,
      file: file ?? this.file,
      title: title ?? this.title,
      fromMark: fromMark ?? this.fromMark,
      submitTime: submitTime ?? this.submitTime,
    );
  }

  StudentHomeworkEntity toEntity() {
    return StudentHomeworkEntity(
      idStudent: idStudent,
      name: name,
      file: file,
      title: title,
      fromMark: fromMark,
      submitTime: submitTime,
    );
  }

  factory StudentHomeworkModel.fromEntity(StudentHomeworkEntity entity) {
    return StudentHomeworkModel(
      idStudent: entity.idStudent,
      name: entity.name,
      file: entity.file,
      title: entity.title,
      fromMark: entity.fromMark,
      submitTime: entity.submitTime,
    );
  }

  @override
  List<Object?> get props => [idStudent, name, file, title, fromMark , submitTime];
}

class HomeworkModel extends Equatable {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String file;
  final double maxMark;
  final List<StudentHomeworkModel> students;

  const HomeworkModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.file,
    required this.maxMark,
    this.students = const [],
  });

  static final empty = HomeworkModel(
    id: '',
    title: '',
    start: DateTime.now(),
    end: DateTime.now(),
    description: '',
    file: '',
    maxMark: 0.0,
  );

  bool get isEmpty => this == HomeworkModel.empty;
  bool get isNotEmpty => this != HomeworkModel.empty;

  // التحقق إذا كان الواجب نشط (قبل تاريخ الانتهاء)
  bool get isActive => DateTime.now().isBefore(end);

  // التحقق إذا كان الواجب منتهي
  bool get isExpired => DateTime.now().isAfter(end);

  // الحصول على الوقت المتبقي
  Duration get timeRemaining => end.difference(DateTime.now());

   // ✅ إحصائيات التسليمات
  int get totalStudents => students.length;
  int get submittedCount => students.where((s) => s.isSubmitted).length;
  int get gradedCount => students.where((s) => s.isGraded).length;
  double get submissionRate => totalStudents > 0 ? submittedCount / totalStudents : 0.0;

  HomeworkModel copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    String? file,
    double? maxMark,
    List<StudentHomeworkModel>? students,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      file: file ?? this.file,
      maxMark: maxMark ?? this.maxMark,
      students: students ?? this.students,
    );
  }

  HomeworkEntity toEntity() {
    return HomeworkEntity(
      id: id,
      title: title,
      start: start,
      end: end,
      description: description,
      file: file,
      maxMark: maxMark,
      students: students.map((student) => student.toEntity()).toList(),
    );
  }

  factory HomeworkModel.fromEntity(HomeworkEntity entity) {
    return HomeworkModel(
      id: entity.id,
      title: entity.title,
      start: entity.start,
      end: entity.end,
      description: entity.description,
      file: entity.file,
      maxMark: entity.maxMark,
      students: entity.students.map((student) => StudentHomeworkModel.fromEntity(student)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, start, end, description, file, maxMark, students];
}
// subjective_content_model.dart
import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

/// 📚 نموذج يمثل المحتوى التعليمي الكامل لمجموعة
class SubjectiveContentModel extends Equatable {
  final List<CurriculumModel> curricula;
  final List<HomeworkModel> homeworks;
  final List<AdvertisementModel> advertisements;
  final List<ExamGradeModel> examGrades;
  final List<AttendanceRecordModel> attendanceRecords;

  const SubjectiveContentModel({
    required this.curricula,
    required this.homeworks,
    this.advertisements = const [],
    this.examGrades = const [],
    this.attendanceRecords = const [],
  });

  static const empty = SubjectiveContentModel(
    curricula: [],
    homeworks: [],
    advertisements: [],
    examGrades: [],
    attendanceRecords: [],
  );

  bool get isEmpty => this == SubjectiveContentModel.empty;
  bool get isNotEmpty => this != SubjectiveContentModel.empty;

  @override
  List<Object?> get props => [curricula, homeworks, advertisements, examGrades, attendanceRecords];
}
AttendanceRecordModel يحتوي علي معرف الخاص به و تاريخ المحاضرة و اسم المحاضرة بالتسلسل مثل "المحاضرة 1 او محاضرة 2 او .........الخ " و قائمة باسماء و ارقام قيد الطلبة حضور و غياب كل وحدة بروحها و ملاجظات لكل طالب  
ولا يتم تغير تاريخ المحاضرة في حالة التعديل او غيره 
وحيت انه يتم حفظ هذا البيانات في هيكل الداتا 
 */