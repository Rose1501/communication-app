import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UserInitial()) {
    on<GetUserById>(_onGetUserById);
    on<GetUsersByIdsOrRole>(_onGetUsersByIdsOrRole);
  }

  Future<void> _onGetUserById(GetUserById event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserByUserID(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onGetUsersByIdsOrRole(GetUsersByIdsOrRole event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _userRepository.getUsersByRoleOrIds(
        userIds: event.userIds,
        role: event.role,
      );
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}