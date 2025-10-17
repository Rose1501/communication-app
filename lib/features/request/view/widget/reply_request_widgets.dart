import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';
import 'package:request_repository/request_repository.dart';

class ReplyRequestWidgets {
  // 🔥 بطاقة الطلب الفردية
  static Widget buildRequestCard({
    required StudentRequestModel  request,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required BuildContext context,
    required VoidCallback onReply,
  }) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطالب
            _buildStudentInfo(request),
            const SizedBox(height: 16),
            // تفاصيل الطلب
            _buildRequestDetails(request),
            const SizedBox(height: 16),
            // أزرار الموافقة والرفض
            _buildActionButtons(
              request: request,
              onApprove: onApprove,
              onReject: onReject,
              onReply: onReply,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 معلومات الطالب
  static Widget _buildStudentInfo(StudentRequestModel request) {
    return Row(
      children: [
        // صورة الطالب
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ColorsApp.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: ColorsApp.primaryLight,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'رقم القيد: ${request.studentID}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // حالة الطلب
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: RequestUtils.getStatusColor(request.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: RequestUtils.getStatusColor(request.status),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                RequestUtils.getStatusIcon(request.status),
                size: 16,
                color: RequestUtils.getStatusColor(request.status),
              ),
              const SizedBox(width: 5),
              Text(
                request.status,
                style: TextStyle(
                  color: RequestUtils.getStatusColor(request.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 تفاصيل الطلب
  static Widget _buildRequestDetails(StudentRequestModel request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نوع الطلب
          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                'نوع الطلب:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.requestType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // وصف الطلب
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description,
                size: 16,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وصف الطلب:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // تاريخ الطلب
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'التاريخ: ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                RequestUtils.formatDate(request.dateTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 🔥 قسم رد الإدمن (إذا وجد)
        if (request.hasAdminReply) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'رد :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request.adminReply!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

  // 🔥 أزرار الموافقة والرفض
  static Widget _buildActionButtons({
    required StudentRequestModel request,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required VoidCallback onReply,
    required BuildContext context,
  }) {
    final isPending = request.status == 'انتظار';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isPending) 
        IconButton(
          onPressed: onReply,
          icon: Icon(
            request.hasAdminReply ? Icons.edit : Icons.reply,
            color: Colors.blue,
          ),
          tooltip: request.hasAdminReply ? 'تعديل رد الطالب' : 'إرسال رد للطالب',
        ),

        if (isPending) ...[
          // زر الرفض
          ElevatedButton.icon(
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('رفض'),
          ),
          const SizedBox(width: 12),
          // زر الموافقة
          ElevatedButton.icon(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('موافقة'),
          ),
        ] else ...[
          // عرض الحالة الحالية إذا لم تكن في حالة انتظار
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: RequestUtils.getStatusColor(request.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RequestUtils.getStatusColor(request.status)),
            ),
            child: Row(
              children: [
                Icon(
                  RequestUtils.getStatusIcon(request.status),
                  size: 18,
                  color: RequestUtils.getStatusColor(request.status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(request.status),
                  style: TextStyle(
                    color: RequestUtils.getStatusColor(request.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 🔥 نص الحالة
  static String _getStatusText(String status) {
    switch (status) {
      case 'موافقة':
        return 'تمت الموافقة على الطلب';
      case 'رفض':
        return 'تم رفض الطلب';
      case 'انتظار':
        return 'في انتظار المراجعة';
      default:
        return status;
    }
  }

  // 🔥 شاشة التحميل
  static Widget buildLoadingWidget() {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor,),
          SizedBox(height: 16),
          Text(
            'جاري تحميل الطلبات...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔥 شاشة الخطأ
  static Widget buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل الطلبات',
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 شاشة لا توجد طلبات
  static Widget buildEmptyRequests() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد طلبات جديدة تحتاج إلى مراجعة',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // يمكن إضافة هذه الدالة إذا أردت رسالة مخصصة لكل حالة
static Widget buildEmptyFilteredRequests(String filter) {
  Map<String, Map<String, String>> messages = {
    'في الانتظار': {
      'icon': '⏳',
      'message': 'لا توجد طلبات في انتظار المراجعة',
      'subMessage': 'جميع الطلبات الحالية تمت معالجتها'
    },
    'تم الموافقة': {
      'icon': '✅',
      'message': 'لا توجد طلبات تمت الموافقة عليها',
      'subMessage': 'لم تتم الموافقة على أي طلب حتى الآن'
    },
    'تم الرفض': {
      'icon': '❌', 
      'message': 'لا توجد طلبات تم رفضها',
      'subMessage': 'لم يتم رفض أي طلب حتى الآن'
    },
    'تم الرد': {
      'icon': '💬',
      'message': 'لا توجد طلبات تم الرد عليها',
      'subMessage': 'لم يتم إضافة رد على أي طلب حتى الآن'
    },
    'الكل': {
      'icon': '📭',
      'message': 'لا توجد طلبات في النظام',
      'subMessage': 'سيظهر هنا الطلبات عندما يقوم الطلاب بإرسالها'
    },
  };

  final data = messages[filter] ?? messages['الكل']!;

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data['icon']!,
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 16),
        Text(
          data['message']!,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['subMessage']!,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
}