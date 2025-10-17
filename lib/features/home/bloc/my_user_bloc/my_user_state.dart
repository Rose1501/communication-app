part of 'my_user_bloc.dart';

enum MyUserStatus { success, loading, failure, logout }

class MyUserState extends Equatable {

	final MyUserStatus status;
  final UserModels? user;

  const MyUserState._({
    this.status = MyUserStatus.loading,
    this.user,
  });

	const MyUserState.loading() : this._();

	const MyUserState.success(UserModels user) : this._(status: MyUserStatus.success, user: user);

	const MyUserState.failure() : this._(status: MyUserStatus.failure);

  const MyUserState.logout() : this._(status: MyUserStatus.logout);

	@override
  List<Object?> get props => [status, user];
}