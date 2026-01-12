import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/course_import_panel.dart';
import 'package:myproject/features/data_management/view/widgets/courses_list.dart';
import 'package:course_repository/course_repository.dart';
/*
 * 📚 شاشة إدارة المواد الدراسية
 * 
 * الوظائف:
 * ✅ عرض قائمة جميع المواد
 * ✅ إضافة مادة جديدة (FAB)
 * ✅ استيراد مواد من Excel
 * ✅ بحث وفلترة المواد
 * ✅ تعديل وحذف المواد
 * 
 * تسلسل العمل:
 * 1. تحميل المواد تلقائياً ← DataManagementBloc ← CourseRepository
 * 2. عرض المواد في CoursesList
 * 3. زر الإضافة ← AddCourseDialog
 * 4. زر الاستيراد ← CourseImportPanel
 */
class CoursesManagementScreen extends StatefulWidget {
  const CoursesManagementScreen({super.key});

  @override
  State<CoursesManagementScreen> createState() => _CoursesManagementScreenState();
}

class _CoursesManagementScreenState extends State<CoursesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    context.read<DataManagementBloc>().add(const LoadCourses());
  }

  void _showImportCoursesDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: CourseImportPanel(
        onImportSuccess: () {
          Navigator.pop(context);
          _loadCourses(); // إعادة تحميل المواد بعد الاستيراد
        },
      ),
    ),
  );
  }

  // ✅ تحديث عند فتح الشاشة أول مرة
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ تحميل البيانات فقط إذا لم تكن محملة مسبقاً
    if (context.read<DataManagementBloc>().state.courses.isEmpty) {
      _loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة المواد',
          style: font18blackbold.copyWith(color: ColorsApp.white),
        ),
        backgroundColor: ColorsApp.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, size: 24.sp,color: ColorsApp.white,),
            onPressed: () => _showImportCoursesDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // شريط البحث والتصفية
            _buildSearchAndFilter(),
            SizedBox(height: 16.h),
            // قائمة المواد
            Expanded(
              child: BlocBuilder<DataManagementBloc, DataManagementState>(
                builder: (context, state) {
                  if (state.status == DataManagementStatus.loading) {
                    return _buildLoadingState();
                  }
                  
                  final filteredCourses = _filterCourses(state.courses);
                  return CoursesList(courses: filteredCourses);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        backgroundColor: ColorsApp.primaryColor,
        child: Icon(Icons.add, color: ColorsApp.white, size: 24.sp),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
  return Column(
    children: [
      Row(
        children: [
          // 🔍 حقل البحث محسن
          Expanded(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(Icons.search, color: Colors.grey[500]),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن المادة ...',
                        hintStyle: font14grey,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: font14black,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500], size: 20.sp),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // قائمة التصفية
          Container(
            width: 140.w,
            child: CustomDropdown(
              items: const ['الكل', 'لها متطلبات', 'بدون متطلبات'],
              hint: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'الكل';
                });
              },
            ),
          ),
        ],
      ),
      // ✅ مؤشر نتائج البحث محسن
      if (_searchController.text.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 16.sp, color: ColorsApp.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  '${_filterCourses(context.read<DataManagementBloc>().state.courses).length} نتيجة',
                  style: font12Grey.copyWith(color: ColorsApp.primaryColor),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          SizedBox(height: 16.h),
          Text('جاري تحميل المواد...', style: font16black),
        ],
      ),
    );
  }

  List<CourseModel> _filterCourses(List<CourseModel> courses) {
  return courses.where((course) {
    final searchTerm = _searchController.text.toLowerCase();
    
    // ✅ بحث شامل في الاسم، الرمز، والمتطلبات
    final matchesSearch = searchTerm.isEmpty ||
        course.name.toLowerCase().contains(searchTerm) ||
        course.codeCs.toLowerCase().contains(searchTerm) ||
        course.requestCourses.any((prereq) => prereq.toLowerCase().contains(searchTerm));
    
    final matchesFilter = _selectedFilter == 'الكل' ||
        (_selectedFilter == 'لها متطلبات' && course.requestCourses.isNotEmpty) ||
        (_selectedFilter == 'بدون متطلبات' && course.requestCourses.isEmpty);
    
    return matchesSearch && matchesFilter;
  }).toList();
}

  void _showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCourseDialog(),
    );
  }
}

class AddCourseDialog extends StatefulWidget {
  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  List<String> _selectedPrerequisites = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(16.r),
      contentPadding: EdgeInsets.all(24.r),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة مادة جديدة',
                  style: font18blackbold,
                ),
                SizedBox(height: 24.h),
                
                // اسم المادة
                CustomTextFiled(
                  hintText: 'اسم المادة',
                  iconData: Icons.school,
                  controller: _nameController,
                  validator: _validateField,
                ),
                SizedBox(height: 16.h),
                
                // كود المادة
                CustomTextFiled(
                  hintText: 'كود المادة',
                  iconData: Icons.code,
                  controller: _codeController,
                  validator: _validateField,
                ),
                SizedBox(height: 16.h),
                
                // الساعات المعتمدة
                CustomTextFiled(
                  hintText: 'الساعات المعتمدة',
                  iconData: Icons.credit_card,
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  validator: _validateCredits,
                ),
                SizedBox(height: 16.h),
                
                // المتطلبات السابقة
                _buildPrerequisitesSection(context),
                SizedBox(height: 24.h),
                
                // أزرار الحفظ والإلغاء
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إلغاء', style: font15primary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ButtonApp(
                        textData: 'حفظ',
                        onTop: _saveCourse,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrerequisitesSection(BuildContext context) {
    return BlocBuilder<DataManagementBloc, DataManagementState>(
      builder: (context, state) {
        print('🔄 بناء قسم المتطلبات - حالة المواد: ${state.courses.length}');
        final availableCourses = state.courses.where((course) => course.id.isNotEmpty).toList();
        print('🔍 المواد المتاحة: ${availableCourses.length}');
        print('   - ${availableCourses.map((course) => course.name).join('\n   - ')}');
        
        return ConstrainedBox(
          constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المتطلبات السابقة', style: font16blackbold),
                SizedBox(height: 8.h),
                // قائمة المتطلبات المختارة
                if (_selectedPrerequisites.isNotEmpty) ...[
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _selectedPrerequisites.map((prereqCode) {
                      final course = availableCourses.firstWhere(
                        (c) => c.codeCs == prereqCode,
                        orElse: () => CourseModel.empty,
                      );
                      
                      if (course.isEmpty) return const SizedBox();
                      
                      return Chip(
                        label: Text('${course.name} ($prereqCode)'),
                        onDeleted: () {
                          setState(() {
                            _selectedPrerequisites.remove(prereqCode);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  ] else ...[
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                      ),
                    child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16.sp, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Text('لا توجد متطلبات سابقة', style: font14grey),
                        ],
                      ),
                  ),
                ],
                // زر إضافة متطلب
                ButtonApp(
                  textData: 'إضافة متطلب ',
                  onTop: () => _showPrerequisitesDialog(context, availableCourses),
                  boxDecoration: borderAllPrimary,
                  textStyle: font15primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrerequisitesDialog(BuildContext context, List<CourseModel> availableCourses) {
  // 🔥 إنشاء قائمة مؤقتة للاختيارات لتجنب تعديل القائمة الأصلية مباشرة
  final List<String> tempSelectedPrerequisites = List.from(_selectedPrerequisites);
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('اختر المتطلبات السابقة'),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400.h),
            child: availableCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined, size: 48.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد مواد متاحة',
                          style: font16black,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'يجب وجود مواد أخرى في النظام لإضافتها كمتطلبات',
                          style: font14grey,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableCourses.length,
                    itemBuilder: (context, index) {
                      final course = availableCourses[index];
                      final isSelected = tempSelectedPrerequisites.contains(course.codeCs);
                      
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0),
                        child: CheckboxListTile(
                          title: Text(
                            course.name,
                            style: font14black.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رمز المادة: ${course.codeCs}', style: font12Grey),
                              if (course.requestCourses.isNotEmpty) 
                                Text(
                                  'متطلباتها: ${course.requestCourses.join(", ")}',
                                  style: font12Grey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                tempSelectedPrerequisites.add(course.codeCs);
                              } else {
                                tempSelectedPrerequisites.remove(course.codeCs);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء', style: font15primary),
                ),
                SizedBox(width: 8.w),
                ButtonApp(
                  width: 90.w,
                  onTop: () {
                    setState(() {
                      _selectedPrerequisites = List.from(tempSelectedPrerequisites);
                    });
                    Navigator.pop(context);
                  },
                  textData: 'حفظ',
                  textStyle: font15White,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

  void _saveCourse() {
    if (_formKey.currentState?.validate() ?? false) {
      final newCourse = CourseModel(
        id: '',
        name: _nameController.text,
        codeCs: _codeController.text,
        credits: int.parse(_creditsController.text),
        requestCourses: _selectedPrerequisites,
      );
      
      context.read<DataManagementBloc>().add(AddCourse(newCourse));
      Navigator.pop(context);
    }
  }
  String? _validateField(String? value) {
    return (value?.isEmpty ?? true) ? 'هذا الحقل مطلوب' : null;
  }

  String? _validateCredits(String? value) {
    if (value?.isEmpty ?? true) return 'يرجى إدخال الساعات المعتمدة';
    if (int.tryParse(value!) == null) return 'يرجى إدخال رقم صحيح';
    return null;
  }
}