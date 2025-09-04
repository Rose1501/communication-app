part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequired extends SignUpEvent{
	final UserModels user;
	final String password;

	const SignUpRequired(this.user, this.password);
}