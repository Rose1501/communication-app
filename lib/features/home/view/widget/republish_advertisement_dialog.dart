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

class RepublishAdvertisementDialog extends StatefulWidget {
  final AdvertisementModel advertisement;
  final UserModels currentUser;

  const RepublishAdvertisementDialog({
    super.key,
    required this.advertisement,
    required this.currentUser,
  });

  @override
  State<RepublishAdvertisementDialog> createState() => _RepublishAdvertisementDialogState();
}

class _RepublishAdvertisementDialogState extends State<RepublishAdvertisementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _newImage;
  bool _isLoading = false;
  bool _showImagePreviewButton = true;
  bool _removeExistingImage = false;
  late String selectedCustom;
  
  final List<String> customOptions = [
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
    selectedCustom = widget.advertisement.custom;
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
        height: MediaQuery.of(context).size.height * 0.70,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    'إعادة نشر الإعلان',
                    style: font18bold,
                  ),
                  getHeight(15),
                  // حقل وصف الإعلان
                  _buildDescriptionField(),
                  // قسم اختيار الفئة المستهدفة
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
                  getHeight(20),
                  // عرض رسالة إذا تمت إزالة الصورة
                  if (_removeExistingImage)
                    _buildImageRemovedMessage(),
                  getHeight(20),
                  // أزرار الإجراءات
                  ActionButtons(
                    isLoading: _isLoading,
                    onCancel: () => Navigator.pop(context),
                    onSave: _submitForm,
                    saveText: 'إعادة النشر',
                  ),
                ],
              ),
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
            hintText: 'يمكنك تعديل وصف الإعلان...',
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
          value: selectedCustom,
          items: customOptions.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCustom = value!;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'الفئة المستهدفة',
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
          getWidth(8),
          Expanded(
            child: Text(
              'سيتم إعادة نشر الإعلان بدون الصورة الحالية',
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  // دالة تقديم النموذج وإعادة النشر
  void _submitForm() async {
    final isConnected = await checkInternetconnection();
    if (!isConnected) {
      ShowWidget.showMessage(context, noNet, Colors.black, font11White); 
      return;
    }
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      
      try {
        // استخدام الدالة المخصصة الجديدة
      context.read<AdvertisementBloc>().add(
        RepublishAdvertisementEvent(
          originalAdvertisement: widget.advertisement,
          newDescription: _descriptionController.text,
          newCustom: selectedCustom,
          currentUser: widget.currentUser,
          newImage: _newImage,
          removeImage: _removeExistingImage,
        ),
      );

      // الانتظار قليلاً ثم الإغلاق
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);

      ShowWidget.showMessage(
        context,
        'تم إعادة نشر الإعلان بنجاح',
        ColorsApp.green,
        font13White,
      );

      } catch (e) {
        print('❌ فشل في إعادة نشر الإعلان: $e');
        ShowWidget.showMessage(
          context,
          'فشل في إعادة نشر الإعلان: $e',
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