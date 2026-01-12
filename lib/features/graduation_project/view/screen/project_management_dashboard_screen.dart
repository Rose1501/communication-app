import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:intl/intl.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/image_utils.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/view/screen/all_announcements_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/all_tasks_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/project_details_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/supervisor_management_screen.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

/// لوحة تحكم المشاريع
/// تعرض إحصائيات المشاريع مع إمكانية الوصول السريع للمهام والإعلانات وإدارة المشرفين
class ProjectManagementDashboardScreen extends StatefulWidget {
  const ProjectManagementDashboardScreen({super.key});

  @override
  State<ProjectManagementDashboardScreen> createState() => _ProjectManagementDashboardScreenState();
}

class _ProjectManagementDashboardScreenState extends State<ProjectManagementDashboardScreen> 
    with AutomaticKeepAliveClientMixin<ProjectManagementDashboardScreen> {
  int _selectedIndex = 1;
  // متغيرات منفصلة لتتبع حالة التحميل لكل جزء من البيانات
  bool _isSemesterLoading = true;
  bool _isProjectsLoading = true;
  bool _isSettingsLoading = true;
  bool _isRefreshing = false; // متغير جديد لتتبع حالة التحديث
  SemesterModel? _currentSemester;
  ProjectSettingsModel? _projectSettings;
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _currentSemesterProjects = [];
  int _totalStudents = 0;
  int _totalSupervisors = 0;


  @override
  bool get wantKeepAlive => true; // إبقاء حالة الـ Widget حية

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, _getUserRole(), context);
  }

  /// الحصول على دور المستخدم الحالي
  String _getUserRole() {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'User';
  }

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// تحديث الإحصائيات بناءً على البيانات المتاحة
  void _updateStatistics() {
    if (_currentSemester != null && _projectSettings != null && _allProjects.isNotEmpty) {
      // حساب المشاريع في الفصل الدراسي الحالي
      _currentSemesterProjects = _allProjects.where((project) {
        return project.createdAt.isAfter(_currentSemester!.startTime) && 
                project.createdAt.isBefore(_currentSemester!.endTime);
      }).toList();

      // حساب عدد الطلاب والمشرفين
      _totalStudents = _projectSettings!.studentList.length;
      _totalSupervisors = _projectSettings!.adminUsers.length;
    }
  }

  /// تحميل جميع البيانات المطلوبة
  Future<void> _loadData() async {
    // إعادة تعيين حالات التحميل
    if (mounted) {
      setState(() {
        _isSemesterLoading = true;
        _isProjectsLoading = true;
        _isSettingsLoading = true;
        _isRefreshing = false; // إعادة تعيين حالة التحديث
      });
    }

    try {
      // تحميل الفصل الدراسي الحالي باستخدام Bloc
      context.read<SemesterCoursesBloc>().add(const GetCurrentSemester());
      
      // تحميل إعدادات المشروع
      context.read<ProjectBloc>().add(GetProjectSettings());
      
      // تحميل جميع المشاريع
      context.read<ProjectBloc>().add(LoadAllProjects());
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      if (mounted) {
        setState(() {
          _isSemesterLoading = false;
          _isProjectsLoading = false;
          _isSettingsLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  /// دالة التحديث عند السحب للتحديث
  Future<void> _refreshData() async {
    // تعيين حالة التحديث
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      // تحميل البيانات مرة أخرى
      await _loadData();
    } finally {
      // إنهاء حالة التحديث دائمًا
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        // الاستماع لتغيرات SemesterCoursesBloc
        BlocListener<SemesterCoursesBloc, SemesterCoursesState>(
          listener: (context, state) {
            print('🔄 SemesterCoursesState تغير: ${state.runtimeType}');
            if (state.currentSemester != null) {
              print('📅 الفصل الدراسي تم تحميله: ${state.currentSemester!.typeSemester}');
              setState(() {
                _currentSemester = state.currentSemester;
                _isSemesterLoading = false; // انتهى تحميل الفصل
                _updateStatistics();
                print('✅ تم تحديث حالة الفصل الدراسي');
              });
            }
            if (state.status == SemesterCoursesStatus.error && state.errorMessage.isNotEmpty) {
              print('❌ خطأ في تحميل الفصل الدراسي: ${state.errorMessage}');
              setState(() {
                _isSemesterLoading = false; // توقف التحميل حتى في حالة الخطأ
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        // الاستماع لتغيرات ProjectBloc
        BlocListener<ProjectBloc, ProjectState>(
          listener: (context, state) {
            print('🔄 ProjectState تغير: ${state.runtimeType}');
            if (state is ProjectsLoaded) {
              print('📊 تم تحميل ${state.projects.length} مشروع');
              setState(() {
                _allProjects = state.projects;
                _isProjectsLoading = false; // انتهى تحميل المشاريع
                _updateStatistics();
                print('✅ تم تحديث حالة المشاريع');
              });
            }
            if (state is ProjectSettingsLoaded) {
              print('🔧 تم تحميل إعدادات المشروع');
              setState(() {
                _projectSettings = state.settings;
                _isSettingsLoading = false; // انتهى تحميل الإعدادات
                _updateStatistics();
                print('✅ تم تحديث حالة إعدادات المشروع');
              });
            }
            if (state is ProjectError) {
              print('❌ خطأ في تحميل بيانات المشروع: ${state.error}');
              setState(() {
                _isProjectsLoading = false;
                _isSettingsLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: const CustomAppBarTitle(title: 'لوحة تحكم المشاريع'),
        body: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            print('🔄 ProjectState في BlocBuilder: ${state.runtimeType}');
        
            // بناء الجسم بناءً على حالة الـ Bloc الحالية
            return _buildBodyForState(state);
          },
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSpeedDial(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          userRole: _getUserRole(),
        ),
      ),
    );
  }

  /// بناء الجسم بناءً على حالة الـ Bloc الحالية
Widget _buildBodyForState(ProjectState state) {
  // عرض مؤشر التحميل عند تحميل البيانات
  if (state is ProjectLoading) {
    return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
  }
  
  // عرض محتوى الشاشة عند اكتمال التحميل
  if (state is ProjectSettingsLoaded || state is ProjectsLoaded) {
    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الفصل الدراسي الحالي
            _buildSemesterInfo(),
            const SizedBox(height: 24),
            
            // بطاقات الإحصائيات
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            
            // معلومات المشروع
            _buildProjectInfo(),
            const SizedBox(height: 24),
            
            // المشرفون
            _buildSupervisorsList(),
            const SizedBox(height: 24),
            
            // المشاريع الحديثة
            _buildRecentProjects(),
            
            // مسافة إضافية في الأسفل للسماح بالسحب للتحديث
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  // عرض رسالة خطأ في حالة وجود خطأ
  if (state is ProjectError) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: font18blackbold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.error,
            style: font14grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
  // عرض رسالة فارغة في حالة عدم وجود بيانات
  if (state is ProjectInitial) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات حالياً',
            style: font18blackbold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('تحميل البيانات'),
          ),
        ],
      ),
    );
  }
  // في حالة أخرى، لا ينبغي أن نصل هنا
  return const Center(
    child: Text('حالة غير معروفة'),
  );
}

  /// بناء معلومات الفصل الدراسي الحالي
  Widget _buildSemesterInfo() {
    if (_currentSemester == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Text('لا يوجد فصل دراسي نشط حالياً', style: font16black),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: ColorsApp.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'الفصل الدراسي الحالي',
                  style: font18blackbold,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'الفصل الدراسي',
                    _currentSemester!.typeSemester,
                    Icons.school,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'الأسبوع الحالي',
                    _currentSemester!.currentWeek,
                    Icons.date_range,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'بداية الفصل',
                    DateFormat('yyyy/MM/dd').format(_currentSemester!.startTime),
                    Icons.play_arrow,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'نهاية الفصل',
                    DateFormat('yyyy/MM/dd').format(_currentSemester!.endTime),
                    Icons.stop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقات الإحصائيات
  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المشاريع',
          style: font18blackbold,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المشاريع',
                '${_allProjects.length}',
                Icons.assignment,
                ColorsApp.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'مشاريع هذا الفصل',
                '${_currentSemesterProjects.length}',
                Icons.today,
                ColorsApp.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'عدد الطلاب',
                '$_totalStudents',
                Icons.people,
                ColorsApp.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'عدد المشرفين',
                '$_totalSupervisors',
                Icons.supervisor_account,
                ColorsApp.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بناء معلومات المشروع
  Widget _buildProjectInfo() {
    if (_projectSettings == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Text('لا توجد إعدادات انضمام متاحة', style: font16black),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key, color: ColorsApp.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'معلومات الانضمام',
                  style: font18blackbold,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorsApp.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _projectSettings!.joinCode,
                    style: font20blackbold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قائمة المشرفين
  Widget _buildSupervisorsList() {
    if (_projectSettings == null || _projectSettings!.adminUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.supervisor_account, color: ColorsApp.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'المشرفون',
                  style: font18blackbold,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: _projectSettings!.adminUsers.map((supervisor) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _buildSupervisorAvatar(supervisor),
                  title: Text(supervisor.name, style: font16black),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء صورة المشرف مع التعامل مع الصور المشفرة
  Widget _buildSupervisorAvatar(UserModels supervisor) {
    // التحقق مما إذا كانت الصورة من Firebase Storage أو Base64
    if (supervisor.urlImg != null && supervisor.urlImg!.isNotEmpty) {
      // إذا كانت الصورة رابط URL من Firebase Storage
      if (supervisor.urlImg!.startsWith('http')) {
        return CircleAvatar(
          radius: 28,
          backgroundColor: ColorsApp.primaryColor,
          backgroundImage: NetworkImage(supervisor.urlImg!),
        );
      }
    }
     // إذا كانت الصورة بتنسيق Base64
    if (supervisor.urlImg != null && supervisor.urlImg!.isNotEmpty) {
      try {
        // التحقق من أن النص يحت على بيانات صالحة Base64
        if (ImageUtils.isValidBase64(supervisor.urlImg!)) {
          return CircleAvatar(
            radius: 28,
            backgroundColor: ColorsApp.primaryColor,
            backgroundImage:
              ImageUtils.base64ToImageWidget(
                supervisor.urlImg!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: _buildDefaultImage(supervisor),
              ).image,
          );
        }
        } catch (e) {
        print('❌ خطأ في تحميل الصورة من Base64: $e');
      }
    }
    
    // في حالة عدم وجود صورة، عرض الصورة الافتراضية
    return _buildDefaultImage(supervisor);
  }

  /// بناء الصورة الافتراضية للمشرف
  Widget _buildDefaultImage(UserModels supervisor) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: ColorsApp.primaryColor,
      backgroundImage: supervisor.gender == "Male" ||supervisor.gender == "male"
        ? const AssetImage(HomeData.man)
        : const AssetImage(HomeData.woman),
    );
  }


  /// بناء المشاريع الحديثة
  Widget _buildRecentProjects() {
    if (_currentSemesterProjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recent_actors, color: ColorsApp.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'مشاريع هذا الفصل',
                  style: font18blackbold,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<ProjectBloc>(context),
                          child: ProjectDetailsScreen(
                            projectSettings: _projectSettings!,
                            userRole: _getUserRole(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('عرض الكل', style: font15primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: _currentSemesterProjects.take(3).map((project) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: ColorsApp.primaryColor,
                    child: Text(
                      project.title.isNotEmpty ? project.title[0] : 'P',
                      style: font16White,
                    ),
                  ),
                  title: Text(project.title, style: font16black),
                  subtitle: Text(
                    'تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd').format(project.createdAt)}',
                    style: font14grey,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر معلومة
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: font12Grey),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: font16black.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: font20blackbold.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: font14grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قائمة الأزرار المنبثقة
  Widget _buildSpeedDial() {
    // تحديد حجم الشاشة
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isVerySmallScreen = screenSize.width < 320;
        
    // في الشاشات الصغيرة جدًا، نغير اتجاه القائمة إلى الجانب
    final direction = isVerySmallScreen ? SpeedDialDirection.left : SpeedDialDirection.up;
    
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
      children: [
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
        // زر إدارة المشرفين
        SpeedDialChild(
          child: const Icon(Icons.person_add),
          label: 'إدارة المشرفين',
          labelStyle: font14black,
          backgroundColor: ColorsApp.primaryColor,
          foregroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupervisorManagementScreen()),
            );
          },
        ),
      ],
    );
  }
}