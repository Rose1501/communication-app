import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageUtils {
  /// تحويل ملف الصورة (File) إلى نص Base64
  /// يستخدم عند رفع صورة جديدة للسيرفر
  static Future<String> fileToBase64(File imageFile) async {
    try {
      // قراءة بايتات الصورة من الملف
      List<int> imageBytes = await imageFile.readAsBytes();
      // تحويل البايتات إلى نص Base64
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      debugPrint('❌ Error converting file to Base64: $e');
      rethrow;
    }
  }

  /// تنظيف نص Base64 من أي بادئات (مثل data:image/jpeg;base64,)
  /// بعض السيرفرات تعيد الصورة مع هذه البادئة ودونها، هذه الدالة تتعامل مع الحالتين
  static String cleanBase64String(String base64String) {
    if (base64String.contains(',')) {
      return base64String.split(',').last;
    }
    return base64String;
  }

  /// فك تشفير نص Base64 وإرجاعه على شكل بايتات (Uint8List)
  /// يستخدم لعرض الصورة داخل الذاكرة أو حفظها
  static Uint8List? base64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      String cleanString = cleanBase64String(base64String);
      // تحويل النص النظيف إلى بايتات
      return base64Decode(cleanString);
    } catch (e) {
      debugPrint('❌ Error decoding Base64 to bytes: $e');
      return null;
    }
  }

  /// دالة جاهزة لتحويل Base64 مباشرة إلى Widget (Image)
  /// تتيح لك التحكم في العرض والارتفاع ومظهر الصورة عند حدوث خطأ
  static Image base64ToImageWidget(
    String base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final cleanString = cleanBase64String(base64String);

    return Image.memory(
      base64Decode(cleanString),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading image from Base64: $error');
        return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }

  /// دالة مساعدة للتحقق مما إذا كانت النصوص تحتوي على بيانات Base64 صالحة
  /// (اختياري، يمكن استخدامه للتأكد قبل محاولة فك التشفير)
  static bool isValidBase64(String? str) {
    if (str == null || str.isEmpty) return false;
    // يمكن إضافة شروط أكثر تعقيداً هنا، مثل التحقق من الطول أو المحتوى
    try {
      base64Decode(cleanBase64String(str));
      return true;
    } catch (e) {
      return false;
    }
  }
}