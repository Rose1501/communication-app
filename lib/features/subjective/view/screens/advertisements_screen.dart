import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/screens/new_advertisement_screen.dart'; 
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AdvertisementsScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final String userId;

  const AdvertisementsScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.userId,
  });

  @override
  State<AdvertisementsScreen> createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends State<AdvertisementsScreen> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  void _loadAdvertisements() {
    // استخدام معرف الفصل الحالي أو جلبه من مكان آخر إذا لزم الأمر
    context.read<SubjectiveBloc>().add(
      LoadAdvertisementsEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
      ),
    );
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: ' إعلانات ${widget.course.codeCs} - ${widget.group.name} '),
      floatingActionButton: widget.userRole == 'Doctor'
          ? FloatingActionButton(
              onPressed: _addAdvertisement,
              backgroundColor: ColorsApp.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          if (state is SubjectiveOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsApp.green,
              ),
            );
            // إعادة تحميل القائمة بعد كل عملية ناجحة
            _loadAdvertisements();
          }
          if (state is SubjectiveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsApp.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubjectiveLoading) {
            return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
          }

          if (state is AdvertisementLoadSuccess) {
            if (state.advertisements.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: ColorsApp.primaryColor,
              onRefresh: () async => _loadAdvertisements(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.advertisements.length,
                itemBuilder: (context, index) {
                  final advertisement = state.advertisements[index];
                  return _buildAdvertisementCard(advertisement);
                },
              ),
            );
          }

          // حالة أولية أو خطأ في تحميل البيانات لأول مرة
          return _buildInitialErrorState();
        },
      ),
    );
  }

  // بناء حالة فارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد إعلانات',
            style: font18blackbold,
          ),
          const SizedBox(height: 8),
          Text(
            widget.userRole == 'Doctor'
                ? 'يمكنك إضافة الإعلانات من خلال زر الإضافة'
                : 'سيتم عرض الإعلانات هنا عندما ينشرها الأستاذ',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // بناء حالة الخطأ الأولية
  Widget _buildInitialErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ ما',
            style: font16black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAdvertisements,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة الإعلان
  Widget _buildAdvertisementCard(AdvertisementModel  advertisement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: advertisement.isImportant ? ColorsApp.white.withOpacity(0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة - العنوان والأيقونة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                          advertisement.isImportant ? Icons.campaign : Icons.announcement,
                          color: advertisement.isImportant ? Colors.red : ColorsApp.primaryColor,),
                          const SizedBox(width: 8),
                          Expanded(
                          child: Text(
                            advertisement.isImportant ? 'أعلان هام' :'أعلان',
                            style: font16black.copyWith(
                              fontWeight: FontWeight.bold,
                              color: advertisement.isImportant ? Colors.red : ColorsApp.primaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                                      ),
                    ],
                  ),
              ),
              // زر القائمة للدكتور فقط
              if (widget.userRole == 'Doctor')
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAdvertisementAction(value, advertisement),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
              // شارة "مهم" للإعلانات المهمة
              if (advertisement.isImportant && widget.userRole != 'Doctor')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'مهم',
                    style: font11White,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // وصف الإعلان
          if (advertisement.description.isNotEmpty) ...[
            Text(
              advertisement.description,
              style: font14black,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
          ],
          
          // معلومات الوقت
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: ColorsApp.grey),
              const SizedBox(width: 4),
              Text(
                _formatTime(advertisement.time),
                style: font12Grey,
              ),
              const Spacer(),
              Text(
                _getTimeAgo(advertisement.time),
                style: font12Grey,
              ),
            ],
          ),
          
          // تاريخ الانتهاء إذا كان موجوداً
          if (advertisement.expiryDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_off, size: 16, color: ColorsApp.grey),
                const SizedBox(width: 4),
                Text(
                  'ينتهي: ${_formatTime(advertisement.expiryDate!)}',
                  style: font12Grey,
                ),
                if (advertisement.isExpired) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'منتهي',
                      style: font11White,
                    ),
                  ),
                ],
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // زر فتح الملف المرفق
          if (advertisement.file.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _openFile(advertisement.file),
              icon: const Icon(Icons.file_open, color: Colors.white),
              label: const Text('فتح الملف المرفق', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.primaryColor,
              ),
            ),
        ],
      ),
    ),
  );
}

  // ========== دوال التعامل مع الإعلانات ==========

  // 1. إضافة إعلان جديد
  void _addAdvertisement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAdvertisementScreen(
          course: widget.course,
          selectedGroups: [widget.group], // إعلان لمجموعة واحدة
          doctorId: widget.userId,
        ),
      ),
    ).then((result) {
      // إذا تمت الإضافة بنجاح، قم بتحديث القائمة
      if (result == true) {
        _loadAdvertisements();
      }
    });
  }

  // 2. التعامل مع قائمة الخيارات (تعديل/حذف)
  void _handleAdvertisementAction(String action, AdvertisementModel advertisement) {
    switch (action) {
      case 'edit':
        _editAdvertisement(advertisement);
        break;
      case 'delete':
        _deleteAdvertisement(advertisement);
        break;
    }
  }

  // 3. تعديل إعلان
  void _editAdvertisement(AdvertisementModel advertisement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAdvertisementScreen(
          course: widget.course,
          selectedGroups: [widget.group],
          doctorId: widget.userId,
          advertisementToEdit: advertisement, // 🔥 تمرير الإعلان للتعديل
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadAdvertisements();
      }
    });
  }
  // 4. حذف إعلان
  void _deleteAdvertisement(AdvertisementModel advertisement) {
    CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الإعلان',
      message: 'هل أنت متأكد من حذف هذا الإعلان؟',
      confirmText: ' احذف',
      cancelText: 'إلغاء',
    ).then((confirmed) {
      if (confirmed) {
        context.read<SubjectiveBloc>().add(
          DeleteAdvertisementEvent(
            courseId: widget.course.id,
            groupId: widget.group.id,
            advertisementId: advertisement.id,
          ),
        );
      }
    });
  }

  // 5. فتح الملف
  Future<void> _openFile(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح الملف: $fileUrl'),
            backgroundColor: ColorsApp.red,
          ),
        );
      }
    }
  }

  // ========== دوال مساعدة ==========

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} - ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}