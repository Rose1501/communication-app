// features/profile/view/controllers/user_profile_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileActions {
  final BuildContext context;
  final UserModels userModel;

  UserProfileActions(this.context, this.userModel);

  // إرسال كود إعادة التعيين
  void sendResetCode() {
    context.read<AuthBloc>().add(SendResetCodeRequested(userModel.email));
  }

  // التحقق من صحة رمز إعادة التعيين
  void verifyResetCode(String code) {
    context.read<AuthBloc>().add(VerifyResetCodeRequested(code));
  }

  // إعادة تعيين كلمة المرور باستخدام الرمز
  void resetPasswordWithCode({
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور وتأكيدها غير متطابقين')),
      );
      return;
    }

    context.read<AuthBloc>().add(ResetPasswordWithCodeRequested(
      code: code,
      newPassword: newPassword,
    ));
  }

  // تغيير كلمة المرور
  void changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور وتأكيدها غير متطابقين')),
      );
      return;
    }

    context.read<AuthBloc>().add(ChangePasswordRequested(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
  }

  // اختيار صورة الملف الشخصي
  Future<void> pickImage(ImageSource source) async {
    try {
      print('📷 بدء اختيار الصورة من: $source');
      
      // التحقق من الاتصال قبل الإرسال
      final isConnected = await checkInternetconnection();
      if (!isConnected) {
        ShowWidget.showMessage(context, noNet, Colors.black, font11White);
        return;
      } else {
        print('✅ متصل بالإنترنت، متابعة اختيار الصورة');
      }

      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final myUserBloc = context.read<MyUserBloc>();
        final user = myUserBloc.state.user;

        print('🔍 === VERIFYING USER DATA ===');
        print('🔍 User ID: ${user?.userID}');
        print('🔍 User Name: ${user?.name}');
        print('🔍 User Email: ${user?.email}');

        // تحقق إضافي من بيانات المستخدم
        if (user?.userID == null || user!.userID.isEmpty) {
          ShowWidget.showMessage(
            context,
            'خطأ في بيانات المستخدم ',
            ColorsApp.red,
            font13White,
          );
          return;
        }

        final updateInfoBloc = context.read<UpdateUserInfoBloc>(); 
        
        print('🎯 === STARTING IMAGE PICK ===');
        print('👤 userID المستخدم: $user');
        print('📁 مسار الصورة المختارة: ${pickedFile.path}');

        // 🔥 عرض رسالة تحميل
      ShowWidget.showMessage(
        context,
        'جاري تحديث الصورة...',
        ColorsApp.primaryColor,
        font13White,
      );

        updateInfoBloc.add(UploadPicture(pickedFile.path, user));
      }
      
      print('📷 انتهاء اختيار الصورة');
    } catch (e) {
      ShowWidget.showMessage(
        context,
        'فشل في اختيار الصورة',
        ColorsApp.red,
        font13White,
      );
    }
  }

  // دالة جديدة: إزالة الصورة الشخصية
  Future<void> removeProfilePicture() async {
    try {
      print('🗑️ بدء عملية إزالة الصورة الشخصية...');
      
      // التحقق من الاتصال قبل الإرسال
      final isConnected = await checkInternetconnection();
      if (!isConnected) {
        ShowWidget.showMessage(context, noNet, Colors.black, font11White);
        return;
      }

      // طلب تأكيد من المستخدم
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إزالة الصورة الشخصية'),
          content: const Text('هل أنت متأكد أنك تريد إزالة صورتك الشخصية؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('إزالة الصورة'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        print('✅ المستخدم وافق على إزالة الصورة');
        
        final updateInfoBloc = context.read<UpdateUserInfoBloc>(); 
        updateInfoBloc.add(RemoveProfilePicture(userModel.userID));
        
        ShowWidget.showMessage(
          context,
          'جاري إزالة الصورة...',
          ColorsApp.primaryColor,
          font13White,
        );
      } else {
        print('❌ المستخدم ألغى عملية الإزالة');
      }
      
    } catch (e) {
      print('❌ خطأ في إزالة الصورة: $e');
      ShowWidget.showMessage(
        context,
        'فشل في إزالة الصورة',
        ColorsApp.red,
        font13White,
      );
    }
  }

  // تسجيل الخروج
  Future<void> logoutUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<MyUserBloc>().add(LogoutUser());
    }
  }
}