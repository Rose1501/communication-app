import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> pickImage(
    BuildContext context, 
    Function(File) onImagePicked
  ) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      _showError(context);
    }
  }

  static void _showError(BuildContext context) {
    ShowWidget.showMessage(
      context,
      'فشل في اختيار الصورة',
      ColorsApp.red,
      font13White,
    );
  }
}