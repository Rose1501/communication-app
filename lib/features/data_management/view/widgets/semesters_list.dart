import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:semester_repository/semester_repository.dart';

/*
 * 📋 قائمة عرض الفصول الدراسية
 * 
 * الوظائف:
 * ✅ عرض بطاقات الفصول
 * ✅ إضافة أزرار التعديل والحذف
 * ✅ دعم التفاعل مع الأحداث
 */

class SemestersList extends StatelessWidget {
  final List<SemesterModel> semesters;
  final Function(SemesterModel) onEditSemester;
  final Function(SemesterModel) onDeleteSemester;

  const SemestersList({
    super.key,
    required this.semesters,
    required this.onEditSemester,
    required this.onDeleteSemester,
  });

  @override
  Widget build(BuildContext context) {
    if (semesters.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: semesters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SemesterCard(
            semester: semesters[index],
            onEdit: onEditSemester,
            onDelete: onDeleteSemester,
          ),
        );
      },
    );
  }

  /// 📭 بناء واجهة الحالة الفارغة
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'لا توجد فصول دراسية',
                style: font18blackbold.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                'انقر على زر الإضافة لإنشاء فصل دراسي جديد',
                style: font14grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
 * 🃏 بطاقة عرض الفصل الدراسي
 * 
 * الوظائف:
 * ✅ عرض معلومات الفصل
 * ✅ أزرار التعديل والحذف
 * ✅ عرض حالة الفصل (نشط/منتهي)
 */

class SemesterCard extends StatelessWidget {
  final SemesterModel semester;
  final Function(SemesterModel) onEdit;
  final Function(SemesterModel) onDelete;

  const SemesterCard({
    super.key,
    required this.semester,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: dataManagementCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ رأس البطاقة مع المعلومات الأساسية
          _buildCardHeader(),
          SizedBox(height: 12.h),
          
          // 📊 معلومات إضافية
          _buildCardInfo(),
        ],
      ),
    );
  }

  /// 🏷️ بناء رأس البطاقة
  Widget _buildCardHeader() {
    return Row(
      children: [
        // 🎯 أيقونة الفصل
        Container(
          width: 40.w,
          height: 40.h,
          decoration: borderAllPrimary,
          child: Icon(Icons.calendar_today, 
              color: ColorsApp.primaryColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        
        // 📝 المعلومات الأساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                semester.typeSemester,
                style: font16blackbold,
              ),
              SizedBox(height: 4.h),
              Text(
                '${_formatDate(semester.startTime)} - ${_formatDate(semester.endTime)}',
                style: font14grey,
              ),
            ],
          ),
        ),
        
        // 🏷️ شارة الحالة وأزرار الإجراءات
        Column(
          children: [
            _buildStatusBadge(semester.isActive),
            SizedBox(height: 8.h),
            _buildActionButtons(),
          ],
        ),
      ],
    );
  }

  /// 📊 بناء معلومات البطاقة
  Widget _buildCardInfo() {
    final coursesCount  =semester.courses.length; 
    print("***********************'${coursesCount },coursesCount ");
    return Row(
      children: [
        _buildInfoItem(Icons.credit_card, 
            '${semester.minCredits}-${semester.maxCredits} ساعة'),
        Spacer(),
        if (semester.isActive)
          _buildInfoItem(Icons.access_time, semester.currentWeek),
      ],
    );
  }

  /// 🏷️ بناء شارة حالة الفصل
  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? ColorsApp.green.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? ColorsApp.green : Colors.grey,
        ),
      ),
      child: Text(
        isActive ? 'نشط' : 'منتهي',
        style: TextStyle(
          fontSize: 12.sp,
          color: isActive ? ColorsApp.green : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔘 بناء أزرار الإجراءات
  Widget _buildActionButtons() {
    return Row(
      children: [
        // ✏️ زر التعديل
        IconButton(
          icon: Icon(Icons.edit, size: 18.sp, color: ColorsApp.primaryColor),
          onPressed: () => onEdit(semester),
          tooltip: 'تعديل الفصل',
        ),
        
        // 🗑️ زر الحذف
        IconButton(
          icon: Icon(Icons.delete, size: 18.sp, color: Colors.red),
          onPressed: () => onDelete(semester),
          tooltip: 'حذف الفصل',
        ),
      ],
    );
  }

  /// 📝 بناء عنصر معلومات
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(text, style: font12Grey),
      ],
    );
  }

  /// 📅 تنسيق التاريخ للنص
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}