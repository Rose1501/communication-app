
  import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';

Widget buildMediaOptions(BuildContext context, AdvertisementFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إضافة وسائط:', style: font16black),
        getHeight(10),
        Row(
          children: [
            // زر الكاميرا
            _buildMediaButton(
              icon: Icons.camera_alt,
              label: 'كاميرا',
              onPressed: () => _pickImage(ImageSource.camera, context),
            ),
            getWidth(10),
            // زر المعرض
            _buildMediaButton(
              icon: Icons.photo_library,
              label: 'معرض',
              onPressed: () => _pickImage(ImageSource.gallery, context),
            ),
            getWidth(10),
            // زر الملف
            _buildMediaButton(
              icon: Icons.attach_file,
              label: 'ملف',
              onPressed: () => _pickFile(context),
            ),
          ],
        ),
      ],
    );
  }

    Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label, style: font12black),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryLight,
          foregroundColor: ColorsApp.primaryColor,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        context.read<AdvertisementFormBloc>().add(
          AdvertisementFormImagePicked(File(pickedFile.path))
        );
      }
      ShowWidget.showMessage(
        context,
        'تم اختيار الصورة',
        ColorsApp.green,
        font13White,
      );
    } catch (e) {
      ShowWidget.showMessage(
        context,
        'فشل في اختيار الصورة',
        ColorsApp.red,
        font13White,
      );
    }
  }

  Future<void> _pickFile(BuildContext context) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      allowCompression: true,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile platformFile = result.files.first;
      
      
      if (platformFile.path != null) {
        File file = File(platformFile.path!);
        context.read<AdvertisementFormBloc>().add(
          AdvertisementFormFilePicked(file)
        );
        
        ShowWidget.showMessage(
          context,
          'تم اختيار الملف: ${platformFile.name}',
          ColorsApp.green,
          font13White,
        );
      }
    }
  } catch (e) {
    ShowWidget.showMessage(
      context,
      'خطأ في اختيار الملف: ${e.toString()}',
      ColorsApp.red,
      font13White,
      );
    }
  }