part of 'request_bloc.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object> props() => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestSuccess extends RequestState {}

class RequestFailure extends RequestState {
  final String error;
  const RequestFailure({required this.error});

  @override
  List<Object> props() => [error];
}

class StudentRequestsLoaded extends RequestState {
  final List<StudentRequestModel> requests;
  const StudentRequestsLoaded({required this.requests});

  @override
  List<Object> props() => [requests];
}

class AllRequestsLoaded extends RequestState {
  final List<StudentRequestModel> requests;
  const AllRequestsLoaded({required this.requests});

  @override
  List<Object> props() => [requests];
}