// ignore_for_file: annotate_overrides
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_repository/course_repository.dart';

class FirebaseCourseRepository implements CourseRepository {
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('all_courses');

  CourseModel _documentToCourse(DocumentSnapshot doc) {
  try {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('❌ المستند فارغ: ${doc.id}');
      return CourseModel.empty;
    }

    // ✅ معالجة المتطلبات السابقة - تحويل من ID إلى Code
    List<String> requestCourses = [];
    final rawRequests = data['request_courses'] ?? data['requset_courses'] ?? [];
    
    if (rawRequests is List) {
      for (var item in rawRequests) {
        if (item is String) {
          // إذا كان الـ ID يحتوي على "course_" فهو ID، وإلا فهو Code
          if (item.contains('course_')) {
            // سنقوم بتحويله لاحقاً
            requestCourses.add(item);
          } else {
            // إنه Code مباشر
            requestCourses.add(item);
          }
        }
      }
    }

    // ✅ معالجة الحقول التي قد تكون null
    final safeData = <String, dynamic>{
      'id': doc.id,
      'name': data['name'] ?? '',
      'code_cs': data['code_cs'] ?? '',
      'credits': data['credits'] ?? 4 ,
      'request_courses': requestCourses,
    };

    print('🔍 تحويل المادة: ${safeData['name']} (${safeData['code_cs']})- ${requestCourses.length} متطلب');
    
    final entity = CourseEntity.fromDocument(safeData);
    return CourseModel.fromEntity(entity);
  } catch (e) {
    print('❌ خطأ في تحويل مستند المادة ${doc.id}: $e');
    print('📋 بيانات المستند: ${doc.data()}');
    return CourseModel.empty;
  }
}

  @override
Future<CourseModel> addCourse(CourseModel course) async {
  try {
    print('🚀 بدء إضافة مادة جديدة: ${course.name}');

    // 🔥 التحقق من أن المتطلبات هي أكواد
    final List<String> validatedPrerequisites = [];
    for (final prereq in course.requestCourses) {
      if (prereq.isNotEmpty) {
        validatedPrerequisites.add(prereq);
      }
    }

    final courseToSave = course.copyWith(
      id: course.id.isEmpty ? _generateCourseId() : course.id,
      requestCourses: validatedPrerequisites, // استخدام الأكواد مباشرة
    );

    await coursesCollection
        .doc(courseToSave.id)
        .set(courseToSave.toEntity().toDocument());

    print('✅ تم إضافة المادة بنجاح: ${courseToSave.id}');
    print('📋 المتطلبات المخزنة: ${courseToSave.requestCourses}');
    return courseToSave;
  } catch (e) {
    print('❌ خطأ في إضافة المادة: $e');
    rethrow;
  }
}
// ✅ دالة لتنظيف البيانات التالفة
  Future<void> cleanupCorruptedData() async {
  try {
    print('🧹 بدء تنظيف البيانات التالفة...');
    
    int deletedCount = 0;
    
    // تنظيف المواد التالفة
    final coursesSnapshot = await coursesCollection.get();
    for (final doc in coursesSnapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          await coursesCollection.doc(doc.id).delete();
          deletedCount++;
          print('🗑️ تم حذف المادة التالفة (بيانات فارغة): ${doc.id}');
          continue;
        }
        
        // ✅ فحص إذا كانت البيانات تالفة
        final name = data['name']?.toString() ?? '';
        final codeCs = data['code_cs']?.toString() ?? '';
        
        if (name.isEmpty || codeCs.isEmpty) {
          await coursesCollection.doc(doc.id).delete();
          deletedCount++;
          print('🗑️ تم حذف المادة التالفة: $name ($codeCs)');
        }
      } catch (e) {
        // إذا فشل التحويل، احذف المستند
        await coursesCollection.doc(doc.id).delete();
        deletedCount++;
        print('🗑️ تم حذف المادة التالفة (خطأ في التحويل): ${doc.id}');
      }
    }
    
    print('✅ تم تنظيف $deletedCount مادة تالفة');
  } catch (e) {
    print('❌ خطأ في تنظيف البيانات التالفة: $e');
  }
}

  @override
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      print('🔍 جلب المادة بواسطة ID: $courseId');

      final docSnapshot = await coursesCollection.doc(courseId).get();

      if (!docSnapshot.exists) {
        throw Exception('المادة غير موجودة');
      }

      final course = _documentToCourse(docSnapshot);
      print('✅ تم جلب المادة: ${course.name}');
      return course;
    } catch (e) {
      print('❌ خطأ في جلب المادة: $e');
      rethrow;
    }
  }

  @override
  Future<CourseModel?> getCourseByCode(String codeCs) async {
    try {
      print('🔍 جلب المادة بواسطة الكود: $codeCs');

      final querySnapshot = await coursesCollection
          .where('code_cs', isEqualTo: codeCs)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ لم يتم العثور على مادة بالكود: $codeCs');
        return null;
      }

      final course = _documentToCourse(querySnapshot.docs.first);
      print('✅ تم جلب المادة: ${course.name}');
      return course;
    } catch (e) {
      print('❌ خطأ في جلب المادة بالكود: $e');
      rethrow;
    }
  }

  @override
  Future<List<CourseModel>> getAllCourses() async {
  try {
    print('🔍 جلب جميع المواد');

    final querySnapshot = await coursesCollection.get();

    final courses = <CourseModel>[];
    
    final Map<String, String> idToCodeMap = {};
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      print('🔍 معالجة وثيقة المادة: ${doc.id}');
      print('   - البيانات الخام: $data');
      if (data?.containsKey('request_courses') != null) {
        /*final code = data['code_cs']?.toString() ?? '';
        if (code.isNotEmpty) {
          idToCodeMap[doc.id] = code;
        }*/
        print('   - request_courses موجود: ${data?['request_courses']}');
          print('   - نوع request_courses: ${data?['request_courses'].runtimeType}');
      }else {
          print('   - ⚠️ request_courses غير موجود في البيانات');
        }
    }

    for (final doc in querySnapshot.docs) {
      final course = _documentToCourse(doc);
      if (!course.isEmpty) {
        // 🔧 تحويل متطلبات ID إلى متطلبات Code
        final List<String> convertedRequests = _convertRequestIdsToCodes(course.requestCourses, idToCodeMap);
        final updatedCourse = course.copyWith(requestCourses: convertedRequests);
        courses.add(updatedCourse);
      }
    }
    
    // ترتيب المواد أبجدياً بالاسم
    courses.sort((a, b) => a.name.compareTo(b.name));

    print('✅ تم جلب ${courses.length} مادة (تم تصفية ${querySnapshot.docs.length - courses.length} مادة فارغة)');
    return courses;
  } catch (e) {
    print('❌ خطأ في جلب جميع المواد: $e');
    rethrow;
  }
}

  @override
Future<CourseModel> updateCourse(CourseModel course) async {
  try {
    print('✏️ تحديث المادة: ${course.name}');
    print('📋 المتطلبات الجديدة: ${course.requestCourses}');

    await coursesCollection
        .doc(course.id)
        .update(course.toEntity().toDocument());

    print('✅ تم تحديث المادة بنجاح: ${course.id}');
    return course;
  } catch (e) {
    print('❌ خطأ في تحديث المادة: $e');
    rethrow;
  }
}

  @override
  Future<void> deleteCourse(String courseId) async {
    try {
      print('🗑️ حذف المادة: $courseId');
      await coursesCollection.doc(courseId).delete();
      print('✅ تم حذف المادة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المادة: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllCourses() async {
    try {
      print('🗑️ حذف جميع المواد');

      final querySnapshot = await coursesCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ تم حذف ${querySnapshot.docs.length} مادة');
    } catch (e) {
      print('❌ خطأ في حذف جميع المواد: $e');
      rethrow;
    }
  }

  @override
  Future<List<CourseModel>> searchCoursesByName(String searchTerm) async {
    try {
      print('🔍 البحث عن مواد بالاسم: $searchTerm');

      if (searchTerm.isEmpty) {
        return await getAllCourses();
      }

      final querySnapshot = await coursesCollection.get();
      final allCourses = querySnapshot.docs.map(_documentToCourse).toList();

      // البحث محلياً (للبحث الجزئي)
      final filteredCourses = allCourses.where((course) =>
          course.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          course.codeCs.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

      filteredCourses.sort((a, b) => a.name.compareTo(b.name));

      print('✅ تم العثور على ${filteredCourses.length} مادة بالبحث: $searchTerm');
      return filteredCourses;
    } catch (e) {
      print('❌ خطأ في البحث عن المواد: $e');
      rethrow;
    }
  }

  /// دالة جديدة لاستيراد البيانات من ملف Excel (JSON)
  /// تقبل بيانات على شكل List<Map<String, dynamic>>
  Future<Map<String, dynamic>> importCoursesFromExcelData(List<Map<String, dynamic>> excelData) async {
    try {
      print('📥 بدء استيراد البيانات من ملف Excel');
      print('📊 عدد السجلات المستوردة: ${excelData.length}');

      int successCount = 0;
      int errorCount = 0;
      int updateCount = 0;
      final List<String> errors = [];

      // الحصول على جميع المواد الحالية للتحقق من التكرار
      final existingCourses = await getAllCourses();
      final existingCoursesMap = {for (var course in existingCourses) course.codeCs: course};

      for (int i = 0; i < excelData.length; i++) {
        try {
          final row = excelData[i];
          final rowNumber = i + 1;

          // 🔧 دعم الأعمدة العربية والإنجليزية
          final String name = _getFieldValue(row, ['اسم_المادة', 'name']);
          final String codeCs = _getFieldValue(row, ['رمز_المادة', 'code_cs']);
          final dynamic creditsRaw = _getFieldValue(row, ['الساعات_المعتمدة', 'credits'], isString: false);
          final dynamic requestsRaw = _getFieldValue(row, ['المتطلبات_السابقة', 'requset_courses', 'request_courses'], isString: false);

        // التحقق من البيانات المطلوبة
        if (name.isEmpty || codeCs.isEmpty) {
          errorCount++;
          errors.add('❌ صف $rowNumber: بيانات ناقصة (يجب وجود اسم المادة ورمز المادة)');
          continue;
        }

        // تحضير البيانات
        final int credits = _parseCredits(creditsRaw);
        final List<String> requestCourses = await _parseRequestCourses(requestsRaw);

        print('📋 معالجة المادة: $name ($codeCs) - $credits ساعة - ${requestCourses.length} متطلب');

          // التحقق إذا كانت المادة موجودة مسبقاً
          final existingCourse = existingCoursesMap[codeCs];
          
          if (existingCourse != null) {
            // تحديث المادة الموجودة
            final updatedCourse = existingCourse.copyWith(
              name: name,
              credits: credits,
              requestCourses: requestCourses,
            );

            await updateCourse(updatedCourse);
            updateCount++;
            print('🔄 تم تحديث المادة: $name ($codeCs)');
          } else {
            // إضافة مادة جديدة
            final newCourse = CourseModel(
              id: _generateCourseId(),
              name: name,
              codeCs: codeCs,
              requestCourses: requestCourses,
              credits: credits,
            );

            await addCourse(newCourse);
            successCount++;
            print('✅ تم إضافة المادة: $name ($codeCs)');
          }
        } catch (e) {
          errorCount++;
          errors.add('❌ صف ${i + 1}: خطأ - ${e.toString()}');
          print('❌ خطأ في معالجة الصف ${i + 1}: $e');
        }
      }

      final result = {
        'success': true,
        'totalRecords': excelData.length,
        'addedCount': successCount,
        'updatedCount': updateCount,
        'errorCount': errorCount,
        'errors': errors,
        'message': 'تم استيراد $successCount مادة جديدة، تحديث $updateCount مادة، مع $errorCount خطأ'
      };

      print('📊 نتائج الاستيراد:');
      print('   ✅ تمت إضافة: $successCount مادة');
      print('   🔄 تم تحديث: $updateCount مادة');
      print('   ❌ أخطاء: $errorCount');
      print('   📋 إجمالي: ${excelData.length} سجل');

      return result;

    } catch (e) {
      print('❌ خطأ عام في استيراد البيانات: $e');
      return {
        'success': false,
        'totalRecords': excelData.length,
        'addedCount': 0,
        'updatedCount': 0,
        'errorCount': excelData.length,
        'errors': ['خطأ عام في الاستيراد: ${e.toString()}'],
        'message': 'فشل في استيراد البيانات'
      };
    }
  }
// 🔥 دالة جديدة لتحليل المتطلبات باستخدام الأكواد مباشرة
List<String> _parseRequestCourses(dynamic requestCourses) {
  if (requestCourses == null) return [];
  
  List<String> requestCodes = [];
  
  if (requestCourses is List) {
    requestCodes = requestCourses.whereType<String>().toList();
  } else if (requestCourses is String) {
    if (requestCourses.isEmpty) return [];
    
    requestCodes = requestCourses
        .split(RegExp(r'[,،\n\r]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  
  print('🔍 تحليل المتطلبات: ${requestCodes.join(', ')}');
  return requestCodes;
}
/// 🔧 دالة مساعدة للحصول على قيمة الحقل من الأعمدة العربية أو الإنجليزية
dynamic _getFieldValue(Map<String, dynamic> row, List<String> possibleKeys, {bool isString = true}) {
  for (final key in possibleKeys) {
    if (row.containsKey(key)) {
      final value = row[key];
      if (value != null) {
        return isString ? value.toString() : value;
      }
    }
  }
  return isString ? '' : null;
}

/// 🔧 تحويل متطلبات ID إلى متطلبات Code
List<String> _convertRequestIdsToCodes(List<String> requestIds, Map<String, String> idToCodeMap) {
  if (requestIds.isEmpty) return [];
  
  final List<String> requestCodes = [];
  
  for (final requestId in requestIds) {
    // إذا كان ليس ID (لا يحتوي على course_)، استخدمه مباشرة
    if (!requestId.contains('course_')) {
      requestCodes.add(requestId);
      continue;
    }
    
    // إذا كان ID، ابحث عن الكود في الخريطة
    final courseCode = idToCodeMap[requestId];
    if (courseCode != null && courseCode.isNotEmpty) {
      requestCodes.add(courseCode);
    } else {
      print('⚠️ لم يتم العثور على كود للمادة: $requestId');
      requestCodes.add(requestId); // الاحتفاظ بالـ ID إذا لم يتم العثور
    }
  }
  
  return requestCodes;
}
  /// دالة مساعدة لتحويل الاعتمادات إلى int
  int _parseCredits(dynamic credits) {
    if (credits == null) return 3; // قيمة افتراضية
    
    if (credits is int) return credits;
    if (credits is String) {
      return int.tryParse(credits) ?? 3;
    }
    return 3;
  }

/// دالة مساعدة لتوليد ID فريد للمادة
  String _generateCourseId() {
    return 'course_${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final result = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      result.write(chars[random % chars.length]);
    }
    
    return result.toString();
  }

}