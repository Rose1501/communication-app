import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FileUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // 🔥 رفع ملف إلى Firebase Storage مع تحسينات حقيقية
  static Future<String> uploadFile(File file, {String? folderName, Function(int)? onProgress}) async {
    try {
      print('📤 بدء رفع الملف الحقيقي: ${file.path}');
      
      // إنشاء اسم فريد للملف
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final String uploadPath = folderName != null ? '$folderName/$fileName' : fileName;
      
      final Reference ref = _storage.ref().child(uploadPath);
      
      // إعداد metadata للملف
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getMimeType(file.path),
        customMetadata: {
          'uploadedBy': 'teacher_app',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // رفع الملف مع متابعة التقدم
      final UploadTask uploadTask = ref.putFile(file, metadata);
      
      // متابعة تقدم الرفع
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📤 تقدم رفع الملف: ${progress.toStringAsFixed(1)}%');
        onProgress?.call(progress.toInt());
      });
      
      // انتظار اكتمال الرفع
      final TaskSnapshot snapshot = await uploadTask;
      
      // الحصول على رابط التنزيل
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ تم رفع الملف بنجاح: $downloadUrl');
      print('📊 حجم الملف: ${_formatFileSize(snapshot.totalBytes)}');
      
      return downloadUrl;
    } catch (e) {
      print('❌ خطأ في رفع الملف: $e');
      throw Exception('فشل في رفع الملف: $e');
    }
  }

  // 🔥 رفع ملف منهج
  static Future<String> uploadCurriculumFile(File file, {Function(int)? onProgress}) async {
    return await uploadFile(file, folderName: 'curricula', onProgress: onProgress);
  }

  // 🔥 رفع ملف واجب
  static Future<String> uploadHomeworkFile(File file, {Function(int)? onProgress}) async {
    return await uploadFile(file, folderName: 'homeworks', onProgress: onProgress);
  }

  // 🔥 رفع ملف إعلان
  static Future<String> uploadAdvertisementFile(File file, {Function(int)? onProgress}) async {
    return await uploadFile(file, folderName: 'advertisements', onProgress: onProgress);
  }

  // 🔥 رفع تسليم طالب
  static Future<String> uploadSubmissionFile(File file, String homeworkId, String studentId, {Function(int)? onProgress}) async {
    return await uploadFile(file, folderName: 'submissions/$homeworkId/$studentId', onProgress: onProgress);
  }

  // 🔥 حذف ملف من Storage
  static Future<void> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.contains('firebasestorage.googleapis.com')) {
        final Reference ref = _storage.refFromURL(fileUrl);
        await ref.delete();
        print('✅ تم حذف الملف: $fileUrl');
      } else {
        print('⚠️ الرابط ليس رابط Firebase Storage: $fileUrl');
      }
    } catch (e) {
      print('❌ خطأ في حذف الملف: $e');
      // لا نرمي خطأ هنا لأن حذف الملف ليس حرجاً
    }
  }

  // 🔥 التحقق من صحة الرابط
  static bool isValidFirebaseUrl(String url) {
    return url.startsWith('https://firebasestorage.googleapis.com');
  }

  // 🔥 الحصول على نوع MIME للملف
  static String? _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf': return 'application/pdf';
      case '.doc': return 'application/msword';
      case '.docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.ppt': return 'application/vnd.ms-powerpoint';
      case '.pptx': return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.xls': return 'application/vnd.ms-excel';
      case '.xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.jpg': case '.jpeg': return 'image/jpeg';
      case '.png': return 'image/png';
      case '.gif': return 'image/gif';
      case '.mp4': return 'video/mp4';
      case '.mov': return 'video/quicktime';
      case '.zip': return 'application/zip';
      case '.rar': return 'application/x-rar-compressed';
      case '.txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }

  // 🔥 التحقق من حجم الملف
  static bool isFileSizeValid(File file, {double maxSizeMB = 25}) {
    final fileSize = file.lengthSync() / (1024 * 1024); // تحويل إلى MB
    return fileSize <= maxSizeMB;
  }

  // 🔥 الحصول على حجم الملف بشكل مقروء
  static String getReadableFileSize(File file) {
    final bytes = file.lengthSync();
    return _formatFileSize(bytes);
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // 🔥 الحصول على معلومات الملف
  static Future<Map<String, dynamic>> getFileInfo(String fileUrl) async {
    try {
      if (isValidFirebaseUrl(fileUrl)) {
        final Reference ref = _storage.refFromURL(fileUrl);
        final metadata = await ref.getMetadata();
        
        return {
          'name': ref.name,
          'size': metadata.size,
          'contentType': metadata.contentType,
          'timeCreated': metadata.timeCreated,
          'updated': metadata.updated,
        };
      }
      return {};
    } catch (e) {
      print('❌ خطأ في الحصول على معلومات الملف: $e');
      return {};
    }
  }
}