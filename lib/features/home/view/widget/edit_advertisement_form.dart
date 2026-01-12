import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/home/view/widget/action_buttons.dart';
import 'package:myproject/features/home/view/widget/image_section.dart';
import 'package:user_repository/user_repository.dart';
// نموذج تعديل الإعلان 
class EditAdvertisementForm extends StatefulWidget {
  final AdvertisemenModel advertisement;
  final UserModels currentUser;

  const EditAdvertisementForm({super.key, required this.advertisement, required this.currentUser});

  @override
  State<EditAdvertisementForm> createState() => _EditAdvertisementFormState();
}

class _EditAdvertisementFormState extends State<EditAdvertisementForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _newImage;
  bool _isLoading = false;
  bool _showImagePreviewButton = true;
  bool _removeExistingImage = false;
  late String selectedcustom;
  final List<String> custom = [
    'الكل',
    'أعضاء هيئة التدريس',
    'الطلاب',
    'الموظفين',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.advertisement.description;
    _showImagePreviewButton = widget.advertisement.advlImg != null && 
                              widget.advertisement.advlImg!.isNotEmpty;
    selectedcustom = widget.advertisement.custom;
    _removeExistingImage = false;
  }
 // دالة عند اختيار صورة جديدة
  void _onImagePicked(File image) {
    setState(() {
      _newImage = image;
      _showImagePreviewButton = false;
      _removeExistingImage = false;
    });
  }
 // دالة عند إزالة الصورة
  void _onImageRemoved() {
    setState(() {
      _newImage = null;
      _removeExistingImage = true;
      _showImagePreviewButton = false;
      
    });
    print('🗑️ تم تفعيل إزالة الصورة الحالية: _removeExistingImage = $_removeExistingImage');
  }
 // دالة لتحديث حالة التحميل
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height *0.70,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
                  mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // حقل وصف الإعلان
                _buildDescriptionField(),
                // قسم اختيار الفئة
                _buildCustomSection(),
                getHeight(20),
                // قسم الصور
                ImageSection(
                  advertisement: widget.advertisement,
                  newImage: _newImage,
                  onImagePicked: _onImagePicked,
                  onImageRemoved: _onImageRemoved,
                  showPreviewButton: _showImagePreviewButton && !_removeExistingImage,
                ),
                getHeight(25),
                // عرض رسالة إذا تمت إزالة الصورة
                if (_removeExistingImage)
                  _buildImageRemovedMessage(),
                getHeight(20),
                // أزرار الإجراءات
                ActionButtons(
                  isLoading: _isLoading,
                  onCancel: () => Navigator.pop(context),
                  onSave: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
// بناء حقل وصف الإعلان
  Widget _buildDescriptionField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'وصف الإعلان',
        style: font15bold,
      ),
      getHeight(8),
      TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'أدخل وصف الإعلان... ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorsApp.primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    ],
  );
}
// بناء قسم اختيار الفئة المستهدفة
Widget _buildCustomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getHeight(15),
        DropdownButtonFormField<String>(
          initialValue: selectedcustom,
          items: custom.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedcustom = value!;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'اختر الفئة المستهدفة',
          ),
        ),
        getHeight(10),
          Text(
            '⚠️ سيظهر هذا الإعلان فقط للمستخدمين المستهدفين.',
            style: font12black,
          ),
      ],
    );
  }
   // بناء رسالة إزالة الصورة
  Widget _buildImageRemovedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.orange[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'سيتم إزالة الصورة الحالية عند حفظ التعديلات',
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

// دالة تقديم النموذج وتعديل الإعلان
  void _submitForm() async {
    final isConnected = await checkInternetconnection();
    if (!isConnected) {
      ShowWidget.showMessage(context, noNet, Colors.black, font11White); 
    }
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      try {
        // 🔥 الحالة 1: إذا طلب المستخدم إزالة الصورة الحالية
      if (_removeExistingImage) {
        print('🗑️ جاري إزالة الصورة الحالية باستخدام الحدث المخصص');
        context.read<AdvertisementBloc>().add(
          RemoveAdvertisementImageEvent(advertisementId: widget.advertisement.id)
        );
        
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context);
        
        ShowWidget.showMessage(
          context,
          'تم إزالة الصورة بنجاح',
          ColorsApp.green,
          font13White,
        );
        return;
      }

        // 🔥 الحالة 2: إذا تم اختيار صورة جديدة
        String? newImageUrl;
        
        // إذا تم اختيار صورة جديدة، رفعها إلى السيرفر
        if (_newImage != null) {
          final advertisementRepository = context.read<AdvertisementRepository>();
          newImageUrl = await advertisementRepository.uploadAdvertisementImageAsBase64(
          _newImage!, 
          widget.advertisement.id
        );
        print('✅ تم رفع صورة الإعلان كـ base64 بنجاح');
        }
        // 🔥 الحالة 3: التحديث العادي (بدون تغيير الصورة أو بإضافة صورة جديدة)
        final updatedAdvertisement = widget.advertisement.copyWith(
          description: _descriptionController.text,
          custom: selectedcustom, 
          advlImg: newImageUrl ?? widget.advertisement.advlImg, 
        );
        print('🔄 جاري تحديث الإعلان: ${updatedAdvertisement.id}');
        print('📝 الوصف: ${updatedAdvertisement.description}');
        print('🖼️ الصورة: ${updatedAdvertisement.advlImg ?? "NULL"}');
        print('⏰ الوقت: ${updatedAdvertisement.timeAdv}');
        print('🎯 الفئة: ${updatedAdvertisement.custom}');
      
        context.read<AdvertisementBloc>().add(
          UpdateAdvertisementEvent(advertisement: updatedAdvertisement)
        );

        // انتظار قليل قبل الإغلاق للتأكد من اكتمال العملية
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context);
        
        // رسالة نجاح
        ShowWidget.showMessage(
          context,
          'تم تعديل الإعلان بنجاح',
          ColorsApp.green,
          font13White,
        );
        
      } catch (e) {
        print('❌ خطأ في تعديل الإعلان: $e');
        ShowWidget.showMessage(
          context,
          'فشل في تعديل الإعلان',
          ColorsApp.red,
          font13White,
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}