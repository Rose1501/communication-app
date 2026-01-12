import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/features/home/view/widget/bulid_advertisemnt_image.dart';
import 'package:myproject/features/home/view/widget/publisher_info_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:user_repository/user_repository.dart';
// كلاس يمثل بطاقة إعلان في الصفحة الرئيسية
class CardHome extends StatelessWidget {
  final UserModels userModel;
  final AdvertisemenModel adv;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRepublish;
  final bool showDepartmentInfo;
  
  const CardHome({
    super.key, 
    required this.userModel, 
    required this.adv, 
    this.onEdit, 
    this.onDelete,
    this.onRepublish,
    this.showDepartmentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط معلومات الناشر (الاسم، الصورة، أزرار التعديل والحذف)
            PublisherInfoBar(
              userModel: userModel, 
              adv: adv, 
              onEdit: onEdit, 
              onDelete: onDelete,
              onRepublish: onRepublish,
              showDepartmentInfo: showDepartmentInfo,
            ),
            getHeight(15),
            ReadMoreText(
              adv.description,
              trimLines: 3,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' عرض المزيد',
              trimExpandedText: ' عرض أقل',
              moreStyle: TextStyle(
                  color: ColorsApp.greylight,
                  fontWeight: FontWeight.bold,
                ),
              lessStyle: TextStyle(
                  color: ColorsApp.greylight,
                  fontWeight: FontWeight.bold,
                ),
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              textAlign: TextAlign.right,
            ),
            getHeight(16),
            if (adv.advlImg != null && adv.advlImg!.isNotEmpty) 
              buildAdvertisementImage(context,adv),
          ],
        ),
      ),
    );
  }
  
  
}