part of 'user_management_bloc.dart';

enum UserManagementStatus { initial, loading, success, error }

class UserManagementState extends Equatable {
  final UserManagementStatus status;
  final List<UserModels> users;
  final String errorMessage;
  final String successMessage;
  final bool isSearching;
  final List<UserModels> searchResults;

  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.isSearching = false,
    this.searchResults = const [],
  });

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<UserModels>? users,
    String? errorMessage,
    String? successMessage,
    bool? isSearching,
    List<UserModels>? searchResults,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object> props() => [
        status,
        users,
        errorMessage,
        successMessage,
        isSearching,
        searchResults,
      ];
}