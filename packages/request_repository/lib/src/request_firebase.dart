import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:request_repository/request_repository.dart';

class FirebaseRequestRepository implements RequestRepository {
  final CollectionReference requestsCollection =
      FirebaseFirestore.instance.collection('Request');

  StudentRequestModel _documentToRequest(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      print('📄 بيانات المستند من Firestore:');
      print('   - id: ${doc.id}');
      print('   - studentID: ${data['studentID']}');
      print('   - dateTime type: ${data['dateTime']?.runtimeType}');
      print('   - dateTime value: ${data['dateTime']}');
      
      final entity = StudentRequestEntity.fromDocument({...data, 'id': doc.id});
      return StudentRequestModel.fromEntity(entity);
    } catch (e) {
      print('❌ خطأ في تحويل المستند: $e');
      rethrow;
    }
  }

  @override
  Future<StudentRequestModel> sendRequest(StudentRequestModel request) async {
    try {
      print('✅ بدء إرسال طلب جديد');
      print('👤 الطالب: ${request.studentID}');
      print('📋 نوع الطلب: ${request.requestType}');

      // حفظ الطلب في Firestore
      final docRef = request.copyWith(
        id: request.id,
        dateTime: DateTime.now(),
      );

      await requestsCollection.doc(docRef.id).set(docRef.toEntity().toDocument());

      print('💾 تم حفظ الطلب في Firestore بنجاح');
      print('🆕 معرّف الطلب: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إرسال الطلب: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentRequestModel>> getStudentRequests(String studentID) async {
    try {
      print('🔍 جلب طلبات الطالب: $studentID');

      final querySnapshot = await requestsCollection
          .where('studentID', isEqualTo: studentID)
          .get();

      final requests = querySnapshot.docs.map(_documentToRequest).toList();

      print('✅ تم جلب ${requests.length} طلب للطالب: $studentID');
      return requests;
    } catch (e) {
      print('❌ خطأ في جلب طلبات الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentRequestModel>> getAllRequests() async {
    try {
      print('🔍 جلب جميع الطلبات من النظام');

      final querySnapshot = await requestsCollection
          .orderBy('dateTime', descending: true)
          .get();

      final requests = querySnapshot.docs.map(_documentToRequest).toList();

      print('✅ تم جلب ${requests.length} طلب من النظام');
      return requests;
    } catch (e) {
      print('❌ خطأ في جلب جميع الطلبات: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status,{String? adminReply}) async {
    try {
      print('✏️ بدء تحديث حالة الطلب: $requestId');
      print('🔄 الحالة الجديدة: $status');
      if (adminReply != null) {
      print('💬 رد الإدمن: $adminReply');
    }

      // التحقق من وجود الطلب أولاً
      final requestDoc = await requestsCollection.doc(requestId).get();

      if (!requestDoc.exists) {
        throw Exception('الطلب غير موجود: $requestId');
      }

      // تحديث حالة الطلب في Firestore
      final updateData = <String, dynamic>{
      'status': status,
      'dateTime': DateTime.now(),
    };

    if (adminReply != null) {
      updateData['adminReply'] = adminReply;
    }

    await requestsCollection.doc(requestId).update(updateData);


      print('✅ تم تحديث حالة الطلب بنجاح');
      print('📝 الطلب: $requestId - الحالة: $status');
      if (adminReply != null) {
      print('📨 تم إضافة رد الإدمن');
    }
    } catch (e) {
      print('❌ خطأ في تحديث حالة الطلب: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      print('🗑️ بدء حذف الطلب: $requestId');

      // التحقق من وجود الطلب أولاً
      final requestDoc = await requestsCollection.doc(requestId).get();

      if (!requestDoc.exists) {
        throw Exception('الطلب غير موجود: $requestId');
      }

      // حذف الطلب من Firestore
      await requestsCollection.doc(requestId).delete();

      print('✅ تم حذف الطلب بنجاح: $requestId');
    } catch (e) {
      print('❌ خطأ في حذف الطلب: $e');
      rethrow;
    }
  }

  @override
Future<void> deleteAllRequests() async {
  try {
    print('🗑️ بدء حذف جميع الطلبات');

    final querySnapshot = await requestsCollection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    print('✅ تم حذف جميع الطلبات بنجاح');
    print('📊 عدد الطلبات المحذوفة: ${querySnapshot.docs.length}');
  } catch (e) {
    print('❌ خطأ في حذف جميع الطلبات: $e');
    rethrow;
  }
}
}
