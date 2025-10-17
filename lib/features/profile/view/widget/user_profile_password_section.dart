import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/text_filed.dart';

class UserProfilePasswordSection extends StatelessWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController resetCodeController;
  final VoidCallback onSendResetCode;
  final VoidCallback onVerifyResetCode;
  final VoidCallback onChangePassword;
  final VoidCallback onResetPasswordWithCode;
  final VoidCallback onCancel;
  final bool isResetMode;
  final VoidCallback onSwitchToNormalMode;
  final VoidCallback onSwitchToResetMode;

  const UserProfilePasswordSection({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.resetCodeController,
    required this.onSendResetCode,
    required this.onVerifyResetCode,
    required this.onChangePassword,
    required this.onResetPasswordWithCode,
    required this.onCancel,
    required this.isResetMode,
    required this.onSwitchToNormalMode,
    required this.onSwitchToResetMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Center(
            child: Text(
              'تغيير كلمة المرور',
              style: fount14Bold.copyWith(color: ColorsApp.primaryColor),
            ),
          ),
          SizedBox(height: 16.h),

          // أزرار التبديل بين الوضعين
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSwitchToNormalMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isResetMode 
                        ? Colors.grey[300] 
                        : ColorsApp.primaryColor,
                    foregroundColor: isResetMode ? Colors.grey : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'بكلمة المرور الحالية',
                    style: isResetMode ? font14black : font15White,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSwitchToResetMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isResetMode 
                        ? ColorsApp.primaryColor 
                        : Colors.grey[300],
                    foregroundColor: isResetMode ? Colors.white : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'بالبريد الإلكتروني',
                    style: isResetMode ? font15White : font14black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // عرض الحقول بناءً على الوضع المختار
          if (isResetMode)
            _buildResetPasswordSection()
          else
            _buildNormalPasswordSection(),

          SizedBox(height: 20.h),
          
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text('إلغاء', style: font14black),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isResetMode 
                      ? onResetPasswordWithCode 
                      : onChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    isResetMode ? 'إعادة التعيين' : 'تغيير كلمة المرور',
                    style: font15White,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordSection() {
    return Column(
      children: [
        Text(
          'إعادة التعيين بالبريد الإلكتروني',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        
        // زر إرسال كود التحقق
        ElevatedButton(
          onPressed: onSendResetCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send, size: 18.w),
              SizedBox(width: 8.w),
              Text('إرسال رمز التحقق إلى بريدي', style: font15White),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        
        // حقل كود التحقق
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextFiled(
                hintText: 'أدخل رمز التحقق',
                controller: resetCodeController,
                iconData: Icons.confirmation_num,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onVerifyResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.green,
                  foregroundColor: ColorsApp.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text('تحقق', style: font13White),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // كلمة المرور الجديدة
        CustomTextFiled(
          hintText: 'كلمة المرور الجديدة',
          isPassword: true,
          controller: newPasswordController,
          iconData: Icons.lock_outline,
        ),
        SizedBox(height: 12.h),
        
        // تأكيد كلمة المرور
        CustomTextFiled(
          hintText: 'تأكيد كلمة المرور الجديدة',
          isPassword: true,
          controller: confirmPasswordController,
          iconData: Icons.lock_reset,
        ),
      ],
    );
  }

  Widget _buildNormalPasswordSection() {
    return Column(
      children: [
        Text(
          'التغيير بكلمة المرور الحالية',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        
        // كلمة المرور الحالية
        CustomTextFiled(
          hintText: 'كلمة المرور الحالية',
          isPassword: true,
          controller: currentPasswordController,
          iconData: Icons.lock,
        ),
        SizedBox(height: 12.h),
        
        // كلمة المرور الجديدة
        CustomTextFiled(
          hintText: 'كلمة المرور الجديدة',
          isPassword: true,
          controller: newPasswordController,
          iconData: Icons.lock_outline,
        ),
        SizedBox(height: 12.h),
        
        // تأكيد كلمة المرور
        CustomTextFiled(
          hintText: 'تأكيد كلمة المرور الجديدة',
          isPassword: true,
          controller: confirmPasswordController,
          iconData: Icons.lock_reset,
        ),
      ],
    );
  }
}