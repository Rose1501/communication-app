part of 'update_user_info_bloc.dart';

abstract class UpdateUserInfoState extends Equatable {
  const UpdateUserInfoState();
  
  @override
  List<Object> props() => [];
}

class UpdateUserInfoInitial extends UpdateUserInfoState {}

class UploadPictureFailure extends UpdateUserInfoState {}
class UploadPictureLoading extends UpdateUserInfoState {}
class UploadPictureSuccess extends UpdateUserInfoState {
	final String userImage;

	const UploadPictureSuccess(this.userImage);

	@override
  List<Object> props() => [userImage];
}
// 🔥  إزالة الصورة
class RemovePictureLoading extends UpdateUserInfoState {}

class RemovePictureSuccess extends UpdateUserInfoState {
  @override
  List<Object> props() => [];
}

class RemovePictureFailure extends UpdateUserInfoState {
  final String error;

  const RemovePictureFailure({required this.error});

  @override
  List<Object> props() => [error];
}

// 🔥 حالات جديدة للبحث عن المستخدم
class SearchUserLoading extends UpdateUserInfoState {}
class SearchUserSuccess extends UpdateUserInfoState {
  final UserModels user;

  const SearchUserSuccess({required this.user});

  @override
  List<Object> props() => [user];
}
class SearchUserFailure extends UpdateUserInfoState {
  final String error;

  const SearchUserFailure({required this.error});

  @override
  List<Object> props() => [error];
}