import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:user_repository/user_repository.dart';

/// 🛠️ خدمة معالجة عمليات الشكاوى
/// 🎯 تجميع العمليات المشتركة في مكان واحد
class ComplaintsService {
  
  /// ✏️ تحديث حالة الشكوى
  static void updateComplaintStatus({
    required BuildContext context,
    required String complaintId,
    required String newStatus,
    String? adminReply,
    required String assignedAdmin,
  }) {
    context.read<ComplaintBloc>().add(
      UpdateComplaintStatusEvent(
        complaintId: complaintId,
        status: newStatus,
        adminReply: adminReply,
        assignedAdmin: assignedAdmin,
      ),
    );
  }

  /// 🗑️ حذف الشكوى
  static void deleteComplaint({
    required BuildContext context,
    required String complaintId,
  }) {
    context.read<ComplaintBloc>().add(DeleteComplaintEvent(complaintId));
  }

  /// 🔄 إعادة توجيه الشكوى
  static void reassignComplaint({
    required BuildContext context,
    required String complaintId,
    required String newTargetRole,
    required UserModels user,
  }) {
    context.read<ComplaintBloc>().add(
      UpdateComplaintStatusEvent(
        complaintId: complaintId,
        status: 'pending',
        assignedAdmin: user.name,
      ),
    );
  }

  /// 📥 تحميل الشكاوى حسب الدور
  static void loadComplaintsByRole({
    required BuildContext context,
    required UserModels user,
  }) {
    final complaintBloc = context.read<ComplaintBloc>();
    
    if (user.role == 'Admin') {
      complaintBloc.add(LoadRoleComplaintsEvent('Admin'));
    } else if (user.role == 'Manager') {
      complaintBloc.add(LoadRoleComplaintsEvent('Manager'));
    } else {
      complaintBloc.add(LoadStudentComplaintsEvent(user.userID));
    }
  }
}