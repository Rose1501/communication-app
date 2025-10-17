part of 'advertisement_form_bloc.dart';

abstract class AdvertisementFormEvent extends Equatable {
  const AdvertisementFormEvent();

  @override
  List<Object> get props => [];
}

class AdvertisementFormDescriptionChanged extends AdvertisementFormEvent {
  final String description;

  const AdvertisementFormDescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class AdvertisementFormTargetChanged extends AdvertisementFormEvent {
  final String target;

  const AdvertisementFormTargetChanged(this.target);

  @override
  List<Object> get props => [target];
}

class AdvertisementFormImagePicked extends AdvertisementFormEvent {
  final File image;

  const AdvertisementFormImagePicked(this.image);

  @override
  List<Object> get props => [image];
}

class AdvertisementFormFilePicked extends AdvertisementFormEvent {
  final File file;

  const AdvertisementFormFilePicked(this.file);

  @override
  List<Object> get props => [file];
}

class AdvertisementFormSubmitted extends AdvertisementFormEvent {
  final String userId;
  final UserModels user;

  const AdvertisementFormSubmitted({required this.userId, required this.user});

  @override
  List<Object> get props => [userId, user];
}

class AdvertisementFormReset extends AdvertisementFormEvent {}

class AdvertisementFormImageRemoved extends AdvertisementFormEvent {}

class AdvertisementFormFileRemoved extends AdvertisementFormEvent {}