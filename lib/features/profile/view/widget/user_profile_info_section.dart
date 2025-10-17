import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileInfoSection extends StatelessWidget {
  final UserModels userModel;

  const UserProfileInfoSection({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoField('الاسم', userModel.name, Icons.person),
        SizedBox(height: 16.h),
        _buildInfoField('البريد الإلكتروني', userModel.email, Icons.email),
        SizedBox(height: 16.h),
        _buildInfoField('الرقم الوطني', userModel.na_Number, Icons.badge),
        SizedBox(height: 16.h),
        _buildInfoField('رقم القيد', userModel.userID, Icons.description),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ColorsApp.primaryColor, size: 20.w),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: black12W600),
              SizedBox(height: 4.h),
              Text(value, style: font14black),
            ],
          ),
        ),
      ],
    );
  }
}