part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> props() => [];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> props() => [currentPassword, newPassword];
}

// حدث لتعيين البريد الإلكتروني في الحالة
class EmailSetEvent extends AuthEvent {
  final String email;

  const EmailSetEvent(this.email);

  @override
  List<Object> props() => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> props() => [email];
}

class SendResetCodeRequested extends AuthEvent {
  final String email;

  const SendResetCodeRequested(this.email);
  @override
  List<Object> props() => [email];
}

class VerifyResetCodeRequested extends AuthEvent {
  final String code;

  const VerifyResetCodeRequested(this.code);

  @override
  List<Object> props() => [code];
}
class ResetPasswordWithCodeRequested extends AuthEvent {
  final String code;
  final String newPassword;

  const ResetPasswordWithCodeRequested({
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object> props() => [code, newPassword];
}

/*class ResetPasswordWithCodeSubmitted extends AuthEvent {
  final String code;
  final String newPassword;

  const ResetPasswordWithCodeSubmitted({
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object> get props => [code, newPassword];
}*/
