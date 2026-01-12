import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
	final UserRepository _userRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  LoginBloc({
		required UserRepository userRepository
	}) : _userRepository = userRepository,
		super(LoginInitial()) {
    on<LoginRequired>((event, emit) async {
      print('LoginRequired event: ${event.email}, ${event.password}');
			emit(LoginProcess());
      try {
        print('Attempting login...');
        await _userRepository.login(event.email, event.password);
				print('Login successful');
        emit(LoginSuccess());
      } catch (e) {
        print('Login failed: $e');
        // تحويل رسالة الخطأ إلى عربية
        final errorMessage = _mapErrorToArabic(e.toString());
        
				emit(LoginFailure(message: errorMessage));
      }
    });
		on<LoginOutRequired>((event, emit) async {
			await _userRepository.logOut();
    });
  }

   // دالة لتحويل رسائل الخطأ إلى عربية
  String _mapErrorToArabic(String error) {
    error = error.toLowerCase();
    
    // أخطاء البريد الإلكتروني
    if (error.contains('invalid-email') || 
        error.contains('invalid email') ||
        error.contains('email malformed')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    if (error.contains('user-not-found') || 
        error.contains('user not found') ||
        error.contains('no user record')) {
      return 'البريد الإلكتروني غير مسجل';
    }
    
    if (error.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
    
    // أخطاء كلمة المرور
    if (error.contains('wrong-password') || 
        error.contains('wrong password') ||
        error.contains('password is invalid')) {
      return 'كلمة المرور غير صحيحة';
    }
    
    if (error.contains('weak-password')) {
      return 'كلمة المرور ضعيفة جداً';
    }
    
    if (error.contains('user-disabled')) {
      return 'الحساب معطل';
    }
    
    // أخطاء الشبكة
    if (error.contains('network-request-failed') ||
        error.contains('network error') ||
        error.contains('timeout') ||
        error.contains('socket')) {
      return 'فشل الاتصال بالشبكة. تحقق من اتصالك بالإنترنت';
    }
    
    if (error.contains('too-many-requests')) {
      return 'محاولات تسجيل دخول كثيرة جداً. حاول مرة أخرى لاحقاً';
    }
    
    if (error.contains('requires-recent-login')) {
      return 'يجب تسجيل الدخول مرة أخرى';
    }
    
    if (error.contains('operation-not-allowed')) {
      return 'طريقة التسجيل هذه غير مسموح بها';
    }
    
    // أخطاء عامة
    if (error.contains('invalid-credential') ||
        error.contains('invalid credential')) {
      return 'بيانات الدخول غير صحيحة';
    }
    
    if (error.contains('quota-exceeded')) {
      return 'تم تجاوز الحد المسموح به. حاول مرة أخرى لاحقاً';
    }
    
    if (error.contains('expired-action-code')) {
      return 'انتهت صلاحية الرابط';
    }
    
    // إذا لم يتطابق مع أي من الرسائل المعروفة
    return 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى';
  }
}