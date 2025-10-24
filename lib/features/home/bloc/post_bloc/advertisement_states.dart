part of 'advertisement_bloc.dart';

// حالات حالة الإعلانات
abstract class AdvertisementState extends Equatable {
  const AdvertisementState();

  @override
  List<Object> get props => [];
}

// الحالة الأولية
class AdvertisementInitial extends AdvertisementState {}

// حالة التحميل
class AdvertisementLoading extends AdvertisementState {}

// حالة التحميل الناجح
class AdvertisementLoaded extends AdvertisementState {
  final List<AdvertisementModel> advertisements;

  const AdvertisementLoaded({required this.advertisements});

  @override
  List<Object> get props => [advertisements];
}

// حالة التحميل الفاشل
class AdvertisementError extends AdvertisementState {
  final String message;

  const AdvertisementError({required this.message});

  @override
  List<Object> get props => [message];
}

// حالة الإضافة الناجحة
class AdvertisementAdded extends AdvertisementState {
  final AdvertisementModel advertisement;

  const AdvertisementAdded({required this.advertisement});

  @override
  List<Object> get props => [advertisement];
}

// حالة التحديث الناجح
class AdvertisementUpdated extends AdvertisementState {
  final AdvertisementModel advertisement;

  const AdvertisementUpdated({required this.advertisement});

  @override
  List<Object> get props => [advertisement];
}

// حالة الحذف الناجح
class AdvertisementDeleted extends AdvertisementState {
  final String advertisementId;

  const AdvertisementDeleted({required this.advertisementId});

  @override
  List<Object> get props => [advertisementId];
}

// 🔥 state جديد لإزالة الصورة (اختياري)
class AdvertisementImageRemoved extends AdvertisementState {
  final String advertisementId;
  AdvertisementImageRemoved({required this.advertisementId});
}

// حالة نجاح إعادة النشر
class AdvertisementRepublished extends AdvertisementState {
  final AdvertisementModel advertisement;

  const AdvertisementRepublished({required this.advertisement});

  @override
  List<Object> get props => [advertisement];
}