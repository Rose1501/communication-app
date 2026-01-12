// features/data_management/view/screens/course_setup_screen.dart
import 'package:course_repository/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/group_students_import_screen.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';
/*
 * ⚙️ شاشة إعداد المادة قبل إضافتها للفصل
 * 
 * الوظائف:
 * ✅ اختيار المادة من القائمة
 * ✅ تحديد الدكتور الأساسي
 * ✅ إعداد عدد الكراسي والمجموعات
 * ✅ إدارة المجموعات وتوزيع الدكاترة
 * ✅ استيراد طلاب للمجموعات
 * 
 */
class CourseSetupScreen extends StatefulWidget {
  final String semesterId;

  const CourseSetupScreen({super.key, required this.semesterId});

  @override
  State<CourseSetupScreen> createState() => _CourseSetupScreenState();
}

class _CourseSetupScreenState extends State<CourseSetupScreen> {
  final TextEditingController _numOfChairsController = TextEditingController();
  final TextEditingController _numOfGroupsController = TextEditingController();
  
  CourseModel? _selectedCourse;
  UserModels? _selectedMainDoctor;
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  final Map<String, List<UserModels>> _pendingImports = {};
  final Map<String, List<Map<String, dynamic>>> _pendingExcelData = {};
  final Map<String, String> _pendingFileNames = {};
  
  // خيارات تسمية المجموعات
  final List<String> _groupNamingOptions = ['أبجدي عربي', 'أبجدي إنجليزي', 'أرقام'];
  String _selectedNamingOption = 'أبجدي عربي';
  
  // قائمة الحروف والأرقام
  final List<String> _arabicLetters = ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح', 'ط', 'ي', 'ك', 'ل', 'م', 'ن', 'س', 'ع', 'ف', 'ص', 'ق', 'ر', 'ش', 'ت', 'ث', 'خ', 'ذ', 'ض', 'ظ', 'غ'];
  final List<String> _englishLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  @override
  void initState() {
    super.initState();
    _numOfGroupsController.text = '1';
    _numOfChairsController.text = '30';
    _initializeGroups();
    _loadDoctors();
  }

  void _initializeGroups() {
    _updateGroupsCount(1);
    _groups = [
    GroupModel(
      id: _generateGroupId(), // ✅ استخدام معرف فريد للمجموعة الأولى
      name: _getGroupName(0),
      idDoctor: _selectedMainDoctor?.userID ?? '',
      nameDoctor: _selectedMainDoctor?.name ?? 'غير محدد',
    )
  ];
  _numOfGroupsController.text = '1';
  _numOfChairsController.text = '30';
  }

  void _loadDoctors() {
    context.read<UserManagementBloc>().add(const LoadAllUsers());
  }

  String _generateGroupId() {
    return const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مادة جديدة', style: font16White),
        backgroundColor: ColorsApp.primaryColor,
      ),
      body: BlocListener<SemesterCoursesBloc, SemesterCoursesState>(
        listener: (context, state) {
          _handleBlocStateChanges(state);
        },
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار المادة
                _buildCourseSelection(),
                SizedBox(height: 24.h),
                
                if (_selectedCourse != null) ...[
                  // الإعدادات الأساسية
                  _buildBasicSettings(),
                  SizedBox(height: 24.h),
                  
                  // إدارة المجموعات
                  _buildGroupsManagement(),
                  SizedBox(height: 32.h),
                  
                  // زر الحفظ
                  _buildSaveButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
// ✅ دالة معالجة تغيرات حالة البلوك
void _handleBlocStateChanges(SemesterCoursesState state) {
  print('🔄 معالجة تغيير حالة البلوك: ${state.status}');
  // معالجة حالة التحميل
  if (state.status == SemesterCoursesStatus.loading) {
    setState(() {
      _isLoading = true;
    });
  }
  
  // معالجة حالة النجاح
  if (state.status == SemesterCoursesStatus.success && state.successMessage.isNotEmpty) {
    setState(() {
      _isLoading = false;
    });
    
    // ✅ تنظيف البيانات المحلية بعد النجاح
    _pendingImports.clear();
    _pendingExcelData.clear();
    _pendingFileNames.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.successMessage),
        backgroundColor: Colors.green,
      ),
    );
    
    // العودة للشاشة السابقة بعد نجاح الحفظ
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
  
  // معالجة حالة الخطأ
  if (state.status == SemesterCoursesStatus.error && state.errorMessage.isNotEmpty) {
    print('❌ حالة الخطأ: ${state.errorMessage}');
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Widget _buildCourseSelection() {
    return BlocBuilder<SemesterCoursesBloc, SemesterCoursesState>(
      builder: (context, state) {
        final availableCourses = state.availableCourses;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختيار المادة', style: font16blackbold),
            SizedBox(height: 12.h),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<CourseModel>(
                value: _selectedCourse,
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('اختر المادة المراد إضافتها', style: font14grey),
                items: availableCourses.map((course) {
                  return DropdownMenuItem(
                    value: course,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name, style: font14black),
                        Text(course.codeCs, style: font12Grey),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (course) {
                  setState(() {
                    _selectedCourse = course;
                  });
                },
              ),
            ),
            
            if (availableCourses.isEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'لا توجد مواد متاحة للإضافة. جميع المواد مضافَة للفصل أو لا توجد مواد في النظام.',
                        style: font12Grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإعدادات الأساسية', style: font16blackbold),
        SizedBox(height: 16.h),
        
        // عدد الكراسي
        CustomTextFiled(
          hintText: 'عدد الكراسي',
          iconData: Icons.chair,
          controller: _numOfChairsController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        
        // الدكتور الأساسي
        BlocBuilder<UserManagementBloc, UserManagementState>(
          builder: (context, state) {
            final doctors = state.users.where((user) => user.role == 'Doctor').toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الدكتور الأساسي', style: font14black),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<UserModels>(
                    value: _selectedMainDoctor,
                    isExpanded: true,
                    underline: SizedBox(),
                    hint: Text('اختر الدكتور الأساسي', style: font14grey),
                    items: doctors.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor,
                        child: Text('${doctor.name} ', style: font14black),
                      );
                    }).toList(),
                    onChanged: (doctor) {
                      setState(() {
                        _selectedMainDoctor = doctor;
                        // تحديث الدكتور الأساسي في جميع المجموعات
                        for (int i = 0; i < _groups.length; i++) {
                          _groups[i] = _groups[i].copyWith(
                            idDoctor: doctor?.userID ?? '',
                            nameDoctor: doctor?.name ?? 'غير محدد',
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupsManagement() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('إدارة المجموعات', style: font16blackbold),
      SizedBox(height: 16.h),
      
      // حاوية عدد المجموعات مع الأزرار
      _buildGroupsCounter(),
      SizedBox(height: 16.h),
      
      // خيارات تسمية المجموعات
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('طريقة تسمية المجموعات', style: font14black),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedNamingOption,
              isExpanded: true,
              underline: SizedBox(),
              items: _groupNamingOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option, style: font14black),
                );
              }).toList(),
              onChanged: (option) {
                setState(() {
                  _selectedNamingOption = option!;
                  _updateGroupsCount(_groups.length);
                });
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 16.h),
      
      // قائمة المجموعات
      ..._groups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return _buildGroupCard(group, index);
      }).toList(),
    ],
  );
}

Widget _buildGroupsCounter() {
  return Container(
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'عدد المجموعات',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        
        // العداد مع الأزرار
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: ColorsApp.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر الناقص
              IconButton(
                icon: Icon(Icons.remove, size: 18.sp),
                onPressed: _removeGroup,
                color: Colors.red,
                padding: EdgeInsets.all(8.r),
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
              ),
              
              // العدد
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  _numOfGroupsController.text,
                  style: font16blackbold.copyWith(
                    color: ColorsApp.primaryColor,
                  ),
                ),
              ),
              
              // زر الزائد
              IconButton(
                icon: Icon(Icons.add, size: 18.sp),
                onPressed: _addGroup,
                color: ColorsApp.primaryColor,
                padding: EdgeInsets.all(8.r),
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ✅  لعرض حالة الاستيراد
  Widget _buildGroupCard(GroupModel group, int index) {
  final hasPendingImport = _pendingImports.containsKey(group.id);
  final pendingCount = hasPendingImport ? _pendingImports[group.id]!.length : 0;
  final fileName = _pendingFileNames[group.id]?? '';

  print('🔄 بناء بطاقة المجموعة: ${group.name}');
  print('   🆔 المعرف: ${group.id}');
  print('   📊 لديه بيانات مؤقتة: $hasPendingImport');
  print('   👥 عدد الطلاب: $pendingCount');
  print('   📁 الملف: $fileName');

  return Card(
    margin: EdgeInsets.only(bottom: 12.h),
    child: Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getGroupName(index), style: font16blackbold),
              Spacer(),
              
              // ✅ عرض عدد الطلاب المعلقين
              if (hasPendingImport)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: font11White,
                  ),
                ),
              
              IconButton(
                icon: Icon(Icons.person_search, color: ColorsApp.primaryColor),
                onPressed: () => _showDoctorSelectionDialog(index),
              ),
              IconButton(
                icon: Icon(
                  Icons.upload_file, 
                  color: hasPendingImport ? Colors.orange : Colors.green,
                ),
                onPressed: () => _importStudentsToGroup(group, index),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text('الدكتور: ${group.nameDoctor}', style: font14grey),
          
          // ✅ عرض معلومات الاستيراد المعلق
          if (hasPendingImport) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, size: 16.sp, color: Colors.orange),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '$pendingCount طالب بانتظار الحفظ',
                          style: font12Grey.copyWith(color: Colors.orange),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, size: 16.sp, color: Colors.red),
                        onPressed: () => _removePendingImport(group.id),
                      ),
                    ],
                  ),
                  if (fileName.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'الملف: $fileName',
                      style: font12Grey.copyWith(fontSize: 10.sp),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
  // ✅ دالة لإزالة الاستيراد المعلق
  void _removePendingImport(String groupId) {
  context.read<SemesterCoursesBloc>().clearPendingImport(groupId);
  
  setState(() {
    _pendingImports.remove(groupId);
    _pendingExcelData.remove(groupId);
    _pendingFileNames.remove(groupId);
  });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء بيانات الاستيراد المؤقتة'),
        backgroundColor: Colors.green,
      ),
    );
  }

void _importStudentsToGroup(GroupModel group, int groupIndex) {
    print('📤 استيراد طلاب للمجموعة: ${group.name}');
    print('   🆔 معرف المجموعة: ${group.id}');
    print('   📍 الفهرس: $groupIndex');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<UserManagementBloc>()),
          ],
          child: GroupStudentsImportScreen(
            group: group,
            courseId: _selectedCourse?.id ?? '',
            onStudentsSelected: (matchedStudents, excelData, fileName) {
            // ✅ حفظ البيانات مؤقتاً للمجموعة المحددة فقط
            _savePendingImport(group.id, matchedStudents, excelData, fileName);
            },
          ),
        ),
      ),
    );
  }

void _debugPrintData() {
  print('🐛 DEBUG - البيانات الحالية:');
  print('   📚 المادة المختارة: ${_selectedCourse?.name}');
  print('   👨‍🏫 الدكتور الأساسي: ${_selectedMainDoctor?.name}');
  print('   👥 عدد المجموعات: ${_groups.length}');
  
  for (int i = 0; i < _groups.length; i++) {
    final group = _groups[i];
    print('   🆔 المجموعة ${i + 1}: ${group.name} (${group.id}) - الدكتور: ${group.nameDoctor}');
  }
  
  print('   💾 البيانات المؤقتة: ${_pendingImports.length} مجموعة');
  for (final entry in _pendingImports.entries) {
    print('      🆔 ${entry.key}: ${entry.value.length} طالب');
  }
}

  // ✅ دالة لحفظ البيانات المؤقتة
  void _savePendingImport(String groupId, List<UserModels> students, List<Map<String, dynamic>> excelData, String fileName) {
   print('💾 حفظ بيانات مؤقتة للمجموعة: $groupId');
  print('   📊 عدد الطلاب: ${students.length}');
  print('   📁 اسم الملف: $fileName');
  print('   🔑 جميع مفاتيح المجموعات: ${_pendingImports.keys.toList()}');
  _debugPrintData();
  context.read<SemesterCoursesBloc>().savePendingImport(
    groupId, students, excelData, fileName
  );
  setState(() {
    _pendingImports[groupId] = students;
    _pendingExcelData[groupId] = excelData;
    _pendingFileNames[groupId] = fileName;
  });
  print('✅ تم حفظ البيانات في البلوك والمحلي');
  print('   🔑 مفاتيح المجموعات في البلوك: ${context.read<SemesterCoursesBloc>().pendingGroupImports.keys.toList()}');
  print('   🔑 مفاتيح المجموعات محلياً: ${_pendingImports.keys.toList()}');

    ShowWidget.showMessage(
    context,
    'تم حفظ بيانات ${students.length} طالب مؤقتاً. سيتم إضافتهم عند حفظ المادة.',
  Colors.blue,
    font15White,
    );
  }

  String _getGroupName(int index) {
    switch (_selectedNamingOption) {
      case 'أبجدي عربي':
        return 'المجموعة ${_arabicLetters[index]}';
      case 'أبجدي إنجليزي':
        return 'Group ${_englishLetters[index]}';
      case 'أرقام':
        return 'المجموعة ${index + 1}';
      default:
        return 'المجموعة ${_arabicLetters[index]}';
    }
  }

  void _addGroup() {
  final currentCount = int.tryParse(_numOfGroupsController.text) ?? 1;
  final newCount = currentCount + 1;
  
  if (_selectedNamingOption == 'أبجدي عربي' && newCount > _arabicLetters.length) {
    _showMaxGroupsWarning(_arabicLetters.length);
    return;
  }
  
  if (_selectedNamingOption == 'أبجدي إنجليزي' && newCount > _englishLetters.length) {
    _showMaxGroupsWarning(_englishLetters.length);
    return;
  }
  
  setState(() {
    _numOfGroupsController.text = newCount.toString();
    _updateGroupsCount(newCount);
  });
}

void _removeGroup() {
  final currentCount = int.tryParse(_numOfGroupsController.text) ?? 1;
  if (currentCount > 1) {
    setState(() {
      _numOfGroupsController.text = (currentCount - 1).toString();
      _updateGroupsCount(currentCount - 1);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('يجب أن يكون هناك مجموعة واحدة على الأقل'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

void _showMaxGroupsWarning(int maxGroups) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('الحد الأقصى للمجموعات هو $maxGroups مجموعة'),
      backgroundColor: Colors.orange,
    ),
  );
}

  void _updateGroupsCount(int count) {
    setState(() {
      _groups = List.generate(count, (index) {
        if (index < _groups.length) {
          return _groups[index];
        } else {
          return GroupModel(
            id: _generateGroupId(),
            name: _getGroupName(index),
            idDoctor: _selectedMainDoctor?.userID ?? '',
            nameDoctor: _selectedMainDoctor?.name ?? 'غير محدد',
          );
        }
      });
    });
  }

  // ✅  دالة للتحقق من البيانات قبل الحفظ
bool _validateDataBeforeSave() {
  print('🔍 التحقق من البيانات قبل الحفظ...');
  
  // التحقق من المادة
  if (_selectedCourse == null) {
    print('❌ لم يتم اختيار مادة');
    return false;
  }
  
  // التحقق من الدكتور
  if (_selectedMainDoctor == null) {
    print('❌ لم يتم اختيار دكتور أساسي');
    return false;
  }
  
  // التحقق من المجموعات
  if (_groups.isEmpty) {
    print('❌ لا توجد مجموعات');
    return false;
  }
  
  // التحقق من أن كل مجموعة لها معرف
  for (int i = 0; i < _groups.length; i++) {
    final group = _groups[i];
    if (group.id.isEmpty) {
      print('❌ المجموعة ${i + 1} لا تحتوي على معرف');
      return false;
    }
    if (group.nameDoctor.isEmpty) {
      print('❌ المجموعة ${i + 1} لا تحتوي على دكتور');
      return false;
    }
  }
  
  // التحقق من البيانات المؤقتة
  print('📊 البيانات المؤقتة:');
  for (final entry in _pendingImports.entries) {
    final groupId = entry.key;
    final students = entry.value;
    print('   🆔 $groupId: ${students.length} طالب');
    
    // التحقق من أن المجموعة موجودة في _groups
    final groupExists = _groups.any((group) => group.id == groupId);
    if (!groupExists) {
      print('❌ بيانات مؤقتة لمجموعة غير موجودة: $groupId');
      return false;
    }
  }
  
  print('✅ جميع البيانات صالحة للحفظ');
  return true;
}

  void _showDoctorSelectionDialog(int groupIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر دكتور المجموعة', style: font16blackbold),
        content: BlocBuilder<UserManagementBloc, UserManagementState>(
          builder: (context, state) {
            final doctors = state.users.where((user) => user.role == 'Doctor').toList();
            
            return Container(
              width: double.maxFinite,
              height: 300.h,
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: ListTile(
                      title: Text(doctor.name, style: font14black),
                      onTap: () {
                        setState(() {
                          _groups[groupIndex] = _groups[groupIndex].copyWith(
                            idDoctor: doctor.userID,
                            nameDoctor: doctor.name,
                          );
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
  // ✅ إضافة مؤشر تحميل في واجهة الحفظ
  Widget _buildSaveButton() {
    return _isLoading
        ? Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: ColorsApp.primaryColor),
                SizedBox(height: 16.h),
                Text('جاري حفظ البيانات...', style: font16black),
              ],
            ),
          )
        : Column(
            children: [
              // ✅ عرض ملخص البيانات المؤقتة
              _buildPendingImportsSummary(),
              Center(
                child: ButtonApp(
                  textData: 'حفظ المادة والمجموعات',
                  onTop: _saveCourseWithGroups,
                ),
              ),
            ],
          );
  }

Widget _buildPendingImportsSummary() {
  if (_pendingImports.isEmpty) return SizedBox();

  final totalPendingStudents = _getTotalPendingStudents();
  final groupsWithImports = _pendingImports.keys.length;

  return Container(
    padding: EdgeInsets.all(16.r),
    margin: EdgeInsets.only(bottom: 16.h),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيانات استيراد معلقة',
                    style: font14black.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$totalPendingStudents طالب في $groupsWithImports مجموعة بانتظار الحفظ',
                    style: font12Grey,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // ✅ عرض تفاصيل كل مجموعة
        SizedBox(height: 8.h),
        ..._pendingImports.entries.map((entry) {
          final groupId = entry.key;
          final students = entry.value;
          final group = _groups.firstWhere((g) => g.id == groupId, orElse: () => GroupModel.empty);
          final fileName = _pendingFileNames[groupId] ?? '';
          
          if (group.isEmpty) return SizedBox();
          
          return Container(
            margin: EdgeInsets.only(bottom: 4.h),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text('${group.name}:', style: font12Grey.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(width: 4.w),
                Text('${students.length} طالب', style: font12Grey),
                if (fileName.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '($fileName)',
                      style: font12Grey.copyWith(fontSize: 10.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}

  int _getTotalPendingStudents() {
    return _pendingImports.values.fold(0, (sum, students) => sum + students.length);
  }

  // ✅ تحديث دالة الحفظ النهائية
  void _saveCourseWithGroups() async {
    // التحقق من البيانات أولاً
  if (!_validateDataBeforeSave()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('يوجد مشكلة في البيانات المدخلة. يرجى التحقق وإعادة المحاولة.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار المادة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMainDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار الدكتور الأساسي'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final numOfChairs = int.tryParse(_numOfChairsController.text) ?? 0;
    if (numOfChairs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال عدد كراسي صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. ✅ حفظ المادة والمجموعات أولاً
      final courseToAdd = CoursesModel(
        id: '',
        name: _selectedCourse!.name,
        codeCs: _selectedCourse!.codeCs,
        numOfStudent: numOfChairs,
        president: _selectedMainDoctor!.name,
        groups: _groups,
      );

      print('🚀 بدء عملية حفظ المادة والمجموعات');
    print('📚 المادة: ${courseToAdd.name}');
    print('👥 عدد المجموعات: ${_groups.length}');
    print('📊 البيانات المؤقتة: ${_pendingImports.length} مجموعة');

      // ✅ حفظ البيانات المؤقتة في البلوك أولاً
      _saveAllPendingImportsToBloc();
      context.read<SemesterCoursesBloc>().add(
      AddCourseWithGroups(courseToAdd, _groups)
    );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('❌ خطأ في حفظ البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في حفظ البيانات: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ دالة جديدة لحفظ جميع البيانات المؤقتة في البلوك
void _saveAllPendingImportsToBloc() {
  final bloc = context.read<SemesterCoursesBloc>();
  
  for (final entry in _pendingImports.entries) {
    final groupId = entry.key;
    final students = entry.value;
    final excelData = _pendingExcelData[groupId] ?? [];
    final fileName = _pendingFileNames[groupId] ?? '';
    
    print('💾 حفظ بيانات مؤقتة في البلوك للمجموعة: $groupId');
    print('   👥 عدد الطلاب: ${students.length}');
    print('   📁 الملف: $fileName');
    
    bloc.savePendingImport(groupId, students, excelData, fileName);
  }
}
}