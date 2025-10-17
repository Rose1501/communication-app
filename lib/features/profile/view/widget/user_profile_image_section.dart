import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileImageSection extends StatelessWidget {
  final UserModels userModel;
  final String? selectedImagePath;
  final bool isChangingImage;
  final VoidCallback onChangeImage;

  const UserProfileImageSection({
    super.key,
    required this.userModel,
    required this.selectedImagePath,
    required this.isChangingImage,
    required this.onChangeImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorsApp.primaryColor, width: 2),
          ),
          child: _buildProfileImage(context, myUserState),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onChangeImage,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration:  BoxDecoration(
                color: ColorsApp.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: ColorsApp.white,
                size: 18.w,
              ),
            ),
          ),
        ),
      ],
      );
      },
    );
  }

  Widget _buildProfileImage(BuildContext context, MyUserState myUserState) {
    if (isChangingImage) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentUser = myUserState.user ?? userModel;
    // تحقق أولاً إذا كانت هناك صورة محلية مختارة
    if (selectedImagePath != null) {
      return CircleAvatar(
        radius: 58.w,
        backgroundColor: ColorsApp.white,
        backgroundImage: FileImage(File(selectedImagePath!)),
      );
    }
    // ثم تحقق من وجود صورة Base64
    if (currentUser.urlImg != null && currentUser.urlImg!.isNotEmpty && currentUser.urlImg!.length > 100 &&!currentUser.urlImg!.contains('null')) {
      print('🖼️ تحميل صورة Base64 من Firestore للـ User: ${currentUser.name}');
      print('📊 طول بيانات الصورة من Firestore: ${currentUser.urlImg!.length}');
      return _buildBase64Image(currentUser.urlImg!);

    }
    // 🔥 إذا لم توجد صورة، استخدم الصورة الافتراضية
  print('🔄 استخدام الصورة الافتراضية للمستخدم: ${currentUser.name}');
  print('🔍 سبب استخدام الافتراضية - urlImg: ${currentUser.urlImg}');
    // أخيراً استخدم الصورة الافتراضية
    return _buildDefaultImage(currentUser);
  }

Widget _buildBase64Image(String base64Data) {
  print('🔍 فحص بيانات Base64:');
print('📏 الطول: ${base64Data.length}');
print('🔗 يبدأ بـ: ${base64Data.substring(0, min(50, base64Data.length))}');
print('📱 يحتوي على comma: ${base64Data.contains(',')}');
print('🌐 يحتوي على http: ${base64Data.contains('http')}');
print('🔥 يحتوي على firebase: ${base64Data.contains('firebase')}');
      try {
        print('🖼️ تحميل صورة Base64 من Firestore');
      String cleanBase64 = _cleanBase64Data(base64Data);
      print('📊 طول البيانات بعد التنظيف: ${cleanBase64.length}');
      // التحقق من أن البيانات صالحة
      if (cleanBase64.length > 100) {
        return CircleAvatar(
          radius: 58.w,
          backgroundColor: ColorsApp.white,
          child: ClipOval(
            child: Image.memory(
              base64Decode(cleanBase64),
              width: 116.w,
              height: 116.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ خطأ في تحميل صورة Base64: $error');
                return _buildDefaultImage(userModel);
              },
            ),
          ),
        );
      } else {
        print('⚠️ بيانات الصورة غير صالحة، استخدام الصورة الافتراضية');
        return _buildDefaultImage(userModel);
      }
    } catch (e) {
      print('❌ خطأ في معالجة صورة Base64: $e');
      print('📊 بيانات Base64 الأولى: ${base64Data.substring(0, min(100, base64Data.length))}...');
      return _buildDefaultImage(userModel);
    }
  } 
String _cleanBase64Data(String base64Data) {
    // إذا كانت البيانات تحتوي على prefix مثل data:image/jpeg;base64,
    if (base64Data.contains(',')) {
      return base64Data.split(',').last;
    }
    return base64Data;
  }
Widget _buildDefaultImage(UserModels user) {
    return CircleAvatar(
      radius: 58.w,
      backgroundColor: ColorsApp.white,
      backgroundImage: user.gender == "Male" ||userModel.gender == "male"
          ? const AssetImage(HomeData.man)
          : const AssetImage(HomeData.woman),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}

