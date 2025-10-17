import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';

class RequestUtils {
  // 🔥 تنسيق التاريخ مثل الإعلانات
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
    if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} ي';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  // 🔥 التحقق من الاتصال بالإنترنت
  static Future<bool> checkInternetConnection(BuildContext context) async {
    try {
    print('التحقق من الاتصال بالإنترنت');
    final isConnected = await checkInternetconnection();
    if (!isConnected) {
      ShowWidget.showMessage(context, noNet, Colors.black, font11White);
      return false; // ✅ تصحيح: يرجع false عندما لا يوجد اتصال
    }
    return true; // ✅ يرجع true عندما يوجد اتصال
  } catch (e) {
    ShowWidget.showMessage(context, 'خطأ في التحقق من الاتصال', Colors.black, font11White);
    return false;
  }
  }

  // 🔥 ألوان حالة الطلب
  static Color getStatusColor(String status) {
    switch (status) {
      case 'موافقة':
        return Colors.green;
      case 'رفض':
        return Colors.red;
      case 'انتظار':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 🔥 أيقونات حالة الطلب
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'موافقة':
        return Icons.check_circle;
      case 'رفض':
        return Icons.cancel;
      case 'انتظار':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }
}