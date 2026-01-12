// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class FirebaseSubjectiveRepository implements SubjectiveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SemesterRepository _semesterRepository;
  final NotificationsRepository? _notificationsRepository;

  FirebaseSubjectiveRepository({
    required SemesterRepository semesterRepository,
    NotificationsRepository? notificationsRepository,
  }) : _semesterRepository = semesterRepository,
       _notificationsRepository = notificationsRepository;

  // ========== 🔧 دوال مساعدة لإنشاء المسارات ==========
  
  /// 📍 الحصول على المسار الأساسي للمحتوى التعليمي
  DocumentReference _getContentDocRef({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) {
    print('📍 الحصول على المسار الأساسي للمحتوى التعليمي');
    print('semesterId:${semesterId}');
    print('courseId:${courseId}');
    print('groupId:${groupId}');
    getSubjectivePath(semesterId, courseId, groupId);
      
    return _firestore
        .collection('semester')
        .doc(semesterId)//semester_1762185935132
        .collection('courses')
        .doc(courseId)//course_1762635223526
        .collection('group')
        .doc(groupId);// group_1762981301864_0 , group_1763468825427_1
  }

  /// 📍 الحصول على document محتوى مجموعة معينة
  DocumentReference _getGroupSubjectiveDocRef({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) {
    return _getContentDocRef(
    semesterId: semesterId,
    courseId: courseId,
    groupId: groupId,
    ).collection('subjective')
    .doc('content');
  }

  /// 📍 الحصول على Collection الفرعية
  CollectionReference _getSubCollectionRef({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String collectionName,
  }) {
    return _getGroupSubjectiveDocRef(
      semesterId: semesterId,
      courseId: courseId,
      groupId: groupId,
    ).collection(collectionName);
  }

  // ========== 🎯 دوال الربط مع Semester ==========

  @override
  Future<String> getCurrentSemesterId() async {
    try {
      print('🔍 جلب معرف الفصل الدراسي الحالي');
      
      final currentSemester = await _semesterRepository.getCurrentSemester();
      
      if (currentSemester == null) {
        throw Exception('لا يوجد فصل دراسي نشط حالياً');
      }
      
      print('✅ تم جلب معرف الفصل الحالي: ${currentSemester.id}');
      return currentSemester.id;
    } catch (e) {
      print('❌ خطأ في جلب معرف الفصل الحالي: $e');
      rethrow;
    }
  }

  @override
  Future<List<CoursesModel>> getDoctorGroups(String doctorId) async {
    try {
      print('🔍 جلب مجموعات الدكتور: $doctorId');
      final doctorCourses = await _semesterRepository.getCoursesByGroupDoctor(doctorId);
      print('✅ تم جلب ${doctorCourses.length} مادة للدكتور: $doctorId');
      return doctorCourses;
    } catch (e) {
      print('❌ خطأ في جلب مجموعات الدكتور: $e');
      rethrow;
    }
  }

  @override
  Future<List<CoursesModel>> getStudentGroups(String studentId) async {
    try {
      print('🔍 جلب مجموعات الطالب: $studentId');
      final studentCourses = await _semesterRepository.getCoursesByStudent(studentId);
      print('✅ تم جلب ${studentCourses.length} مادة للطالب: $studentId');
      return studentCourses;
    } catch (e) {
      print('❌ خطأ في جلب مجموعات الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentModel>> getGroupStudents({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب طلاب المجموعة: $groupId');
      final querySnapshot = await _firestore
          .collection('semester')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .collection('student')
          .get();

      final students = querySnapshot.docs
          .map((doc) => _mapStudentDocument(doc))
          .where((student) => student.isNotEmpty)
          .toList();

      students.sort((a, b) => a.name.compareTo(b.name));
      print('✅ تم جلب ${students.length} طالب في المجموعة: $groupId');
      return students;
    } catch (e) {
      print('❌ خطأ في جلب طلاب المجموعة: $e');
      rethrow;
    }
  }

  @override
  Future<SubjectiveContentModel> getGroupSubjectiveContent({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب المحتوى التعليمي للمجموعة: $groupId');

      final [
        curricula,
        homeworks,
        advertisements,
        examGrades,
        attendanceRecords,
      ] = await Future.wait([
        getGroupCurricula(semesterId: semesterId, courseId: courseId, groupId: groupId),
        getGroupHomeworks(semesterId: semesterId, courseId: courseId, groupId: groupId),
        getGroupAdvertisements(semesterId: semesterId, courseId: courseId, groupId: groupId),
        getExamGrades(semesterId: semesterId, courseId: courseId, groupId: groupId),
        getGroupAttendanceRecords(semesterId: semesterId, courseId: courseId, groupId: groupId),
      ]);

      final content = SubjectiveContentModel(
        curricula: curricula.cast<CurriculumModel>(),
        homeworks: homeworks.cast<HomeworkModel>(),
        advertisements: advertisements.cast<AdvertisementModel>(),
        attendanceRecords: attendanceRecords.cast<AttendanceRecordModel>(),
        examGrades: examGrades.cast<ExamGradeModel>(),
      );

      print('✅ تم جلب المحتوى التعليمي: ${curricula.length} منهج، ${homeworks.length} واجب، ${advertisements.length} إعلان');
      return content;
    } catch (e) {
      print('❌ خطأ في جلب المحتوى التعليمي: $e');
      rethrow;
    }
  }

  // ========== 📚 دوال إدارة المناهج ==========

  @override
  Future<List<CurriculumModel>> getGroupCurricula({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب مناهج المجموعة: $groupId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'curricula',
      ).get();

      final curricula = querySnapshot.docs
          .map((doc) => CurriculumModel.fromEntity(
                CurriculumEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .where((curriculum) => curriculum.isNotEmpty)
          .toList();

      curricula.sort((a, b) => b.time.compareTo(a.time));
      print('✅ تم جلب ${curricula.length} منهج للمجموعة: $groupId');
      return curricula;
    } catch (e) {
      print('❌ خطأ في جلب مناهج المجموعة: $e');
      rethrow;
    }
  }

  @override
  Future<void> addCurriculumToMultipleGroups({
    required String semesterId,
    required String courseId,
    required List<String> groupIds,
    required CurriculumModel curriculum,
  }) async {
    try {
      print('🚀 نشر المنهج لـ ${groupIds.length} مجموعة');
      
      // رفع الملف (إذا وجد)
      String fileUrl = curriculum.file;
      if (curriculum.file.isNotEmpty && !curriculum.file.startsWith('http')) {
        fileUrl = await _uploadFile(curriculum.file, 'curriculum');
      }

      final finalCurriculum = curriculum.copyWith(file: fileUrl);
      final batch = _firestore.batch();

      for (final groupId in groupIds) {
        final docRef = _getSubCollectionRef(
          semesterId: semesterId,
          courseId: courseId,
          groupId: groupId,
          collectionName: 'curricula',
        ).doc();

        final curriculumData = finalCurriculum.copyWith(id: docRef.id);
        batch.set(docRef, curriculumData.toEntity().toDocument());
        // 🔥 إرسال إشعار للطلاب في هذه المجموعة
        if (_notificationsRepository != null) {
          try {
            // الحصول على طلاب المجموعة
            final students = await getGroupStudents(
              semesterId: semesterId,
              courseId: courseId,
              groupId: groupId,
            );
            
            final studentIds = students.map((s) => s.id).toList();
            
            await _notificationsRepository.saveCurriculumNotification(
              curriculumData,
              studentIds,
            );
            
            print('📨 تم إرسال إشعارات المنهج لـ ${studentIds.length} طالب');
          } catch (e) {
            print('⚠️ خطأ في إرسال إشعارات المنهج: $e');
          }
        }
      }

      await batch.commit();
      print('✅ تم نشر المنهج بنجاح في ${groupIds.length} مجموعة');
    } catch (e) {
      print('❌ خطأ في نشر المنهج: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCurriculum({
    required String semesterId,
    required String courseId,
    required String groupId,
    required CurriculumModel curriculum,
  }) async {
    try {
      print('✏️ تحديث المنهج: ${curriculum.id}');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'curricula',
      ).doc(curriculum.id).update(curriculum.toEntity().toDocument());
      
      print('✅ تم تحديث المنهج بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث المنهج: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCurriculum({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String curriculumId,
  }) async {
    try {
      print('🗑️ حذف المنهج: $curriculumId');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'curricula',
      ).doc(curriculumId).delete();
      
      print('✅ تم حذف المنهج بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المنهج: $e');
      rethrow;
    }
  }

  // ========== 📝 دوال إدارة الواجبات ==========

  @override
  Future<List<HomeworkModel>> getGroupHomeworks({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب واجبات المجموعة: $groupId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).get();

      final homeworks = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final homework = HomeworkModel.fromEntity(
            HomeworkEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
          );
          
          final submissions = await getHomeworkSubmissions(
            semesterId: semesterId,
            courseId: courseId,
            groupId: groupId,
            homeworkId: homework.id,
          );
          
          return homework.copyWith(students: submissions);
        })
      );

      homeworks.sort((a, b) => b.end.compareTo(a.end));
      print('✅ تم جلب ${homeworks.length} واجب للمجموعة: $groupId');
      return homeworks;
    } catch (e) {
      print('❌ خطأ في جلب واجبات المجموعة: $e');
      rethrow;
    }
  }

  @override
  Future<void> addHomeworkToMultipleGroups({
    required String semesterId,
    required String courseId,
    required List<String> groupIds,
    required HomeworkModel homework,
  }) async {
    try {
      print('🚀 نشر واجب لـ ${groupIds.length} مجموعة');
      
      String fileUrl = homework.file;
      if (homework.file.isNotEmpty && !homework.file.startsWith('http')) {
        fileUrl = await _uploadFile(homework.file, 'homework');
      }

      final finalHomework = homework.copyWith(file: fileUrl);
      final batch = _firestore.batch();

      for (final groupId in groupIds) {
        final docRef = _getSubCollectionRef(
          semesterId: semesterId,
          courseId: courseId,
          groupId: groupId,
          collectionName: 'homework',
        ).doc();

        batch.set(docRef, finalHomework.toEntity().toDocument());

      // 🔥 إرسال إشعار للطلاب في هذه المجموعة
        if (_notificationsRepository != null) {
          try {
            // الحصول على طلاب المجموعة
            final students = await getGroupStudents(
              semesterId: semesterId,
              courseId: courseId,
              groupId: groupId,
            );
            
            final studentIds = students.map((s) => s.id).toList();
            
            await _notificationsRepository.saveHomeworkNotification(
              finalHomework.copyWith(id: docRef.id),
              studentIds,
            );
            
            print('📨 تم إرسال إشعارات الواجب لـ ${studentIds.length} طالب');
          } catch (e) {
            print('⚠️ خطأ في إرسال إشعارات الواجب: $e');
          }
        }
      }

      await batch.commit();
      print('✅ تم نشر الواجب بنجاح في جميع المجموعات');
    } catch (e) {
      print('❌ خطأ في نشر الواجب: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required HomeworkModel homework,
  }) async {
    try {
      print('✏️ تحديث الواجب: ${homework.id}');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homework.id).update(homework.toEntity().toDocument());
      
      print('✅ تم تحديث الواجب بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الواجب: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
  }) async {
    try {
      print('🗑️ حذف الواجب: $homeworkId');
      
      final submissions = await getHomeworkSubmissions(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        homeworkId: homeworkId,
      );

      final batch = _firestore.batch();
      for (final submission in submissions) {
        final studentDocRef = _getSubCollectionRef(
          semesterId: semesterId,
          courseId: courseId,
          groupId: groupId,
          collectionName: 'homework',
        ).doc(homeworkId).collection('student').doc(submission.idStudent);
        
        batch.delete(studentDocRef);
      }

      final homeworkDocRef = _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homeworkId);
      
      batch.delete(homeworkDocRef);
      await batch.commit();
      
      print('✅ تم حذف الواجب وإجاباته بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الواجب: $e');
      rethrow;
    }
  }

  // ========== 👨‍🎓 دوال إدارة إجابات الطلاب ==========

  @override
  Future<StudentHomeworkModel> submitHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
    required StudentHomeworkModel submission,
  }) async {
    try {
      print('🚀 تقديم إجابة واجب: ${submission.title}');

      final existing = await _getStudentHomeworkSubmission(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        homeworkId: homeworkId,
        studentId: submission.idStudent,
      );
      
      if (existing != null) {
        throw Exception('لقد قمت بتقديم الإجابة مسبقاً');
      }

      final submissionRef = _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homeworkId).collection('student').doc(submission.idStudent);

      await submissionRef.set(submission.toEntity().toDocument());

      print('✅ تم تقديم الإجابة بنجاح: ${submission.title}');
      return submission.copyWith(submitTime: DateTime.now());
    } catch (e) {
      print('❌ خطأ في تقديم الإجابة: $e');
      rethrow;
    }
  }

  @override
  Future<void> gradeHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
    required String studentId,
    required double mark,
  }) async {
    try {
      print('✏️ تقييم إجابة الطالب: $studentId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final submission = await _getStudentHomeworkSubmission(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        homeworkId: homeworkId,
        studentId: studentId,
      );
      
      if (submission == null) {
        throw Exception('لم يقم الطالب بتقديم الإجابة');
      }

      final updatedSubmission = submission.copyWith(fromMark: mark);

      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homeworkId).collection('student').doc(studentId)
        .update(updatedSubmission.toEntity().toDocument());

      // 🔥 إرسال إشعار التقييم
      if (_notificationsRepository != null) {
        try {
          // الحصول على تفاصيل الواجب
          final homeworkDoc = await _getSubCollectionRef(
            semesterId: semesterId,
            courseId: courseId,
            groupId: groupId,
            collectionName: 'homework',
          ).doc(homeworkId).get();
          
          if (homeworkDoc.exists) {
            final homeworkData = homeworkDoc.data() as Map<String, dynamic>;
            final maxMark = homeworkData['maxMark'] as double? ?? 100.0;
            
            await _notificationsRepository.saveHomeworkGradeNotification(
              homeworkId,
              studentId,
              mark,
              maxMark,
            );
            
            print('📨 تم إرسال إشعار التقييم');
          }
        } catch (e) {
          print('⚠️ خطأ في إرسال إشعار التقييم: $e');
        }
      }

      print('✅ تم تقييم إجابة الطالب بنجاح: $mark');
    } catch (e) {
      print('❌ خطأ في تقييم إجابة الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentHomeworkModel>> getHomeworkSubmissions({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
  }) async {
    try {
      print('🔍 جلب إجابات الواجب: $homeworkId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homeworkId).collection('student').get();

      return querySnapshot.docs
          .map((doc) => StudentHomeworkModel.fromEntity(
                StudentHomeworkEntity.fromDocument({...doc.data(), 'id': doc.id})
              ))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب إجابات الواجب: $e');
      return [];
    }
  }

  Future<StudentHomeworkModel?> _getStudentHomeworkSubmission({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
    required String studentId,
  }) async {
    try {
      final doc = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'homework',
      ).doc(homeworkId).collection('student').doc(studentId).get();

      return doc.exists 
          ? StudentHomeworkModel.fromEntity(
              StudentHomeworkEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
            )
          : null;
    } catch (e) {
      print('⚠️ خطأ في جلب إجابة الطالب: $e');
      return null;
    }
  }

  // ========== 📢 دوال إدارة الإعلانات ==========

  @override
  Future<List<AdvertisementModel>> getGroupAdvertisements({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب إعلانات المجموعة: $groupId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);
      
      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'advertisements',
      ).get();

      final advertisements = querySnapshot.docs
          .map((doc) => AdvertisementModel.fromEntity(
                AdvertisementEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .where((ad) => ad.isNotEmpty)
          .toList();

      // ترتيب: المهمة أولاً، ثم الأحدث
      advertisements.sort((a, b) {
        if (a.isImportant && !b.isImportant) return -1;
        if (!a.isImportant && b.isImportant) return 1;
        return b.time.compareTo(a.time);
      });

      print('✅ تم جلب ${advertisements.length} إعلان للمجموعة: $groupId');
      return advertisements;
    } catch (e) {
      print('❌ خطأ في جلب الإعلانات: $e');
      rethrow;
    }
  }

  @override
  Future<void> addAdvertisementToMultipleGroups({
    required String semesterId,
    required String courseId,
    required List<String> groupIds,
    required AdvertisementModel advertisement,
  }) async {
    try {
      print('🚀 نشر إعلان لـ ${groupIds.length} مجموعة');
      
      String fileUrl = advertisement.file;
      if (advertisement.file.isNotEmpty && !advertisement.file.startsWith('http')) {
        fileUrl = await _uploadFile(advertisement.file, 'advertisement');
      }

      final finalAdvertisement = advertisement.copyWith(file: fileUrl);
      final batch = _firestore.batch();

      for (final groupId in groupIds) {
        final docRef = _getSubCollectionRef(
          semesterId: semesterId,
          courseId: courseId,
          groupId: groupId,
          collectionName: 'advertisements',
        ).doc();

        final adWithId = finalAdvertisement.copyWith(id: docRef.id);
        batch.set(docRef, adWithId.toEntity().toDocument());
        // 🔥 إرسال إشعار للطلاب في هذه المجموعة
        if (_notificationsRepository != null) {
          try {
            // الحصول على طلاب المجموعة
            final students = await getGroupStudents(
              semesterId: semesterId,
              courseId: courseId,
              groupId: groupId,
            );
            
            final studentIds = students.map((s) => s.id).toList();
            
            // استخدام الدالة الجديدة لإعلانات المجموعات
            await _notificationsRepository.saveGroupAdvertisementNotification(
              advertisement: adWithId,
              studentIds: studentIds,
            );
            
            print('📨 تم إرسال إشعارات الإعلان لـ ${studentIds.length} طالب');
          } catch (e) {
            print('⚠️ خطأ في إرسال إشعارات الإعلان: $e');
          }
        }
      }

      await batch.commit();
      print('✅ تم نشر الإعلان بنجاح في ${groupIds.length} مجموعة');
    } catch (e) {
      print('❌ خطأ في نشر الإعلان: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAdvertisement({
    required String semesterId,
    required String courseId,
    required String groupId,
    required AdvertisementModel advertisement,
  }) async {
    try {
      print('✏️ تحديث الإعلان: ${advertisement.id}');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'advertisements',
      ).doc(advertisement.id).update(advertisement.toEntity().toDocument());
      
      print('✅ تم تحديث الإعلان بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الإعلان: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAdvertisement({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String advertisementId,
  }) async {
    try {
      print('🗑️ حذف الإعلان: $advertisementId');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'advertisements',
      ).doc(advertisementId).delete();
      
      print('✅ تم حذف الإعلان بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الإعلان: $e');
      rethrow;
    }
  }

  // ========== 📊 دوال إدارة درجات الامتحانات ==========

  @override
  Future<List<ExamGradeModel>> getExamGrades({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب درجات الامتحانات للمجموعة: $groupId');
      
      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'exam_grades',
      ).get();

      final examGrades = querySnapshot.docs
          .map((doc) => ExamGradeModel.fromEntity(
                ExamGradeEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .toList();

      examGrades.sort((a, b) => a.studentName.compareTo(b.studentName));
      print('✅ تم جلب ${examGrades.length} درجة امتحان');
      return examGrades;
    } catch (e) {
      print('❌ خطأ في جلب درجات الامتحانات: $e');
      rethrow;
    }
  }

  @override
  Future<void> addExamGrade({
    required String semesterId,
    required String courseId,
    required String groupId,
    required ExamGradeModel examGrade,
  }) async {
    try {
      print('🚀 إضافة درجة امتحان للطالب: ${examGrade.studentName}');

      final docId = examGrade.id.isEmpty ? _generateExamGradeId() : examGrade.id;
      final examGradeWithId = examGrade.copyWith(id: docId);

      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'exam_grades',
      ).doc(docId).set(examGradeWithId.toEntity().toDocument());

      // 🔥 إرسال إشعار للطالب
      if (_notificationsRepository != null) {
        try {
          await _notificationsRepository.saveExamGradeNotification(examGradeWithId);
          print('📨 تم إرسال إشعار درجة الامتحان');
        } catch (e) {
          print('⚠️ خطأ في إرسال إشعار درجة الامتحان: $e');
        }
      }

      print('✅ تم إضافة درجة الامتحان بنجاح');
    } catch (e) {
      print('❌ خطأ في إضافة درجة الامتحان: $e');
      rethrow;
    }
  }

  Future<void> updateExamGrade({
    required String semesterId,
    required String courseId,
    required String groupId,
    required ExamGradeModel examGrade,
  }) async {
    try {
      print('✏️ تحديث درجة الامتحان: ${examGrade.id}');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'exam_grades',
      ).doc(examGrade.id).update(examGrade.toEntity().toDocument());
      
      print('✅ تم تحديث درجة الامتحان بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث درجة الامتحان: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteExamGrade({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String examGradeId,
  }) async {
    try {
      print('🗑️ حذف درجة الامتحان: $examGradeId');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'exam_grades',
      ).doc(examGradeId).delete();

      print('✅ تم حذف درجة الامتحان بنجاح: $examGradeId');
    } catch (e) {
      print('❌ خطأ في حذف درجة الامتحان: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteExamColumnGrades({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String examType,
  }) async {
    try {
      print('🗑️ حذف جميع درجات الامتحان من النوع: $examType');

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'exam_grades',
      ).where('exam_type', isEqualTo: examType).get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ تم حذف ${querySnapshot.docs.length} درجة امتحان من النوع: $examType');
    } catch (e) {
      print('❌ خطأ في حذف درجات العمود: $e');
      rethrow;
    }
  }

  // ========== 📝 دوال الحضور والغياب ==========

  @override
  Future<List<AttendanceRecordModel>> getAttendance({
    required String semesterId,
    required String courseId,
    required String groupId,
    required DateTime date,
  }) async {
    try {
      print('🔍 جلب سجل الحضور للمجموعة: $groupId بتاريخ: $date');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

      final attendanceRecords = querySnapshot.docs
          .map((doc) => AttendanceRecordModel.fromEntity(
                AttendanceEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .toList();

      attendanceRecords.sort((a, b) => b.date.compareTo(a.date));
      print('✅ تم جلب ${attendanceRecords.length} سجل حضور');
      return attendanceRecords;
    } catch (e) {
      print('❌ خطأ في جلب سجل الحضور: $e');
      rethrow;
    }
  }

  /// 📅 جلب جميع سجلات الحضور للمجموعة
  Future<List<AttendanceRecordModel>> getGroupAttendanceRecords({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🔍 جلب جميع سجلات الحضور للمجموعة: $groupId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).orderBy('date', descending: true).get();

      final attendanceRecords = querySnapshot.docs
          .map((doc) => AttendanceRecordModel.fromEntity(
                AttendanceEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .toList();

      print('✅ تم جلب ${attendanceRecords.length} سجل حضور');
      return attendanceRecords;
    } catch (e) {
      print('❌ خطأ في جلب سجلات الحضور: $e');
      return [];
    }
  }

  @override
  Future<void> updateAttendance({
    required String semesterId,
    required String courseId,
    required String groupId,
    required AttendanceRecordModel attendance,
  }) async {
    try {
      print('✏️ تحديث سجل الحضور: ${attendance.id}');
      
      if (attendance.id.isEmpty) {
        throw Exception('معرف سجل الحضور فارغ');
      }

      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).doc(attendance.id).set(attendance.toEntity().toDocument(), SetOptions(merge: true));

      print('✅ تم تحديث سجل الحضور بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث سجل الحضور: $e');
      rethrow;
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getGroupLectures({
    required String semesterId,
    required String courseId,
    required String groupId,
    String? doctorId,
  }) async {
    try {
      print('🔍 جلب المحاضرات السابقة للمجموعة: $groupId');
      await checkCurriculumStructure(semesterId, courseId, groupId,);

      final querySnapshot = await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).orderBy('date', descending: true).get();

      final lectures = querySnapshot.docs
          .map((doc) => AttendanceRecordModel.fromEntity(
                AttendanceEntity.fromDocument({...doc.data() as Map<String, dynamic>, 'id': doc.id})
              ))
          .toList();

      print('✅ تم جلب ${lectures.length} محاضرة');
      return lectures;
    } catch (e) {
      print('❌ خطأ في جلب المحاضرات: $e');
      throw e;
    }
  }

  @override
  Future<void> addLecture({
    required String semesterId,
    required String courseId,
    required String groupId,
    required AttendanceRecordModel lecture,
    required String doctorId,
  }) async {
    try {
      print('➕ إضافة محاضرة جديدة: ${lecture.lectureTitle}');
      
      final docId = lecture.id.isEmpty 
          ? 'lecture_${DateTime.now().millisecondsSinceEpoch}' 
          : lecture.id;

      final lectureWithDoctor = lecture.copyWith(
        id: docId,
        studentNotes: {
          ...lecture.studentNotes,
          '_createdBy': doctorId,
          '_createdAt': DateTime.now().toIso8601String(),
        },
      );

      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).doc(docId).set(lectureWithDoctor.toEntity().toDocument());

      print('✅ تم إضافة المحاضرة بنجاح: ${lecture.lectureTitle}');
    } catch (e) {
      print('❌ خطأ في إضافة المحاضرة: $e');
      throw e;
    }
  }

  @override
  Future<void> updateLecture({
    required String semesterId,
    required String courseId,
    required String groupId,
    required AttendanceRecordModel lecture,
    required String doctorId,
  }) async {
    try {
      print('✏️ تحديث المحاضرة: ${lecture.id}');
      
      final lectureWithDoctor = lecture.copyWith(
        studentNotes: {
          ...lecture.studentNotes,
          '_updatedBy': doctorId,
          '_updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).doc(lecture.id).update(lectureWithDoctor.toEntity().toDocument());

      print('✅ تم تحديث المحاضرة بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث المحاضرة: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteLecture({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String lectureId,
    required String doctorId,
  }) async {
    try {
      print('🗑️ حذف المحاضرة: $lectureId');
      
      await _getSubCollectionRef(
        semesterId: semesterId,
        courseId: courseId,
        groupId: groupId,
        collectionName: 'attendance_records',
      ).doc(lectureId).delete();

      print('✅ تم حذف المحاضرة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف المحاضرة: $e');
      throw e;
    }
  }

  @override
  Future<void> checkCurriculumStructure(String semesterId, String courseId, String groupId) async {
    try {
    print('🔍 بدء فحص هيكل Firestore...');
    
    // فحص الإعلانات
    final adsRef = _getSubCollectionRef(
      semesterId: semesterId,
      courseId: courseId,
      groupId: groupId,
      collectionName: 'advertisements',
    );
    
    final adsSnapshot = await adsRef.get();
    print('📊 عدد الإعلانات في قاعدة البيانات: ${adsSnapshot.docs.length}');
    
    for (final doc in adsSnapshot.docs) {
      print('📢 الإعلان ${doc.id}:');
      final data = doc.data()as Map<String, dynamic>;
      print('   - العنوان: ${data['title']}');
      print('   - الوصف: ${data['description']}');
      print('   - الوقت: ${data['time']} (${data['time']?.runtimeType})');
      print('   - الملف: ${data['file']}');
      print('   - المهم: ${data['isImportant']}');
    }
    
    // فحص المناهج
    final curriculaRef = _getSubCollectionRef(
      semesterId: semesterId,
      courseId: courseId,
      groupId: groupId,
      collectionName: 'curricula',
    );
    
    final curriculaSnapshot = await curriculaRef.get();
    print('📊 عدد المناهج في قاعدة البيانات: ${curriculaSnapshot.docs.length}');
    
    for (final doc in curriculaSnapshot.docs) {
      print('📚 المنهج ${doc.id}:');
      final data = doc.data()as Map<String, dynamic>;
      print('   - الوصف: ${data['description']}');
      print('   - الوقت: ${data['time']} (${data['time']?.runtimeType})');
      print('   - الملف: ${data['file']}');
    }
    
    print('✅ اكتمال فحص الهيكل');
    } catch (e) {
      print('❌ خطأ في فحص الهيكل: $e');
    }
 }

  // ========== 🔧 دوال مساعدة ==========

  /// 📤 رفع ملف (تطبيق حسب احتياجك)
  Future<String> _uploadFile(String filePath, String type) async {
    // TODO: قم بتنفيذ رفع الملف إلى Firebase Storage حسب نظامك
    print('📤 رفع ملف $type: $filePath');
    return "https://example.com/${type}_file_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// 🔄 تحويل مستند الطالب إلى StudentModel
  StudentModel _mapStudentDocument(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final studentId = data['student_id']?.toString() ?? data['userID']?.toString() ?? '';
      
      return StudentModel(
        id: doc.id,
        name: data['name']?.toString() ?? 'طالب غير محدد',
        studentId: studentId,
      );
    } catch (e) {
      print('❌ خطأ في تحويل مستند الطالب ${doc.id}: $e');
      return StudentModel.empty;
    }
  }

  /// 🔧 إنشاء معرف لدرجة الامتحان
  String _generateExamGradeId() {
    return 'exam_grade_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 📍 الحصول على المسار الكامل للمحتوى التعليمي
  String getSubjectivePath(String semesterId, String courseId, String groupId) {
    return 'semester/$semesterId/courses/$courseId/group/$groupId/subjective/content';
  }

  /// 🔍 التحقق من وجود المجموعة
  Future<bool> checkGroupExists({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      final doc = await _firestore
          .collection('semester')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .collection('group')
          .doc(groupId)
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ خطأ في التحقق من وجود المجموعة: $e');
      return false;
    }
  }

  /// 🧹 حذف جميع بيانات subjective لمجموعة
  Future<void> deleteAllSubjectiveData({
    required String semesterId,
    required String courseId,
    required String groupId,
  }) async {
    try {
      print('🧹 حذف جميع بيانات المحتوى التعليمي للمجموعة: $groupId');
      
      final collections = [
        'curricula',
        'homework',
        'advertisements',
        'attendance_records',
        'exam_grades',
        'archived_curricula',
      ];
      
      for (final collection in collections) {
        try {
          final querySnapshot = await _getSubCollectionRef(
            semesterId: semesterId,
            courseId: courseId,
            groupId: groupId,
            collectionName: collection,
          ).get();
          
          final batch = _firestore.batch();
          for (final doc in querySnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          
          print('✅ تم حذف مجموعة $collection');
        } catch (e) {
          print('⚠️ خطأ في حذف مجموعة $collection: $e');
        }
      }
      
      print('✅ تم حذف جميع بيانات المحتوى التعليمي بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف جميع البيانات: $e');
      rethrow;
    }
  }
}