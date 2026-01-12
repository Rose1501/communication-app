// features/user_management/bloc/user_management_event.dart
part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object> props() => [];
}

class LoadAllUsers extends UserManagementEvent {
  const LoadAllUsers();
}

class ImportUsersFromExcel extends UserManagementEvent {
  final List<Map<String, dynamic>> excelData;
  const ImportUsersFromExcel(this.excelData);
}

class AddUser extends UserManagementEvent {
  final UserModels user;
  const AddUser(this.user);
}

class UpdateUser extends UserManagementEvent {
  final UserModels user;
  final String originalUserID;
  const UpdateUser({required this.user, required this.originalUserID});
  @override
  List<Object> props() => [user, originalUserID];
}

class DeleteUser extends UserManagementEvent {
  final String userId;
  const DeleteUser(this.userId);
}

class SearchUsers extends UserManagementEvent {
  final String searchTerm;
  const SearchUsers(this.searchTerm);
}

class ClearMessages extends UserManagementEvent {
  const ClearMessages();
}