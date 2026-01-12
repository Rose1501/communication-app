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