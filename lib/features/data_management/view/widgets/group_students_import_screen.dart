import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';
/*
 * 🎓 شاشة استيراد الطلاب لمجموعة محددة
 * 
 * التسلسل:
 * 1. اختيار ملف Excel بالطلاب
 * 2. مطابقة الطلاب مع قاعدة البيانات
 * 3. عرض الطلاب المتطابقين وغير المتطابقين
 * 4. إرجاع البيانات للشاشة الرئيسية
 */
class GroupStudentsImportScreen extends StatefulWidget {
  final GroupModel group;
  final String courseId;
  final Function(List<UserModels>, List<Map<String, dynamic>>, String) onStudentsSelected;
  final bool isAdditionalImport;

  const GroupStudentsImportScreen({
    super.key,
    required this.group,
    required this.courseId,
    required this.onStudentsSelected,
    this.isAdditionalImport = false,
  });

  @override
  State<GroupStudentsImportScreen> createState() => _GroupStudentsImportScreenState();
}

class _GroupStudentsImportScreenState extends State<GroupStudentsImportScreen> {
  List<Map<String, dynamic>> _excelData = [];
  List<UserModels> _matchedStudents = [];
  List<Map<String, dynamic>> _unmatchedRecords = [];
  bool _isLoading = false;
  String? _fileName;
  int _totalRecords = 0;
  int _matchedCount = 0;
  int _unmatchedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استيراد طلاب ${widget.group.name}', style: font16White),
        backgroundColor: ColorsApp.primaryColor,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  // 🔘 زر اختيار الملف
                  if (_excelData.isEmpty) 
                  Expanded(child: _buildFilePicker()),
                  
                  // 📊 نتائج المعالجة
                  if (_excelData.isNotEmpty) ...[
                    _buildImportResults(),
                    SizedBox(height: 16.h),
                  ],
                  
                  // 👥 قائمة الطلاب المتطابقين وغير المتطابقين
                  if (_excelData.isNotEmpty) 
                    Expanded(
                      child: _buildResultsContent(),
                    ),
                  
                  // 🔘 أزرار الإجراءات
                  if (_excelData.isNotEmpty) _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildResultsContent() {
  return Column(
    children: [
      // 👥 قائمة الطلاب المتطابقين
      if (_matchedStudents.isNotEmpty) 
        Expanded(
          flex: _unmatchedRecords.isNotEmpty ? 5 : 10,
          child: _buildMatchedStudentsList(),
        ),
      
      // ⚠️ قائمة الطلاب غير المتطابقين
      if (_unmatchedRecords.isNotEmpty) 
        Expanded(
          flex: _matchedStudents.isNotEmpty ? 5 : 10,
          child: _buildUnmatchedStudentsList(),
        ),
      
      // 🔥 رسالة عندما لا توجد نتائج
      if (_matchedStudents.isEmpty && _unmatchedRecords.isEmpty)
        Expanded(
          child: _buildNoResultsState(),
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
          Text('جاري معالجة الملف...', style: font16black),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            Icon(Icons.upload_file, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'استيراد طلاب من ملف Excel',
              style: font18blackbold,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'اختر ملف Excel يحتوي على بيانات الطلاب',
              style: font14grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المتطلبات:', style: font16blackbold),
                  SizedBox(height: 8.h),
                  _buildRequirementItem('يجب أن يحتوي الملف على عمود "رقم القيد" أو "userID"'),
                  _buildRequirementItem('يتم مطابقة الطلاب بناءً على رقم القيد فقط'),
                  _buildRequirementItem('الطلاب غير المسجلين في النظام سيتم تجاهلهم'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            ButtonApp(
              textData: 'اختيار ملف Excel',
              onTop: _pickExcelFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: font12Grey)),
        ],
      ),
    );
  }

  Widget _buildImportResults() {
  final existingInGroup = _unmatchedRecords.where((r) => r['_reason']?.contains('مضاف مسبقاً') == true).length;
  final notInSystem = _unmatchedRecords.where((r) => r['_reason']?.contains('غير مسجل') == true).length;

  return Card(
    child: Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: ColorsApp.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text('نتائج المعالجة', style: fount14Bold),
              Spacer(),
              if (_fileName != null)
                Text(
                  _fileName!,
                  style: font12Grey,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          
          // 🔥 الإحصائيات المختصرة
          Wrap(
            spacing: 4.w,
            runSpacing: 8.h,
            children: [
              _buildCompactStatItem('إجمالي', '$_totalRecords', Icons.list, Colors.blue),
              if (_matchedCount > 0)
                _buildCompactStatItem('جديد', '$_matchedCount', Icons.check_circle, Colors.green),
              if (existingInGroup > 0)
                _buildCompactStatItem('موجود', '$existingInGroup', Icons.person_off, Colors.purple),
              if (notInSystem > 0)
                _buildCompactStatItem('غير مسجل', '$notInSystem', Icons.person_remove, Colors.red),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildCompactStatItem(String label, String value, IconData icon, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 4.w),
        Text(value, style: font12black.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        )),
        SizedBox(width: 4.w),
        Text(label, style: font12Grey),
      ],
    ),
  );
}

  Widget _buildMatchedStudentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Text('الطلاب المتطابقين :', style: font16blackbold),
              SizedBox(width: 8.w),
              Chip(
                label: Text('$_matchedCount', style: font11White),
                backgroundColor: ColorsApp.primaryColor,
              ),
              Spacer(),
              Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            ],
          ),
        ),
        // 🔥 قائمة الطلاب مع مساحة محددة
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: ListView.builder(
            itemCount: _matchedStudents.length,
            padding: EdgeInsets.all(8.r),
            itemBuilder: (context, index) {
              final student = _matchedStudents[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ColorsApp.primaryColor,
                    child: Text(
                      student.name.isNotEmpty ? student.name[0] : '?',
                      style: font15White,
                    ),
                  ),
                  title: Text(
                    student.name.isNotEmpty ? student.name : 'طالب بدون اسم',
                    style: font14black,
                  ),
                  subtitle: Text('رقم القيد: ${student.userID}', style: font14grey),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                ),
              );
            },
          ),
        ),
      ),
      ],
    );
  }

  Widget _buildUnmatchedStudentsList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Text('سجلات غير متطابقة', style: font16blackbold),
            SizedBox(width: 8.w),
            Chip(
              label: Text('$_unmatchedCount', style: font11White),
              backgroundColor: Colors.orange,
            ),
            Spacer(),
            Icon(Icons.warning, color: Colors.orange, size: 20.sp),
          ],
        ),
      ),
      // 🔥 قائمة غير المتطابقين مع مساحة محددة
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: ListView.builder(
            itemCount: _unmatchedRecords.length,
            padding: EdgeInsets.all(8.r),
            itemBuilder: (context, index) {
              final record = _unmatchedRecords[index];
              final studentId = record['_studentId']?.toString() ?? _extractStudentId(record);
              final studentName = record['name']?.toString() ?? record['_studentName']?.toString() ?? 'غير معروف';
              final reason = record['_reason']?.toString() ?? 'سبب غير معروف';
              
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getUnmatchedReasonColor(reason),
                    child: _getUnmatchedReasonIcon(reason),
                  ),
                  title: Text(studentName, style: font14black),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (studentId.isNotEmpty)
                        Text('رقم القيد: $studentId', style: font14grey),
                      SizedBox(height: 2.h),
                      Text('السبب: $reason', 
                        style: font12Grey.copyWith(
                          color: _getUnmatchedReasonColor(reason),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.warning, color: _getUnmatchedReasonColor(reason)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

Widget _buildNoResultsState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64.sp, color: Colors.grey[400]),
        SizedBox(height: 16.h),
        Text(
          'لا توجد نتائج',
          style: font18blackbold,
        ),
        SizedBox(height: 8.h),
        Text(
          'لم يتم العثور على طلاب مطابقين في البيانات',
          style: font14grey,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// 🔥 دوال مساعدة لتلوين الأسباب
Color _getUnmatchedReasonColor(String reason) {
  if (reason.contains('مضاف مسبقاً')) return Colors.orange;
  if (reason.contains('غير مسجل')) return Colors.red;
  if (reason.contains('لا يوجد رقم قيد')) return Colors.purple;
  return Colors.purple;
}

Widget _getUnmatchedReasonIcon(String reason) {
  if (reason.contains('مضاف مسبقاً')) return Icon(Icons.person_off, color: Colors.white, size: 16.sp);
  if (reason.contains('غير مسجل')) return Icon(Icons.person_remove, color: Colors.white, size: 16.sp);
  return Icon(Icons.warning, color: Colors.white, size: 16.sp);
}
// ✅ تحديث واجهة الأزرار
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _excelData.clear();
                    _matchedStudents.clear();
                    _unmatchedRecords.clear();
                    _totalRecords = 0;
                    _matchedCount = 0;
                    _unmatchedCount = 0;
                    _fileName = null;
                  });
                },
                child: Text('مسح النتائج', style: font15primary),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ButtonApp(
                textData: 'إضافة المتطابقين',
                onTop: _matchedStudents.isNotEmpty ? _returnSelectedStudents : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
          _fileName = result.files.single.name;
        });

        await _processExcelFile(File(result.files.single.path!));
      }
    } catch (e) {
      print('❌ خطأ في اختيار الملف: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في فتح الملف: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processExcelFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      final List<Map<String, dynamic>> data = [];
      
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        if (sheet.rows.isEmpty) continue;
        
        final headers = _extractHeaders(sheet.rows.first);

        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final rowData = _processDataRow(row, headers);
          
          if (rowData.isNotEmpty) {
            data.add(rowData);
          }
        }
      }

      await _matchStudentsWithUsers(data);
      
      setState(() {
        _excelData = data;
        _totalRecords = data.length;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ خطأ في معالجة ملف Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في معالجة الملف: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> _extractHeaders(List<Data?> headerRow) {
    final headers = <String>[];
    
    for (final cell in headerRow) {
      if (cell != null) {
        final header = _convertCellToString(cell);
        headers.add(header);
      } else {
        headers.add('');
      }
    }
    
    return headers;
  }

  Map<String, dynamic> _processDataRow(List<Data?> row, List<String> headers) {
    final rowData = <String, dynamic>{};
    
    for (int j = 0; j < headers.length && j < row.length; j++) {
      final cell = row[j];
      if (cell != null && headers[j].isNotEmpty) {
        final cellValue = _convertCellToString(cell);
        rowData[headers[j]] = cellValue;
      }
    }
    
    return rowData;
  }

  String _convertCellToString(Data cell) {
    try {
      if (cell.value == null) return '';
      
      final value = cell.value;
      
      if (value is String) {
        return (value?.toString() ?? '').trim();
      }
      
      if (value is int || value is double) {
        final numValue = value as num;
        if (numValue % 1 == 0) {
          return numValue.toInt().toString();
        } else {
          return numValue.toInt().toString();
        }
      }
      
      return value.toString().trim();
      
    } catch (e) {
      print('⚠️ خطأ في تحويل الخلية: $e');
      return cell.value?.toString() ?? '';
    }
  }

  Future<void> _matchStudentsWithUsers(List<Map<String, dynamic>> excelData) async {
    final userState = context.read<UserManagementBloc>().state;
    final allUsers = userState.users.where((user) => user.role == 'Student').toList();
    // 🔥 جلب الطلاب الحاليين في المجموعة
    final existingGroupStudents = await _getExistingGroupStudents();
    final existingStudentIds = existingGroupStudents.map((student) => student.studentId).toSet();
    
    _matchedStudents.clear();
    _unmatchedRecords.clear();

    for (final row in excelData) {
      final studentId = _extractStudentId(row);
      
      if (studentId.isNotEmpty) {
        final matchedUser = allUsers.firstWhere(
          (user) => user.userID == studentId,
          orElse: () => UserModels.empty,
        );

        if (matchedUser.isNotEmpty) {
        // 🔥 التحقق مما إذا كان الطالب مضافاً بالفعل في المجموعة
        if (existingStudentIds.contains(studentId)) {
          // الطالب موجود بالفعل في المجموعة - نضيفه للقائمة غير المتطابقة مع سبب واضح
          _unmatchedRecords.add({
            ...row,
            '_reason': 'الطالب مضاف مسبقاً في هذه المجموعة',
            '_studentId': studentId,
            '_studentName': matchedUser.name,
          });
        } else {
          // الطالب غير مضاف في المجموعة - نضيفه للقائمة المتطابقة
          _matchedStudents.add(matchedUser);
        }
      } else {
        // الطالب غير موجود في قاعدة البيانات
        _unmatchedRecords.add({
          ...row,
          '_reason': 'الطالب غير مسجل في النظام',
          '_studentId': studentId,
        });
      }
    } else {
      // لا يوجد رقم قيد
      _unmatchedRecords.add({
        ...row,
        '_reason': 'لا يوجد رقم قيد في السجل',
      });
    }
  }

    setState(() {
      _matchedCount = _matchedStudents.length;
      _unmatchedCount = _unmatchedRecords.length;
    });
  }

  // 🔥 دالة جديدة لجلب الطلاب المضافين مسبقاً في المجموعة
Future<List<StudentModel>> _getExistingGroupStudents() async {
  try {
    final semesterCoursesBloc = context.read<SemesterCoursesBloc>();
    final semesterId = semesterCoursesBloc.state.currentSemester?.id ?? '';
    
    print('🔍 جلب الطلاب الحاليين للمجموعة: ${widget.group.name}');
    
    final students = await semesterCoursesBloc.semesterRepository.getGroupStudents(
      semesterId,
      widget.courseId,
      widget.group.id,
    );
    
    print('✅ تم جلب ${students.length} طالب من المجموعة ${widget.group.name}');
    return students;
  } catch (e) {
    print('❌ خطأ في جلب الطلاب الحاليين للمجموعة: $e');
    return [];
  }
}

  String _extractStudentId(Map<String, dynamic> row) {
  // البحث عن رقم القيد بأشكاله المختلفة
  final possibleKeys = ['userID', 'رقم القيد', 'student_id', 'id', 'الرقم الجامعي', 'user_id', 'studentId'];
  
  for (final key in possibleKeys) {
    if (row.containsKey(key) && row[key] != null && row[key].toString().trim().isNotEmpty) {
      String value = row[key].toString().trim();
      
      // 🔥 تنظيف إضافي للبيانات
      value = value.replaceAll(RegExp(r'\.0$'), ''); // إزالة .0 من الأرقام
      value = value.replaceAll(RegExp(r'[^\d]'), ''); // إزالة جميع الأحرف غير الرقمية
      
      return value;
    }
  }
  
  return '';
}

  // ✅  دالة إرجاع البيانات
void _returnSelectedStudents() {
  if (_matchedStudents.isEmpty) {
    ShowWidget.showMessage(
    context,
    'لم يتم اختيار أي طلاب للإضافة',
  Colors.orange,
    font15White,
  );
    return;
  }

  print('📤 إرجاع البيانات للمجموعة: ${widget.group.name}');
  print('   🆔 معرف المجموعة: ${widget.group.id}');
  print('   👥 عدد الطلاب: ${_matchedStudents.length}');
  print('   📁 اسم الملف: ${_fileName ?? "غير معروف"}');

  // ✅ التأكد من أن البيانات تحتوي على userID صحيح
  for (final student in _matchedStudents) {
    print('   👤 التحقق من الطالب: ${student.name} - ${student.userID}');
    if (student.userID.isEmpty) {
      print('   ⚠️ تحذير: الطالب ${student.name} لا يحتوي على userID');
    }
  }

  // ✅ إرجاع البيانات للشاشة الرئيسية
  widget.onStudentsSelected(_matchedStudents, _excelData, _fileName ?? '');
  
  Navigator.pop(context);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم تحضير ${_matchedStudents.length} طالب للإضافة'),
      backgroundColor: Colors.green,
    ),
  );
}

}