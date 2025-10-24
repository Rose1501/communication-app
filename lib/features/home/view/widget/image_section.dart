import 'dart:convert';
import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/image_preview_dialog.dart';
import 'package:myproject/components/widget/image_picker_service.dart';
// قسم إدارة الصور في نموذج تعديل الإعلان
class ImageSection extends StatelessWidget {
  final AdvertisementModel advertisement;
  final File? newImage;
  final Function(File) onImagePicked;
  final Function() onImageRemoved;
  final bool showPreviewButton;

  const ImageSection({
    super.key,
    required this.advertisement,
    required this.newImage,
    required this.onImagePicked,
    required this.onImageRemoved,
    required this.showPreviewButton,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود صورة حالية في الإعلان
    final hasExistingImage = advertisement.advlImg != null && 
                            advertisement.advlImg!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasExistingImage && showPreviewButton) 
          _buildExistingImageSection(context)
        else if (!hasExistingImage || !showPreviewButton)
          _buildNoImageSection(context),
          _buildNewImagePreview(context),
      ],
    );
  }

  Widget _buildExistingImageSection(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.visibility,
          text: 'معاينة الصورة الحالية',
          color: ColorsApp.primaryColor,
          onPressed: () => _showImagePreview(context),
          isOutlined: true,
        ),
        getHeight(12),
        
        _buildActionButton(
          icon: Icons.edit,
          text: 'تغيير الصورة',
          color: Colors.orange,
          onPressed: () => _pickImage(context),
          isOutlined: false,
        ),
        getHeight(8),
        
        _buildActionButton(
          icon: Icons.delete,
          text: 'إزالة الصورة',
          color: Colors.red,
          onPressed: () {
            _showRemoveConfirmationDialog(context);
          },
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildNoImageSection(BuildContext context) {
    return _buildActionButton(
      icon: Icons.add_photo_alternate,
      text: 'إضافة صورة للإعلان',
      color: ColorsApp.primaryColor,
      onPressed: () => _pickImage(context),
      isOutlined: false,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isOutlined,
  }) {
    return Container(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              icon: Icon(icon, size: 20, color: color),
              label: Text(
                text,
                style: TextStyle(color: color, fontSize: 14),
              ),
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          : ElevatedButton.icon(
              icon: Icon(icon, size: 20),
              label: Text(text, style: TextStyle(color: color,fontSize: 15)),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                //backgroundColor: color,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: color),
              ),
            ),
    );
  }

  Widget _buildNewImagePreview(BuildContext context) {
    if (newImage == null) return const SizedBox();

    return Column(
      children: [
        getHeight(16),
        Text(
          'معاينة الصورة الجديدة:',
          style: font14grey,
        ),
        getHeight(8),
        GestureDetector(
          onTap: () {
            // معاينة الصورة الجديدة
            _previewNewImage(context);
          },
          child: Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    newImage!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      onImageRemoved();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _previewNewImage(BuildContext context) {
  // تحويل File إلى base64 للمعاينة
  newImage!.readAsBytes().then((bytes) {
    final base64Image = base64Encode(bytes);
    final imageUrl = 'data:image/jpeg;base64,$base64Image';
    
    AdvancedImagePreviewDialog.show(context, imageUrl);
  }).catchError((error) {
    print('❌ خطأ في معاينة الصورة الجديدة: $error');
  });
}

  void _showImagePreview(BuildContext context) {
    if (advertisement.advlImg != null && advertisement.advlImg!.isNotEmpty) {
      AdvancedImagePreviewDialog.show(context, advertisement.advlImg!);
    }
  }

  void _pickImage(BuildContext context) {
    ImagePickerService.pickImage(context, onImagePicked);
  }

  void _showRemoveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الإزالة'),
        content: Text('هل أنت متأكد من أنك تريد إزالة الصورة الحالية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onImageRemoved();
            },
            child: Text('تأكيد الإزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}