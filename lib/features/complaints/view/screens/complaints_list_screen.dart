import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:myproject/features/complaints/view/screens/add_complaint_screen.dart';
import 'package:myproject/features/complaints/view/widgets/complaints_content.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:user_repository/user_repository.dart';

/// 🏠 الشاشة الرئيسية لعرض قائمة الشكاوى
/// 📱 تدعم أدوار مختلفة: طالب، دكتور، مدير، مسؤول
class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  /// 📥 تحميل الشكاوى بناءً على دور المستخدم
  void _loadComplaints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUserState = context.read<MyUserBloc>().state;
      if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
        final user = myUserState.user!;
        _loadComplaintsBasedOnRole(user);
      }
    });
  }

  /// 🎯 تحميل الشكاوى حسب دور المستخدم
  void _loadComplaintsBasedOnRole(UserModels user) {
    final complaintBloc = context.read<ComplaintBloc>();
    
    if (user.role == 'Admin') {
      complaintBloc.add(LoadRoleComplaintsEvent('Admin'));
      print('👑 Admin: جلب الشكاوى الموجهة للإدارة');
    } else if (user.role == 'Manager') {
      complaintBloc.add(LoadRoleComplaintsEvent('Manager'));
      print('👔 Manager: جلب الشكاوى الموجهة للمديرين');
    } else {
      complaintBloc.add(LoadStudentComplaintsEvent(user.userID));
      print('📚 جلب شكاوى المستخدم: ${user.name}');
    }
  }

  /// 🧭 التعامل مع التنقل بين الشاشات
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, getUserRole(context), context);
  }

  /// 🔍 الحصول على دور المستخدم الحالي
  String getUserRole(BuildContext context) {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'Student';
  }

  /// ➕ فتح شاشة إضافة شكوى جديدة
  void _showAddComplaintDialog(BuildContext context, UserModels user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddComplaintScreen(currentUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        return _buildUserStateContent(myUserState);
      },
    );
  }

  /// 🏗️ بناء المحتوى بناءً على حالة بيانات المستخدم
  Widget _buildUserStateContent(MyUserState myUserState) {
    // ⏳ حالة التحميل
    if (myUserState.status == MyUserStatus.loading) {
      return Scaffold(
        appBar: const CustomAppBarTitle(title: 'صندوق الشكاوى'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ حالة الفشل
    if (myUserState.status == MyUserStatus.failure) {
      return Scaffold(
        appBar: const CustomAppBarTitle(title: 'صندوق الشكاوى'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text('فشل في تحميل بيانات المستخدم'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<MyUserBloc>().add(GetMyUser()),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    // ⚠️ حالة غير معروفة
    if (myUserState.status != MyUserStatus.success || myUserState.user == null) {
      return Scaffold(
        appBar: const CustomAppBarTitle(title: 'صندوق الشكاوى'),
        body: const Center(child: Text('حالة غير معروفة')),
      );
    }

    final user = myUserState.user!;
    final canAddComplaint = user.role == 'Student' || user.role == 'Doctor';

    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'صندوق الشكاوى'),
      floatingActionButton: canAddComplaint 
          ? FloatingActionButton(
              onPressed: () => _showAddComplaintDialog(context, user),
              backgroundColor: ColorsApp.primaryColor,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      body: ComplaintsContent(
        onRefresh: _loadComplaints,
        user: user,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userRole: getUserRole(context),
      ),
    );
  }
}