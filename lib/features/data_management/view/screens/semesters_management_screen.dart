import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/add_semester_dialog.dart';
import 'package:myproject/features/data_management/view/widgets/delete_semester_dialog.dart';
import 'package:myproject/features/data_management/view/widgets/edit_semester_dialog.dart';
import 'package:myproject/features/data_management/view/widgets/semesters_list.dart';
import 'package:semester_repository/semester_repository.dart';

/*
 * 📅 شاشة إدارة الفصول الدراسية
 * 
 * الوظائف:
 * ✅ عرض جميع الفصول
 * ✅ إنشاء فصل جديد
 * ✅ فلترة الفصول (نشط، منتهي، قادم)
 * ✅ تعديل وحذف الفصول
 * 
 */

class SemestersManagementScreen extends StatefulWidget {
  const SemestersManagementScreen({super.key});

  @override
  State<SemestersManagementScreen> createState() => _SemestersManagementScreenState();
}

class _SemestersManagementScreenState extends State<SemestersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  /// 🔄 تحميل الفصول الدراسية من قاعدة البيانات
  void _loadSemesters() {
    context.read<DataManagementBloc>().add(const LoadSemesters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الفصول الدراسية',
          style: font18blackbold.copyWith(color: ColorsApp.white),
        ),
        backgroundColor: ColorsApp.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.sp),
            onPressed: _loadSemesters,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // 🔍 شريط البحث والتصفية
            _buildSearchAndFilter(),
            SizedBox(height: 16.h),
            
            // 📋 قائمة الفصول
            Expanded(
              child: BlocBuilder<DataManagementBloc, DataManagementState>(
                builder: (context, state) {
                  if (state.status == DataManagementStatus.loading) {
                    return _buildLoadingState();
                  }
                  
                  final filteredSemesters = _filterSemesters(state.semesters);
                  return SemestersList(
                    semesters: filteredSemesters,
                    onEditSemester: _showEditSemesterDialog,
                    onDeleteSemester: _showDeleteConfirmation,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSemesterDialog(context),
        backgroundColor: ColorsApp.primaryColor,
        child: Icon(Icons.add, color: ColorsApp.white, size: 24.sp),
      ),
    );
  }

  /// 🎨 بناء واجهة البحث والتصفية
  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // 🔍 حقل البحث
        Expanded(
          child: CustomTextFiled(
            hintText: 'ابحث عن فصل...',
            iconData: Icons.search,
            controller: _searchController,
            onChanged: (value) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        
        // 📊 قائمة التصفية
        Container(
          width: 120.w,
          child: CustomDropdown(
            items: const ['الكل', 'نشط', 'منتهي', 'قادم'],
            hint: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value ?? 'الكل';
              });
            },
          ),
        ),
      ],
    );
  }

  /// ⏳ بناء واجهة التحميل
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          SizedBox(height: 16.h),
          Text('جاري تحميل الفصول...', style: font16black),
        ],
      ),
    );
  }

  /// 🔍 فلترة الفصول حسب البحث والتصفية
  List<SemesterModel> _filterSemesters(List<SemesterModel> semesters) {
    final now = DateTime.now();
    return semesters.where((semester) {
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch = semester.typeSemester.toLowerCase().contains(searchTerm);
      
      final matchesFilter = _selectedFilter == 'الكل' ||
          (_selectedFilter == 'نشط' && semester.isActive) ||
          (_selectedFilter == 'منتهي' && semester.endTime.isBefore(now)) ||
          (_selectedFilter == 'قادم' && semester.startTime.isAfter(now));
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// ➕ عرض نافذة إضافة فصل جديد
  void _showAddSemesterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSemesterDialog(),
    );
  }

  /// ✏️ عرض نافذة تعديل فصل
  void _showEditSemesterDialog(SemesterModel semester) {
    showDialog(
      context: context,
      builder: (context) => EditSemesterDialog(semester: semester),
    );
  }

  /// 🗑️ عرض تأكيد حذف فصل
  void _showDeleteConfirmation(SemesterModel semester) {
    showDialog(
      context: context,
      builder: (context) => DeleteSemesterDialog(semester: semester),
    );
  }
}