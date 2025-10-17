import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/text_field_box.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';
import 'package:myproject/features/manager/view/widget/build_media_previews.dart';
import 'package:myproject/features/manager/view/widget/build_media_options.dart';
import 'package:myproject/features/manager/view/widget/build_target_dropdown.dart';
import 'package:user_repository/user_repository.dart';

class AdvertisementFormContent extends StatelessWidget {
  final UserModels currentUser;
  final TextEditingController _descriptionController = TextEditingController();

  AdvertisementFormContent({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdvertisementFormBloc, AdvertisementFormState>(
      listener: (context, state) {
        // 🔥 إضافة listener للتحقق من تغييرات State
        print('🔄 تغيير في State: ${state.runtimeType}');
        if (state is AdvertisementFormData) {
        print('📊 بيانات State الحالي:');
        print('   - imagePreview: ${state.imagePreview != null ? "موجود" : "null"}');
        print('   - filePreviewName: ${state.filePreviewName ?? "null"}');
        print('   - error: ${state.error}');
        }
        if (state is AdvertisementFormSuccess) {
          ShowWidget.showMessage(
            context,
            'تم نشر الإعلان بنجاح',
            ColorsApp.green,
            font13White,
          );
          Navigator.of(context).pop();
        } else if (state is AdvertisementFormFailure) {
          ShowWidget.showMessage(
            context,
            state.error,
            ColorsApp.red,
            font13White,
          );
        }
      },
      builder: (context, state) {
        if (state is AdvertisementFormInitial) {
          context.read<AdvertisementFormBloc>().add(
            AdvertisementFormDescriptionChanged('')
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل وصف الإعلان
              TextFieldBox(
                controller: _descriptionController,
                maxLines: 5,
                hintText: 'يرجى إدخال وصف الإعلان',
                errorText: state is AdvertisementFormData && state.error.isNotEmpty 
                    ? state.error 
                    : null,
                onChanged: (value) {
                  context.read<AdvertisementFormBloc>().add(
                    AdvertisementFormDescriptionChanged(value)
                  );
                },
              ),
              getHeight(20),

              // اختيار الفئة المستهدفة
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'المستهدف:',
                    style: font16black,
                  ),
                  getWidth(10),
                  buildTargetDropdown(context, state),
                ],
              ),
              getHeight(20),
              // خيارات الوسائط
              buildMediaOptions(context, state),
              getHeight(20),
              // 🔥 معاينة الوسائط قبل النشر
              buildMediaPreviews(context, state),
              getHeight(20),
              // زر النشر
              _buildSubmitButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, AdvertisementFormState state) {
    final isLoading = state is AdvertisementFormData && state.isLoading;
    final hasDescription = _descriptionController.text.isNotEmpty;

    return Center(
    child: Column(
      children: [
        isLoading
            ? const CupertinoActivityIndicator(radius: 15)
            : ElevatedButton(
                onPressed: hasDescription ? () {
                  print('🚀 بدء نشر الإعلان...');
                  print('📝 الوصف: ${_descriptionController.text}');
                  
                  if (state is AdvertisementFormData) {
                    print('📸 حالة الصورة: ${state.imagePreview != null ? "موجودة" : "غير موجودة"}');
                    print('📁 حالة الملف: ${state.file != null ? "موجود" : "غير موجود"}');
                  }
                  
                  context.read<AdvertisementFormBloc>().add(
                    AdvertisementFormSubmitted(
                      userId: currentUser.userID,
                      user: currentUser,
                    )
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasDescription 
                      ? ColorsApp.primaryColor 
                      : Colors.grey,
                  foregroundColor: ColorsApp.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('نشر الإعلان', style: font16White),
              ),
      ],
    ),
  );
}
}