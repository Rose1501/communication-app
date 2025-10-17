// features/profile/view/listeners/user_profile_listeners.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';

class UserProfileListeners extends StatelessWidget {
  final Widget child;
  final VoidCallback onToggleEditPasswordMode;
  final VoidCallback onLogoutSuccess;

  const UserProfileListeners({
    super.key,
    required this.child,
    required this.onToggleEditPasswordMode,
    required this.onLogoutSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // مستمع AuthBloc
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            print('🎧 === AuthBloc Listener CALLED ===');
            print('🎧 State: $state');
            
            if (state.status == AuthStatus.resetCodeSent) {
              ShowWidget.showMessage(
                context,
                'تم إرسال كود التحقق إلى بريدك الإلكتروني',
                ColorsApp.green,
                font13White,
              );
            } else if (state.status == AuthStatus.resetCodeVerified) {
              ShowWidget.showMessage(
                context,
                'تم التحقق من الكود بنجاح',
                ColorsApp.green,
                font13White,
              );
            } else if (state.status == AuthStatus.resetPasswordSuccess) {
              ShowWidget.showMessage(
                context,
                'تم تغيير كلمة المرور بنجاح',
                ColorsApp.green,
                font13White,
              );
              onToggleEditPasswordMode();
            } else if (state.status == AuthStatus.success) {
              ShowWidget.showMessage(
                context,
                'تم تغيير كلمة المرور بنجاح',
                ColorsApp.green,
                font13White,
              );
              onToggleEditPasswordMode();
            } else if (state.status == AuthStatus.failure) {
              ShowWidget.showMessage(
                context,
                state.errorMessage ?? 'حدث خطأ',
                ColorsApp.red,
                font13White,
              );
            }
          },
        ),

        // مستمع MyUserBloc
        BlocListener<MyUserBloc, MyUserState>(
          listener: (context, state) {
            if (state.status == MyUserStatus.logout) {
              ShowWidget.showMessage(
                context,
                'تم تسجيل الخروج بنجاح',
                ColorsApp.green,
                font13White,
              );
              onLogoutSuccess();
            } else if (state.status == MyUserStatus.failure) {
              ShowWidget.showMessage(
                context,
                'فشل في تسجيل الخروج',
                ColorsApp.red,
                font13White,
              );
            } else if (state.status == MyUserStatus.success) {
              if (state.user?.urlImg != null) {
                print('🔍 Image Data Length: ${state.user!.urlImg!.length}');
              }
            }
          },
        ),

        // مستمع UpdateUserInfoBloc
        BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
          listener: (context, state) {
            print('🔔 UpdateUserInfoBloc state changed: $state');
            print('🎧 === UpdateUserInfoBloc Listener CALLED ===');
            print('🎯 DEBUG LISTENER - State: ${state.runtimeType}');
            if (state is UploadPictureSuccess) {
              // إعادة تحميل بيانات المستخدم بعد تحديث الصورة
              print('🔄 إعادة تحميل بيانات المستخدم بعد تحديث الصورة');
              
              context.read<MyUserBloc>().add(GetMyUser());
              // تحديث الإعلانات عند تغيير صورة الملف الشخصي
              context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
              
              print('✅ تم رفع الصورة بنجاح');
              print('🖼️ طول base64 الذي تم إرجاعه: ${state.userImage.length}');
              
              ShowWidget.showMessage(
                context,
                'تم تحديث الصورة بنجاح',
                ColorsApp.green,
                font13White,
              );
            } else if (state is UploadPictureLoading) {
              print('🔄 جاري رفع الصورة...');
              ShowWidget.showMessage(
                context,
                'جاري تحديث الصورة',
                ColorsApp.orange,
                font13White,
              );
            } else if (state is RemovePictureSuccess) {
              print('🎉 تم إزالة الصورة بنجاح');
              
              // تحديث بيانات المستخدم
              context.read<MyUserBloc>().add(GetMyUser());
              // 🔥 تأخير بسيط قبل تحديث الإعلانات
              Future.delayed(const Duration(milliseconds: 300),(){
                // 🔥 تحديث قائمة الإعلانات
              context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
              print('🔄 تم تحديث الإعلانات بعد إزالة الصورة');
              });
              
              // 🔥 إظهار رسالة نجاح
              ShowWidget.showMessage(
                context,
                'تم إزالة الصورة الشخصية بنجاح',
                ColorsApp.green,
                font13White,
              );
              print('🔄 تم طلب إعادة تحميل جميع البيانات');
            } else if (state is RemovePictureFailure) {
              print('❌ فشل في إزالة الصورة: ${state.error}');
              ShowWidget.showMessage(
                context,
                'فشل في إزالة الصورة: ${state.error}',
                ColorsApp.red,
                font13White,
              );
            }else if (state is UploadPictureFailure) {
              ShowWidget.showMessage(
                context,
                'فشل في تحديث الصورة',
                ColorsApp.red,
                font13White,
              );
            }
            
          },
        ),
      ],
      child: child,
    );
  }
}