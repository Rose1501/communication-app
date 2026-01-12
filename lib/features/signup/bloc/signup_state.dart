part of 'signup_bloc.dart';


abstract class SignUpState extends Equatable {
  const SignUpState();
  
  @override
  List<Object> props() => [];
}

class SignUpInitial extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final UserModels user;
  SignUpSuccess({required this.user});
  @override
  List<Object> props() => [user];
}
class SignUpFailure extends SignUpState {
  final String message;
  
  const SignUpFailure({required this.message});
  
  @override
  List<Object> props() => [message];
}
class SignUpProcess extends SignUpState {}
class SignUpLoading extends SignUpState {}
