part of 'advertisement_form_bloc.dart';

abstract class AdvertisementFormState extends Equatable {
  const AdvertisementFormState();

  @override
  List<Object> props() => [];
}

class AdvertisementFormInitial extends AdvertisementFormState {}

class AdvertisementFormData extends AdvertisementFormState {
  final String description;
  final String custom;
  final File? image;
  final File? file;
  final String? imageUrl;
  final String? fileUrl;
  final bool isLoading;
  final String error;
  // 🔥 إضافة حقول جديدة للمعاينة
  final Uint8List? imagePreview; // معاينة الصورة كـ bytes
  final String? filePreviewName; // اسم الملف للمعاينة
  final int? filePreviewSize; // حجم الملف للمعاينة

  const AdvertisementFormData({
    this.description = '',
    this.custom = 'الكل',
    this.image,
    this.file,
    this.imageUrl,
    this.fileUrl,
    this.isLoading = false,
    this.error = '',
    // 🔥 القيم الافتراضية للحقول الجديدة
    this.imagePreview,
    this.filePreviewName,
    this.filePreviewSize,
  });

  AdvertisementFormData copyWith({
    String? description,
    String? custom,
    File? image,
    File? file,
    String? imageUrl,
    String? fileUrl,
    bool? isLoading,
    String? error,
    Uint8List? imagePreview,
    String? filePreviewName,
    int? filePreviewSize,
  }) {
    return AdvertisementFormData(
      description: description ?? this.description,
      custom: custom ?? this.custom,
      image: image ,
      file: file ,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      imagePreview: imagePreview ,
      filePreviewName: filePreviewName ,
      filePreviewSize: filePreviewSize ,
    );
  }

  @override
  List<Object> props() => [
        description,
        custom,
        image ?? '',
        file ?? '',
        imageUrl ?? '',
        fileUrl ?? '',
        isLoading,
        error,
        imagePreview ?? '',
        filePreviewName ?? '',
        filePreviewSize ?? '',
      ];
}

class AdvertisementFormSuccess extends AdvertisementFormState {}

class AdvertisementFormFailure extends AdvertisementFormState {
  final String error;

  const AdvertisementFormFailure(this.error);

  @override
  List<Object> props() => [error];
}