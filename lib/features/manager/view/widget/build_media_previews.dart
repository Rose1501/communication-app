// 🔥 دالة لعرض معاينة الوسائط
  import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';


Widget buildMediaPreviews(BuildContext context, AdvertisementFormState state) {
    if (state is! AdvertisementFormData){
    print('ℹ️ state ليس AdvertisementFormData، نوع: ${state.runtimeType}');
    return const SizedBox();
  }
    final hasImagePreview = state.imagePreview != null;
    final hasFilePreview = state.filePreviewName != null;
print('🔍 حالة المعاينات:');
  print('   - imagePreview: ${hasImagePreview ? "موجود" : "غير موجود"}');
  print('   - filePreview: ${hasFilePreview ? "موجود" : "غير موجود"}');

    if (!hasImagePreview && !hasFilePreview){
    print('ℹ️ لا توجد وسائط للمعاينة - إرجاء SizedBox');
    return const SizedBox();
  }
    print('🎨 بناء معاينة الوسائط...');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عرض الوسائط قبل النشر:', style: font16blackbold),
        getHeight(10),
        
        if (hasImagePreview) 
          _buildImagePreview(context, state),
        
        if (hasFilePreview) 
          _buildFilePreview(context, state),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, AdvertisementFormData state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ColorsApp.primaryColor),
        borderRadius: BorderRadius.circular(12),
        color: ColorsApp.primaryLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: ColorsApp.primaryColor),
              getWidth(8),
              Text('معاينة الصورة', style: fount14Bold),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.zoom_in, color: ColorsApp.primaryColor),
                onPressed: () {
                  _previewImage(context, state.imagePreview!);
                },
              ),
              IconButton(
                icon: Icon(Icons.close, color: ColorsApp.red),
                onPressed: () {
                  print('🗑️ طلب إزالة الصورة من الواجهة');
                final bloc = BlocProvider.of<AdvertisementFormBloc>(context);
                bloc.add(AdvertisementFormImageRemoved());
                print('✅ تم إرسال event الإزالة إلى الـ Bloc');
                },
              ),
            ],
          ),
          getHeight(8),
          Center(
            child: Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  state.imagePreview!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.grey),
                          Text('خطأ في المعاينة', style: font14grey),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          getHeight(8),
          Text(
            '📸 الصورة جاهزة للنشر',
            style: font14grey,
            textAlign: TextAlign.center,
          ),
          Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'حجم الصورة: ${state.imagePreview!.length} bytes',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context, AdvertisementFormData state) {
    final fileSize = _formatFileSize(state.filePreviewSize ?? 0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.orange),
              getWidth(8),
              Text('معاينة الملف', style: fount14Bold),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: ColorsApp.red),
                onPressed: () {
                // ✅ استخدام context الممرر من الدالة الأم
                context.read<AdvertisementFormBloc>().add(
                  AdvertisementFormFileRemoved()
                  );
                },
              ),
            ],
          ),
          getHeight(8),
          Row(
            children: [
              Icon(Icons.insert_drive_file, size: 40, color: Colors.orange),
              getWidth(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.filePreviewName!,
                      style: font14black,
                      overflow: TextOverflow.ellipsis,
                    ),
                    getHeight(4),
                    Text(
                      'الحجم: $fileSize',
                      style: font14grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          getHeight(8),
          Text(
            '📁 الملف جاهز للنشر',
            style: font14grey,
          ),
        ],
      ),
    );
  }

  void _previewImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                print('❌ إغلاق معاينة الصورة');
                Navigator.of(context).pop(); // ✅ إغلاق الدايلوج
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes bytes';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }