import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';

class RequestService {
  // 🔥 إرسال طلب جديد مع التحقق من الإنترنت
  static Future<void> submitRequest({
    required BuildContext context,
    required dynamic request,
    required String studentID,
  }) async {
    // التحقق من الاتصال قبل الإرسال
    final isConnected = await RequestUtils.checkInternetConnection(context);
    if (!isConnected) {
      ShowWidget.showMessage(context, noNet, Colors.black, TextStyle(color: Colors.white, fontSize: 11));
      return;
    }

    try {
      context.read<RequestBloc>().add(SendRequestEvent(request));
      
      ShowWidget.showMessage(
        context,
        'تم إرسال الطلب بنجاح',
        Colors.green,
        TextStyle(color: Colors.white, fontSize: 13),
      );
      
      // إعادة تحميل الطلبات بعد الإرسال
      Future.delayed(Duration(milliseconds: 500), () {
        context.read<RequestBloc>().add(LoadStudentRequestsEvent(studentID));
      });
      
    } catch (e) {
      ShowWidget.showMessage(
        context,
        'فشل في إرسال الطلب',
        Colors.red,
        TextStyle(color: Colors.white, fontSize: 13),
      );
    }
  }

  // 🔥 حذف طلب مع التحقق من الإنترنت
  static Future<void> deleteRequest({
    required BuildContext context,
    required String requestId,
    required String studentID,
  }) async {
    // التحقق من الاتصال قبل الحذف
    final isConnected = await RequestUtils.checkInternetConnection(context);
    if (!isConnected) {
      ShowWidget.showMessage(context, noNet, Colors.black, TextStyle(color: Colors.white, fontSize: 11));
      return;
    }

    try {
      context.read<RequestBloc>().add(DeleteRequestEvent(requestId, studentID));
      
      ShowWidget.showMessage(
        context,
        'تم حذف الطلب بنجاح',
        Colors.green,
        TextStyle(color: Colors.white, fontSize: 13),
      );
      
      // إعادة تحميل الطلبات بعد الحذف
      Future.delayed(Duration(milliseconds: 500), () {
        context.read<RequestBloc>().add(LoadStudentRequestsEvent(studentID));
      });
      
    } catch (e) {
      ShowWidget.showMessage(
        context,
        'فشل في حذف الطلب',
        Colors.red,
        TextStyle(color: Colors.white, fontSize: 13),
      );
    }
  }

  // 🔥 عرض حوار تأكيد الحذف
  static void showDeleteDialog({
    required BuildContext context,
    required String requestId,
    required String studentID,
  }) {
    // 🔥 حفظ الـ Bloc قبل فتح الحوار
  final requestBloc = context.read<RequestBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('حذف الطلب'),
        content: Text('هل أنت متأكد من حذف هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () {
            print('❌ إلغاء حذف الطلب: $requestId');
            Navigator.pop(dialogContext);
            },
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
            print('✅ تأكيد حذف الطلب: $requestId');
            
            // إغلاق الحوار أولاً
            Navigator.pop(dialogContext);
            
            // 🔥 تنفيذ الحذف بعد إغلاق الحوار مباشرة
            _executeDeleteAfterDialog(
              requestBloc: requestBloc,
              requestId: requestId,
              studentID: studentID,
              context: context,
            );
          },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  // 🔥 دالة مساعدة لتنفيذ الحذف بعد إغلاق الحوار
static Future<void> _executeDeleteAfterDialog({
  required RequestBloc requestBloc,
  required String requestId,
  required String studentID,
  required BuildContext context,
}) async {
  // التحقق من الاتصال بالإنترنت
  final isConnected = await RequestUtils.checkInternetConnection(context);
  if (!isConnected) {
    ShowWidget.showMessage(context, noNet, Colors.black, 
        TextStyle(color: Colors.white, fontSize: 11));
    return;
  }
  
  try {
    print('🚀 بدء عملية حذف الطلب...');
    
    // 🔥 استخدام Future.delayed لضمان إغلاق الحوار تماماً
    await Future.delayed(const Duration(milliseconds: 100));
    
    // استدعاء حدث الحذف باستخدام الـ Bloc المحفوظ
    requestBloc.add(DeleteRequestEvent(requestId, studentID));
    
    // إظهار رسالة تأكيد
    ShowWidget.showMessage(
      context,
      'جاري حذف الطلب...',
      Colors.orange,
      TextStyle(color: Colors.white, fontSize: 13),
    );
    
  } catch (e) {
    print('❌ خطأ في استدعاء حذف الطلب: $e');
    ShowWidget.showMessage(
      context,
      'فشل في بدء عملية الحذف',
      Colors.red,
      TextStyle(color: Colors.white, fontSize: 13),
    );
  }
  }
}