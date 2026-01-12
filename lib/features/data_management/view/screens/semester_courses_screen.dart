import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/view/screens/course_setup_screen.dart';
import 'package:myproject/features/data_management/view/widgets/semester_courses_list.dart';
/*
 * 🎯 شاشة عرض وإدارة مواد الفصل الحالي
 * 
 * الوظائف:
 * ✅ عرض معلومات الفصل الحالي
 * ✅ قائمة مواد الفصل مع إمكانية التعديل
 * ✅ إضافة مادة جديدة للفصل
 * ✅ التوجيه لشاشة إعداد المادة (CourseSetupScreen)
 * 
 * تسلسل العمل:
 * 1. تحميل الفصل الحالي ومواده ← SemesterCoursesBloc
 * 2. عرض البطاقات القابلة للنقر للتعديل
 * 3. زر الإضافة ← CourseSetupScreen
 */
class SemesterCoursesScreen extends StatefulWidget {
  const SemesterCoursesScreen({super.key});

  @override
  State<SemesterCoursesScreen> createState() => _SemesterCoursesScreenState();
}

class _SemesterCoursesScreenState extends State<SemesterCoursesScreen> {
  bool _isSemesterInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    print('🚀 بدء تحميل بيانات مواد الفصل');
    context.read<SemesterCoursesBloc>().add(const LoadSemesterCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: 'مواد الفصل الدراسي'),
      body: BlocConsumer<SemesterCoursesBloc, SemesterCoursesState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            ShowWidget.showMessage(
              context,
              state.errorMessage,
              Colors.red,
              font15White,
            );
            // 🔥 تنظيف الرسالة بعد العرض
            _clearMessages();
          }
          if (state.successMessage.isNotEmpty) {
            ShowWidget.showMessage(
              context,
              state.successMessage,
              Colors.green,
              font15White,
            );
            // 🔥 تنظيف الرسالة بعد العرض
            _clearMessages();
          }
        },
        builder: (context, state) {
          print('🎨 بناء واجهة مواد الفصل - الحالة: ${state.status}');
          print('📊 عدد مواد الفصل: ${state.semesterCourses.length}');
          print('📊 عدد المواد المتاحة: ${state.filteredCourses.length}');
          
          return Column(
            children: [
              // معلومات الفصل الحالي
              _buildSemesterInfo(state),
              // قائمة مواد الفصل
              Expanded(
                child: SemesterCoursesList(
                  courses: state.semesterCourses,
                  isLoading: state.status == SemesterCoursesStatus.loading,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseSetupScreen(context),
        backgroundColor: ColorsApp.primaryColor,
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }

// ✅ دالة مساعدة لمسح الرسائل
  void _clearMessages() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<SemesterCoursesBloc>().add(const ClearMessagesSemester());
      }
    });
  }

  Widget _buildSemesterInfo(SemesterCoursesState state) {
    if (state.currentSemester == null) {
      return _buildNoSemesterInfo();
    }
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.all(16.r),
      child: Column(
        children: [
          // 🔥 رأس قابل للنقر
          InkWell(
            onTap: () {
              setState(() {
                _isSemesterInfoExpanded = !_isSemesterInfoExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: ColorsApp.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSemesterInfoExpanded ? Icons.expand_less : Icons.expand_more,
                    color: ColorsApp.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'الفصل الدراسي الحالي: ${state.currentSemester!.typeSemester}',
                      style: font16blackbold,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          
          // 🔥 محتوى قابل للطي
          if (_isSemesterInfoExpanded) ...[
            SizedBox(height: 8.h),
            _buildExpandedSemesterInfo(state),
          ],
        ],
      ),
    );
  }

Widget _buildNoSemesterInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لا يوجد فصل دراسي نشط حالياً',
            style: font16blackbold,
          ),
          getHeight(8),
          Text(
            'يرجى إنشاء فصل دراسي جديد أو تفعيل فصل موجود',
            style: font14grey,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSemesterInfo(SemesterCoursesState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('الفترة:', '${_formatDate(state.currentSemester!.startTime)} - ${_formatDate(state.currentSemester!.endTime)}'),
          _buildInfoRow('الساعات المعتمدة:', '${state.currentSemester!.minCredits} - ${state.currentSemester!.maxCredits}'),
          _buildInfoRow('المواد المضافة:', '${state.semesterCourses.length} مادة'),
          _buildInfoRow('الحالة:', state.currentSemester!.isActive ? 'نشط' : 'منتهي'),
        ],
      ),
    );
  }
Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: font14black.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: font14grey,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCourseSetupScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<SemesterCoursesBloc>(),
          child: CourseSetupScreen(
            semesterId: context.read<SemesterCoursesBloc>().state.currentSemester?.id ?? '',
          ),
        ),
      ),
    );
  }
}