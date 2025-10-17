import 'dart:convert';
import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/outline_border_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';
// شريط إنشاء منشور جديد في الصفحة الرئيسية
class NewPostBar extends StatelessWidget {
  final VoidCallback onTap;
  final UserModels userModel;
  final VoidCallback onProfileTap;
  const NewPostBar({super.key, required this.onTap, required this.userModel, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              color: ColorsApp.white,
              child: Row(
                children: [
                  getWidth(5),
                  GestureDetector(
                    onTap: onProfileTap, // استدعاء الدالة عند النقر
                    child: _buildUserAvatar(),
                  ),
                  getWidth(5),
                  if(userModel.role == 'Admin' || userModel.role== 'Manager' ) ...[
                  Expanded(
                    child: FractionallySizedBox(
                      child: GestureDetector(
                        onTap: onTap,
                        child: AbsorbPointer(
                          child: TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: '  بم تفكر؟  ',
                              hintStyle: const TextStyle(fontSize: 18),
                              border: bordercircularGrey,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 30,
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  getWidth(5),
                  IconButton(
                    icon: Icon(
                      Icons.image,
                      color: ColorsApp.primaryColor,
                    ),
                    onPressed: () => _pickImageAndPublishDirectly(context),
                  ),
                  ],
                ],
              ),
            ),
          );
  }
  // 🔥اختيار الصورة ونشرها مباشرة بدون وصف
  Future<void> _pickImageAndPublishDirectly(BuildContext context) async {
    try {
      print('📸 بدء اختيار الصورة ونشرها مباشرة...');
      
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        print('✅ تم اختيار الصورة: ${pickedFile.path}');
        
        // 🔥 عرض مؤشر تحميل
        ShowWidget.showMessage(
          context,
          'جاري نشر الصورة...',
          ColorsApp.primaryColor,
          font13White,
        );

        // 🔥 نشر الصورة مباشرة
        await _publishImageDirectly(context, File(pickedFile.path));
        
      } else {
        print('ℹ️ لم يتم اختيار أي صورة');
      }
    } catch (e) {
      print('❌ خطأ في اختيار الصورة: $e');
      ShowWidget.showMessage(
        context,
        'فشل في اختيار الصورة',
        ColorsApp.red,
        font13White,
      );
    }
  }

  // 🔥نشر الصورة مباشرة بدون وصف
  Future<void> _publishImageDirectly(BuildContext context, File imageFile) async {
    try {
      print('🚀 بدء نشر الصورة مباشرة...');
      
      final advertisementBloc = context.read<AdvertisementBloc>();
      final advertisementRepository = advertisementBloc.advertisementRepository;

      // إنشاء كود فريد للإعلان
      final advertisementId = _generateAdvertisementId();
      
      // 🔥 تشفير الصورة إلى base64
      print('🔤 جاري تشفير الصورة إلى base64...');
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      print('✅ تم تشفير الصورة، الطول: ${base64Image.length}');

      // إنشاء الإعلان بدون وصف
      final advertisement = AdvertisementModel(
        id: advertisementId,
        description: '', // 🔥 وصف فارغ
        timeAdv: DateTime.now(),
        fileUrl: null,
        advlImg: base64Image, // 🔥 الصورة مشفرة
        custom: 'الكل', // 🔥 افتراضي
        user: userModel,
      );

      print('🆕 بيانات الإعلان النهائية:');
      print('   - ID: ${advertisement.id}');
      print('   - الوصف: "بدون وصف"');
      print('   - الصورة: موجودة (${base64Image.length} حرف)');
      print('   - الفئة: الكل');

      // 🔥 إضافة الإعلان إلى قاعدة البيانات
      await advertisementRepository.addAdvertisement(advertisement);
      
      print('🎉 تم نشر الصورة بنجاح ${advertisement.id}');

      // 🔥 تحديث قائمة الإعلانات
      advertisementBloc.add(LoadAdvertisementsEvent());

      // 🔥 رسالة نجاح
      ShowWidget.showMessage(
        context,
        'تم نشر الصورة بنجاح',
        ColorsApp.green,
        font13White,
      );

      print('✅ تم تحديث الإعلانات والعودة للشاشة الرئيسية');

    } catch (e) {
      print('❌ فشل في نشر الصورة: $e');
      ShowWidget.showMessage(
        context,
        'فشل في نشر الصورة: ${e.toString()}',
        ColorsApp.red,
        font13White,
      );
    }
  }

  // 🔥إنشاء معرف فريد للإعلان
  String _generateAdvertisementId() {
  return Uuid().v1(); // أو Uuid().v4()
}
// بناء الصورة الشخصية للمستخدم مع تأثيرات
  Widget _buildUserAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 45,
          height: 50,
          decoration: BoxDecoration(
            color: ColorsApp.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorsApp.white, width: 2),
          ),
          child: _buildProfileImage(),
        ),
      ],
    );
  }
// بناء الصورة الشخصية بناءً على بيانات المستخدم
  Widget _buildProfileImage() {
    if (userModel.urlImg != null && userModel.urlImg!.isNotEmpty) {
      return _buildBase64Image(userModel.urlImg!);
    }
    return _buildDefaultImage();
  }
// بناء صورة من بيانات base64
  Widget _buildBase64Image(String base64Data) {
    try {
      String cleanBase64 = _cleanBase64Data(base64Data);
      
      if (cleanBase64.length > 100) {
        return ClipOval(
          child: Image.memory(
            base64Decode(cleanBase64),
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultImage();
            },
          ),
        );
      } else {
        return _buildDefaultImage();
      }
    } catch (e) {
      return _buildDefaultImage();
    }
  }

  String _cleanBase64Data(String base64Data) {
    if (base64Data.contains(',')) {
      return base64Data.split(',').last;
    }
    return base64Data;
  }

  Widget _buildDefaultImage() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: ColorsApp.white,
      backgroundImage: userModel.gender == "Male" ||userModel.gender == "male"
          ? const AssetImage(HomeData.man)
          : const AssetImage(HomeData.woman),
    );
  }
}