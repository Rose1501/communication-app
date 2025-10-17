// image_preview_dialog.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// نافذة معاينة الصورة الأساسية
// مع إمكانية التكبير والتحريك
class AdvancedImagePreviewDialog extends StatefulWidget {
  final String imageUrl;
  final String? tag;

  const AdvancedImagePreviewDialog({
    super.key,
    required this.imageUrl,
    this.tag,
  });
//دالة ثابتة للعرض 
  static void show(BuildContext context, String imageUrl, {String? tag}) {
    showDialog(
      context: context,
      builder: (context) => AdvancedImagePreviewDialog(imageUrl: imageUrl, tag: tag),
      barrierColor: Colors.black87,
    );
  }

  @override
  State<AdvancedImagePreviewDialog> createState() => _AdvancedImagePreviewDialogState();
}

class _AdvancedImagePreviewDialogState extends State<AdvancedImagePreviewDialog> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails _doubleTapDetails = TapDownDetails();
// معالجة حدث النقر المزدوج لأسفل
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }
// معالجة النقر المزدوج للتكبير/التصغير
  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          // الخلفية
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
          
          // محتوى الصورة مع إمكانية التكبير
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(40),
                minScale: 0.1,// أصغر مقياس تكبير
                maxScale: 5.0,// أكبر مقياس تكبير
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height,
                  ),
                  child: GestureDetector(
                    onDoubleTapDown: _handleDoubleTapDown,
                    onDoubleTap: _handleDoubleTap,
                    child: Hero(
                      tag: widget.tag ?? widget.imageUrl,
                      child: _buildImageContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // زر الإغلاق
          _buildCloseButton(context),
        ],
      ),
    );
  }
// بناء محتوى الصورة
  Widget _buildImageContent() {
    if (_isBase64Image(widget.imageUrl)) {
      return Image.memory(
        _decodeBase64(widget.imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  bool _isBase64Image(String url) {
    return url.startsWith('data:image') || url.startsWith('/9j/') || url.length > 1000;
  }

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

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('فشل في تحميل الصورة'),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}