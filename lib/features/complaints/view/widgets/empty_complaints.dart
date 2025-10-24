import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/text_style.dart';

// مكون الواجهة الفارغة للشكاوى
class EmptyComplaintsWidget extends StatelessWidget {
  final String userRole;

  const EmptyComplaintsWidget({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: font16black,
          ),
          const SizedBox(height: 8),
          if (userRole == 'Student' || userRole == 'Doctor')
            Text(
              'انقر على + لإضافة شكوى جديدة',
              style: font14grey,
            ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (userRole) {
      case 'Student':
        return 'لا توجد شكاوى لعرضها';
      case 'Doctor':
        return 'لا توجد شكاوى لعرضها';
      case 'Manager':
        return 'لا توجد شكاوى موجهة إليك';
      case 'Admin':
        return 'لا توجد شكاوى في النظام';
      default:
        return 'لا توجد شكاوى لعرضها';
    }
  }
}