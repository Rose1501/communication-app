part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure ,
  resetCodeSent,    // تم إرسال الرمز
  resetCodeVerified, // تم التحقق من الرمز
  resetPasswordSuccess // تم تغيير كلمة المرور بنجاح
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? email; // لتخزين البريد الإلكتروني أثناء العملية
  final String? resetCode; // لتخزين الرمز المؤقت


  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.email,
    this.resetCode,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? email,
    String? resetCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      resetCode: resetCode ?? this.resetCode,
    );
  }

  @override
  List<Object?> props() => [status, errorMessage, email, resetCode];
}