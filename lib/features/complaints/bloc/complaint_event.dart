part of 'complaint_bloc.dart';

abstract class ComplaintEvent extends Equatable {
  const ComplaintEvent();

  @override
  List<Object> get props => [];
}

class SendComplaintEvent extends ComplaintEvent {
  final ComplaintModel complaint;
  const SendComplaintEvent(this.complaint);

  @override
  List<Object> get props => [complaint];
}

class LoadStudentComplaintsEvent extends ComplaintEvent {
  final String studentID;
  const LoadStudentComplaintsEvent(this.studentID);

  @override
  List<Object> get props => [studentID];
}

class LoadRoleComplaintsEvent extends ComplaintEvent {
  final String targetRole;
  const LoadRoleComplaintsEvent(this.targetRole);

  @override
  List<Object> get props => [targetRole];
}

class UpdateComplaintStatusEvent extends ComplaintEvent {
  final String complaintId;
  final String status;
  final String? adminReply;
  final String? assignedAdmin;

  const UpdateComplaintStatusEvent({
    required this.complaintId,
    required this.status,
    this.adminReply,
    this.assignedAdmin,
  });

  @override
  List<Object> get props => [complaintId, status];
}

class DeleteComplaintEvent extends ComplaintEvent {
  final String complaintId;
  const DeleteComplaintEvent(this.complaintId);

  @override
  List<Object> get props => [complaintId];
}