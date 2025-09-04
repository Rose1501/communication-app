import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final id = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  SignUpBloc({
    required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async {
      emit(SignUpLoading());
      try {
        await _userRepository.signUp(event.user.userID, event.user.email, event.password);
        // انتظر قليلاً لضمان اكتمال عملية التسجيل
        await Future.delayed(Duration(seconds: 1));
         // 2. جلب بيانات المستخدم بعد التسجيل
          UserModels user = await _userRepository.getCurrentUser();
          // تحقق من البيانات قبل الانتقال
          if (user.userID.isEmpty || user.email.isEmpty) {
            throw Exception('بيانات المستخدم غير مكتملة بعد التسجيل');
          }
        emit(SignUpSuccess(user: user));
        } catch (e) {
        emit(SignUpFailure(message: _getErrorMessage(e)));
        }
    });
  }
  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'لا يوجد مستخدم مسجل بهذه البيانات. يرجى التحقق من البريد الإلكتروني ورقم القيد';
        case 'account-already-exists':
          return 'هذا المستخدم لديه حساب مفعل بالفعل';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح';
        case 'weak-password':
          return 'كلمة المرور ضعيفة';
        default:
          return e.message ?? 'حدث خطأ غير متوقع أثناء التسجيل';
      }
    }
    return e.toString();
  }
  @override
  Future<void> close() {
    id.dispose();
    email.dispose();
    password.dispose();
    return super.close();
  }
}
