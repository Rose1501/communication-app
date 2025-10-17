import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/request/view/widget/admin_reply_dialog.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';

class ReplyRequestService {
  // 🔥 عرض حوار الرد للطالب
  static Future<void> showAdminReplyDialog({
    required BuildContext context,
    required String requestId,
    required String studentName,
    required String requestType,
    required String currentStatus,
    required String? existingReply,
  }) async {
    final isConnected = await RequestUtils.checkInternetConnection(context);
    if (!isConnected) {
      return;
    }
    final scaffoldContext = context;
    showDialog(
      context: context,
      builder: (context) => AdminReplyDialog(
        studentName: studentName,
        requestType: requestType,
        currentStatus: currentStatus,
        existingReply: existingReply,
        onReplySubmitted: (newStatus, adminReply) {
          _updateRequestWithReply(
            scaffoldContext: scaffoldContext,
            requestId: requestId,
            newStatus: newStatus,
            adminReply: adminReply,
            studentName: studentName,
            isEditing: existingReply != null,
          );
        },
      ),
    );
  }

  // 🔥 تحديث الطلب مع الرد
  static Future<void> _updateRequestWithReply({
    required BuildContext scaffoldContext,
    required String requestId,
    required String newStatus,
    required String adminReply,
    required String studentName,
    required bool isEditing,
  }) async {
    final isConnected = await RequestUtils.checkInternetConnection(scaffoldContext);
    if (!isConnected) {
      return;
    }
    try {
      scaffoldContext.read<RequestBloc>().add(
        UpdateRequestStatusEvent(requestId, newStatus, adminReply: adminReply.isNotEmpty ? adminReply : null),
      );

      String message = '';
      if (isEditing) {
        message = adminReply.isNotEmpty 
            ? 'تم تحديث رد الطالب بنجاح'
            : 'تم حذف رد الطالب بنجاح';
      } else {
        message = 'تم ${newStatus == 'موافقة' ? 'الموافقة' : 'الرفض'} على الطلب';
        if (adminReply.isNotEmpty) {
          message += ' وإرسال الرد للطالب';
        }
      }

      ShowWidget.showMessage(
        scaffoldContext,
        message,
        newStatus == 'موافقة' ? Colors.green : Colors.red,
        const TextStyle(color: Colors.white, fontSize: 13),
      );
    } catch (e) {
      ShowWidget.showMessage(
        scaffoldContext,
        'فشل في تحديث حالة الطلب',
        Colors.red,
        const TextStyle(color: Colors.white, fontSize: 13),
      );
    }
  }

  // 🔥 عرض حوار تأكيد تغيير الحالة
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String studentName,
    required String requestType,
    required String newStatus,
  }) async {
    final statusText = newStatus == 'موافقة' ? 'الموافقة على' : 'رفض';
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإجراء'),
        content: Text('هل أنت متأكد من $statusText طلب $requestType للطالب $studentName؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              newStatus == 'موافقة' ? 'موافقة' : 'رفض',
              style: TextStyle(
                color: newStatus == 'موافقة' ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  // 🔥 تغيير حالة الطلب
  static Future<void> updateRequestStatus({
    required BuildContext context,
    required String requestId,
    required String studentName,
    required String requestType,
    required String newStatus,
  }) async {
    final isConnected = await RequestUtils.checkInternetConnection(context);
    if (!isConnected) {
      return;
    }
    final confirmed = await showConfirmationDialog(
      context: context,
      studentName: studentName,
      requestType: requestType,
      newStatus: newStatus,
    );

    if (confirmed) {
      try {
        context.read<RequestBloc>().add(
          UpdateRequestStatusEvent(requestId, newStatus),
        );

        ShowWidget.showMessage(
          context,
          'تم ${newStatus.toLowerCase()} الطلب بنجاح',
          newStatus == 'موافقة' ? Colors.green : Colors.red,
          const TextStyle(color: Colors.white, fontSize: 13),
        );
      } catch (e) {
        ShowWidget.showMessage(
          context,
          'فشل في تحديث حالة الطلب',
          Colors.red,
          const TextStyle(color: Colors.white, fontSize: 13),
        );
      }
    }
  }

  // 🔥 عرض حوار تأكيد حذف جميع الطلبات
  static Future<bool> showDeleteAllConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الطلبات'),
        content: const Text(
          'هل أنت متأكد من حذف جميع الطلبات؟\n\nهذا الإجراء لا يمكن التراجع عنه وسيتم حذف جميع الطلبات بما في ذلك التي تمت الموافقة عليها أو رفضها.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    ) ?? false;
  }

  // 🔥 حذف جميع الطلبات
  static Future<void> deleteAllRequests(BuildContext context) async {
    final isConnected = await RequestUtils.checkInternetConnection(context);
    if (!isConnected) {
      return;
    }

    final confirmed = await showDeleteAllConfirmationDialog(context);
    if (confirmed) {
      try {
        context.read<RequestBloc>().add(DeleteAllRequestsEvent());

        ShowWidget.showMessage(
          context,
          'تم حذف جميع الطلبات بنجاح',
          Colors.green,
          const TextStyle(color: Colors.white, fontSize: 13),
        );
      } catch (e) {
        ShowWidget.showMessage(
          context,
          'فشل في حذف جميع الطلبات',
          Colors.red,
          const TextStyle(color: Colors.white, fontSize: 13),
        );
      }
    }
  }
}