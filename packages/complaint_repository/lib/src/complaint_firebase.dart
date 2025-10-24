import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'complaint_repo.dart';

class FirebaseComplaintRepository implements ComplaintRepository {
  final CollectionReference complaintsCollection =
      FirebaseFirestore.instance.collection('complaints');

  ComplaintModel _documentToComplaint(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final entity = ComplaintEntity.fromDocument({...data, 'id': doc.id});
      return ComplaintModel.fromEntity(entity);
    } catch (e) {
      print('❌ خطأ في تحويل مستند الشكوى: $e');
      rethrow;
    }
  }

  @override
  Future<ComplaintModel> sendComplaint(ComplaintModel complaint) async {
    try {
      print('🚀 بدء إرسال شكوى جديدة: ${complaint.title}');

      final docRef = complaint.copyWith(
        id: complaint.id.isEmpty ? _generateComplaintId() : complaint.id,
        createdAt: DateTime.now(),
      );

      await complaintsCollection
          .doc(docRef.id)
          .set(docRef.toEntity().toDocument());

      print('✅ تم إرسال الشكوى بنجاح: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ خطأ في إرسال الشكوى: $e');
      rethrow;
    }
  }

  @override
  Future<List<ComplaintModel>> getStudentComplaints(String studentID) async {
    try {
      print('🔍 جلب شكاوى الطالب: $studentID');

      final querySnapshot = await complaintsCollection
          .where('studentID', isEqualTo: studentID)
          .get();

       // 🔥 الترتيب محلياً في التطبيق
    final requests = querySnapshot.docs.map(_documentToComplaint).toList();

      // ترتيب من الأحدث إلى الأقدم محلياً
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ تم جلب ${requests.length} شكوى للطالب: $studentID');
      return requests;
    } catch (e) {
      print('❌ خطأ في جلب شكاوى الطالب: $e');
      rethrow;
    }
  }

  @override
  Future<List<ComplaintModel>> getComplaintsForRole(String targetRole) async {
    try {
      print('🔍 جلب الشكاوى الموجهة لـ: $targetRole');

      final querySnapshot = await complaintsCollection
          .where('targetRole', isEqualTo: targetRole)
          .get();

      final complaints = querySnapshot.docs.map(_documentToComplaint).toList();
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ تم جلب ${complaints.length} شكوى موجهة لـ: $targetRole');
      return complaints;
    } catch (e) {
      print('❌ خطأ في جلب الشكاوى الموجهة: $e');
      rethrow;
    }
  }

  @override
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      print('🔍 جلب جميع الشكاوى');

      final querySnapshot = await complaintsCollection
          .get();

      final complaints = querySnapshot.docs.map(_documentToComplaint).toList();

      print('✅ تم جلب ${complaints.length} شكوى من النظام');
      return complaints;
    } catch (e) {
      print('❌ خطأ في جلب جميع الشكاوى: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? adminReply,
    String? assignedAdmin,
  }) async {
    try {
      print('✏️ تحديث حالة الشكوى: $complaintId إلى $status');

      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now(),
        if (adminReply != null) 'adminReply': adminReply,
        if (assignedAdmin != null) 'assignedAdmin': assignedAdmin,
      };

      await complaintsCollection.doc(complaintId).update(updateData);

      print('✅ تم تحديث حالة الشكوى بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث حالة الشكوى: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteComplaint(String complaintId) async {
    try {
      print('🗑️ حذف الشكوى: $complaintId');
      await complaintsCollection.doc(complaintId).delete();
      print('✅ تم حذف الشكوى بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الشكوى: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllComplaints() async {
    try {
      print('🗑️ حذف جميع الشكاوى');

      final querySnapshot = await complaintsCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ تم حذف ${querySnapshot.docs.length} شكوى');
    } catch (e) {
      print('❌ خطأ في حذف جميع الشكاوى: $e');
      rethrow;
    }
  }

  String _generateComplaintId() {
    return 'complaint_${DateTime.now().millisecondsSinceEpoch}';
  }
}