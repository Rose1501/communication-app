part of 'advertisement_bloc.dart';

// الأحداث الأساسية للإعلانات
abstract class AdvertisementEvent extends Equatable {
  const AdvertisementEvent();

  @override
  List<Object> get props => [];
}

// حدث تحميل الإعلانات
class LoadAdvertisementsEvent extends AdvertisementEvent {
  @override
  List<Object> get props => [];
}

// حدث إضافة إعلان جديد
class AddAdvertisementEvent extends AdvertisementEvent {
  final AdvertisementModel advertisement;

  const AddAdvertisementEvent({required this.advertisement});

  @override
  List<Object> get props => [advertisement];
}

// حدث تحديث إعلان
class UpdateAdvertisementEvent extends AdvertisementEvent {
  final AdvertisementModel advertisement;

  const UpdateAdvertisementEvent({required this.advertisement});

  @override
  List<Object> get props => [advertisement];
}

// حدث حذف إعلان
class DeleteAdvertisementEvent extends AdvertisementEvent {
  final String advertisementId;

  const DeleteAdvertisementEvent({required this.advertisementId});

  @override
  List<Object> get props => [advertisementId];
}

// حدث تحديث حالة الإعلانات
class RefreshAdvertisementsEvent extends AdvertisementEvent {
  @override
  List<Object> get props => [];
}

// 🔥 حدث  لإزالة الصورة
class RemoveAdvertisementImageEvent extends AdvertisementEvent {
  final String advertisementId;
  RemoveAdvertisementImageEvent({required this.advertisementId});
}

// حدث إعادة نشر الإعلان
class RepublishAdvertisementEvent extends AdvertisementEvent {
  final AdvertisementModel originalAdvertisement;
  final String newDescription;
  final String newCustom;
  final UserModels currentUser;
  final File? newImage;
  final bool removeImage;

  const RepublishAdvertisementEvent({
    required this.originalAdvertisement,
    required this.newDescription,
    required this.newCustom,
    required this.currentUser,
    this.newImage,
    this.removeImage = false,
  });

  @override
  List<Object> get props => [
    originalAdvertisement,
    newDescription,
    newCustom,
    currentUser,
    removeImage,
    ];
}