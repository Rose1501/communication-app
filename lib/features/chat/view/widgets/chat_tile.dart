import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:chat_repository/chat_repository.dart';

class ChatTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد العنوان والصورة بناءً على نوع الدردشة
    String title = chat.name;
    String subtitle = chat.lastMessage ?? 'لا توجد رسائل';
    String imagePath = chat.imageUrl ?? '';
    IconData iconData;
    Color iconColor;

    if (chat.type == 'doctors_group') {
      iconData = Icons.school;
      iconColor = Colors.purple;
      title = 'أعضاء هيئة التدريس';
    } else if (chat.type == 'educational_group') {
      iconData = Icons.group;
      iconColor = Colors.green;
    } else {
      iconData = Icons.person;
      iconColor = Colors.blue;
      // للمحادثات الخاصة، إذا لم يكن هناك اسم في الـ chat model، يمكن جلبه من الـ args
      // هنا نفترض أن الاسم محفوظ في chat.name
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          backgroundImage: imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
          child: imagePath.isEmpty
              ? Icon(iconData, color: iconColor)
              : null,
        ),
        title: Text(
          title,
          style: font16blackbold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: font14grey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastActivity.isNotEmpty)
              Text(
                _formatTime(chat.lastActivity),
                style: font10Grey,
              ),
            // هنا يمكن إضافة نقطة غير مقروءة مستقبلاً
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatTime(String isoTime) {
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