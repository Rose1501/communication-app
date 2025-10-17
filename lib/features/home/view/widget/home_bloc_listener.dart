// features/home/view/widget/home_bloc_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';

/// ملف مستقل للاستماع لتغيرات الـBloc في الشاشة الرئيسية
class HomeBlocListener extends StatelessWidget {
  final Widget child;

  const HomeBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // الاستماع لتحديث صورة المستخدم
        BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
          listener: (context, state) {
            if (state is UploadPictureSuccess) {
              // تحديث صورة المستخدم في حالة النجاح
              final currentUser = context.read<MyUserBloc>().state.user;
              if (currentUser != null) {
                context.read<MyUserBloc>().add(GetMyUser());
              }
              // تحديث الإعلانات عند تغيير صورة الملف الشخصي
              context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
            }
          },
        ),
      ],
      child: child,
    );
  }
}