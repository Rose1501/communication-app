import 'package:flutter/material.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/widget/image_preview_dialog.dart';
import 'package:myproject/components/widget/image_utils.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSender;
  final bool showSenderName;
  final VoidCallback? onImageTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.showSenderName,
    this.onImageTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // 1. التحقق من أن الرسالة ليست محذوفة
    if (message.isDeleted) {
      return const SizedBox.shrink();
    }

    // 2. التحقق مما إذا كانت الرسالة تحتوي على صورة
    final bool hasImage = message.messageAttachment.isNotEmpty && message.messageAttachment != 'image';
    
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // عرض اسم المرسل
            if (showSenderName && !isSender)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // المحتوى الرئيسي (الفقاعة)
            IntrinsicWidth(
              child: GestureDetector(
                onLongPress: onLongPress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSender 
                        ? ColorsApp.primaryColor 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: hasImage 
                      ? const EdgeInsets.all(5) 
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عرض الرسالة النصية
                      if (message.message.isNotEmpty)
                        Text(
                          message.message,
                          style: TextStyle(
                            color: isSender ? Colors.white : Colors.black,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      
                      // عرض الصورة المرفقة
                      if (hasImage) ...[
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () {
                              if (onImageTap != null) {
                                onImageTap!();
                              } else {
                                _openImagePreview(context, message);
                              }
                            },
                            child: Hero(
                              tag: 'msg_${message.groupId}_${message.id}',
                              child: _buildImageWidget(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // وقت الرسالة
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                _formatTime(message.timeMessage),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة بناء ويدجت الصورة (المعدلة)
  Widget _buildImageWidget(BuildContext context) {
    String attachment = message.messageAttachment;

    // 1. الحالة الأولى: رابط URL صريح (http أو https)
    if (attachment.startsWith('http')) {
      return Image.network(
        attachment,
        width: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 250,
            height: 200,
            color: Colors.grey[100],
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }

    // 2. الحالة الثانية: Base64 (بدون رابط)
    // نستخدم isValidBase64 للتأكد. 
    // هذه الدالة ستحاول فك تشفير النص، إذا نجحت فهي صورة Base64.
    if (ImageUtils.isValidBase64(attachment)) {
      return ImageUtils.base64ToImageWidget(
        attachment,
        width: 250,
        height: null,
        fit: BoxFit.cover,
        errorWidget: _buildErrorWidget(),
      );
    }

    // 3. الحالة الثالثة: فشل التحميل (أو نوع غير معروف)
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  void _openImagePreview(BuildContext context, MessageModel message) {
    AdvancedImagePreviewDialog.show(
      context,
      message.messageAttachment,
      tag: 'msg_${message.groupId}_${message.id}',
    );
  }

  String _formatTime(String isoTime) {
    // تم استخدام الدالة الجديدة، لكن سنتركها هنا كـ backup إذا لم يتم تمرير formattedTime
    try {
      final dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'الآن';
      if (difference.inHours < 1) return '${difference.inMinutes}د';
      if (difference.inDays < 1) return '${difference.inHours}س';
      if (difference.inDays < 7) return '${difference.inDays}ي';
      return '${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return '';
    }
  }
}