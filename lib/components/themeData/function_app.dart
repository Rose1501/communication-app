/// فئة مساعدة تحتوي على دوال التحقق من الصحة ودوال مساعدة أخرى للتطبيق
/// هذه الفئة توفر دوال ثابتة (static) يمكن استدعاؤها مباشرة دون إنشاء كائن
/// وتشمل دوال للتحقق من صحة المدخلات ودوال للتعامل dengan التواريخ
class FunctionApp {
  /// التحقق من صحة البريد الإلكتروني
  static String validateEmail(String email) {
    final RegExp pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (email.isEmpty) {
      return 'البريد الإلكتروني لا يمكن أن يكون فارغًا.';
    } else if (!pattern.hasMatch(email)) {
      return 'بريد الإلكتروني غير صالح : yourname@mail.com';
    }
    return '';
  }
/// التحقق من صحة كلمة المرور
  static String validatePassword(String password) {
    return password.isEmpty
        ? 'كلمة المرور لا يمكن ان تكون فارغة'
        : password.length <= 6
            ? 'كلمة سر ضعيفة جدا'
            : '';
  }
/// التحقق من صحة الاسم
  static String validateName(String name) {
    final RegExp pattern = RegExp(r'^[a-zA-Zأ-ي\s]+$');
    if (name.isEmpty) {
      return 'اسم المستخدم لا يمكن أن يكون فارغًا.';
    } else if (!pattern.hasMatch(name)) {
      return 'اسم المستخدم يجب أن يحتوي على حروف فقط';
    }
    return '';
  }
/// التحقق من صحة رقم القيد الطلابي
  static String validateStudentId(String studentId) {
    // نمط للتحقق من أن المدخل يحتوي على أرقام فقط
    final RegExp numericPattern = RegExp(r'^[0-9]+$');
    
    if (studentId.isEmpty) {
      return 'رقم القيد لا يمكن أن يكون فارغًا.';
    } else if (!numericPattern.hasMatch(studentId)) {
      return 'رقم القيد يجب أن يحتوي على أرقام فقط.';
    } else if (studentId.length < 8) {
      return 'رقم القيد يجب أن يكون على الأقل 8 أرقام.';
    } else if (studentId.length > 12) {
      return 'رقم القيد يجب أن لا يتجاوز 12 رقمًا.';
    }
    
    return ''; 
  }
/// تحويل التاريخ إلى صيغة "منذ وقت" (مثل: منذ 5 دقائق، منذ ساعة واحدة)
static String timeAgo(String timeAdv) {
  DateTime dateTime = DateTime.parse(timeAdv);
  Duration difference = DateTime.now().difference(dateTime);

  String prefix = 'منذ ';

  if (difference.inDays > 30) {
    int months = (difference.inDays / 30).floor();
    return '$prefix$months شهر${months > 1 ? "ات" : ""}';
  } else if (difference.inDays > 1) {
    return '$prefix${difference.inDays} يوم';
  } else if (difference.inDays == 1) {
    return '$prefix يوم واحد';
  } else if (difference.inHours > 1) {
    return '$prefix${difference.inHours} ساعة';
  } else if (difference.inHours == 1) {
    return '$prefix ساعة واحدة';
  } else if (difference.inMinutes > 1) {
    return '$prefix${difference.inMinutes} دقيقة';
  } else if (difference.inMinutes == 1) {
    return '$prefix دقيقة واحدة';
  } else {
    return 'الآن';
  }
}
}
