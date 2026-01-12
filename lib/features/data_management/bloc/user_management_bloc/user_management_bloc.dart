import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserRepository userRepository;

  UserManagementBloc({required this.userRepository}) : super(const UserManagementState()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<ImportUsersFromExcel>(_onImportUsersFromExcel);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<SearchUsers>(_onSearchUsers);
    on<ClearMessages>(_onClearMessages);
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      final users = await userRepository.getAllUsers();
      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        errorMessage: 'فشل في تحميل المستخدمين: ${e.toString()}',
      ));
    }
  }

  Future<void> _onImportUsersFromExcel(
    ImportUsersFromExcel event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      final result = await userRepository.importUsersFromExcel(event.excelData);
      
      if (result['success'] == true) {
        final users = await userRepository.getAllUsers();
        // 🔥 بناء رسالة النتائج المفصلة
      final totalRecords = result['totalRecords'] as int;
      final importedCount = result['importedCount'] as int;
      final duplicateCount = result['duplicateCount'] as int;
      final errorCount = result['errorCount'] as int;
      
      String resultMessage = '✅ تم استيراد $importedCount مستخدم بنجاح\n';
      
      if (duplicateCount > 0) {
        resultMessage += '🔄 تم تخطي $duplicateCount مستخدم مكرر\n';
      }
      
      if (errorCount > 0) {
        resultMessage += '❌ حدث $errorCount خطأ أثناء الاستيراد';
      }
        emit(state.copyWith(
          status: UserManagementStatus.success,
          users: users,
          successMessage: resultMessage,
        ));
        print('''
        🎉 نتائج الاستيراد النهائية:
        📋 إجمالي السجلات: $totalRecords
        ✅ تمت الإضافة: $importedCount
        🔄 مكرر (تم تخطيه): $duplicateCount
        ❌ أخطاء: $errorCount''');
        // 🔥 مسح الرسالة تلقائياً بعد 5 ثواني
        Future.delayed(const Duration(seconds: 5), () {
        if (state.successMessage == resultMessage) {
          add(const ClearMessages());
        }
        });
      } else {
        emit(state.copyWith(
          status: UserManagementStatus.error,
          errorMessage: result['message'] as String,
        ));
        // 🔥 مسح رسالة الخطأ تلقائياً بعد 5 ثواني
        Future.delayed(const Duration(seconds: 5), () {
        if (state.errorMessage == result['message']) {
          add(const ClearMessages());
          }
        });
      }
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        errorMessage: 'فشل في استيراد المستخدمين: ${e.toString()}',
      ));
      // 🔥 مسح رسالة الخطأ تلقائياً بعد 5 ثواني
      Future.delayed(const Duration(seconds: 5), () {
      add(const ClearMessages());
      });
    }
  }

  Future<void> _onAddUser(
    AddUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await userRepository.addUser(event.user);
      final users = await userRepository.getAllUsers();
      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        errorMessage: 'فشل في إضافة المستخدم: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await userRepository.updateUser(event.user, event.originalUserID);
      final users = await userRepository.getAllUsers();
      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await userRepository.deleteUser(event.userId);
      final users = await userRepository.getAllUsers();
      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        errorMessage: 'فشل في حذف المستخدم: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    print('🎯 استلام طلب البحث: "${event.searchTerm}"');
  
    if (event.searchTerm.isEmpty) {
    print('📭 مسح نتائج البحث');
      emit(state.copyWith(
        isSearching: false,
        searchResults: [],
      ));
      return;
    }

    emit(state.copyWith(isSearching: true));
    try {
      // 🔥 البحث محلياً في البيانات المحملة بدلاً من قاعدة البيانات
    final searchTerm = event.searchTerm.toLowerCase();
    print('🔎 البحث عن: "$searchTerm" في ${state.users.length} مستخدم');
    final results = state.users.where((user) {
      final nameMatch = user.name.toLowerCase().contains(searchTerm);
      final emailMatch = user.email.toLowerCase().contains(searchTerm);
      final idMatch = user.userID.toLowerCase().contains(searchTerm);
      final roleMatch = user.role.toLowerCase().contains(searchTerm);
      
      final found = nameMatch || emailMatch || idMatch || roleMatch;
      
      if (found) {
        print('✅ وجد مستخدم: ${user.name} (${user.userID})');
      }
      
      return found;
    }).toList();
    print('📊 نتائج البحث: ${results.length} مستخدم');
      emit(state.copyWith(
        searchResults: results,
        isSearching: false,
      ));
    } catch (e) {
    print('❌ خطأ في البحث: $e');
      emit(state.copyWith(
        isSearching: false,
        errorMessage: 'فشل في البحث: ${e.toString()}',
      ));
    }
  }

  // 🔥 دالة  لمسح الرسائل
  void _onClearMessages(
    ClearMessages event,
    Emitter<UserManagementState> emit,
  ) {
    emit(state.copyWith(
      errorMessage: '',
      successMessage: '',
    ));
  }
}