// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:math' show min;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'my_user_event.dart';
part 'my_user_state.dart';

class MyUserBloc extends Bloc<MyUserEvent, MyUserState> {
	final UserRepository _userRepository;

  MyUserBloc({
		required UserRepository myUserRepository
	}) : _userRepository = myUserRepository,
		super(const MyUserState.loading()) {
    on<GetMyUser>((event, emit) async {
      try {
        // جلب بيانات المستخدم الحالي من المستودع
				UserModels myUser= await _userRepository.getCurrentUser();
          print('3.تم جلب بيانات المستخدم الحالي: ${myUser.name}');
        // 🔥 فحص بيانات الصورة بعد الجلب
    if (myUser.urlImg != null) {
      print('🖼️ بيانات الصورة بعد الجلب - الطول: ${myUser.urlImg!.length}');
      print('🔍 أول 50 حرف: ${myUser.urlImg!.substring(0, min(50, myUser.urlImg!.length))}');
    } else {
      print('🔍 لا توجد صورة للمستخدم بعد الجلب');
    }
        emit(MyUserState.success(myUser));
      } catch (e) {
			log(e.toString());
			emit(const MyUserState.failure());
      }
    });

    on<LogoutUser>((event, emit) async {
      try {
        emit(const MyUserState.loading()); // حالة تحميل أثناء الخروج
        await _userRepository.logOut(); // استدعاء دالة الخروج من الـ repository
        emit(const MyUserState.logout()); // حالة نجاح الخروج
      } catch (e) {
        log(e.toString());
        emit(const MyUserState.failure());
      }
    });
  }
}