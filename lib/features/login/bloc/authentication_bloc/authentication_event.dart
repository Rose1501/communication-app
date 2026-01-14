part of 'authentication_bloc.dart';


abstract class AuthenticationEvent extends Equatable {
	const AuthenticationEvent();

	@override
  List<Object> props() => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  const AuthenticationUserChanged(this.user, {this.isFirstLaunch = true});

  final User? user;
  final bool isFirstLaunch;
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  const AuthenticationStatusChanged({
    required this.status,
    this.user,
    this.isFirstLaunch = false,
  });

  final AuthenticationStatus status;
  final User? user;
  final bool isFirstLaunch;
}