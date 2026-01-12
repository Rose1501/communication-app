import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/view/screen/new_announcement_screen.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:intl/intl.dart';

/// شاشة عرض جميع الإعلانات
/// تستخدم لعرض قائمة الإعلانات مع إمكانية إضافة إعلان جديد (للمشرفين فقط)
class AllAnnouncementsScreen extends StatefulWidget {
  const AllAnnouncementsScreen({super.key});

  @override
  State<AllAnnouncementsScreen> createState() => _AllAnnouncementsScreenState();
}

class _AllAnnouncementsScreenState extends State<AllAnnouncementsScreen> {
  // متغير لتتبع حالة التحديث
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    // تحميل جميع الإعلانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAnnouncements();
    });
  }

  /// دالة لتحديث الإعلانات
  Future<void> _refreshAnnouncements() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      context.read<ProjectBloc>().add(const LoadAllAnnouncements());
      // انتظر قليلاً لضمان اكتمال العملية
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// التحقق مما إذا كان المستخدم الحالي مشرفًا
  bool _isCurrentUserSupervisor() {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      final userRole = myUserState.user!.role;
      // المشرفون هم Doctor, ويمكن إضافة أدوار أخرى حسب الحاجة
      return userRole == 'Doctor' || userRole == 'Admin' || userRole == 'Manager';
    }
    return false;
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'جميع الإعلانات'),
      // إظهار زر الإضافة فقط للمشرفين
      floatingActionButton: _isCurrentUserSupervisor() ? _buildAddAnnouncementButton(context) : null,
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectOperationSuccess) {
            // إعادة تحميل البيانات بعد أي عملية ناجحة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshAnnouncements();
            });
            
            // عرض رسالة نجاح
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading && !_isRefreshing) {
              return Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
            }
            if (state is AnnouncementsLoaded) {
              if (state.announcements.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد إعلانات حالياً',
                        style: font18blackbold,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCurrentUserSupervisor() 
                          ? 'استخدم الزر (+) لإضافة إعلان جديد'
                          : 'سيتم عرض الإعلانات هنا عند إضافتها',
                        style: font14grey,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: ColorsApp.primaryColor,
                backgroundColor: Colors.white,
                onRefresh: _refreshAnnouncements,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: state.announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = state.announcements[index];
                    return _buildAnnouncementCard(announcement);
                  },
                ),
              );
            }
            if (state is ProjectError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل الإعلانات',
                      style: font18blackbold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error,
                      style: font14grey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshAnnouncements,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('ابدأ بتحميل الإعلانات'));
          },
        ),
      ),
    );
  }

  /// زر إضافة إعلان جديد (يظهر فقط للمشرفين)
  Widget? _buildAddAnnouncementButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewAnnouncementScreen(),
          ),
        ).then((_) {
          // عند العودة من شاشة الإضافة، قم بتحديث القائمة
          _refreshAnnouncements();
        });
      },
      backgroundColor: ColorsApp.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// بناء بطاقة الإعلان مع عرض الحالة وأزرار التعديل والحذف
  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    Color statusColor = _getPriorityColor(announcement.priority);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(
                _getPriorityIcon(announcement.priority),
                color: statusColor,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: font16blackbold,
                  ),
                ),
                // عرض حالة الإعلان
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getPriorityText(announcement.priority),
                    style: font12black.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (announcement.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      announcement.content,
                      style: font14grey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'تاريخ الإنشاء: ${_formatDate(announcement.createdAt)}',
                  style: font12Grey,
                ),
              ],
            ),
            trailing: _isCurrentUserSupervisor() 
              ? PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editAnnouncement(announcement);
                    } else if (value == 'delete') {
                      _deleteAnnouncement(announcement);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
          ),
        ],
      ),
    );
  }

  /// الحصول على أيقونة الأولوية
  IconData _getPriorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Icons.priority_high;
      case AnnouncementPriority.important:
        return Icons.priority_high;
      default:
        return Icons.notifications;
    }
  }

  /// الحصول على لون الأولوية
  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Colors.red;
      case AnnouncementPriority.important:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// الحصول على نص الأولوية (نفس الدالة في NewAnnouncementScreen)
  String _getPriorityText(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return 'عاجل';
      case AnnouncementPriority.important:
        return 'مهم';
      default:
        return 'عادي';
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// تعديل الإعلان
  void _editAnnouncement(AnnouncementModel announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAnnouncementScreen(
          announcement: announcement, // تمرير الإعلان المحدد للتعديل
        ),
      ),
    ).then((_) {
      // عند العودة من شاشة التعديل، قم بتحديث القائمة
      _refreshAnnouncements();
    });
  }

  /// حذف الإعلان
  void _deleteAnnouncement(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: Text('هل تريد حذف الإعلان "${announcement.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('إلغاء',style: font12black,),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // استخدام الحدث الجديد لحذف الإعلان
              context.read<ProjectBloc>().add(DeleteAnnouncement(announcementId: announcement.id));
            },
            style: ElevatedButton.styleFrom(),
            child:  Text('حذف',style: font12black,),
          ),
        ],
      ),
    );
  }
}