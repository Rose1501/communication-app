part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> props() => [];
}

class LoginInitial extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});
  @override
  List<Object> props() => [message];
}

class LoginProcess extends LoginState {}