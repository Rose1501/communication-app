import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:complaint_repository/complaint_repository.dart';

part 'complaint_event.dart';
part 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository _complaintRepository;

  ComplaintBloc({required ComplaintRepository complaintRepository})
      : _complaintRepository = complaintRepository,
        super(ComplaintInitial()) {
    on<SendComplaintEvent>(_onSendComplaint);
    on<LoadStudentComplaintsEvent>(_onLoadStudentComplaints);
    on<LoadRoleComplaintsEvent>(_onLoadRoleComplaints);
    on<UpdateComplaintStatusEvent>(_onUpdateComplaintStatus);
    on<DeleteComplaintEvent>(_onDeleteComplaint);
  }
// ➕ إرسال شكوى جديدة
  Future<void> _onSendComplaint(
    SendComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintLoading());
    try {
      final savedComplaint = await _complaintRepository.sendComplaint(event.complaint);
      print('✅ تم إرسال الشكوى بنجاح: ${savedComplaint.id}');
      emit(ComplaintSuccess());
      // إعادة تحميل الشكاوى بعد الإرسال
      add(LoadStudentComplaintsEvent(event.complaint.studentID));
    } catch (e) {
      print('❌ فشل إرسال الشكوى: $e');
      emit(ComplaintFailure(error: e.toString()));
    }
  }
 // 👤 تحميل شكاوى طالب
  Future<void> _onLoadStudentComplaints(
    LoadStudentComplaintsEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintLoading());
    try {
      final complaints = await _complaintRepository.getStudentComplaints(event.studentID);
      print('✅ تم جلب ${complaints.length} شكوى للطالب: ${event.studentID}');
      emit(StudentComplaintsLoaded(complaints: complaints));
    } catch (e) {
      print('❌ فشل جلب شكاوى الطالب: $e');
      emit(ComplaintFailure(error: e.toString()));
    }
  }
// 🎯 تحميل شكاوى حسب الدور
  Future<void> _onLoadRoleComplaints(
    LoadRoleComplaintsEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintLoading());
    print('🔄 جاري تحميل الشكاوى للدور: ${event.targetRole}');
    try {
      final complaints = await _complaintRepository.getComplaintsForRole(event.targetRole);
      print('✅ تم جلب ${complaints.length} شكوى موجهة لـ: ${event.targetRole}');
      emit(RoleComplaintsLoaded(complaints: complaints));
      print('🎯 تم إصدار حالة RoleComplaintsLoaded');
    } catch (e) {
      print('❌ فشل جلب الشكاوى الموجهة: $e');
      emit(ComplaintFailure(error: e.toString()));
    }
  }

// ✏️ تحديث حالة الشكوى
  Future<void> _onUpdateComplaintStatus(
    UpdateComplaintStatusEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      await _complaintRepository.updateComplaintStatus(
        complaintId: event.complaintId,
        status: event.status,
        adminReply: event.adminReply,
        assignedAdmin: event.assignedAdmin,
      );
      print('✅ تم تحديث حالة الشكوى بنجاح');
    
    // 🔥 التصحيح: إعادة تحميل الشكاوى المناسبة حسب الحالة الحالية
    if (state is StudentComplaintsLoaded) {
      final currentState = state as StudentComplaintsLoaded;
      add(LoadStudentComplaintsEvent(currentState.complaints.first.studentID));
    } else if (state is RoleComplaintsLoaded) {
      final currentState = state as RoleComplaintsLoaded;
      add(LoadRoleComplaintsEvent(currentState.complaints.first.targetRole));
    } else {
      add(LoadRoleComplaintsEvent('Admin'));
    }
    
    } catch (e) {
      emit(ComplaintFailure(error: e.toString()));
    }
  }
// 🗑️ حذف شكوى
  Future<void> _onDeleteComplaint(
    DeleteComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      await _complaintRepository.deleteComplaint(event.complaintId);
      // إعادة تحميل الشكاوى بعد الحذف
      if (state is StudentComplaintsLoaded) {
        final currentState = state as StudentComplaintsLoaded;
        if (currentState.complaints.isNotEmpty) {
          add(LoadStudentComplaintsEvent(currentState.complaints.first.studentID));
        }
      }
    } catch (e) {
      emit(ComplaintFailure(error: e.toString()));
    }
  }
}