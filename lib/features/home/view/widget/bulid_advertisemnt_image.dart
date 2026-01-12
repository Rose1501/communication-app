
import 'dart:convert';
import 'dart:typed_data';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/widget/image_preview_dialog.dart';

// دالة لبناء وعرض صورة الإعلان مع إمكانيات متقدمة
Widget buildAdvertisementImage(BuildContext context, AdvertisemenModel advertisement) {
  if (advertisement.advlImg == null || advertisement.advlImg!.isEmpty) {
    return const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () {
      // فتح معاينة الصورة
      AdvancedImagePreviewDialog.show(
        context, 
        advertisement.advlImg!,
        tag: 'image_${advertisement.id}', // لـ Hero animation
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // الصورةالأساسية
            _buildImageWidget(advertisement),
            
            // تأثير عند الضغط
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // أيقونة التكبير في الزاوية
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// دالة مساعدة لبناء عنصر الصورة بناءً على نوعها
Widget _buildImageWidget(AdvertisemenModel advertisement) {
  if (_isBase64Image(advertisement.advlImg!)) {
    return Image.memory(
      _decodeBase64(advertisement.advlImg!),
      width: double.infinity,
      height: 400,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImageErrorWidget();
      },
    );
  } else {
    return Image.network(
      advertisement.advlImg!,
      width: double.infinity,
      height: 400,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImageErrorWidget();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildImageLoadingWidget(loadingProgress);
      },
    );
  }
}
// بناء واجهة خطأ عند فشل تحميل الصورة
Widget _buildImageErrorWidget() {
  return Container(
    width: double.infinity,
    height: 200,
    color: Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
        SizedBox(height: 8),
        Text(
          'فشل في تحميل الصورة',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
// بناء واجهة تحميل أثناء جلب الصورة
Widget _buildImageLoadingWidget(ImageChunkEvent loadingProgress) {
  return Container(
    width: double.infinity,
    height: 200,
    color: Colors.grey[200],
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null,
      ),
    ),
  );
}
// دالة للتحقق إذا كانت الصورة بصيغة base64
bool _isBase64Image(String url) {
  return url.startsWith('data:image') || url.startsWith('/9j/') || url.length > 1000;
}
// دالة لفك تشفير صورة base64
Uint8List _decodeBase64(String base64String) {
  try {
    final String data = base64String.contains(',') 
        ? base64String.split(',').last 
        : base64String;
    return base64Decode(data);
  } catch (e) {
    throw Exception('فشل في فك تشفير صورة base64: $e');
  }
}