part of 'advertisement_bloc.dart';

// حالات حالة الإعلانات
abstract class AdvertisementState extends Equatable {
  const AdvertisementState();

  @override
  List<Object> props() => [];
}

// الحالة الأولية
class AdvertisementInitial extends AdvertisementState {}

// حالة التحميل
class AdvertisementLoading extends AdvertisementState {}

// حالة التحميل الناجح
class AdvertisementLoaded extends AdvertisementState {
  final List<AdvertisemenModel> advertisements;

  const AdvertisementLoaded({required this.advertisements});

  @override
  List<Object> props() => [advertisements];
}

// حالة التحميل الفاشل
class AdvertisementError extends AdvertisementState {
  final String message;

  const AdvertisementError({required this.message});

  @override
  List<Object> props() => [message];
}

// حالة الإضافة الناجحة
class AdvertisementAdded extends AdvertisementState {
  final AdvertisemenModel advertisement;

  const AdvertisementAdded({required this.advertisement});

  @override
  List<Object> props() => [advertisement];
}

// حالة التحديث الناجح
class AdvertisementUpdated extends AdvertisementState {
  final AdvertisemenModel advertisement;

  const AdvertisementUpdated({required this.advertisement});

  @override
  List<Object> props() => [advertisement];
}

// حالة الحذف الناجح
class AdvertisementDeleted extends AdvertisementState {
  final String advertisementId;

  const AdvertisementDeleted({required this.advertisementId});

  @override
  List<Object> props() => [advertisementId];
}

// 🔥 state جديد لإزالة الصورة (اختياري)
class AdvertisementImageRemoved extends AdvertisementState {
  final String advertisementId;
  AdvertisementImageRemoved({required this.advertisementId});
}

// حالة نجاح إعادة النشر
class AdvertisementRepublished extends AdvertisementState {
  final AdvertisemenModel advertisement;

  const AdvertisementRepublished({required this.advertisement});

  @override
  List<Object> props() => [advertisement];
}