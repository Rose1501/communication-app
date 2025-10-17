part of 'update_user_info_bloc.dart';

abstract class UpdateUserInfoState extends Equatable {
  const UpdateUserInfoState();
  
  @override
  List<Object> get props => [];
}

class UpdateUserInfoInitial extends UpdateUserInfoState {}

class UploadPictureFailure extends UpdateUserInfoState {}
class UploadPictureLoading extends UpdateUserInfoState {}
class UploadPictureSuccess extends UpdateUserInfoState {
	final String userImage;

	const UploadPictureSuccess(this.userImage);

	@override
  List<Object> get props => [userImage];
}
// 🔥  إزالة الصورة
class RemovePictureLoading extends UpdateUserInfoState {}

class RemovePictureSuccess extends UpdateUserInfoState {
  @override
  List<Object> get props => [];
}

class RemovePictureFailure extends UpdateUserInfoState {
  final String error;

  const RemovePictureFailure({required this.error});

  @override
  List<Object> get props => [error];
}