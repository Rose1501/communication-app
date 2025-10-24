import 'package:flutter/material.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:myproject/features/complaints/view/widgets/complaint_card.dart';
import 'package:user_repository/user_repository.dart';

class ComplaintsList extends StatelessWidget {
  final List<ComplaintModel> complaints;
  final UserModels user;
  final ScrollController scrollController;
  final bool showStats;

  const ComplaintsList({
    super.key,
    required this.complaints,
    required this.user,
    required this.scrollController,
    required this.showStats,
  });

  @override
  Widget build(BuildContext context) {
    print('📜 بناء ComplaintsList بعدد ${complaints.length} شكوى');
    final isAdminOrManager = user.role == 'Admin' || user.role == 'Manager';
    final sortedComplaints = _sortComplaintsByDate(complaints);
    print('🎯 الشكاوى المرتبة: ${sortedComplaints.length}');

    return ListView.builder(
      padding: EdgeInsets.only(
        top: isAdminOrManager ? (showStats ? 280 : 80) : 0,
      ),
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedComplaints.length,
      itemBuilder: (context, index) {
        final complaint = sortedComplaints[index];
        print('🔄 بناء بطاقة الشكوى $index: ${complaint.id}');
        
        try {
          return ComplaintCard(
            complaint: complaint,
            currentUser: user,
            onStatusUpdate: (newStatus, adminReply) => _handleStatusUpdate(complaint.id, newStatus, adminReply, context),
            onDelete: () => _handleDelete(complaint.id, context),
            onReassign: (newTargetRole) => _handleReassign(complaint.id, newTargetRole, context),
          );
        } catch (e) {
          print('❌ خطأ في بناء بطاقة الشكوى $index: $e');
          return Container(
            height: 100,
            color: Colors.red[100],
            child: Center(
              child: Text('خطأ في عرض الشكوى: ${e.toString()}'),
            ),
          );
        }
      },
    );
  }

  List<ComplaintModel> _sortComplaintsByDate(List<ComplaintModel> complaints) {
    return List<ComplaintModel>.from(complaints)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _handleStatusUpdate(String complaintId, String newStatus, String? adminReply, BuildContext context) {
    context.read<ComplaintBloc>().add(
      UpdateComplaintStatusEvent(
        complaintId: complaintId,
        status: newStatus,
        adminReply: adminReply,
        assignedAdmin: 'System',
      ),
    );
  }

  void _handleDelete(String complaintId, BuildContext context) {
    context.read<ComplaintBloc>().add(DeleteComplaintEvent(complaintId));
  }

  void _handleReassign(String complaintId, String newTargetRole, BuildContext context) {
    context.read<ComplaintBloc>().add(
      UpdateComplaintStatusEvent(
        complaintId: complaintId,
        status: 'pending', // إعادة تعيين الحالة إلى في الانتظار
        assignedAdmin: user.name,
      ),
    );
  }
}