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
/*
 * ✏️ شاشة تعديل المادة المضافَة للفصل
 * 
 * الوظائف:
 * ✅ تعديل الإعدادات الأساسية
 * ✅ إدارة المجموعات والطلاب
 * ✅ استيراد طلاب إضافيين
 * ✅ عرض وحذف الطلاب الحاليين
 * 
 * تسلسل العمل:
 * 1. تحميل بيانات المادة الحالية
 * 2. التعديلات ← تحديث في SemesterRepository
 * 3. إدارة الطلاب ← GroupStudentsImportScreen
 */
class CourseEditScreen extends StatefulWidget {
  final String semesterId;
  final CoursesModel course;

  const CourseEditScreen({
    super.key,
    required this.semesterId,
    required this.course,
  });

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final TextEditingController _numOfChairsController = TextEditingController();
  final TextEditingController _numOfGroupsController = TextEditingController();
  
  UserModels? _selectedMainDoctor;
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  final Map<String, List<UserModels>> _pendingImports = {};
  final Map<String, List<Map<String, dynamic>>> _pendingExcelData = {};
  final Map<String, String> _pendingFileNames = {};
  
  // خيارات تسمية المجموعات (تظهر فقط إذا لم يكن هناك مجموعات)
  final List<String> _groupNamingOptions = ['أبجدي عربي', 'أبجدي إنجليزي', 'أرقام'];
  String _selectedNamingOption = 'أرقام';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadDoctors();
  }

  void _initializeData() {
    // تعبئة البيانات الحالية للمادة
    _numOfChairsController.text = widget.course.numOfStudent.toString();
    _numOfGroupsController.text = widget.course.groups.length.toString();
    
    // تعيين المجموعات الحالية
    _groups = List.from(widget.course.groups);
    
    // إذا كانت هناك مجموعات موجودة، استخدم طريقة التسمية بناءً على الأسماء الحالية
    if (_groups.isNotEmpty) {
      _determineNamingStyle();
    }
  }

  void _determineNamingStyle() {
    if (_groups.isEmpty) return;
    
    final firstGroupName = _groups.first.name;
    
    if (firstGroupName.contains('أ') || firstGroupName.contains('ب')) {
      _selectedNamingOption = 'أبجدي عربي';
    } else if (firstGroupName.contains('A') || firstGroupName.contains('B')) {
      _selectedNamingOption = 'أبجدي إنجليزي';
    } else {
      _selectedNamingOption = 'أرقام';
    }
  }

  void _loadDoctors() {
    context.read<UserManagementBloc>().add(const LoadAllUsers());
  }

  // دالة للبحث عن الدكتور بناءً على الاسم
  UserModels? _findDoctorByName(List<UserModels> doctors, String doctorName) {
    try {
      return doctors.firstWhere(
        (doctor) => doctor.name == doctorName,
        orElse: () => UserModels.empty,
      );
    } catch (e) {
      print('❌ خطأ في البحث عن الدكتور: $e');
      return null;
    }
  }

  // ✅ دالة معالجة حالة البلوك
void _handleBlocStateChanges(SemesterCoursesState state) {
  if (state.status == SemesterCoursesStatus.loading) {
    setState(() {
      _isLoading = true;
    });
  }
  
  if (state.status == SemesterCoursesStatus.success && state.successMessage.isNotEmpty) {
    setState(() {
      _isLoading = false;
    });
    
    // تنظيف البيانات المؤقتة
    _pendingImports.clear();
    _pendingExcelData.clear();
    _pendingFileNames.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.successMessage),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }
  
  if (state.status == SemesterCoursesStatus.error && state.errorMessage.isNotEmpty) {
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

List<Widget> _buildGroupActionButtons(GroupModel group, int index,bool hasExistingStudents) {
    final hasPendingImport = _pendingImports.containsKey(group.id);

    return [
      // زر الدكتور (يظهر دائماً)
      IconButton(
        icon: Icon(Icons.person_search, color: ColorsApp.primaryColor),
        onPressed: () => _showDoctorSelectionDialog(index),
      ),
      
      // زر الاستيراد (يظهر عندما لا يوجد طلاب)
      if (!hasExistingStudents)
        IconButton(
          icon: Icon(Icons.upload_file, 
            color: hasPendingImport ? Colors.orange : Colors.green),
          onPressed: () => _importStudentsToGroup(group, index),
        ),
      
      // زر المعاينة (يظهر عندما يوجد طلاب)
      if (hasExistingStudents)
        IconButton(
          icon: Icon(Icons.people, color: Colors.blue),
          onPressed: () => _viewGroupStudents(group),
        ),
      
      // زر الاستيراد الإضافي (يظهر كزر منفصل عندما يوجد طلاب)
      if (hasExistingStudents)
        IconButton(
          icon: Icon(Icons.add_box, color: Colors.green),
          onPressed: () => _importAdditionalStudents(group, index),
          tooltip: 'استيراد طلاب إضافيين',
        ),
    ];
  }

  @override
void dispose() {
  // ✅ تنظيف المتحكمات والبيانات المؤقتة
  _numOfChairsController.dispose();
  _numOfGroupsController.dispose();
  _clearStudentsCountCache();
  _pendingImports.clear();
  _pendingExcelData.clear();
  _pendingFileNames.clear();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<SemesterCoursesBloc, SemesterCoursesState>(
      listener: (context, state) {
      _handleBlocStateChanges(state);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة ${widget.course.name}', style: font16White),
          backgroundColor: ColorsApp.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المادة (للعرض فقط)
                _buildCourseInfo(),
                SizedBox(height: 24.h),
                
                // الإعدادات الأساسية
                _buildBasicSettings(),
                SizedBox(height: 24.h),
                
                // إدارة المجموعات
                _buildGroupsManagement(),
                SizedBox(height: 32.h),
                
                // زر الحفظ
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: ColorsApp.primaryColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.course.name, style: font16blackbold),
                SizedBox(height: 4.h),
                Text('كود: ${widget.course.codeCs}', style: font14grey),
                Text('الدكتور: ${widget.course.president}', style: font14grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإعدادات الأساسية', style: font16blackbold),
        SizedBox(height: 16.h),
        
        // عدد الكراسي فقط
        CustomTextFiled(
          hintText: 'عدد الكراسي',
          iconData: Icons.chair,
          controller: _numOfChairsController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        
        // الدكتور الأساسي (عرض الأسماء فقط)
        BlocBuilder<UserManagementBloc, UserManagementState>(
          builder: (context, state) {
            final doctors = state.users.where((user) => user.role == 'Doctor').toList();
            
            // البحث عن الدكتور الحالي في القائمة
            if (_selectedMainDoctor == null && doctors.isNotEmpty) {
              final currentDoctor = _findDoctorByName(doctors, widget.course.president);
              if (currentDoctor != null && currentDoctor.isNotEmpty) {
                _selectedMainDoctor = currentDoctor;
              } else if (doctors.isNotEmpty) {
                _selectedMainDoctor = doctors.first;
              }
            }
            
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
                        child: Text(doctor.name, style: font14black), // ✅ عرض الاسم فقط
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
                
                // عرض معلومات إضافية في حالة وجود مشكلة
                if (_selectedMainDoctor == null && doctors.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(8.r),
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
                            'الدكتور الحالي (${widget.course.president}) غير موجود في القائمة',
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
        ),
      ],
    );
  }

  Widget _buildGroupsManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('إدارة المجموعات', style: font16blackbold),
            SizedBox(width: 8.w),
            Chip(
              label: Text('${_groups.length}', style: font11White),
              backgroundColor: ColorsApp.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // حاوية عدد المجموعات مع الأزرار
        _buildGroupsCounter(),
        SizedBox(height: 16.h),
        
        // خيارات تسمية المجموعات (تظهر فقط إذا لم يكن هناك مجموعات)
        if (_groups.isEmpty) ...[
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
        ],
        
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

  Widget _buildGroupCard(GroupModel group, int index) {
  final isLoading = _groupsLoadingState[group.id] ?? false;
  
  if (isLoading) {
    return _buildGroupLoadingCard(group);
  }
  
  final hasPendingImport = _pendingImports.containsKey(group.id);
  final pendingCount = hasPendingImport ? _pendingImports[group.id]!.length : 0;
  final fileName = _pendingFileNames[group.id] ?? '';

  return Card(
    margin: EdgeInsets.only(bottom: 12.h),
    child: Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: font16blackbold),
                    SizedBox(height: 4.h),
                    Text('الدكتور: ${group.nameDoctor}', style: font14grey),
                  ],
                ),
              ),
              
              // ✅ عرض عدد الطلاب الحاليين والمعلقين
              FutureBuilder<int>(
                future: _getGroupStudentsCount(group.id),
                builder: (context, snapshot) {
                  final studentCount = snapshot.data ?? 0;
                  final hasExistingStudents = studentCount > 0;
                  
                  return Row(
                    children: [
                      // عرض عدد الطلاب الحاليين
                      if (hasExistingStudents)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Text(
                            '$studentCount',
                            style: font12Grey.copyWith(color: Colors.blue),
                          ),
                        ),
                      
                      SizedBox(width: 8.w),
                      
                      // عرض عدد الطلاب المعلقين
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
                      
                      // أزرار الإجراءات
                      ..._buildGroupActionButtons(group, index, hasExistingStudents),
                    ],
                  );
                },
              ),
            ],
          ),
          
          // ✅ معلومات الاستيراد المعلق
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
//دالة مساعدة لعرض حالة التحميل
Widget _buildGroupLoadingCard(GroupModel group) {
  return Card(
    margin: EdgeInsets.only(bottom: 12.h),
    child: Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsApp.primaryColor),
            strokeWidth: 2,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text('جاري تحميل بيانات ${group.name}...', 
              style: font14grey,
            ),
          ),
        ],
      ),
    ),
  );
}
/*// ✅ دالة جديدة للتحقق من وجود طلاب حاليين
bool  _getExistingStudentsCount(String groupId) {
  // يمكنك استخدام FutureBuilder في الواجهة بدلاً من هذه الدالة
  // أو تخزين عدد الطلاب في حالة محلية
  final originalGroup = widget.course.groups.firstWhere(
    (g) => g.id == groupId,
    orElse: () => GroupModel.empty,
  );
  if (originalGroup.isNotEmpty) {
    // إذا كانت المجموعة موجودة في البيانات الأصلية، نفترض أن لديها طلاب
    return true;
  }
    return false;
}
*/
// ✅ تحسين التخزين المؤقت وإدارة الذاكرة
final Map<String, int> _studentsCountCache = {};
final Map<String, Future<int>> _studentsCountFutures = {};
// ✅ إضافة حالة تحميل منفصلة للمجموعات
final Map<String, bool> _groupsLoadingState = {};

// ✅ دالة جديدة لاستيراد طلاب إضافيين
void _importAdditionalStudents(GroupModel group, int groupIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<UserManagementBloc>()),
        ],
        child: GroupStudentsImportScreen(
          group: group,
          courseId: widget.course.id,
          onStudentsSelected: (matchedStudents, excelData, fileName) {
            _saveAdditionalImport(group.id, matchedStudents, excelData, fileName);
          },
          // ✅ إضافة خاصية للتمييز بين الاستيراد العادي والإضافي
          isAdditionalImport: true,
        ),
      ),
    ),
  );
}

// ✅ دالة جديدة لحفظ الاستيراد الإضافي
void _saveAdditionalImport(String groupId, List<UserModels> students, 
  List<Map<String, dynamic>> excelData, String fileName) {
  // ✅ جلب الطلاب الحاليين المعلقين أولاً
  final existingPending = _pendingImports[groupId] ?? [];
  // ✅ التحقق من التكرار ومنع إضافة طلاب مكررين
  final newStudents = <UserModels>[];
  final existingStudentIds = existingPending.map((s) => s.userID).toSet();
  
  for (final student in students) {
    if (!existingStudentIds.contains(student.userID)) {
      newStudents.add(student);
    }
  }
  
  if (newStudents.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جميع الطلاب المحددين مضافين مسبقاً'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }
  final existingExcelData = _pendingExcelData[groupId] ?? [];
  final existingFileName = _pendingFileNames[groupId] ?? '';
  
  setState(() {
    _pendingImports[groupId] = [...existingPending, ...newStudents];
    _pendingExcelData[groupId] = [...existingExcelData, ...excelData];
    _pendingFileNames[groupId] = existingFileName.isNotEmpty 
      ? '$existingFileName, $fileName' 
      : fileName;
  });
  // ✅ تحديث التخزين المؤقت للعدادات
  _clearStudentsCountCache();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم إضافة ${students.length} طالب إضافي للمجموعة. إجمالي الطلاب المعلقين: ${_pendingImports[groupId]!.length}'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ),
  );
}
// ✅ تحسين إدارة حالة التحميل
void _setGroupLoading(String groupId, bool loading) {
  setState(() {
    if (loading) {
      _groupsLoadingState[groupId] = true;
    } else {
      _groupsLoadingState.remove(groupId);
    }
  });
}

// ✅ دالة للحصول على عدد الطلاب في المجموعة
Future<int> _getGroupStudentsCount(String groupId) async {
  if (!mounted) return 0;
  // استخدام التخزين المؤقت لتجنب طلبات متكررة
  if (_studentsCountCache.containsKey(groupId)) {
    return _studentsCountCache[groupId]!;
  }
  if (_studentsCountFutures.containsKey(groupId)) {
    return _studentsCountFutures[groupId]!;
  }
  try {
    _setGroupLoading(groupId, true);
    final future = context.read<SemesterCoursesBloc>().semesterRepository.getGroupStudents(
      widget.semesterId,
      widget.course.id,
      groupId,
    ).then((students) {
      if (mounted) {
        final count = students.length;
        _studentsCountCache[groupId] = count;
        _studentsCountFutures.remove(groupId);
        _setGroupLoading(groupId, false);
        return count;
      }
      return 0;
    });
    
    _studentsCountFutures[groupId] = future;
    return await future;
  } catch (e) {
    _setGroupLoading(groupId, false);
    return 0;
  }
}
void _clearStudentsCountCache() {
  _studentsCountCache.clear();
  _studentsCountFutures.clear();
  _groupsLoadingState.clear();
}

  void _removePendingImport(String groupId) {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<UserManagementBloc>()),
          ],
          child: GroupStudentsImportScreen(
            group: group,
            courseId: widget.course.id,
            onStudentsSelected: (matchedStudents, excelData, fileName) {
              _savePendingImport(group.id, matchedStudents, excelData, fileName);
              // ✅ تحديث العداد مباشرة
              _clearStudentsCountCache();
              setState(() {});
            },
          ),
        ),
      ),
      ).then((_) {
        // ✅ تحديث الواجهة بعد العودة من الشاشة
        _clearStudentsCountCache();
        if (mounted) setState(() {});
      });
  }

  void _savePendingImport(String groupId, List<UserModels> students, List<Map<String, dynamic>> excelData, String fileName) {
    setState(() {
      _pendingImports[groupId] = students;
      _pendingExcelData[groupId] = excelData;
      _pendingFileNames[groupId] = fileName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ بيانات ${students.length} طالب مؤقتاً. سيتم إضافتهم عند حفظ التغييرات.'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getGroupName(int index) {
    // إذا كانت هناك مجموعات موجودة، استخدم أسمائها الحالية
    if (index < _groups.length && _groups[index].name.isNotEmpty) {
      return _groups[index].name;
    }
    
    // إذا لم تكن هناك مجموعات، استخدم التسمية المختارة
    switch (_selectedNamingOption) {
      case 'أبجدي عربي':
        final arabicLetters = ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح', 'ط', 'ي'];
        return 'المجموعة ${arabicLetters[index]}';
      case 'أبجدي إنجليزي':
        final englishLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
        return 'Group ${englishLetters[index]}';
      case 'أرقام':
      default:
        return 'المجموعة ${index + 1}';
    }
  }

  void _addGroup() {
    final currentCount = int.tryParse(_numOfGroupsController.text) ?? 1;
    final newCount = currentCount + 1;
    
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

  void _updateGroupsCount(int count) {
  setState(() {
    if (count > _groups.length) {
      // إضافة مجموعات جديدة
      for (int i = _groups.length; i < count; i++) {
        _groups.add(GroupModel(
          id: _generateGroupId(),
          name: _getGroupName(i),
          idDoctor: _selectedMainDoctor?.userID ?? '',
          nameDoctor: _selectedMainDoctor?.name ?? 'غير محدد',
        ));
      }
    } else if (count < _groups.length) {
      // حذف المجموعات الزائدة
      _groups.removeRange(count, _groups.length);
    }
    
    _numOfGroupsController.text = count.toString();
  });
}

  String _generateGroupId() {
    return 'group_${DateTime.now().millisecondsSinceEpoch}_${_groups.length}';
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

// ✅ دالة لعرض الطلاب الحاليين
void _viewGroupStudents(GroupModel group) {
  // ✅ حفظ المرجع قبل فتح الديالوج
  final repository = context.read<SemesterCoursesBloc>().semesterRepository;
  
  showDialog(
    context: context,
    builder: (context) {
      // ✅ استخدام StatefulBuilder للتحديث الديناميكي
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('طلاب ${group.name}', style: font16blackbold),
            content: FutureBuilder<List<StudentModel>>(
              future: repository.getGroupStudents(
                widget.semesterId,
                widget.course.id,
                group.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Text('خطأ في تحميل الطلاب: ${snapshot.error}');
                }
                
                final students = snapshot.data ?? [];
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر الاستيراد الإضافي
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 18.sp),
                        label: Text('استيراد طلاب إضافيين', style: font15White),
                        onPressed: () {
                          Navigator.pop(context); // إغلاق الديالوج
                          _importAdditionalStudents(group, _groups.indexOf(group));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    
                    // قائمة الطلاب
                    if (students.isEmpty) ...[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48.sp, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد طلاب في هذه المجموعة',
                            style: font14grey,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        width: double.maxFinite,
                        height: 300.h,
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(student.name.isNotEmpty ? student.name[0] : '?'),
                                ),
                                title: Text(student.name, style: font14black),
                                subtitle: Text('رقم القيد: ${student.studentId}', style: font12Grey),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                                  onPressed: () {
                                    // ✅ استخدام دالة محسنة للحذف
                                    _showDeleteStudentDialogImproved(group.id, student, setDialogState);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق', style: font14black),
              ),
            ],
          );
        },
      );
    },
  );
}
// ✅ دالة محسنة لحذف طالب مع تحديث الواجهة داخل الديالوج
void _showDeleteStudentDialogImproved(String groupId, StudentModel student, Function setDialogState) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('حذف الطالب', style: font16blackbold),
      content: Text('هل أنت متأكد من حذف الطالب ${student.name} من المجموعة؟', style: font14black),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: font14black),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // إغلاق ديالوج الحذف
            
            try {
              // ✅  حالة تحميل
              setDialogState(() {});
              await context.read<SemesterCoursesBloc>().semesterRepository.deleteStudent(
                widget.semesterId,
                widget.course.id,
                groupId,
                student.id,
              );
              // ✅ إعادة تحميل بيانات الطلاب وتحديث التخزين المؤقت
              _clearStudentsCountCache();
              
              // ✅ تحديث حالة الديالوج مباشرة
              setDialogState(() {});
              // ✅ تحديث الواجهة الرئيسية أيضاً
              if (mounted) {
                setState(() {});
              }
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('تم حذف الطالب ${student.name} بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('فشل في حذف الطالب: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text('حذف', style: font14Error),
        ),
      ],
    ),
  );
}
/*
// ✅ دالة جديدة لجلب طلاب المجموعة
Future<List<StudentModel>> _loadGroupStudents(String groupId) async {
  try {
    return await context.read<SemesterCoursesBloc>().semesterRepository.getGroupStudents(
      widget.semesterId,
      widget.course.id,
      groupId,
    );
  } catch (e) {
    print('❌ خطأ في جلب طلاب المجموعة: $e');
    return [];
  }
}
*/
  Widget _buildSaveButton() {
    return _isLoading
        ? Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: ColorsApp.primaryColor),
                SizedBox(height: 16.h),
                Text('جاري حفظ التغييرات...', style: font16black),
              ],
            ),
          )
        : Column(
            children: [
              _buildPendingImportsSummary(),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء', style: font15primary),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ButtonApp(
                      textData: 'حفظ التغييرات',
                      onTop: _saveChanges,
                    ),
                  ),
                ],
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
        ],
      ),
    );
  }

  int _getTotalPendingStudents() {
    return _pendingImports.values.fold(0, (sum, students) => sum + students.length);
  }

  // ✅ دالة لحفظ جميع البيانات المؤقتة في البلوك
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

  void _saveChanges() async {
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
      print('💾 بدء حفظ التغييرات للمادة: ${widget.course.name}');
      print('👥 عدد المجموعات: ${_groups.length}');
      _saveAllPendingImportsToBloc();
      // تحديث بيانات المادة
      final updatedCourse = widget.course.copyWith(
      numOfStudent: int.parse(_numOfChairsController.text),
      president: _selectedMainDoctor!.name,
      groups: _groups,
    );

    // ✅ استخدام المعرف الأصلي للمادة والمجموعات
    context.read<SemesterCoursesBloc>().add(
      UpdateCourseWithGroups(
        semesterId: widget.semesterId,
        course: updatedCourse,
        groups: _groups,
      )
    );

    print('✅ تم إرسال حدث تحديث المادة إلى البلوك');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('❌ خطأ في حفظ التغييرات: $e');
      ShowWidget.showMessage(
      context,
      'فشل في حفظ التغييرات: ${e.toString()}',
    Colors.red,
      font15White,
      );
    }
  }
}