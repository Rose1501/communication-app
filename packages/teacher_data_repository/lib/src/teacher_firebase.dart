import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

class FirebaseTeacherDataRepository implements TeacherDataRepository {
  final CollectionReference teachersCollection =
      FirebaseFirestore.instance.collection('teachers_data');

  @override
  Future<TeacherDataModel> getTeacherData(String teacherId) async {
    try {
      print('🔍 جلب بيانات الأستاذ: $teacherId');
      
      final doc = await teachersCollection.doc(teacherId).get();
      
      if (!doc.exists) {
        print('⚠️ لم يتم العثور على بيانات للأستاذ');
        // إرجاع نموذج فارغ
        return TeacherDataModel.empty.copyWith(teacherId: teacherId);
      }
      
      final entity = TeacherDataEntity.fromDocument({
        ...doc.data() as Map<String, dynamic>,
        'teacherId': doc.id,
      });
      
      print('✅ تم جلب بيانات الأستاذ بنجاح');
      return TeacherDataModel.fromEntity(entity);
    } catch (e) {
      print('❌ خطأ في جلب بيانات الأستاذ: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTeacherData(TeacherDataModel teacherData) async {
    try {
      print('✏️ تحديث بيانات الأستاذ: ${teacherData.teacherId}');
      
      await teachersCollection
          .doc(teacherData.teacherId)
          .set(teacherData.toEntity().toDocument(), SetOptions(merge: true));
      
      print('✅ تم تحديث بيانات الأستاذ بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث بيانات الأستاذ: $e');
      rethrow;
    }
  }

  @override
Future<List<OfficeHoursModel>> getOfficeHours(String teacherId) async {
  try {
    print('🔍 جلب الساعات المكتبية للأستاذ: $teacherId');
    
    final doc = await teachersCollection.doc(teacherId).get();
    
    if (!doc.exists) {
      return [];
    }
    
    final data = doc.data() as Map<String, dynamic>;
    if (data.containsKey('officeHours')) {
      final officeHours = (data['officeHours'] as List)
          .map((e) => OfficeHoursEntity.fromDocument(e as Map<String, dynamic>))
          .toList();
      
      return officeHours.map((entity) => OfficeHoursModel.fromEntity(entity)).toList();
    }
    
    return [];
  } catch (e) {
    print('❌ خطأ في جلب الساعات المكتبية: $e');
    rethrow;
  }
}


  @override
  Future<void> addOfficeHours(String teacherId, List<OfficeHoursModel> officeHoursList) async {
    try {
      print('➕ إضافة ${officeHoursList.length} ساعات مكتبية للأستاذ: $teacherId');
      
      final teacherData = await getTeacherData(teacherId);
      
      final updatedList = [
        ...teacherData.officeHours,
        ...officeHoursList.map((oh) => oh.copyWith(
          id: _generateId('oh'),
          createdAt: DateTime.now(),
        )),
      ];
      
      final updatedEntity = teacherData.copyWith(officeHours: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم إضافة الساعات المكتبية بنجاح');
    } catch (e) {
      print('❌ خطأ في إضافة الساعات المكتبية: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOfficeHours(String teacherId, OfficeHoursModel officeHours) async {
    try {
      print('✏️ تحديث ساعات مكتبية: ${officeHours.id}');
      
      final teacherData = await getTeacherData(teacherId);
      final updatedList = teacherData.officeHours
          .map((oh) => oh.id == officeHours.id ? officeHours : oh)
          .toList();
      
      final updatedEntity = teacherData.copyWith(officeHours: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم تحديث الساعات المكتبية بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الساعات المكتبية: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOfficeHours(String teacherId, String officeHoursId) async {
    try {
      print('🗑️ حذف ساعات مكتبية: $officeHoursId');
      
      final teacherData = await getTeacherData(teacherId);
      final updatedList = teacherData.officeHours
          .where((oh) => oh.id != officeHoursId)
          .toList();
      
      final updatedEntity = teacherData.copyWith(officeHours: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم حذف الساعات المكتبية بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الساعات المكتبية: $e');
      rethrow;
    }
  }

  @override
  Future<void> addTeachingCourses(String teacherId, List<TeachingCourseModel> courses) async {
    try {
      print('➕ إضافة ${courses.length} مادة دراسية للأستاذ: $teacherId');
      
      final teacherData = await getTeacherData(teacherId);
      
      final updatedList = [
        ...teacherData.teachingCourses,
        ...courses.map((course) => course.copyWith(
          id: _generateId('course'),
        )),
      ];
      
      final updatedEntity = teacherData.copyWith(teachingCourses: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم إضافة المواد الدراسية بنجاح');
    } catch (e) {
      print('❌ خطأ في إضافة المواد الدراسية: $e');
      rethrow;
    }
  }

  @override
Future<List<TeachingCourseModel>> getTeachingCourses(String teacherId) async {
  try {
    print('🔍 جلب المواد الدراسية للأستاذ: $teacherId');
    
    final doc = await teachersCollection.doc(teacherId).get();
    
    if (!doc.exists) {
      print('⚠️ لم يتم العثور على بيانات للأستاذ: $teacherId');
      return [];
    }
    
    final data = doc.data() as Map<String, dynamic>;
    
    // التحقق من وجود حقل teachingCourses
    if (!data.containsKey('teachingCourses') || 
        data['teachingCourses'] == null || 
        (data['teachingCourses'] as List).isEmpty) {
      print('ℹ️ لا توجد مواد دراسية مسجلة للأستاذ: $teacherId');
      return [];
    }
    
    // تحويل البيانات إلى TeachingCourseModel
    final courses = (data['teachingCourses'] as List)
        .map((e) => TeachingCourseEntity.fromDocument(e as Map<String, dynamic>))
        .toList();
    
    final teachingCourses = courses
        .map((entity) => TeachingCourseModel.fromEntity(entity))
        .where((course) => course.isNotEmpty)
        .toList();
    
    // ترتيب المواد حسب الاسم أو الكود
    teachingCourses.sort((a, b) => a.courseName.compareTo(b.courseName));
    
    print('✅ تم جلب ${teachingCourses.length} مادة دراسية للأستاذ: $teacherId');
    
    // طباعة تفاصيل المواد للتصحيح
    for (var course in teachingCourses) {
      print('📚 ${course.courseCode} - ${course.courseName}');
    }
    
    return teachingCourses;
  } catch (e) {
    print('❌ خطأ في جلب المواد الدراسية: $e');
    rethrow;
  }
}

  @override
  Future<void> deleteTeachingCourse(String teacherId, String courseId) async {
    try {
      print('🗑️ حذف مادة دراسية: $courseId');
      
      final teacherData = await getTeacherData(teacherId);
      final updatedList = teacherData.teachingCourses
          .where((course) => course.id != courseId)
          .toList();
      
      final updatedEntity = teacherData.copyWith(teachingCourses: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم حذف المادة الدراسية بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المادة الدراسية: $e');
      rethrow;
    }
  }

  @override
  Future<void> archiveCurricula(String teacherId,String teacherName, List<ArchivedCurriculumModel> curricula) async {
    try {
      print('📁 أرشفة ${curricula.length} منهج للأستاذ: $teacherId');
      
      final teacherData = await getTeacherData(teacherId);
      final updatedTeacherData = teacherData.copyWith(teacherName: teacherName);
      
      final updatedList = [
        ...updatedTeacherData.archivedCurricula,
        ...curricula.map((curriculum) => curriculum.copyWith(
          id: _generateId('archive'),
          archivedAt: DateTime.now(),
        )),
      ];
      
      final updatedEntity = updatedTeacherData.copyWith(archivedCurricula: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم أرشفة المناهج بنجاح');
    } catch (e) {
      print('❌ خطأ في أرشفة المناهج: $e');
      rethrow;
    }
  }

  @override
  Future<List<ArchivedCurriculumModel>> getArchivedCurricula(String teacherId) async {
    try {
      print('🔍 جلب المناهج المؤرشفة للأستاذ: $teacherId');
      
      final teacherData = await getTeacherData(teacherId);
      
      // ترتيب من الأحدث إلى الأقدم
      final sorted = List<ArchivedCurriculumModel>.from(teacherData.archivedCurricula)
        ..sort((a, b) => b.archivedAt.compareTo(a.archivedAt));
      
      print('✅ تم جلب ${sorted.length} منهج مؤرشف');
      return sorted;
    } catch (e) {
      print('❌ خطأ في جلب المناهج المؤرشفة: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreCurriculum(String teacherId, String archiveId) async {
    try {
      print('🔄 محاولة استعادة منهج مؤرشف: $archiveId');
      
      final teacherData = await getTeacherData(teacherId);
      // (اختياري) يمكنك استدعاء المنهج المؤرشف هنا إذا كنت بحاجة لاستخدامه:
      // final curriculum = teacherData.archivedCurricula.firstWhere((ac) => ac.id == archiveId);
      // هنا يمكنك إضافة المنطق لاستعادة المنهج إلى موقعه الأصلي
      
      final updatedList = teacherData.archivedCurricula
          .where((ac) => ac.id != archiveId)
          .toList();
      
      final updatedEntity = teacherData.copyWith(archivedCurricula: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم استعادة المنهج بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في استعادة المنهج: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllTeachingCourses(String teacherId) async {
    try {
      print('🗑️ حذف جميع المواد الدراسية السابقة للأستاذ: $teacherId');
      
      // الحصول على بيانات الأستاذ الحالية
      final teacherData = await getTeacherData(teacherId);
      
      // إنشاء نسخة جديدة مع قائمة مواد فارغة
      final updatedTeacherData = teacherData.copyWith(
        teachingCourses: [],
      );
      
      // حفظ التحديث
      await updateTeacherData(updatedTeacherData);
      
      print('✅ تم حذف جميع المواد الدراسية السابقة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المواد الدراسية السابقة: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTeachingCourses(String teacherId, List<TeachingCourseModel> courses) async {
    try {
      print('🔄 تحديث المواد الدراسية للأستاذ: $teacherId');
      print('📚 عدد المواد الجديدة: ${courses.length}');
      
      // 1. حذف جميع المواد الدراسية السابقة
      await deleteAllTeachingCourses(teacherId);
      
      // 2. إضافة المواد الجديدة فقط إذا كانت موجودة
      if (courses.isNotEmpty) {
        await addTeachingCourses(teacherId, courses);
        print('✅ تم تحديث المواد الدراسية بنجاح');
      } else {
        print('ℹ️ لا توجد مواد جديدة لإضافتها');
      }
    } catch (e) {
      print('❌ خطأ في تحديث المواد الدراسية: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteArchivedCurriculum(String teacherId, String archiveId) async {
    try {
      print('🗑️ حذف منهج مؤرشف: $archiveId');
      
      final teacherData = await getTeacherData(teacherId);
      final updatedList = teacherData.archivedCurricula
          .where((ac) => ac.id != archiveId)
          .toList();
      
      final updatedEntity = teacherData.copyWith(archivedCurricula: updatedList).toEntity();
      
      await teachersCollection
          .doc(teacherId)
          .set(updatedEntity.toDocument(), SetOptions(merge: true));
      
      print('✅ تم حذف المنهج المؤرشف بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المنهج المؤرشف: $e');
      rethrow;
    }
  }

  @override
  Future<List<ArchivedCurriculumModel>> searchArchivedCurricula(
    String teacherId, 
    String query
  ) async {
    try {
      print('🔍 البحث في المناهج المؤرشفة: $query');
      
      final archived = await getArchivedCurricula(teacherId);
      final lowercaseQuery = query.toLowerCase();
      
      final results = archived.where((curriculum) {
        return curriculum.courseName.toLowerCase().contains(lowercaseQuery) ||
                (curriculum.archiveDescription?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
      
      print('✅ تم العثور على ${results.length} نتيجة');
      return results;
    } catch (e) {
      print('❌ خطأ في البحث في المناهج المؤرشفة: $e');
      rethrow;
    }
  }

  String _generateId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}