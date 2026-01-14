part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {

	final AuthenticationStatus status;
  final User? user;
  final bool isFirstLaunch;

	const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user,
    this.isFirstLaunch = true,
  });

	/// No information about the [AuthenticationStatus] of the current user.
  const AuthenticationState.unknown({bool isFirstLaunch = true}) 
      : this._(isFirstLaunch: isFirstLaunch);

	/// Current user is [authenticated].
  /// 
  /// It takes a [MyUser] property representing the current [authenticated] user.
  const AuthenticationState.authenticated(User user,{bool isFirstLaunch = false}) : this._(status: AuthenticationStatus.authenticated, user: user, isFirstLaunch: isFirstLaunch);

	/// Current user is [unauthenticated].
  const AuthenticationState.unauthenticated({bool isFirstLaunch = false}) : this._(status: AuthenticationStatus.unauthenticated, isFirstLaunch: isFirstLaunch);

	@override
	List<Object?> props() => [status, user,isFirstLaunch];


}