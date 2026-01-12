part of 'complaint_bloc.dart';

abstract class ComplaintState extends Equatable {
  const ComplaintState();

  @override
  List<Object> props() => [];
}

class ComplaintInitial extends ComplaintState {}

class ComplaintLoading extends ComplaintState {}

class ComplaintSuccess extends ComplaintState {}

class ComplaintFailure extends ComplaintState {
  final String error;
  const ComplaintFailure({required this.error});

  @override
  List<Object> props() => [error];
}

class StudentComplaintsLoaded extends ComplaintState {
  final List<ComplaintModel> complaints;
  const StudentComplaintsLoaded({required this.complaints});

  @override
  List<Object> props() => [complaints];
}

class RoleComplaintsLoaded extends ComplaintState {
  final List<ComplaintModel> complaints;
  const RoleComplaintsLoaded({required this.complaints});

  @override
  List<Object> props() => [complaints];
}