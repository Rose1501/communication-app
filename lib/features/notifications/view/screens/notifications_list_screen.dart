import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:myproject/features/notifications/bloc/notifications_bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import '../widgets/notification_card.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  int _selectedIndex = 2;
  bool _isSelectMode = false;
  Set<String> _selectedNotifications = <String>{};
  
  // إضافة متغير لحفظ حالة الـ Bloc
  // ignore: unused_field
  NotificationsState? _currentState;

  @override
  void initState() {
    super.initState();
    
    // تحميل الإشعارات بعد فترة قصيرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAndLoadNotifications();
    });
  }

  // أضف هذه الدوال لإدارة حالة التحديد
  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _toggleNotificationSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  // دالة للتبديل بين تحديد الكل وإلغاء التحديد
void _toggleSelectAll() {
  final blocState = context.read<NotificationsBloc>().state;
  
  if (blocState is NotificationsLoadSuccess) {
    final notifications = blocState.notifications;
    
    setState(() {
      if (_selectedNotifications.length == notifications.length) {
        // إذا كانت جميع الإشعارات محددة، ألغ التحديد
        _selectedNotifications.clear();
      } else {
        // إذا لم تكن جميع الإشعارات محددة، حدد الكل
        _selectedNotifications = notifications
            .map((n) => n.id)
            .toSet();
      }
    });
  }
}

  void _deleteSelectedNotifications() {
    if (_selectedNotifications.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإشعارات'),
        content: Text('هل أنت متأكد من حذف ${_selectedNotifications.length} إشعار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // هنا ستضيف منطق حذف الإشعارات
              _performDeletion();
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔥 دالة لحذف جميع الإشعارات
  void _showDeleteAllDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('حذف جميع الإشعارات'),
      content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<NotificationsBloc>().add(DeleteAllNotifications());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف جميع الإشعارات'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  }

  void _performDeletion() {
  if (_selectedNotifications.isEmpty) return;
  
  // تحويل Set إلى List
  final notificationIds = _selectedNotifications.toList();
  
  // إرسال حدث الحذف إلى الـ Bloc
  context.read<NotificationsBloc>().add(
    DeleteNotifications(notificationIds),
  );
  
  // عرض رسالة نجاح
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم حذف ${notificationIds.length} إشعار'),
      backgroundColor: Colors.green,
    ),
  );
  
  // إعادة تعيين الحالة
  setState(() {
    _selectedNotifications.clear();
    _isSelectMode = false;
  });
  }

  // دالة جديدة لتحديد الكل
  void _selectAllNotifications() {
    // الحصول على حالة الـ Bloc الحالية
    final blocState = context.read<NotificationsBloc>().state;
    
    if (blocState is NotificationsLoadSuccess) {
      final notifications = blocState.notifications;
      setState(() {
        _selectedNotifications = notifications
            .map((n) => n.id)
            .toSet();
      });
    }
  }

  void _checkUserAndLoadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('👤 User logged in: ${user.uid}');
      // تأخير قليل للتأكد من أن الـ Bloc مستعد
      Future.delayed(const Duration(milliseconds: 300), () {
        context.read<NotificationsBloc>().add(LoadNotifications());
      });
    } else {
      print('❌ No user logged in');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, getUserRole(context), context);
  }

  @override
Widget build(BuildContext context) {
  print('🏗️ Building NotificationsListScreen');
  
  return BlocConsumer<NotificationsBloc, NotificationsState>(
    listener: (context, state) {
      print('🎧 BlocListener - State changed: ${state.runtimeType}');
      _currentState = state;
      
      if (state is NotificationsLoadSuccess) {
        print('📊 Success state with ${state.notifications.length} notifications');
      }
      
      if (state is NotificationsDeleteFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف الإشعارات: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    builder: (context, state) {
      _currentState = state;
      
      return Scaffold(
        appBar: _buildAppBar(context, state),
        body: _buildBody(context, state),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          userRole: getUserRole(context),
        ),
      );
    },
  );
}

// 🔥 دالة منفصلة لبناء AppBar
AppBar _buildAppBar(BuildContext context, NotificationsState state) {
  return AppBar(
    title: _isSelectMode 
        ? Text('${_selectedNotifications.length} محددة',style: TextStyle(color: ColorsApp.white),)
        :  Text('الإشعارات',style: TextStyle(color: ColorsApp.white),),
    backgroundColor: ColorsApp.primaryColor,
    actions: [
      if (_isSelectMode)
        IconButton(
          icon:  Icon(Icons.delete,color: ColorsApp.white,),
          onPressed: _selectedNotifications.isEmpty 
              ? null
              : _deleteSelectedNotifications,
          tooltip: 'حذف المحددة',
        ),
      if (_isSelectMode)
  if (_isSelectMode)
  IconButton(
    icon: _selectedNotifications.isEmpty
        ? Icon(Icons.select_all, color: ColorsApp.white)
        : Icon(Icons.deselect, color: ColorsApp.white),
    onPressed: _toggleSelectAll,
    tooltip: _selectedNotifications.isEmpty 
        ? 'تحديد الكل'
        : 'إلغاء تحديد الكل',
  ),
      if (_isSelectMode)
        IconButton(
          icon:  Icon(Icons.close,color: ColorsApp.white,),
          onPressed: _toggleSelectMode,
          tooltip: 'إغلاق وضع التحديد',
        ),
      if (!_isSelectMode)
        IconButton(
          icon:  Icon(Icons.checklist,color: ColorsApp.white,),
          onPressed: _toggleSelectMode,
          tooltip: 'تحديد الإشعارات',
        ),
      if (!_isSelectMode)
        IconButton(
          icon:  Icon(Icons.done_all,color: ColorsApp.white,),
          onPressed: () {
            print('✅ Mark all as read triggered');
            context.read<NotificationsBloc>().add(MarkAllAsRead());
          },
          tooltip: 'تحديد الكل كمقروء',
        ),
      // زر القائمة المنبثقة لحذف الكل
      if (!_isSelectMode && state is NotificationsLoadSuccess && (state as NotificationsLoadSuccess).notifications.isNotEmpty)
        PopupMenuButton<String>(
          icon:  Icon(Icons.more_vert,color: ColorsApp.white,),
          onSelected: (value) {
            if (value == 'delete_all') {
              _showDeleteAllDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'delete_all',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف جميع الإشعارات'),
                ],
              ),
            ),
          ],
        ),
    ],
  );
}

  Widget _buildBody(BuildContext context, NotificationsState state) {
    print('🔄 BlocBuilder building with state: ${state.runtimeType}');
    
    if (state is NotificationsLoading) {
      print('⏳ Showing loading indicator');
      return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ColorsApp.primaryColor,),
            SizedBox(height: 16),
            Text('جاري تحميل الإشعارات...'),
          ],
        ),
      );
    }
    
    if (state is NotificationsLoadFailure) {
      print('❌ Showing error: ${state.error}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text('خطأ: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('🔄 Loading notifications from initial state');
                context.read<NotificationsBloc>().add(LoadNotifications());
              },
              child: const Text('تحميل الإشعارات'),
            ),
          ],
        ),
      );
    }
    
    if (state is NotificationsLoadSuccess) {
      final notifications = state.notifications;
      print('📋 Displaying ${notifications.length} notifications');
      
      // طباعة تفاصيل كل إشعار للتأكد
      for (var (index, notification) in notifications.indexed) {
        print('''📬 Notification ${index + 1}:ID: ${notification.id}Title: ${notification.title}Body: ${notification.body}Timestamp: ${notification.timestamp}Is Read: ${notification.isRead}Target UID: ${notification.targetFirebaseUID}''');
      }
      
      if (notifications.isEmpty) {
        print('📭 Showing empty state');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size:100,color: ColorsApp.primaryColor,),
              const SizedBox(height: 16),
              Text('لا توجد إشعارات',style: font18blackbold,),
            ],
          ),
        );
      }
      
      print('📱 Building ListView with ${notifications.length} items');
      return RefreshIndicator(
        color: ColorsApp.primaryColor,
        onRefresh: () async {
          print('⬇️ Pull to refresh');
          context.read<NotificationsBloc>().add(LoadNotifications());
        },
        child: ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            print('🔄 Building card for notification ${index + 1}: ${notification.title}');
            
            if (_isSelectMode) {
              return _buildSelectableCard(notification);
            } else {
              return NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(context, notification),
              );
            }
          },
        ),
      );
    }
    
    // الحالة الأولية
    print('🎯 Showing initial state');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications, size: 80,color: ColorsApp.primaryColor,),
          const SizedBox(height: 16),
          const Text('انقر على زر التحديث لتحميل الإشعارات'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              print('🔄 Loading notifications from initial state');
              context.read<NotificationsBloc>().add(LoadNotifications());
            },
            child: const Text('تحميل الإشعارات'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              print('🧪 Creating test notification from initial state');
              context.read<NotificationsBloc>().add(CreateTestNotification());
            },
            child: const Text('إنشاء إشعار اختبار'),
          ),
        ],
      ),
    );
  }

  // إضافة مؤشر أن الإشعار قابل للنقر
Widget _buildSelectableCard(NotificationModel notification) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    color: _selectedNotifications.contains(notification.id)
        ? ColorsApp.primaryLight
        : null,
    child: InkWell(
      onTap: () {
        if (_isSelectMode) {
          _toggleNotificationSelection(notification.id);
        } else {
          _handleNotificationTap(context, notification);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: !_isSelectMode && !notification.isRead
              ? Border.all(color: ColorsApp.primaryColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: _isSelectMode 
              ? Checkbox(
                  value: _selectedNotifications.contains(notification.id),
                  onChanged: (value) {
                    _toggleNotificationSelection(notification.id);
                  },
                  checkColor: ColorsApp.primaryLight,
                  activeColor: ColorsApp.primaryColor,
                )
              : CircleAvatar(
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: notification.isRead ? Colors.grey : Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  if (!_isSelectMode)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(notification.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (!notification.isRead && !_isSelectMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'جديد',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          trailing: !_isSelectMode
              ? (notification.isRead 
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                  : Icon(Icons.circle, color: ColorsApp.primaryColor, size: 16))
              : null,
          isThreeLine: true,
          onLongPress: () {
            if (!_isSelectMode) {
              _toggleSelectMode();
              _toggleNotificationSelection(notification.id);
            }
          },
        ),
      ),
    ),
  );
}
// 🔥 دالة جديدة للتعامل مع الضغط على الإشعار
void _handleNotificationTap(BuildContext context, NotificationModel notification) {
  // تحديث حالة الإشعار كمقروء أولاً
  _markNotificationAsRead(context, notification.id);
  
  // ثم الانتقال للشاشة المناسبة
  switch (notification.type) {
    case 'advertisement':
      _navigateToAdvertisement(context, notification);
      break;
    case 'complaint':
      _navigateToComplaint(context, notification);
      break;
    case 'request':
      _navigateToRequest(context, notification);
      break;
    case 'homework':
    case 'curriculum':
    case 'attendance':
    case 'exam':
    case 'group_advertisement':
      _navigateToSubjective(context, notification);
      break;
    case 'test':
      // للإشعارات الاختبارية، لا ننتقل
      break;
    default:
      print('ℹ️ Unknown notification type: ${notification.type}');
  }
}

// 🔥 دالة لتحديد الإشعار كمقروء
void _markNotificationAsRead(BuildContext context, String notificationId) {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<NotificationsBloc>().add(MarkNotificationAsRead(notificationId));
    }
  } catch (e) {
    print('⚠️ Error marking notification as read: $e');
  }
}

// 🔥 دالة للانتقال للإعلانات
void _navigateToAdvertisement(BuildContext context, NotificationModel notification) {
  final advertisementId = notification.metadata?['advertisementId'];
  final custom = notification.metadata?['custom'];
  
  if (advertisementId != null) {
    print('📢 Navigating to advertisement: $advertisementId');
    // الانتقال لشاشة الإعلانات
    // context.pushNamed(Routes.advertisements, arguments: {
    //   'advertisementId': advertisementId,
    //   'custom': custom,
    // });
  }
}

// 🔥 دالة للانتقال للشكاوى
void _navigateToComplaint(BuildContext context, NotificationModel notification) {
  final complaintId = notification.metadata?['complaintId'];
  final studentId = notification.metadata?['studentId'];
  
  if (complaintId != null) {
    print('📋 Navigating to complaint: $complaintId');
    // الانتقال لشاشة الشكاوى
    context.pushNamed(Routes.complaintsList);
    
    // يمكنك أيضاً تمرير arguments للانتقال مباشرة لشكوى محددة
    // context.pushNamed(Routes.complaintsList, arguments: {
    //   'selectedComplaintId': complaintId,
    //   'studentId': studentId,
    // });
  }
}

// 🔥 دالة للانتقال للطلبات
void _navigateToRequest(BuildContext context, NotificationModel notification) {
  final requestId = notification.metadata?['requestId'];
  final requestType = notification.metadata?['requestType'];
  final status = notification.metadata?['status'];
  
  if (requestId != null) {
    print('📝 Navigating to request: $requestId');
    
    // تحديد الشاشة المناسبة بناءً على دور المستخدم
    final userRole = getUserRole(context);
    
    if (userRole == 'Admin' || userRole == 'Manager') {
      // للمسؤولين: الانتقال لشاشة رد الطلبات
      context.pushNamed(Routes.replyRequest, arguments: {
        'requestId': requestId,
        'requestType': requestType,
      });
    } else {
      // للطلاب: الانتقال لشاشة عرض الطلبات
      context.pushNamed(Routes.displayRequest);
    }
  }
}

// 🔥 دالة للانتقال للشاشات الأكاديمية
void _navigateToSubjective(BuildContext context, NotificationModel notification) {
  final metadata = notification.metadata ?? {};
  
  print('🎓 Navigating to subjective with type: ${notification.type}');
  
  // أولاً: الانتقال للشاشة الرئيسية للمواد
  context.pushNamed(Routes.subjectiveMain);
  
  // يمكنك إضافة منطق أكثر تقدماً للانتقال مباشرة للشاشة المحددة
  switch (notification.type) {
    case 'homework':
      // يمكن الانتقال مباشرة لشاشة الواجبات
      // final homeworkId = metadata['homeworkId'];
      // final groupId = metadata['groupId'];
      break;
    case 'curriculum':
      // شاشة المناهج
      break;
    case 'exam':
      // شاشة الدرجات
      break;
    case 'attendance':
      // شاشة الحضور والغياب
      break;
  }
}


}