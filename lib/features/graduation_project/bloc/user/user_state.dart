part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> props() => [];
}

class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final UserModels user;
  const UserLoaded(this.user);
  @override
  List<Object> props() => [user];
}
class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object> props() => [message];
}

class UsersLoaded extends UserState {
  final List<UserModels> users;
  const UsersLoaded(this.users);
  @override
  List<Object> props() => [users];
}