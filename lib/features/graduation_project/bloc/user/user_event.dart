part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object>  props() => [];
}

class GetUserById extends UserEvent {
  final String userId;
  const GetUserById(this.userId);

  @override
  List<Object>  props() => [userId];
}


class GetUsersByIdsOrRole extends UserEvent {
  final String? role;
  final List<String>? userIds;

  const GetUsersByIdsOrRole({this.role, this.userIds});

  @override
  List<Object> props() => [role!, userIds!];
}