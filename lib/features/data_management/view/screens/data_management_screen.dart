import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/view/screens/courses_management_screen.dart';
import 'package:myproject/features/data_management/view/screens/semester_courses_screen.dart';
import 'package:myproject/features/data_management/view/screens/semesters_management_screen.dart';
import 'package:myproject/features/data_management/view/screens/users_management_screen.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';

/*
 * 🏠 الشاشة الرئيسية لإدارة البيانات
 * 
 * الأقسام:
 * 📚 مواد الفصل الدراسي | 👥 المستخدمين | 📖 المواد | 📅 الفصول
 */

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  int _selectedIndex = 1;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDataOnInit();
  }

  /// 🚀 تحميل البيانات تلقائياً عند فتح الشاشة
  void _loadDataOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataManagementBloc>().add(const LoadAllData());
    });
  }

  /// 🔄 سحب يدوي لتحديث البيانات
  Future<void> _handleRefresh() async {
    context.read<DataManagementBloc>().add(const ClearMessages());
    context.read<DataManagementBloc>().add(const LoadAllData());
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        if (myUserState.status != MyUserStatus.success || myUserState.user == null) {
          return _buildLoadingAppBar();
        }
        
        return _buildMainScreen(myUserState.user!);
      },
    );
  }

  /// ⏳ بناء شاشة التحميل
  Widget _buildLoadingAppBar() {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'إدارة البيانات'),
      body: Center(
        child: CircularProgressIndicator(color: ColorsApp.primaryColor),
      ),
    );
  }

  /// 🏗️ بناء الشاشة الرئيسية
  Widget _buildMainScreen(dynamic user) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: _getAppBarTitle()),
      body: BlocConsumer<DataManagementBloc, DataManagementState>(
        listener: _handleStateMessages,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: ColorsApp.primaryColor,
            backgroundColor: Colors.white,
            child: _buildBody(context, state, user),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 📢 معالجة رسائل الحالة
  void _handleStateMessages(BuildContext context, DataManagementState state) {
    if (state.errorMessage.isNotEmpty) {
      _showErrorMessage(state.errorMessage);
    }
    if (state.successMessage.isNotEmpty) {
      _showSuccessMessage(state.successMessage);
    }
  }

  /// ❌ عرض رسالة الخطأ
  void _showErrorMessage(String message) {
    ShowWidget.showMessage(context, message, Colors.red, font15White);
    _clearMessageAfterDelay();
  }

  /// ✅ عرض رسالة النجاح
  void _showSuccessMessage(String message) {
    ShowWidget.showMessage(context, message, Colors.green, font15White);
    _clearMessageAfterDelay();
  }

  /// 🧹 مسح الرسائل بعد عرضها
  void _clearMessageAfterDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<DataManagementBloc>().add(const ClearMessages());
      }
    });
  }

  /// 🏷️ الحصول على عنوان الشريط العلوي
  String _getAppBarTitle() {
    switch (_currentTab) {
      case 0: return 'مواد الفصل الدراسي';
      case 1: return 'إدارة المستخدمين';
      case 2: return 'إدارة المواد';
      case 3: return 'إدارة الفصول الدراسية';
      default: return 'إدارة البيانات';
    }
  }

  /// 🎨 بناء جسم الشاشة
  Widget _buildBody(BuildContext context, DataManagementState state, dynamic user) {
    return Column(
      children: [
        _buildTabBar(),
        getHeight(16),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  /// 🎯 بناء شريط التبويب
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.dashboard, 'مواد الفصل'),
          _buildTabItem(1, Icons.people, 'المستخدمين'),
          _buildTabItem(2, Icons.menu_book, 'المواد'),
          _buildTabItem(3, Icons.calendar_today, 'الفصول'),
        ],
      ),
    );
  }

  /// 🔘 بناء عنصر تبويب
  Widget _buildTabItem(int tabIndex, IconData icon, String label) {
    final isSelected = _currentTab == tabIndex;
    return Expanded(
      child: Material(
        color: isSelected ? ColorsApp.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _currentTab = tabIndex),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, 
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20.sp,
                ),
                getHeight(4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📱 بناء محتوى التبويب
  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0: return _buildSemesterCoursesTab();
      case 1: return const UsersManagementScreen();
      case 2: return const CoursesManagementScreen();
      case 3: return const SemestersManagementScreen();
      default: return _buildSemesterCoursesTab();
    }
  }

  /// 📚 تبويب مواد الفصل الدراسي
  Widget _buildSemesterCoursesTab() {
    return BlocBuilder<SemesterCoursesBloc, SemesterCoursesState>(
      builder: (context, state) => SemesterCoursesScreen(),
    );
  }

  /// 🔘 شريط التنقل السفلي
  Widget _buildBottomNavigationBar() {
    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      userRole: _getUserRole(context),
    );
  }

  /// 👤 الحصول على دور المستخدم
  String _getUserRole(BuildContext context) {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'User';
  }

  /// 🎯 التعامل مع النقر على شريط التنقل
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    navigateToScreen(index, getUserRole(context), context);
  }
}