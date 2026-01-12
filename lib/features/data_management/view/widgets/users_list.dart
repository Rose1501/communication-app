// features/user_management/view/widgets/users_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/data_management/view/widgets/user_card.dart';
import 'package:user_repository/user_repository.dart';

class UsersList extends StatelessWidget {
  final List<UserModels> users;

  const UsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    print('👥 بناء قائمة المستخدمين: ${users.length} مستخدم');
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 8.h),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        print('👤 عرض المستخدم $index: ${user.name} (${user.userID})');
        
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: UserCard(user: user),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مستخدمين',
              style: font18blackbold.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'انقر على زر الاستيراد لإضافة مستخدمين',
              style: font14grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}