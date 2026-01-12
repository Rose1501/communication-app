import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/edit_user_dialog.dart';
import 'package:user_repository/user_repository.dart';

class UserCard extends StatelessWidget {
  final UserModels user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    print('🃏 بناء بطاقة المستخدم: ${user.name} (${user.userID})');
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: dataManagementCardDecoration,
      child: Row(
        children: [
          // 🖼️ صورة المستخدم
          _buildUserAvatar(),
          SizedBox(width: 16.w),
          
          // 📋 معلومات المستخدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'مستخدم بدون اسم',
                  style: font16blackbold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email.isNotEmpty ? user.email : 'لا يوجد بريد إلكتروني',
                  style: font14grey,
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 4.h,
                  children: [
                    _buildInfoItem(Icons.badge, user.userID),
                    _buildInfoItem(_getRoleIcon(user.role), _getRoleDisplayName(user.role)),
                    _buildInfoItem(_getGenderIcon(user.gender), _getGenderDisplayName(user.gender)),
                  ],
                ),
              ],
            ),
          ),
          
          // ⚙️ زر الإجراءات
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              const PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: primaryCircle,
      child: user.urlImg?.isNotEmpty == true
          ? CircleAvatar(
              backgroundImage: MemoryImage(_decodeBase64(user.urlImg!)),
            )
          : Icon(
              _getRoleIcon(user.role),
              color: Colors.white,
              size: 24.sp,
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              text,
              style: font12Grey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Icons.admin_panel_settings;
      case 'doctor': return Icons.school;
      case 'manager': return Icons.manage_accounts;
      case 'student': return Icons.person;
      default: return Icons.person;
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'ذكر': return Icons.woman;
      case 'أنثى': return Icons.man;
      default: return Icons.man;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return 'دراسة و الامتحانات';
      case 'Admin': return 'دراسة و الامتحانات';
      case 'doctor': return 'دكتور';
      case 'Doctor': return 'دكتور';
      case 'manager': return 'مدير';
      case 'Manager': return 'مدير';
      case 'student': return 'طالب';
      case 'Student': return 'طالب';
      default: return role; // إذا كان الدور غير معروف، عرضه كما هو
    }
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      final String data = base64String.contains(',') 
          ? base64String.split(',').last 
          : base64String;
      return base64Decode(data);
    } catch (e) {
      throw Exception('فشل في فك تشفير صورة base64: $e');
    }
  }
  // 🔥 دالة جديدة لتحويل الجنس من الإنجليزية إلى العربية للعرض
  String _getGenderDisplayName(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return 'ذكر';
      case 'Male': return 'ذكر';
      case 'female': return 'أنثى';
      case 'Female': return 'أنثى';
      case 'ذكر': return 'ذكر'; // إذا كان مخزناً بالعربية بالفعل
      case 'أنثى': return 'أنثى'; // إذا كان مخزناً بالعربية بالفعل
      default: return gender;
    }
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showEditUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل أنت متأكد من حذف المستخدم ${user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserManagementBloc>().add(DeleteUser(user.userID));
              Navigator.pop(context);
            },
            child: Text('حذف', style: font14Error),
          ),
        ],
      ),
    );
  }
}