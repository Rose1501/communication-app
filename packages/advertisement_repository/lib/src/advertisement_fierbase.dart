import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

class AdvertisementFirebaseRepository implements AdvertisementRepository {
  final CollectionReference advcollection;

  // Constructor يحتاج إلى instance من FirebaseFirestore
  AdvertisementFirebaseRepository([FirebaseFirestore? firestore])
      : advcollection = (firestore ?? FirebaseFirestore.instance).collection('advertisements');

  // إضافة إعلان جديد
  @override
  Future<AdvertisementModel> addAdvertisement(AdvertisementModel advertisement) async {
    try {
    print('✅ بدء إضافة إعلان جديد');
    print('🆕 معرّف الإعلان: ${advertisement.id}');
    print('📝 وصف الإعلان: ${advertisement.description}');
    print('🖼️ وجود صورة: ${advertisement.advlImg != null}');
      // 🔥 تشفير الصورة إلى base64 إذا كانت موجودة
      String? finalImage = advertisement.advlImg;
      if (advertisement.advlImg != null && 
        advertisement.advlImg!.startsWith('/') && 
        !advertisement.advlImg!.startsWith('/9j/'))  {
        try {
          // التحقق إذا كانت الصورة ملف أو مسار
          final imageFile = File(advertisement.advlImg!);
          if (await imageFile.exists()) {
            print('📸 جاري تشفير صورة الإعلان إلى base64...');
            List<int> imageBytes = await imageFile.readAsBytes();
            finalImage  = base64Encode(imageBytes);
            print('🔤 تم تشفير الصورة، الطول: ${finalImage .length}');
          } 
        } catch (e) {
          print('⚠️ خطأ في تشفير الصورة: $e');
        }
      } else if (advertisement.advlImg != null) {
      print('🔤 الصورة مشفرة مسبقاً كـ base64');
      }
      final advertisementWithBase64 =advertisement.copyWith(
        id: advertisement.id,
        timeAdv: DateTime.now(),
        advlImg: finalImage, // استخدام الصورة المشفرة
      );
      print('🆕 معرّف الإعلان: ${advertisementWithBase64.id}');
      print('📝 وصف الإعلان: ${advertisementWithBase64.description}');
      print('🖼️ وجود صورة: ${advertisementWithBase64.advlImg != null}');
      // حفظ الإعلان في Firestore
      await advcollection.doc(advertisementWithBase64.id).set(advertisementWithBase64.toEntity().toDocument());
      print('💾 تم حفظ الإعلان في Firestore بنجاح');
      return advertisementWithBase64;
    } catch (e) {
      log('❌ خطأ في إضافة الإعلان: $e');
      rethrow;
    }
  }

  // الحصول على جميع الإعلانات
  @override
  Future<List<AdvertisementModel>> getAdvertisements() async {
    
    try {
      // جلب جميع المستندات من مجموعة 'advertisements'
      final querySnapshot = await advcollection.orderBy('timeAdv', descending: true).get();
      
      // تحويل كل مستند إلى كائن AdvertisementModel
      return querySnapshot.docs.map((doc) {
        return AdvertisementModel.fromEntity(
          AdvertisementEntity.fromDocument(doc.data() as Map<String, dynamic>),
        );
      }).toList();
    } catch (e) {
      // تسجيل الخطأ في حالة فشل العملية
      log(e.toString());
      // إعادة throw الخطأ للتعامل معه في الطبقات الأعلى
      rethrow;
    }
  }

  // تحديث إعلان
  @override
  Future<void> updateAdvertisement(AdvertisementModel advertisement) async {
    try {
      print('✏️ بدء تحديث الإعلان: ${advertisement.id}');
      print('📝 البيانات المرسلة للتحديث:');
      print('   - الوصف: ${advertisement.description}');
      print('   - الصورة: ${advertisement.advlImg ?? "NULL"}');
      print('   - الوقت: ${advertisement.timeAdv}');
      print('   - الفئة: ${advertisement.custom}');
      
      // 🔥 تشفير الصورة الجديدة إذا كانت موجودة
      String? base64Image = advertisement.advlImg;
      
      // التحقق إذا كانت الصورة ملف جديد (يبدأ بـ / أو يحتوي على مسار ملف)
      if (advertisement.advlImg != null && 
          (advertisement.advlImg!.startsWith('/') || 
            advertisement.advlImg!.contains('/data/'))) {
        try {
          final imageFile = File(advertisement.advlImg!);
          if (await imageFile.exists()) {
            print('📸 جاري تشفير الصورة الجديدة إلى base64...');
            List<int> imageBytes = await imageFile.readAsBytes();
            base64Image = base64Encode(imageBytes);
            print('🔤 تم تشفير الصورة الجديدة، الطول: ${base64Image.length}');
          }
        } catch (e) {
          print('⚠️ خطأ في تشفير الصورة الجديدة: $e');
        }
      }

      // إنشاء نسخة محدثة مع الصورة المشفرة
      final updatedAdvertisement = advertisement.copyWith(
        advlImg: base64Image,
      );

      // تحديث المستند في Firestore
      await advcollection.doc(updatedAdvertisement.id).update(
        updatedAdvertisement.toEntity().toDocument(),
      );

      // تحويل النموذج إلى خريطة للتحديث
    final updateData = advertisement.toEntity().toDocument();
    
    print('🗂️ بيانات التحديث النهائية:');
    updateData.forEach((key, value) {
      print('   - $key: $value');
    });
    
    // تحديث المستند في Firestore
    await advcollection.doc(advertisement.id).update(updateData);

      print('✅ تم تحديث الإعلان بنجاح');
    } catch (e) {
      log('❌ خطأ في تحديث الإعلان: $e');
      rethrow;
    }
  }

  // حذف إعلان
  @override
  Future<void> deleteAdvertisement(String id) async {
    print('حذف الإعلان بالمعرف: $id');
    try {
      // حذف المستند من Firestore باستخدام المعرف
      await advcollection.doc(id).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // 🔥 دالة مخصصة لإعادة نشر الإعلان
@override
Future<AdvertisementModel> republishAdvertisement({
  required AdvertisementModel originalAdvertisement,
  required String newDescription,
  required String newCustom,
  required UserModels currentUser,
  File? newImage,
  bool removeImage = false,
}) async {
  try {
    print('🔄 بدء إعادة نشر الإعلان...');
    final newAdId = const Uuid().v4();

    // 🔥 معالجة الصورة بشكل صحيح
    String? finalImageUrl;

    if (removeImage) {
      // الحالة 1: إعادة النشر بدون صورة
      finalImageUrl = null;
      print('🔄 إعادة النشر بدون صورة');
    } else if (newImage != null) {
      // الحالة 2: رفع صورة جديدة
      print('📸 جاري رفع الصورة الجديدة...');
      final imageBytes = await newImage.readAsBytes();
      finalImageUrl = base64Encode(imageBytes);
      print('✅ تم تحويل الصورة الجديدة إلى base64');
    } else {
      // الحالة 3: استخدام الصورة الأصلية
      finalImageUrl = originalAdvertisement.advlImg;
      print('🔄 استخدام الصورة الأصلية');
    }

    // إنشاء الإعلان الجديد
    final newAdvertisement = AdvertisementModel(
      id: newAdId,
      description: newDescription,
      custom: newCustom,
      user: currentUser,
      advlImg: finalImageUrl,
      timeAdv: DateTime.now(),
    );

    print('🆕 إنشاء إعلان جديد:');
    print('   - ID: $newAdId');
    print('   - الوصف: $newDescription');
    print('   - الفئة: $newCustom');
    print('   - الصورة: ${finalImageUrl != null ? "موجودة" : "بدون صورة"}');
    print('   - الناشر: ${currentUser.name}');

    // حفظ الإعلان الجديد في Firestore
    await advcollection.doc(newAdId).set(newAdvertisement.toEntity().toDocument());
    
    print('✅ تم إعادة نشر الإعلان بنجاح');
    return newAdvertisement;

  } catch (e) {
    print('❌ فشل في إعادة نشر الإعلان: $e');
    rethrow;
  }
}

  // 🔥 الدالة الجديدة لإزالة صورة الإعلان (تعيينها إلى null)
@override
Future<void> removeAdvertisementImage(String advertisementId) async {
  try {
    print('🗑️ بدء إزالة صورة الإعلان: $advertisementId');
    
    // التحقق من وجود الإعلان
    final advertisementDoc = await advcollection.doc(advertisementId).get();
    
    if (!advertisementDoc.exists) {
      throw Exception('الإعلان غير موجود: $advertisementId');
    }
    final currentData = advertisementDoc.data() as Map<String, dynamic>;
    final hasImage = currentData['advlImg'] != null && 
                    (currentData['advlImg'] as String).isNotEmpty;
    
    if (!hasImage) {
      print('ℹ️ الإعلان لا يحتوي على صورة للإزالة');
      return; // لا داعي للاستمرار إذا لا توجد صورة
    }
    
    // تحديث الإعلان بإزالة الصورة
    await advcollection.doc(advertisementId).update({
      'advlImg': null, // 🔥 تعيين الصورة إلى null
      'timeAdv': DateTime.now(), // تحديث وقت التعديل
    });
    
    print('✅ تم إزالة صورة الإعلان بنجاح');
    
  } catch (e) {
    print('❌ خطأ في إزالة صورة الإعلان: $e');
    rethrow;
  }
}

  @override
  // الدالة الحالية لرفع الصورة إلى Firebase Storage (تبقى كما هي)
  Future<String> uploadAdvertisementImage(File imageFile, String advertisementId) async {
  try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('advertisements')
          .child(advertisementId)
          .child('${Uuid().v1()}.jpg');
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
  } catch (e) {
    print('خطأ في رفع الصورة: $e');
    rethrow;
  }
}

  @override
  Future<String> uploadAdvertisementFile(File file, String advertisementId) async {
  try {
    // الحصول على امتداد الملف الأصلي
      final File dartFile = file;
      final fileExtension = dartFile.path.split('.').last;
      final fileName = '${Uuid().v1()}.$fileExtension';

      // إنشاء مرجع للتخزين في Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('advertisements')
          .child(advertisementId)
          .child('files')
          .child(fileName);

      // رفع الملف إلى Firebase Storage
      await storageRef.putFile(file);
    print('تم رفع الملف بنجاح: $fileName');


    // الحصول على رابط التحميل
    final String downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl; // إرجاع رابط الملف الحقيقي
  } catch (e) {
    print('خطأ في رفع الملف: $e');
    rethrow;
  }
}

  // 🔥 الدالة الجديدة لرفع صورة الإعلان كـ base64 وتحديثها مباشرة في Firestore
  @override
  Future<String> uploadAdvertisementImageAsBase64(File imageFile, String advertisementId) async {
    try {
      print('✅ بدء رفع صورة الإعلان كـ base64 للإعلان: $advertisementId');
      print('📁 مسار الملف: ${imageFile.path}');
      
      // التحقق من وجود الملف
      bool fileExists = await imageFile.exists();
      print('   📄 الملف موجود: $fileExists');
      
      if (!fileExists) {
        throw Exception('الملف غير موجود: ${imageFile.path}');
      }

      // قراءة الملف وتحويله إلى base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      print('📸 حجم الصورة: ${imageBytes.length} bytes');
      print('🔤 طول base64: ${base64Image.length}');
      
      // التحقق من وجود الإعلان
      print('🔄 التحقق من وجود الإعلان في Firestore...');
      final advertisementDoc = await advcollection.doc(advertisementId).get();
      
      if (!advertisementDoc.exists) {
        throw Exception('الإعلان غير موجود: $advertisementId');
      }
      
      print('✅ الإعلان موجود، جاري تحديث الصورة...');
      
      // تحديث صورة الإعلان في Firestore
      await advcollection.doc(advertisementId).update({
        'advlImg': base64Image,
      });
      
      print('✅ تم تحديث صورة الإعلان في Firestore بنجاح');
      
      return base64Image; // إرجاع سلسلة base64

    } catch (e) {
      print('❌ خطأ في رفع صورة الإعلان: $e');
      rethrow;
    }
  }
}