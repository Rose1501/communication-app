part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object> props() => [];
}

class SendRequestEvent extends RequestEvent {
  final StudentRequestModel request;
  const SendRequestEvent(this.request);

  @override
  List<Object> props() => [request];
}

class LoadStudentRequestsEvent extends RequestEvent {
  final String studentID;
  const LoadStudentRequestsEvent(this.studentID);

  @override
  List<Object> props() => [studentID];
}

class LoadAllRequestsEvent extends RequestEvent {}

class UpdateRequestStatusEvent extends RequestEvent {
  final String requestId;
  final String status;
  final String? adminReply;
  const UpdateRequestStatusEvent(this.requestId, this.status, {this.adminReply});

  @override
  List<Object> props() => [requestId, status];
}

class DeleteRequestEvent extends RequestEvent {
  final String requestId;
  final String studentID;
  const DeleteRequestEvent(this.requestId, this.studentID);

  @override
  List<Object> props() => [requestId, studentID];
}

// 🔥  لحذف جميع الطلبات
class DeleteAllRequestsEvent extends RequestEvent {}