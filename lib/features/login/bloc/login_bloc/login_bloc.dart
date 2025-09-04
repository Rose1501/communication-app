import 'dart:developer';

import 'package:equatable/equatable.dart';
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
        log(e.toString());
				emit(LoginFailure(message: e.toString()));
      }
    });
		on<LoginOutRequired>((event, emit) async {
			await _userRepository.logOut();
    });
  }
}