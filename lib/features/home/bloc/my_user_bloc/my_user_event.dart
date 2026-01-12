part of 'my_user_bloc.dart';

abstract class MyUserEvent extends Equatable {
  const MyUserEvent();

  @override
  List<Object> props() => [];
}

class GetMyUser extends MyUserEvent {
  final bool forceRefresh;

  const GetMyUser({this.forceRefresh = false});

  @override
  List<Object> props() => [forceRefresh];
}

class LogoutUser extends MyUserEvent {}