import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  AuthBloc({required this.userRepository}) : super(const AuthState()) {
    // أحداث إعادة تعيين كلمة المرور
    on<SendResetCodeRequested>(_onSendResetCodeRequested);
    on<VerifyResetCodeRequested>(_onVerifyResetCodeRequested);
    on<ResetPasswordWithCodeRequested>(_onResetPasswordWithCodeRequested);
    
    // أحداث تغيير كلمة المرور (للمستخدم المسجل دخوله)
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    // إضافة هذا المعالج في constructor
    on<EmailSetEvent>((event, emit) {
        emit(state.copyWith(email: event.email));
        });
  }

@override
  Future<void> close() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
  /// معالجة حدث تغيير كلمة المرور (للمستخدم المسجل دخوله)
  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await userRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(state.copyWith(status: AuthStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage:  _getFirebaseErrorMessage(e.code),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'حدث خطأ غير متوقع',
        ),
      );
    }
  }

/// تحويل أخطاء Firebase إلى رسائل مفهومة
  String  _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
        return 'كلمة المرور الحالية غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور الجديدة ضعيفة جداً';
      case 'requires-recent-login':
        return 'يجب إعادة تسجيل الدخول لتغيير كلمة المرور';
      case 'user-not-found':
        return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'expired-action-code':
        return 'انتهت صلاحية رمز التحقق';
      default:
        return 'حدث خطأ ما. يرجى المحاولة مرة أخرى';
    }
  }
/// معالجة أنواع مختلفة من الأخطاء
  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      return _getFirebaseErrorMessage(e.code);
    } else if (e is Exception) {
      return e.toString();
    }
    return 'حدث خطأ غير متوقع';
  }
/// معالجة حدث إعادة تعيين كلمة المرور باستخدام الرمز
Future<void> _onResetPasswordWithCodeRequested(
    ResetPasswordWithCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await userRepository.resetPasswordWithCode(
        state.email!,
        event.code,
        event.newPassword,
      );
      
      emit(state.copyWith(status: AuthStatus.resetPasswordSuccess));
    } catch (e) {
      log('Reset password with code error: ${e.toString()}');
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
/// معالجة حدث التحقق من رمز إعادة التعيين
Future<void> _onVerifyResetCodeRequested(
    VerifyResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final isValid  = await userRepository.verifyResetCode(
        state.email!, 
        event.code
      );
      if (isValid) {
        emit(state.copyWith(
          status: AuthStatus.resetCodeVerified,
          resetCode: event.code,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'رمز التحقق غير صحيح',
        ));
      }
      } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
      }
  }
/// معالجة حدث إرسال رمز إعادة التعيين
Future<void> _onSendResetCodeRequested(
    SendResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    // إعادة تعيين الحالة أولاً
    emit(const AuthState(status: AuthStatus.loading));
    
    try {
      await userRepository.sendResetCode(event.email);
      emit(AuthState(
        status: AuthStatus.resetCodeSent,
        email: event.email,
        errorMessage: null,
      ));
      print('✅ تم إرسال الرمز بنجاح إلى: ${event.email}');
    } catch (e) {
      log('❌ خطأ في إرسال الرمز: $e');
      emit(AuthState(
        status: AuthStatus.failure,
        errorMessage: _getErrorMessage(e),
        email: event.email,
      ));
    }
  }
}
