import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_repository/course_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';

class EditCourseDialog extends StatefulWidget {
  final CourseModel course;

  const EditCourseDialog({super.key, required this.course});

  @override
  State<EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  List<String> _selectedPrerequisites = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _refreshData();
  }

  void _initializeForm() {
  print('🔧 بدء تهيئة نموذج التعديل للمادة: ${widget.course.name}');
  print('📋 بيانات المادة الأصلية:');
  print('   - الاسم: ${widget.course.name}');
  print('   - الكود: ${widget.course.codeCs}');
  print('   - الساعات: ${widget.course.credits}');
  print('   - المتطلبات الخام: ${widget.course.requestCourses}');
  print('   - نوع المتطلبات: ${widget.course.requestCourses.runtimeType}');
  print('   - طول المتطلبات: ${widget.course.requestCourses.length}');
  
  _nameController.text = widget.course.name;
  _codeController.text = widget.course.codeCs;
  _creditsController.text = widget.course.credits.toString();
  
  // 🔥 إصلاح تحميل المتطلبات
  _selectedPrerequisites = _ensureStringList(widget.course.requestCourses);
  
  print('✅ المتطلبات بعد التهيئة: $_selectedPrerequisites');
  print('✅ نوع المتطلبات بعد التهيئة: ${_selectedPrerequisites.runtimeType}');
}
// 🔥 دالة مساعدة لضمان أن المتطلبات هي List<String>
List<String> _ensureStringList(List<dynamic> input) {
  if (input.isEmpty) return [];
  
  return input.map((item) {
    if (item is String) {
      return item;
    } else {
      return item.toString();
    }
  }).toList();
}
void _refreshData() {
  // 🔥 إعادة تحميل البيانات لضمان الحصول على أحدث نسخة
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<DataManagementBloc>().add(const LoadCourses());
  });
}

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
                Text('تعديل المادة', style: font18blackbold),
                SizedBox(height: 24.h),
                
                _buildFormFields(context),
                SizedBox(height: 24.h),
                
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        CustomTextFiled(
          hintText: 'اسم المادة',
          iconData: Icons.school,
          controller: _nameController,
          validator: _validateField,
        ),
        SizedBox(height: 16.h),
        
        CustomTextFiled(
          hintText: 'كود المادة',
          iconData: Icons.code,
          controller: _codeController,
          validator: _validateField,
          //enabled: false, // لا يمكن تعديل الكود
        ),
        SizedBox(height: 16.h),
        
        CustomTextFiled(
          hintText: 'الساعات المعتمدة',
          iconData: Icons.credit_card,
          controller: _creditsController,
          keyboardType: TextInputType.number,
          validator: _validateCredits,
        ),
        SizedBox(height: 16.h),
        
        _buildPrerequisitesSection(context),
      ],
    );
  }

  Widget _buildPrerequisitesSection (BuildContext context) {
  return BlocBuilder<DataManagementBloc, DataManagementState>(
    builder: (context, state) {
      final availableCourses = state.courses
          .where((course) => course.id != widget.course.id) // منع اختيار المادة نفسها
          .toList();
      
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('المتطلبات السابقة:', style: font16blackbold),
              SizedBox(height: 8.h),
              
              // 🔥 عرض المتطلبات الحالية بالأكواد
              if (_selectedPrerequisites.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _selectedPrerequisites.map((prereqCode) {
                    
                    // البحث عن المادة بالكود
                    final course = availableCourses.firstWhere(
                      (c) => c.codeCs == prereqCode,
                      orElse: () => CourseModel.empty,
                    );
                    
                    final displayName = course.isEmpty 
                        ? prereqCode // إذا لم يتم العثور، عرض الكود فقط
                        : '${course.name} ($prereqCode)';
                    
                    return Chip(
                      label: Text(displayName,
                      style: font11White,
                      ),
                      backgroundColor: ColorsApp.primaryColor,
                      onDeleted: () => _removePrerequisite(prereqCode),
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
                      Text(
                        'لا توجد متطلبات سابقة',
                        style: font14grey,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              // 🔥 زر إدارة المتطلبات مع التحقق من توفر المواد
              if (availableCourses.isNotEmpty) 
              ButtonApp(
                textData: 'إدارة المتطلبات',
                onTop: () => _showPrerequisitesDialog(availableCourses),
                boxDecoration: borderAllPrimary,
                textStyle: font15primary,
              )
              else
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 16.sp, color: Colors.orange),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'لا توجد مواد أخرى متاحة لإضافتها كمتطلبات',
                          style: font12Grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ) 
      );
    },
  );
}
  
  
  Widget _buildActionButtons() {
    return Row(
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
            textData: 'حفظ التعديلات',
            onTop: _updateCourse,
          ),
        ),
      ],
    );
  }

  String? _validateField(String? value) {
    return (value?.isEmpty ?? true) ? 'هذا الحقل مطلوب' : null;
  }

  String? _validateCredits(String? value) {
    if (value?.isEmpty ?? true) return 'يرجى إدخال الساعات المعتمدة';
    if (int.tryParse(value!) == null) return 'يرجى إدخال رقم صحيح';
    return null;
  }

  void _removePrerequisite(String prereqCode) {
    setState(() => _selectedPrerequisites.remove(prereqCode));
  }

  void _showPrerequisitesDialog(List<CourseModel> availableCourses) {
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
                        margin: EdgeInsets.symmetric(vertical: 4.h),
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
            getWidth(8.w),
            ButtonApp(
              width: 90.w,
              onTop: () {
                setState(() {
                  _selectedPrerequisites = List.from(tempSelectedPrerequisites);
                });
                Navigator.pop(context);
              },
              textData:'حفظ',
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

  void _updateCourse() {
    if (_formKey.currentState?.validate() ?? false) {
      print('🔄 بيانات التحديث:');
      print('📝 الاسم: ${_nameController.text}');
      print('🔤 الكود: ${_codeController.text}');
      print('⏰ الساعات: ${_creditsController.text}');
      print('📋 المتطلبات: $_selectedPrerequisites');
      final updatedCourse = widget.course.copyWith(
        name: _nameController.text,
        credits: int.parse(_creditsController.text),
        requestCourses: _selectedPrerequisites,
      );
      print('✅ تم إنشاء الكائن المحدث: ${updatedCourse}');
      context.read<DataManagementBloc>().add(UpdateCourse(updatedCourse));
      Navigator.pop(context);
    }
  }
}