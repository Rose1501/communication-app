import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

part 'advertisement_form_event.dart';
part 'advertisement_form_state.dart';

class AdvertisementFormBloc
    extends Bloc<AdvertisementFormEvent, AdvertisementFormState> {
  final AdvertisementRepository advertisementRepository;

  AdvertisementFormBloc({required this.advertisementRepository})
    : super(AdvertisementFormData()) {
    on<AdvertisementFormDescriptionChanged>(_onDescriptionChanged);
    on<AdvertisementFormTargetChanged>(_onTargetChanged);
    on<AdvertisementFormImagePicked>(_onImagePicked);
    on<AdvertisementFormFilePicked>(_onFilePicked);
    on<AdvertisementFormImageRemoved>(_onImageRemoved);
    on<AdvertisementFormFileRemoved>(_onFileRemoved);
    on<AdvertisementFormSubmitted>(_onSubmitted);
    on<AdvertisementFormReset>(_onReset);
  }

  void _onDescriptionChanged(
    AdvertisementFormDescriptionChanged event,
    Emitter<AdvertisementFormState> emit,
  ) {
    if (state is AdvertisementFormData) {
      final currentState = state as AdvertisementFormData;
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onTargetChanged(
    AdvertisementFormTargetChanged event,
    Emitter<AdvertisementFormState> emit,
  ) {
    if (state is AdvertisementFormData) {
      final currentState = state as AdvertisementFormData;
      emit(currentState.copyWith(custom: event.target));
    }
  }

void _onImagePicked(
  AdvertisementFormImagePicked event,
  Emitter<AdvertisementFormState> emit,
) async {
  if (state is AdvertisementFormData) {
    final currentState = state as AdvertisementFormData;

    try {
      // 🔥 قراءة الصورة كـ bytes للمعاينة
        final imageBytes = await event.image.readAsBytes();
        
        emit(currentState.copyWith(
          image: event.image,
          imagePreview: imageBytes, // 🔥 حفظ bytes للمعاينة
          isLoading: false,
          error: '',
        ));
        
        print('📸 تم تحميل صورة للمعاينة، الحجم: ${imageBytes.length} bytes');
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoading: false,
          error: 'فشل في رفع الصورة: ${e.toString()}',
        ),
      );
    }
  }
}

  void _onFilePicked(
  AdvertisementFormFilePicked event,
  Emitter<AdvertisementFormState> emit,
) async {
  if (state is AdvertisementFormData) {
    final currentState = state as AdvertisementFormData;

    try {
      // 🔥 الحصول على معلومات الملف للمعاينة
        final fileStat = await event.file.stat();
        final fileName = event.file.path.split('/').last;
        
        emit(currentState.copyWith(
          file: event.file,
          filePreviewName: fileName, // 🔥 اسم الملف للمعاينة
          filePreviewSize: fileStat.size, // 🔥 حجم الملف للمعاينة
          isLoading: false,
        ));
        
        print('📁 تم تحميل ملف للمعاينة: $fileName, الحجم: ${fileStat.size} bytes');
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoading: false,
          error: 'فشل في رفع الملف: ${e.toString()}',
        ),
      );
    }
  }
}

  void _onSubmitted(
    AdvertisementFormSubmitted event,
    Emitter<AdvertisementFormState> emit,
  ) async {
    print('يتم التحقق من حالة النموذج والإعلان');
    if (state is AdvertisementFormData) {
      print('الحالة الحالية ليست AdvertisementFormData');
    final currentState = state as AdvertisementFormData;
    print('الوصف الحالي: ${currentState.description}');

    if (currentState.description.isEmpty&& 
        currentState.image == null ) {
      print('❌ لا يمكن نشر إعلان بدون محتوى');
      emit(currentState.copyWith(error: 'يرجى إدخال وصف أو إضافة صورة/ملف'));
      return;
    }

    emit(currentState.copyWith(isLoading: true, error: ''));

    try {
      // إنشاء كود فريد للإعلان
      final advertisementId = Uuid().v1();
      
      String? finalImageUrl;
        String? finalFileUrl;

        // 🔥 إذا كانت هناك صورة، تشفيرها كـ base64
        if (currentState.image != null) {
          print('🔤 جاري تشفير الصورة إلى base64...');
          
          final imageBytes = await currentState.image!.readAsBytes();
          finalImageUrl = base64Encode(imageBytes);
          print('✅ تم تشفير الصورة، الطول: ${finalImageUrl.length}');
          // 🔥 التحقق النهائي من الحجم
            if (finalImageUrl.length > 1000000) {
                emit(currentState.copyWith(
                  isLoading: false,
                  error: 'حجم الصورة كبير جداً. يرجى اختيار صورة أصغر.',
                ));
                print('❌ حجم الصورة تجاوز الحد المسموح (1MB)');
                return;
            }
        }else {
        print('ℹ️ لا توجد صورة للمعاينة');
      }

        // 🔥 إذا كان هناك ملف، رفعه إلى Firebase Storage
        if (currentState.file != null) {
          print('📤 جاري رفع الملف إلى السيرفر...');
          dynamic fileToUpload = currentState.file!;
          if (kIsWeb) {
            fileToUpload = await currentState.file!.readAsBytes();
          }
          finalFileUrl = await advertisementRepository.uploadAdvertisementFile(fileToUpload, advertisementId);
          print('✅ تم رفع الملف، الرابط: $finalFileUrl');
        }else {
        print('ℹ️ لا توجد ملفات للرفع');
      }
      // إنشاء الإعلان مع البيانات المشفرة
      final advertisement = AdvertisementModel(
        id: advertisementId,
        description: currentState.description,
        timeAdv: DateTime.now(),
        fileUrl: finalFileUrl,
        advlImg: finalImageUrl, 
        custom: currentState.custom,
        user: event.user,
      );

      print('🆕 بيانات الإعلان النهائية:');
      print('   - ID: ${advertisement.id}');
      print('   - الوصف: ${advertisement.description}');
      print('   - الصورة: ${advertisement.advlImg != null ? "موجودة" : "غير موجودة"}');
      print('   - الملف: ${advertisement.fileUrl ?? "غير موجود"}');
      print('   - الفئة: ${advertisement.custom}');

      // إضافة الإعلان إلى قاعدة البيانات
      await advertisementRepository.addAdvertisement(advertisement);
      print('تم نشر الإعلان بنجاح ${advertisement.id}');
      emit(AdvertisementFormSuccess());
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoading: false,
          error: 'فشل في نشر الإعلان: ${e.toString()}',
        ),
      );
    }
    }
    print('نهاية عملية الإرسال');
  }

  void _onReset(
    AdvertisementFormReset event,
    Emitter<AdvertisementFormState> emit,
  ) {
    emit(AdvertisementFormInitial());
  }

  void _onImageRemoved(
    AdvertisementFormImageRemoved event,
    Emitter<AdvertisementFormState> emit,
  ) {
    if (state is AdvertisementFormData) {
      final currentState = state as AdvertisementFormData;
      //emit(currentState.copyWith(image: null, imageUrl: null,imagePreview: null,));
    
    
    print('🗑️ بدء إزالة الصورة من الـ Bloc');
    print('📸 قبل الإزالة - image: ${currentState.image != null ? "موجود" : "null"}');
    print('📸 قبل الإزالة - imagePreview: ${currentState.imagePreview != null ? "موجود" : "null"}');
    
    // 🔥 إنشاء state جديد مع إزالة جميع حقول الصورة
    final newState = AdvertisementFormData(
      description: currentState.description,
      custom: currentState.custom,
      image: null, // 🔥 تعيين صريح لـ null
      file: currentState.file,
      imageUrl: null,
      fileUrl: currentState.fileUrl,
      isLoading: currentState.isLoading,
      error: currentState.error,
      imagePreview: null, // 🔥 تعيين صريح لـ null
      filePreviewName: currentState.filePreviewName,
      filePreviewSize: currentState.filePreviewSize,
    );
    
    print('🔄 بعد الإزالة - image: ${newState.image != null ? "موجود" : "null"}');
    print('🔄 بعد الإزالة - imagePreview: ${newState.imagePreview != null ? "موجود" : "null"}');
    
    emit(newState);
    
    print('✅ تم إزالة الصورة بنجاح في الـ Bloc');
  } else {
    print('❌ الحالة الحالية ليست AdvertisementFormData');
    }
  }

  void _onFileRemoved(
    AdvertisementFormFileRemoved event,
    Emitter<AdvertisementFormState> emit,
  ) {
    if (state is AdvertisementFormData) {
      final currentState = state as AdvertisementFormData;
      //emit(currentState.copyWith(file: null, fileUrl: null,filePreviewName: null,filePreviewSize: null,));
      print('🗑️ بدء إزالة الملف من الـ Bloc');
    print('📁 قبل الإزالة - file: ${currentState.file != null ? "موجود" : "null"}');
    print('📁 قبل الإزالة - filePreviewName: ${currentState.filePreviewName ?? "null"}');
    
    // 🔥 إنشاء state جديد مع إزالة جميع حقول الملف
    final newState = AdvertisementFormData(
      description: currentState.description,
      custom: currentState.custom,
      image: currentState.image,
      file: null, // 🔥 تعيين صريح لـ null
      imageUrl: currentState.imageUrl,
      fileUrl: null,
      isLoading: currentState.isLoading,
      error: currentState.error,
      imagePreview: currentState.imagePreview,
      filePreviewName: null, // 🔥 تعيين صريح لـ null
      filePreviewSize: null, // 🔥 تعيين صريح لـ null
    );
    
    print('🔄 بعد الإزالة - file: ${newState.file != null ? "موجود" : "null"}');
    print('🔄 بعد الإزالة - filePreviewName: ${newState.filePreviewName ?? "null"}');
    
    emit(newState);
    
    print('✅ تم إزالة الملف بنجاح في الـ Bloc');
  } else {
    print('❌ الحالة الحالية ليست AdvertisementFormData');
  }
  }

}
