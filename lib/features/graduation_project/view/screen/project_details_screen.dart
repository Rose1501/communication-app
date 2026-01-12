import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/bloc/user/user_bloc.dart';
import 'package:myproject/features/graduation_project/view/screen/all_announcements_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/all_tasks_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/create_project_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/project_management_dashboard_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// شاشة عرض جميع المشاريع في جدول
/// تعرض جميع المشاريع مع إمكانية عرض الملفات المرفقة
class ProjectDetailsScreen extends StatefulWidget {
  final ProjectSettingsModel projectSettings;
  final String userRole;

  const ProjectDetailsScreen({
    super.key,
    required this.projectSettings,
    required this.userRole,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  bool _isRefreshing = false; // متغير لتتبع حالة التحديث
  int _selectedProjectIndex = 0;
  
  // متغيرات لتخزين بيانات الإعدادات المحدثة
  ProjectSettingsModel _currentSettings;
  // إضافة المُنشئ لتهيئة المتغير
  _ProjectDetailsScreenState() : _currentSettings = const ProjectSettingsModel(
    joinCode: '',
    studentList: [],
    adminUsers: [],
  );

  @override
  void initState() {
    super.initState();
    // تهيئة بيانات الإعدادات الحالية
    _currentSettings = widget.projectSettings;
    
    // تحميل جميع المشاريع عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  /// تحديث جميع البيانات (المشاريع والإعدادات)
  Future<void> _refreshData() async {
    // تحميل المشاريع
    context.read<ProjectBloc>().add(LoadAllProjects());
    
    // تحميل إعدادات المشروع
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // استخدام Future.delayed لمحاكاة تحميل البيانات
      await Future.delayed(const Duration(milliseconds: 500));
      
      // في التطبيق الحقيقي، ستقوم باستدعاء الـ Bloc لتحميل الإعدادات
      context.read<ProjectBloc>().add(GetProjectSettings());
    } catch (e) {
      print('خطأ في تحديث البيانات: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// عرض مربع حوار لتحميل الملف المرفق
  void _showDownloadDialog(BuildContext context, String? fileUrl, String projectName) {
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد ملف مرفق'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحميل الملف المرفق'),
        content: const Text('هل تريد تحميل الملف المرفق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(fileUrl, projectName);
            },
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }

  /// تحميل الملف المرفق
  Future<void> _downloadFile(String fileUrl, String projectName) async {
    try {
      // هنا يمكنك تحميل الملف من الرابط
      // هذا مجرد مثال، ستحتاج إلى تعديله حسب احتياجاتك
      
      // إنشاء ملف مؤقت
      final directory = await getTemporaryDirectory();
      final fileName = fileUrl.split('/').last;
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // محاكاة تحميل الملف
      await Future.delayed(const Duration(seconds: 1));
      await file.writeAsString('محتوى الملف المرفق للمشروع: $projectName');
      
      // مشاركة الملف
        await Share.shareXFiles(
        [XFile(filePath)],
        text: 'ملف مرفق للمشروع: $projectName',
        subject: 'ملف مرفق للمشروع',
      );
      
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحميل الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// بناء قائمة الأزرار المنبثقة
  Widget _buildSpeedDial() {
    // تحديد حجم الشاشة
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isVerySmallScreen = screenSize.width < 320;
    
    // في الشاشات الصغيرة جدًا، نغير اتجاه القائمة إلى الجانب
    final direction = isVerySmallScreen ? SpeedDialDirection.left : SpeedDialDirection.up;
    
    // إنشاء قائمة الأزرار
    List<SpeedDialChild> children = [
      // زر الإعلانات
      SpeedDialChild(
        child: const Icon(Icons.campaign),
        label: 'الإعلانات',
        labelStyle: font14black,
        backgroundColor: ColorsApp.primaryColor,
        foregroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllAnnouncementsScreen()),
          );
        },
      ),
      // زر المهام
      SpeedDialChild(
        child: const Icon(Icons.assignment),
        label: 'المهام',
        labelStyle: font14black,
        backgroundColor: ColorsApp.primaryColor,
        foregroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllTasksScreen()),
          );
        },
      ),
    ];
    
    // إضافة زر إضافة مشروع للطلاب فقط
    if (widget.userRole == 'Student') {
      children.add(
        SpeedDialChild(
          child: const Icon(Icons.add),
          label: 'إضافة مشروع جديد',
          labelStyle: font14black,
          backgroundColor: ColorsApp.primaryColor,
          foregroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
            );
          },
        ),
      );
    }
    
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
      spaceBetweenChildren: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
      childMargin: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      animationCurve: Curves.elasticInOut,
      animationDuration: const Duration(milliseconds: 200),
      visible: true,
      direction: direction,
      switchLabelPosition: false,
      closeManually: false,
      useRotationAnimation: true,
      foregroundColor: Colors.white,
      backgroundColor: ColorsApp.primaryColor,
      activeForegroundColor: ColorsApp.primaryColor,
      activeBackgroundColor: Colors.white,
      elevation: 8.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'المشاريع'),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectsLoaded) {
            setState(() {
              _projects = state.projects;
              _isLoading = false;
            });
          }
          if (state is ProjectLoading) {
            setState(() {
              _isLoading = true;
            });
          }
          if (state is ProjectError) {
            setState(() {
              _isLoading = false;
              _isRefreshing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ProjectOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // إعادة تحميل المشاريع بعد التحديث
            context.read<ProjectBloc>().add(LoadAllProjects());
          }
          // تحديث بيانات الإعدادات عند تحميلها
          if (state is ProjectSettingsLoaded) {
            setState(() {
              _currentSettings = state.settings;
              _isRefreshing = false;
            });
          }
        },
        child: Column(
          children: [
            if (widget.userRole == 'Doctor' )
            _buildHeader(),
            getHeight(16),
            Expanded(
              child:  _isRefreshing && _projects.isEmpty
                  ?  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,))
                  : _buildProjectsTable(),
            ),
          ],
        ),
      ),
      // قائمة الأزرار المنبثقة
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding:  const EdgeInsets.all( 16.0),
          child: _buildSpeedDial(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // تحديد موقع الزر في اليمين
    );
  }

  /// بناء رأس الصفحة
  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'كود الانضمام: ',
                  style: font14grey,
                ),
                Text(
                  _currentSettings.joinCode,
                  style: font18blackbold,
                ),
                if (_isRefreshing)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorsApp.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
            getHeight(8),
            Row(
              children: [
                Text(
                  'عدد الطلاب: ',
                  style: font14grey,
                ),
                Text(
                  '${_currentSettings.studentList.length}',
                  style: font16black.copyWith(fontWeight: FontWeight.bold),
                ),
                getWidth(16),
                Text(
                  'عدد المشرفين: ',
                  style: font14grey,
                ),
                Text(
                  '${_currentSettings.adminUsers.length}',
                  style: font16black.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء جدول المشاريع
  Widget _buildProjectsTable() {
    if (_isLoading && _projects.isEmpty) {
      return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
    }

    if (_projects.isEmpty) {
      return RefreshIndicator(
        color: ColorsApp.primaryColor,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // السماح بالسحب حتى لو كان المحتوى قصيرًا
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6, // إعطاء ارتفاع كافٍ للسحب
            child: const Center(
              child: Text(
                'لا توجد مشاريع',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // السماح بالسحب حتى لو كان المحتوى قصيرًا
        child: Column(
          children: [
            // إضافة مساحة إضافية في الأعلى للسماح بالسحب
            SizedBox(height: _projects.isEmpty ? 20.0 : 0.0),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(), // منع الارتداد الأفقي المفرط
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(), // منع الارتداد العمودي المفرط
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(ColorsApp.primaryColor.withOpacity(0.1)),
                    columns: [
                      DataColumn(
                        label: Text('م', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('عنوان المشروع', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('النوع', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('تاريخ الإنشاء', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('المشرف', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      if (widget.userRole == 'Doctor') // العمود الوحيد الذي يظهر للطالب
                        DataColumn(
                          label: Text('الملف المرفق', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      //if (widget.userRole == 'Doctor' || widget.userRole == 'Manager'|| widget.userRole == 'Student')
                        DataColumn(
                          label: Text('الإجراءات', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                        ),
                    ],
                    rows: _projects.asMap().entries.map((entry) {
                      final index = entry.key;
                      final project = entry.value;
                      
                      // استخراج اسم المشرف الأول
                      String supervisorName = 'غير محدد';
                      if (project.supervisors.isNotEmpty) {
                        supervisorName = project.supervisors.first;
                      }
                      return DataRow(
                        cells: [
                          // خلية الترتيب
                          DataCell(Text((index + 1).toString())),
                          // خلية عنوان المشروع
                          DataCell(
                            Tooltip(
                              message: project.title,
                              child: Text(
                                project.title,
                                style: font12black,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                           // خلية نوع المشروع
                          DataCell(Text(project.projectType, style: font12black)),
                           // خلية تاريخ الإنشاء
                          DataCell(Text(DateFormat('yyyy/MM/dd').format(project.createdAt), style: font12black)),
                          // خلية اسم المشرف الأول
                          DataCell(Text(supervisorName,style: font12black,maxLines: 1,overflow: TextOverflow.ellipsis,),),
                          // خلية الملف المرفق (للأطباء فقط)
                          if (widget.userRole == 'Doctor') // العمود الوحيد الذي يظهر لدكتور
                            DataCell(
                              project.attachmentFile != null && project.attachmentFile!.isNotEmpty
                                  ? IconButton(
                                      icon:  Icon(Icons.download, color: ColorsApp.primaryColor),
                                      onPressed: () => _showDownloadDialog(context, project.attachmentFile, project.title),
                                      tooltip: 'تحميل الملف المرفق',
                                    )
                                  :  Text('لا يوجد ملف', style: font12Grey),
                            ),
                            // خلية الإجراءات (للأطباء والمديرين والطلاب)
                          //if (widget.userRole == 'Doctor' || widget.userRole == 'Manager'|| widget.userRole == 'Student')
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // زر عرض التفاصيل
                                  IconButton(
                                    icon: const Icon(Icons.info, color: Colors.blue),
                                    onPressed: () => _showProjectDetailsDialog(context, project),
                                    tooltip: 'عرض التفاصيل',
                                  ),
                                  // زر الحذف للأطباء فقط
                                  if ( widget.userRole == 'Doctor')
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteProjectDialog(context, project),
                                      tooltip: 'حذف المشروع',
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: _projects.isEmpty ? 20.0 : 100.0), // إضافة مساحة إضافية في الأسفل للسماح بالسحب
          ],
        ),
      ),
    );
  }

  /// عرض مربع حوار لتفاصيل المشروع
  void _showProjectDetailsDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الوصف: ${project.description}'),
              getHeight(8),
              Text('النوع: ${project.projectType}'),
              getHeight(8),
              Text('الأهداف: ${project.projectGoals}'),
              getHeight(8),
              Text('المشرفون: ${project.supervisors.join(', ')}'),
              getHeight(8),
              Text(
                'الطلاب: ${project.studentsName.asMap().entries.map((entry) {
                    final index = entry.key;
                    final name = entry.value;
                    final id = project.studentIds[index];
                    return '$name ($id)';
                  }).join(', ')}',
                ),
              getHeight(8),
              Text('تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd').format(project.createdAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// عرض مربع حوار لحذف المشروع
  void _showDeleteProjectDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشروع'),
        content: Text('هل تريد حذف المشروع "${project.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProjectBloc>().add(DeleteProject(projectId: project.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}