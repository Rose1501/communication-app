import 'package:request_repository/request_repository.dart';

class RequestFilterUtils {
  // 🔥 تصفية الطلبات حسب الحالة والوقت
  static List<StudentRequestModel> filterRequests({
    required List<StudentRequestModel> requests,
    required String statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<StudentRequestModel> filteredRequests = requests;

    // التصفية حسب الحالة
    if (statusFilter != 'الكل') {
      filteredRequests = filteredRequests.where((request) {
        switch (statusFilter) {
          case 'في الانتظار':
            return request.status == 'انتظار';
          case 'تم الموافقة':
            return request.status == 'موافقة';
          case 'تم الرفض':
            return request.status == 'رفض';
          case 'تم الرد':
          return request.adminReply != null && request.adminReply!.isNotEmpty;
          default:
            return true;
        }
      }).toList();
    }

    // 🔥 التصفية حسب التاريخ - دعم اليوم الواحد والفترة
    if (startDate != null) {
      filteredRequests = filteredRequests.where((request) {
        final requestDate = request.dateTime;
        
        // تحويل التواريخ إلى بداية اليوم (للتخلص من الوقت)
        final requestDay = DateTime(requestDate.year, requestDate.month, requestDate.day);
        final startDay = DateTime(startDate.year, startDate.month, startDate.day);
        
        // إذا كان هناك تاريخ نهاية (فترة زمنية)
        if (endDate != null && !_isSameDay(startDate, endDate)) {
          final endDay = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
          return requestDay.isAfter(startDay.subtract(const Duration(days: 1)))&& requestDay.isBefore(endDay);
        } else {
          // إذا كان يوم واحد فقط
          return _isSameDay(requestDate, startDate);
        }
      }).toList();
    }

    return filteredRequests;
  }

  // 🔥 التحقق من أن اليوم نفسه
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }

  // 🔥 تنسيق الفترة الزمنية
  static String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'جميع الأوقات';
    if (start != null && end == null) return 'يوم ${_formatDate(start)}';
    if (start == null && end != null) return 'حتى ${_formatDate(end)}';
    
    // إذا كان نفس اليوم (يوم واحد)
    if (_isSameDay(start!, end!)) {
      return 'يوم ${_formatDate(start)}';
    } else {
      // إذا كانت فترة زمنية
      return 'من ${_formatDate(start)} إلى ${_formatDate(end)}';
    }
  }

  static String _formatDate(DateTime date) {
    final monthName = getArabicMonthName(date.month);
    return '${date.day} $monthName ${date.year}';
  }

  // 🔥 الحصول على اسم الشهر بالعربية
  static String getArabicMonthName(int month) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  // 🔥 الحصول على اسم اليوم بالعربية
  static String getArabicDayName(int weekday) {
    final days = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    return days[weekday - 1];
  }
  // 🔥 الحصول على نوع الفلترة
  static String getFilterType(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'جميع الأوقات';
    if (start != null && end == null) return 'يوم محدد';
    if (start == null && end != null) return 'حتى تاريخ';
    if (_isSameDay(start!, end!)) return 'يوم واحد';
    return 'فترة زمنية';
  }
}