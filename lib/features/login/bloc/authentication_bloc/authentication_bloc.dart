import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;
  static const String _firstLaunchKey = 'first_launch';

  AuthenticationBloc({
		required UserRepository myUserRepository
	}) : userRepository = myUserRepository,
		super(const AuthenticationState.unknown()) {
      // التحقق من حالة التشغيل الأول عند بدء التطبيق
      _initializeFirstLaunch();
      
			_userSubscription = userRepository.user.listen((authUser) {
				add(AuthenticationUserChanged(authUser));
			});

    on<AuthenticationUserChanged>((event, emit) async {
      // التحقق من حالة التشغيل الأول
      final isFirstLaunch = await _getIsFirstLaunch();
			if(event.user != null) {
				emit(AuthenticationState.authenticated(event.user!, isFirstLaunch: isFirstLaunch));
			} else {
				emit(AuthenticationState.unauthenticated(isFirstLaunch: isFirstLaunch));
			}
    });
  }
  // تهيئة حالة التشغيل الأول
  Future<void> _initializeFirstLaunch() async {
    final isFirstLaunch = await _getIsFirstLaunch();
    debugPrint('🚀 isFirstLaunch: $isFirstLaunch');
    // ignore: invalid_use_of_visible_for_testing_member
    emit(AuthenticationState.unknown(isFirstLaunch: isFirstLaunch));
  }
  // دالة للتحقق مما إذا كان هذا هو التشغيل الأول للتطبيق
  Future<bool> _getIsFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    
    // إذا كان التشغيل الأول، قم بتحديث القيمة
    if (isFirstLaunch) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    
    return isFirstLaunch;
  }
	@override
	Future<void> close() {
		_userSubscription.cancel();
		return super.close();
	}
}