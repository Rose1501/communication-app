part of 'update_user_info_bloc.dart';

abstract class UpdateUserInfoEvent extends Equatable {
  const UpdateUserInfoEvent();

  @override
  List<Object> props() => [];
}

class UploadPicture extends UpdateUserInfoEvent {
	final String file;
	final UserModels userModel;

	const UploadPicture(this.file, this.userModel);

	@override
  List<Object> props() => [file, userModel];
}

class RemoveProfilePicture extends UpdateUserInfoEvent {
  final String userId;

  const RemoveProfilePicture(this.userId);

  @override
  List<Object> props() => [userId];
}

class SearchUserByUserID extends UpdateUserInfoEvent {
  final String userID;

  const SearchUserByUserID(this.userID);

  @override
  List<Object> props() => [userID];
}

class ResetSearchState extends UpdateUserInfoEvent {}