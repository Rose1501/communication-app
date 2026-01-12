import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notification_repository/notification_repository.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      // التنقل الافتراضي بناءً على نوع الإشعار
      _navigateBasedOnType(context);
    }
  }

  void _navigateBasedOnType(BuildContext context) {
    switch (notification.type) {
      case 'advertisement':
        _navigateToAdvertisement(context);
        break;
      case 'complaint':
        _navigateToComplaint(context);
        break;
      case 'request':
        _navigateToRequest(context);
        break;
      case 'homework':
      case 'curriculum':
      case 'attendance':
      case 'exam':
      case 'group_advertisement':
        _navigateToSubjective(context);
        break;
      default:
        // للإشعارات العامة لا ننتقل
        break;
    }
  }

  void _navigateToAdvertisement(BuildContext context) {
    final advertisementId = notification.metadata?['advertisementId'];
    if (advertisementId != null) {
      // هنا يمكنك الانتقال لشاشة الإعلانات
      // context.pushNamed(Routes.advertisements, arguments: {...});
      print('📢 Navigate to advertisement: $advertisementId');
    }
  }

  void _navigateToComplaint(BuildContext context) {
    final complaintId = notification.metadata?['complaintId'];
    if (complaintId != null) {
      // الانتقال لشاشة الشكاوى
      // context.pushNamed(Routes.complaintsList, arguments: {...});
      print('📋 Navigate to complaint: $complaintId');
    }
  }

  void _navigateToRequest(BuildContext context) {
    final requestId = notification.metadata?['requestId'];
    if (requestId != null) {
      // الانتقال لشاشة الطلبات
      // context.pushNamed(Routes.displayRequest, arguments: {...});
      print('📝 Navigate to request: $requestId');
    }
  }

  void _navigateToSubjective(BuildContext context) {
    // للإشعارات الأكاديمية، ننتقل للشاشة الرئيسية للمواد
    // context.pushNamed(Routes.subjectiveMain);
    print('🎓 Navigate to subjective');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _handleTap(context),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
            child: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  color: notification.isRead ? Colors.grey : Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // سطرين فقط
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(notification.timestamp),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          trailing: notification.isRead 
              ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
              : const Icon(Icons.circle, color: Colors.blue, size: 16),
          isThreeLine: true,
        ),
      ),
    );
  }
}