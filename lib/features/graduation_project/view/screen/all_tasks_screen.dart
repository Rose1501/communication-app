import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/view/screen/new_task_screen.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// شاشة عرض جميع المهام
/// تستخدم لعرض قائمة المهام مع إمكانية إضافة مهمة جديدة (للمشرفين فقط)
class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  // متغير لتتبع حالة التحديث
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    // تحميل جميع المهام عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTasks();
    });
  }

  /// دالة لتحديث المهام
  Future<void> _refreshTasks() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      context.read<ProjectBloc>().add(const LoadAllTasks());
      // انتظر قليلاً لضمان اكتمال العملية
      await Future.delayed(const Duration(milliseconds: 300));
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
      return userRole == 'Doctor';
    }
    return false;
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'جميع المهام'),
      // إظهار زر الإضافة فقط للمشرفين
      floatingActionButton: _isCurrentUserSupervisor() ? _buildAddTaskButton(context) : null,
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectOperationSuccess) {
            // إعادة تحميل البيانات بعد أي عملية ناجحة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshTasks();
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
            if (state is TasksLoaded) {
              if (state.tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مهام حالياً',
                        style: font18blackbold,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCurrentUserSupervisor() 
                          ? 'استخدم الزر (+) لإضافة مهمة جديدة'
                          : 'سيتم عرض المهام هنا عند إضافتها',
                        style: font14grey,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: ColorsApp.primaryColor,
                backgroundColor: Colors.white,
                onRefresh: _refreshTasks,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return _buildTaskCard(task);
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
                      'حدث خطأ في تحميل المهام',
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
                      onPressed: _refreshTasks,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('ابدأ بتحميل المهام'));
          },
        ),
      ),
    );
  }

  /// زر إضافة مهمة جديدة (يظهر فقط للمشرفين)
  Widget? _buildAddTaskButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewTaskScreen(),
          ),
        ).then((_) {
          // عند العودة من شاشة الإضافة، قم بتحديث القائمة
          _refreshTasks();
        });
      },
      backgroundColor: ColorsApp.primaryColor,
      child: const Icon(Icons.assignment, color: Colors.white),
    );
  }

  /// بناء بطاقة المهمة
  Widget _buildTaskCard(TaskModel task) {
    Color statusColor = ColorsApp.primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.assignment, color: statusColor),
            ),
            title: Text(task.title, style: font16blackbold),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null)
                  Text(
                    task.description!,
                    style: font14grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  'تاريخ الإنشاء: ${_formatDate(task.createdAt)}',
                  style: font12Grey,
                ),
              ],
            ),
            trailing: _isCurrentUserSupervisor() 
              ? PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editTask(task);
                    } else if (value == 'delete') {
                      _deleteTask(task);
                    } else if (value == 'submissions') {
                      _viewTaskSubmissions(task);
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
                    PopupMenuItem(
                      value: 'submissions',
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Text('التسليمات'),
                        ],
                      ),
                    ),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.folder_open, color: ColorsApp.primaryColor),
                  onPressed: () => _viewTaskSubmissions(task),
                  tooltip: 'عرض التسليمات',
                ),
            onTap: () {
              // يمكن إضافة التنقل إلى تفاصيل المهمة هنا
            },
          ),
          // قسم المرفقات
          if (task.attachmentUrl != null && task.attachmentUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[20],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مرفق: ${task.attachmentUrl!.split('/').last}',
                      style: font12Grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _downloadAttachment(task),
                    child: Text(
                      'تحميل',
                      style: font13Primary.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // إضافة دالة تعديل المهمة
  void _editTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(
          task: task, // تمرير المهمة المحددة للتعديل
        ),
      ),
    ).then((_) {
      // عند العودة من شاشة التعديل، قم بتحديث القائمة
      _refreshTasks();
    });
  }

  // إضافة دالة حذف المهمة
  void _deleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: Text('هل تريد حذف المهمة "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('إلغاء',style: font12black,),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // استخدام الحدث الجديد لحذف المهمة
              context.read<ProjectBloc>().add(DeleteTask(taskId: task.id));
            },
            style: ElevatedButton.styleFrom(),
            child:  Text('حذف',style: font12black,),
          ),
        ],
      ),
    );
  }

  // إضافة دالة عرض تسليمات المهمة
  void _viewTaskSubmissions(TaskModel task) {
    context.pushNamed(
      Routes.taskSubmission,
      arguments: {
        'taskid': task.id,
        'title': task.title,
      },
    ).then((_) {
      // عند العودة من شاشة التسليمات، قم بتحديث القائمة
      _refreshTasks();
    });
  }

  // دالة تحميل المرفق
  Future<void> _downloadAttachment(TaskModel task) async {
    try {
      ShowWidget.showMessage(context, 'جاري تحميل المرفق...', Colors.blue, font13White);
      
      // محاكاة تحميل الملف
      await Future.delayed(const Duration(seconds: 1));
      
      // إنشاء ملف مؤقت
      final directory = await getTemporaryDirectory();
      final fileName = task.attachmentUrl!.split('/').last;
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // للتجربة، سنقوم بإنشاء ملف نصي بسيط
      await file.writeAsString('محتوى الملف المرفق للمهمة: ${task.title}');
      
      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'ملف مرفق للمهمة: ${task.title}',
        subject: 'ملف مرفق للمهمة',
      );
      
      ShowWidget.showMessage(context, 'تم تحميل الملف بنجاح', Colors.green, font13White);
    } catch (e) {
      ShowWidget.showMessage(context, 'فشل في تحميل الملف: $e', Colors.red, font13White);
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}