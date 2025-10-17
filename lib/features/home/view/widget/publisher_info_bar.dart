import 'dart:convert';

import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:user_repository/user_repository.dart';
// شريط معلومات الناشر في بطاقة الإعلان
class PublisherInfoBar extends StatelessWidget {
  final UserModels userModel;
  final AdvertisementModel adv;
  final Function()? onEdit; // دالة التعديل
  final Function()? onDelete; // دالة الحذف
  final bool showDepartmentInfo;

  const PublisherInfoBar({
    super.key,
    required this.userModel,
    required this.adv,
    this.onEdit,
    this.onDelete, 
    required this.showDepartmentInfo,
  });

  @override
  Widget build(BuildContext context) {
    print('✅ بناء PublisherInfoBar لـ ${adv.user.name}');
    final user = adv.user;
    // ignore: unnecessary_null_comparison
    if (user == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        // الصف الأول: اسم المستخدم وصورته
        Row(
          children: [
            _buildUserAvatar(user),
            getWidth(10),
            Text(userModel.name, style: black12W600),
       //   const Spacer(),
            getWidth(8),
            _buildAdvertisementTypeIcon(adv.custom),
            getWidth(20),
            
            // الصف الثاني: أيقونة النشر والتاريخ
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                getWidth(2),
                Text(
                  _formatDate(adv.timeAdv),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                
              ],
            ),
          if(showDepartmentInfo)
            // أزرار التعديل والحذف 
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.red,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ), 
          ],
        ),
      ],
    );
  }
// 🔥 دالة بناء أيقونة نوع الإعلان
  Widget _buildAdvertisementTypeIcon(String? customType) {
    final type = customType ?? 'الكل';
    
    switch (type) {
      case 'الطلاب':
        return const Tooltip(
          message: 'إعلان مخصص للطلاب',
          child: Icon(Icons.school, size: 16, color: Colors.grey),
        );
      
      case 'أعضاء هيئة التدريس':
        return const Tooltip(
          message: 'إعلان مخصص لأعضاء هيئة التدريس',
          child: Icon(Icons.work, size: 16, color: Colors.grey),
        );
      
      case 'الموظفين':
        return const Tooltip(
          message: 'إعلان مخصص للموظفين',
          child: Icon(Icons.business_center, size: 16, color: Colors.grey),
        );
      
      case 'الكل':
      default:
        return const Tooltip(
          message: 'إعلان عام للجميع',
          child: Icon(Icons.public, size: 16, color: Colors.grey),
        );
    }
  }

Widget _buildUserAvatar(UserModels user) {
    return Container(
      width: 26, 
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ColorsApp.primaryColor, width: 1),
      ),
      child: _buildProfileImage(user),
    );
  }

  Widget _buildProfileImage(UserModels user) {
    // تحقق من وجود صورة Base64
    if (user.urlImg != null && user.urlImg!.isNotEmpty) {
      print('🖼️ تحميل صورة Base64 للمستخدم في PublisherInfoBar: ${user.name}');
      print('📊 طول بيانات الصورة: ${user.urlImg!.length}');
      return _buildBase64Image(user.urlImg!);
    }
    
    // استخدام الصورة الافتراضية
    return _buildDefaultImage(user);
  }

  Widget _buildBase64Image(String base64Data) {
    print('🔍 فحص بيانات Base64 في PublisherInfoBar:');
    print('📏 الطول: ${base64Data.length}');
    print('🔗 يبدأ بـ: ${base64Data.substring(0, min(50, base64Data.length))}');
    
    try {
      String cleanBase64 = _cleanBase64Data(base64Data);
      print('📊 طول البيانات بعد التنظيف: ${cleanBase64.length}');
      
      // التحقق من أن البيانات صالحة
      if (cleanBase64.length > 100) {
        return ClipOval(
          child: Image.memory(
            base64Decode(cleanBase64),
            width: 24, // أصغر قليلاً من الحاوية
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ خطأ في تحميل صورة Base64 في PublisherInfoBar: $error');
              return _buildDefaultImage(UserModels.empty);
            },
          ),
        );
      } else {
        print('⚠️ بيانات الصورة قصيرة جداً في PublisherInfoBar: ${cleanBase64.length} حرف');
        return _buildDefaultImage(UserModels.empty);
      }
    } catch (e) {
      print('❌ خطأ في معالجة صورة Base64 في PublisherInfoBar: $e');
      return _buildDefaultImage(UserModels.empty);
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
      radius: 13,
      backgroundColor: ColorsApp.white,
      backgroundImage: user.gender == "Male" ||userModel.gender == "male"
          ? const AssetImage(HomeData.man)
          : const AssetImage(HomeData.woman),
    );
  }

  int min(int a, int b) => a < b ? a : b;
  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
  if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
  if (difference.inDays == 1) return 'أمس';
  if (difference.inDays < 7) return 'منذ ${difference.inDays} ي';
  
  return '${date.day}/${date.month}/${date.year}';
}
}
