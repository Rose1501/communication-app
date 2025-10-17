part of 'my_user_bloc.dart';

abstract class MyUserEvent extends Equatable {
  const MyUserEvent();

  @override
  List<Object> get props => [];
}

class GetMyUser extends MyUserEvent {
  final bool forceRefresh;

  const GetMyUser({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class LogoutUser extends MyUserEvent {}