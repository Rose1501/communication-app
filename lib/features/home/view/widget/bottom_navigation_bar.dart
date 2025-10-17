import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد عناصر القائمة بناءً على دور المستخدم
    final List<BottomNavigationBarItem> items = _getNavigationItems(userRole);

    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      selectedItemColor: ColorsApp.primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
    );
  }

  // دالة لإرجاع عناصر التنقل بناءً على دور المستخدم
  List<BottomNavigationBarItem> _getNavigationItems(String role) {
    if (role == 'Admin') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'المستخدمين',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.mark_email_unread_outlined),
          label: 'الطلبات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'شكاوي ',
        ),
      ];
    } else if (role == 'Manager') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'المقررات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'شكاوي',
        ),
      ];
    }  else if (role == 'Doctor') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'المقررات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'شكاوي',
        ),
      ];
    } else if (role == 'Student'){
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'المقررات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.mark_email_unread_outlined),
          label: 'الطلبات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'شكاوي',
        ),
      ];
    }else {
      // للمستخدمين العاديين
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'مقرراتي',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الملف الشخصي',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
      ];
    }
  }
}

// دالة للتنقل إلى الشاشات المختلفة
void navigateToScreen(int index, String userRole, BuildContext context) {
  // يمكنك استبدال هذه الدالة بالتنقل الفعلي إلى الشاشات
  print('التنقل إلى الشاشة: $index للمستخدم: $userRole');
  // مثال للتنقل بناءً على الدور والمؤشر
  if (userRole == 'Admin') {
    switch (index) {
      case 0:
        context.pushAndRemoveUntil(Routes.home);
        break;
      case 1:
        // صفحة إدارة المستخدمين
        
      case 2:
        // صفحة الطلبات
        break;
      case 3:
        // الطلبات
        context.pushAndRemoveUntil(Routes.replyRequest);
      case 4:
        //الشكاوي
        break;
    }
  } else if (userRole == 'Manager') {
    switch (index) {
      case 0:
        context.pushAndRemoveUntil(Routes.home);
        break;
      case 1:
        // صفحة المقررات
        break;
      case 2:
        // صفحة الإشعارات
        break;
      case 3:
        //الشكاوي
      case 4:
        break;
    }
  }else if (userRole == 'Doctor') {
    switch (index) {
      case 0:
        context.pushAndRemoveUntil(Routes.home);
        break;
      case 1:
        // صفحة المقررات
        
        break;
      case 2:
        // صفحة الإشعارات
        break;
      case 3:
        //الشكاوي
      case 4:
        
        break;
    }
  }else if (userRole == 'Student') {
    switch (index) {
      case 0:
        context.pushAndRemoveUntil(Routes.home);
        break;
      case 1:
        // صفحة المقررات
        
        break;
      case 2:
        // صفحة الإشعارات
        break;
      case 3:
        // الطلبات
        context.pushAndRemoveUntil(Routes.displayRequest);
      case 4:
        //الشكاوي
        break;
    }
  } else {
    switch (index) {
      case 0:
        context.pushAndRemoveUntil(Routes.home);
        break;
      case 1:
        // صفحة مقرراتي
        // Navigator.push(context, MaterialPageRoute(builder: (context) => MyCoursesScreen()));
        break;
      case 2:
        // صفحة الملف الشخصي
        break;
      case 3:
        
    }
  }
}

String getUserRole(BuildContext context) {
  // الحصول على دور المستخدم من الـBloc إذا كان متوفرًا
  final myUserState = context.read<MyUserBloc>().state;
  if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
    return myUserState.user!.role;
  }
  return 'User';
}
