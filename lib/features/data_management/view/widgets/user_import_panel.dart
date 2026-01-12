import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:user_repository/user_repository.dart';
/*
 * 👥 لوحة استيراد المستخدمين من Excel
 * 
 * التسلسل:
 * 1. اختيار الملف ومعالجته
 * 2. تحليل التكرارات في الملف وقاعدة البيانات
 * 3. معاينة البيانات الفريدة فقط
 * 4. الإرسال ← UserManagementBloc
 */
class UserImportPanel extends StatefulWidget {
  final VoidCallback onImportSuccess;

  const UserImportPanel({super.key, required this.onImportSuccess});

  @override
  State<UserImportPanel> createState() => _UserImportPanelState();
}

class _UserImportPanelState extends State<UserImportPanel> {
  List<Map<String, dynamic>> _excelData = [];
  bool _isLoading = false;
  String? _fileName;

  // 🔥 دالة لاختيار ملف Excel حقيقي
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
      ShowWidget.showMessage(
      context,
      'فشل في فتح الملف: ${e.toString()}',
      Colors.red,
      font15White,
      );
    }
  }

  // 🔥 دالة لمعالجة ملف Excel
  Future<void> _processExcelFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      final List<Map<String, dynamic>> data = [];
      
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        // افتراض أن الصف الأول يحتوي على العناوين
        if (sheet.rows.isEmpty) continue;
        
        final headers = _extractHeaders(sheet.rows.first);

        // 🔥 طباعة العناوين والأمثلة للتصحيح
        print('🏷️ عناوين الأعمدة المكتشفة:');
        headers.asMap().forEach((index, header) {
        print('   $index: "$header"');
        });
        
        // معالجة الصفوف بدءاً من الصف الثاني
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final rowData = _processDataRow(row, headers);
          
          if (rowData.isNotEmpty) {
            data.add(rowData);
            // 🔥 طباعة مثال للبيانات الخام للتصحيح
          if (i == 1) {
            print('🔍 مثال على البيانات الخام من Excel:');
            row.asMap().forEach((index, cell) {
              final cellType = cell?.value.runtimeType.toString() ?? 'null';
              final cellValue = cell?.value?.toString() ?? 'null';
              print('   الخلية $index: النوع=$cellType, القيمة="$cellValue"');
            });
          }
          }
        }
      }
      // 🔥 طباعة العناوين للتصحيح
      if (data.isNotEmpty) {
        print('🏷️ عناوين الأعمدة في الملف:');
        data.first.forEach((key, value) {
          print('   - "$key"');
        });
      }
      setState(() {
        _excelData = data;
        _isLoading = false;
      });
      
      print('✅ تم معالجة ${data.length} سجل من ملف Excel');
      
    } catch (e) {
      print('❌ خطأ في معالجة ملف Excel: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 دالة لاستخراج العناوين من الصف الأول
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

  // 🔥 دالة محسنة لمعالجة صف البيانات
Map<String, dynamic> _processDataRow(List<Data?> row, List<String> headers) {
  final rowData = <String, dynamic>{};
  
  for (int j = 0; j < headers.length && j < row.length; j++) {
    final cell = row[j];
    if (cell != null && headers[j].isNotEmpty) {
      // 🔥 تحويل جميع الخلايا إلى نص مع الحفاظ على التنسيق
      final cellValue = _convertCellToString(cell);
      // 🔥 تنظيف الأرقام بشكل إضافي
      String cleanedValue = cellValue;
      if (_isNumericColumn(headers[j])) {
        // إزالة .0 من نهاية الأرقام
        cleanedValue = cleanedValue.replaceAll(RegExp(r'\.0$'), '');
      }
      rowData[headers[j]] = cellValue;
    }
  }
  
  return rowData;
}
// 🔥 دالة مساعدة للتحقق إذا كان العمود رقمي
bool _isNumericColumn(String header) {
  final numericHeaders = ['رقم القيد', 'الرقم الوطني', 'userID', 'na_Number'];
  return numericHeaders.any(header.contains);
}

  // 🔥 دالة لتحويل أي نوع خلية إلى نص مع الحفاظ على التنسيق
String _convertCellToString(Data cell) {
  try {
    // معالجة أنواع البيانات المختلفة
    if (cell.value == null) return '';
    
    final value = cell.value;
    
    // إذا كان نصاً
    if (value is String) {
      return (value?.toString() ?? '').trim();
    }
    
    // إذا كان رقماً
    if (value is int || value is double) {
      // 🔥 الحفاظ على الأصفار البادئة بتحديد الطول المطلوب
      final numValue = value as num;
      
      // إذا كان الرقم يحتوي على فاصلة عشرية، احذفها
      if (numValue % 1 == 0) {
        // رقم صحيح - احتفظ به كما هو
        return numValue.toInt().toString();
      } else {
        // رقم عشري - حوله لصحيح (نحذف الكسور)
        return numValue.toInt().toString();
      }
    }
    
    // أنواع أخرى
    return value.toString().trim();
    
  } catch (e) {
    print('⚠️ خطأ في تحويل الخلية: $e');
    return cell.value?.toString() ?? '';
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🎯 رأس اللوحة
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('استيراد المستخدمين', style: font18blackbold),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        Divider(height: 1),
        Expanded(
          child: _isLoading 
              ? _buildLoadingState()
              : _excelData.isEmpty 
                  ? _buildImportGuide()
                  : _buildPreviewTable(),
        ),
        
        // 🔘 أزرار الإجراء
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _excelData.isEmpty ? _pickExcelFile : null,
                  child: Text('اختيار ملف Excel'),
                ),
              ),
              getWidth(12.w),
              Expanded(
                child: ButtonApp(
                  textData: 'استيراد البيانات',
                  onTop: _excelData.isNotEmpty ? _importUsers : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 تحديث زر اختيار الملف
  Widget _buildImportGuide() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 24.h),
          Text(
            'استيراد المستخدمين من ملف Excel',
            style: font20blackbold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'اختر ملف Excel يحتوي على بيانات المستخدمين',
            style: font16black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          
          // 📋 دليل الأعمدة (نفس الكود السابق)...
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الأعمدة المدعومة:', style: font16blackbold),
                SizedBox(height: 12.h),
                _buildColumnGuideItem('رقم القيد', 'userID', 'مطلوب'),
                _buildColumnGuideItem('الاسم', 'name', 'مطلوب'),
                _buildColumnGuideItem('البريد الإلكتروني', 'email', 'مطلوب'),
                _buildColumnGuideItem('الدور (تلقائي طالب)', 'role', 'مسئول, دكتور, طالب, رئيس'),
                _buildColumnGuideItem('الجنس', 'gender', 'ذكر, أنثى'),
                _buildColumnGuideItem('الرقم الوطني', 'na_Number', 'اختياري'),
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
    );
  }

  Widget _buildColumnGuideItem(String arabicName, String englishName, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 4.h, right: 12.w),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$arabicName', style: font14black),
                SizedBox(height: 2.h),
                Text(description, style: font12Grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 تحديث واجهة المعاينة لعرض التكرارات الحقيقية
Widget _buildPreviewTable() {
  return FutureBuilder<Map<String, dynamic>>(
    future: _analyzeDuplicates(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingState();
      }
      
      final duplicateInfo = snapshot.data!;
      final uniqueData = _getUniqueData(duplicateInfo);
      
      return Column(
        children: [
          // 🎯 رأس الجدول مع إحصائيات
          Container(
            padding: EdgeInsets.all(16.r),
            color: ColorsApp.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('المستخدمين الجدد الذين سيتم إضافتهم', style: font16White),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('${uniqueData.length} مستخدم', style: font13White),
                          Text('جديد', style: font11White),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_fileName != null)
                  Text(
                    'الملف: $_fileName',
                    style: font13White.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                // 🔥 عرض إحصائيات مفصلة
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (duplicateInfo['totalDuplicatesInFile'] > 0)
                        Row(
                          children: [
                            Icon(Icons.copy, color: Colors.orange, size: 14.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '${duplicateInfo['totalDuplicatesInFile']} مكرر في الملف - سيتم تخطيهم',
                                style: font13White,
                              ),
                            ),
                          ],
                        ),
                      if (duplicateInfo['totalDuplicatesInDatabase'] > 0)
                        Row(
                          children: [
                            Icon(Icons.storage, color: Colors.red, size: 14.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '${duplicateInfo['totalDuplicatesInDatabase']} موجود في النظام - سيتم تخطيهم',
                                style: font13White,
                              ),
                            ),
                          ],
                        ),
                      if (duplicateInfo['uniqueRecords'] > 0)
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '${duplicateInfo['uniqueRecords']} مستخدم جديد سيتم إضافته',
                                style: font13White.copyWith(color: Colors.green[100]),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 📊 جدول المعاينة (البيانات الفريدة فقط)
          Expanded(
            child: uniqueData.isEmpty 
                ? _buildNoUniqueDataState()
                : ListView.builder(
                    itemCount: uniqueData.length,
                    itemBuilder: (context, index) {
                      final row = uniqueData[index];
                      final mappedRow = _mapArabicToEnglishColumns(row);
                      
                      return Container(
                        padding: EdgeInsets.all(12.r),
                        margin: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30.w,
                                  child: Text('${index + 1}', style: font12black),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mappedRow['name']?.toString() ?? 'بدون اسم',
                                        style: font14black.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        mappedRow['email']?.toString() ?? 'بدون بريد',
                                        style: font12Grey,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  width: 80.w,
                                  child: Text(
                                    mappedRow['userID']?.toString() ?? 'بدون رقم',
                                    style: font12black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    _getRoleDisplayNameForPreview(mappedRow['role']),
                                    style: font11White,
                                  ),
                                  backgroundColor: _getRoleColor(mappedRow['role']),
                                ),
                                SizedBox(width: 8.w),
                                if (mappedRow['na_Number']?.toString().isNotEmpty ?? false)
                                  Text(
                                    'رقم وطني: ${mappedRow['na_Number']}',
                                    style: font12Grey,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}
// 🔥 دالة محسنة للحصول على البيانات الفريدة
List<Map<String, dynamic>> _getUniqueData(Map<String, dynamic> duplicateInfo) {
  final List<Map<String, dynamic>> uniqueData = [];
  final duplicatesInFile = duplicateInfo['duplicatesInFile'] as Map<int, dynamic>;
  final duplicatesInDatabase = duplicateInfo['duplicatesInDatabase'] as Map<int, dynamic>;
  
  for (int i = 0; i < _excelData.length; i++) {
    // 🔥 استبعاد المكررين في الملف وقاعدة البيانات
    if (!duplicatesInFile.containsKey(i) && !duplicatesInDatabase.containsKey(i)) {
      uniqueData.add(_excelData[i]);
    }
  }
  
  print('✅ البيانات الفريدة الجديدة: ${uniqueData.length} سجل');
  return uniqueData;
}
  // 🔥 واجهة عندما لا توجد بيانات فريدة جديدة
Widget _buildNoUniqueDataState() {
  return SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, size: 64.sp, color: Colors.orange),
          getHeight(16.h),
          Text(
            'لا توجد مستخدمين جدد',
            style: font18blackbold,
          ),
          getHeight(8.h),
          Text(
            'جميع المستخدمين في الملف إما مكررين أو موجودين مسبقاً في النظام',
            style: font14grey,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          ButtonApp(
            textData: 'اختيار ملف آخر',
            onTop: _pickExcelFile,
          ),
        ],
      ),
    ),
  );
}

// 🔥 دالة لتحليل التكرارات
Future<Map<String, dynamic>> _analyzeDuplicates() async {
  final userIDs = <String>{}; 
  final emails = <String>{};
  final duplicatesInFile = <int, Map<String, dynamic>>{};
  final duplicatesInDatabase = <int, Map<String, dynamic>>{};
  int totalDuplicatesInFile = 0;
  int totalDuplicatesInDatabase = 0;
  
  // 🔥 جلب المستخدمين الحاليين من قاعدة البيانات
  final existingUsers = await _getExistingUsers();
  final existingUserIDs = existingUsers.map((user) => user.userID).toSet();
  final existingEmails = existingUsers.map((user) => user.email.toLowerCase()).toSet();
  
  print('🔍 التحقق من التكرار في قاعدة البيانات: ${existingUserIDs.length} مستخدم موجود');
  
  for (int i = 0; i < _excelData.length; i++) {
    final row = _excelData[i];
    final mappedRow = _mapArabicToEnglishColumns(row);
    // 🔥 تنظيف البيانات قبل التحقق
    final userID = (mappedRow['userID']?.toString().trim() ?? '').replaceAll(RegExp(r'\.0$'), '');
    final email = (mappedRow['email']?.toString().trim().toLowerCase() ?? '').replaceAll(RegExp(r'\.0$'), '');
    print('🔍 فحص السجل $i: userID="$userID", email="$email"');
    
    final duplicateReasonsInFile = <String>[];
    final duplicateReasonsInDatabase = <String>[];
    bool isDuplicateInFile = false;
    bool isDuplicateInDatabase = false;
    
    // 🔥 التحقق من التكرار في الملف نفسه
    if (userIDs.contains(userID) && userID.isNotEmpty) {
      duplicateReasonsInFile.add('رقم القيد مكرر في الملف: $userID');
      isDuplicateInFile = true;
    }
    
    if (emails.contains(email) && email.isNotEmpty) {
      duplicateReasonsInFile.add('البريد الإلكتروني مكرر في الملف: $email');
      isDuplicateInFile = true;
    }
    
    // 🔥 التحقق من التكرار في قاعدة البيانات
    if (existingUserIDs.contains(userID) && userID.isNotEmpty) {
      duplicateReasonsInDatabase.add('رقم القيد موجود مسبقاً: $userID');
      isDuplicateInDatabase = true;
    }
    
    if (existingEmails.contains(email) && email.isNotEmpty) {
      duplicateReasonsInDatabase.add('البريد الإلكتروني موجود مسبقاً: $email');
      isDuplicateInDatabase = true;
    }
    
    if (isDuplicateInFile) {
      duplicatesInFile[i] = {
        'reasons': duplicateReasonsInFile,
        'userID': userID,
        'email': email,
        'type': 'file_duplicate'
      };
      totalDuplicatesInFile++;
    }
    
    if (isDuplicateInDatabase) {
      duplicatesInDatabase[i] = {
        'reasons': duplicateReasonsInDatabase,
        'userID': userID,
        'email': email,
        'type': 'database_duplicate'
      };
      totalDuplicatesInDatabase++;
    }
    
    userIDs.add(userID);
    emails.add(email);
  }
  
  final uniqueRecords = _excelData.length - totalDuplicatesInFile - totalDuplicatesInDatabase;
  
  print('''
  📊 تحليل التكرارات:
  📋 إجمالي السجلات: ${_excelData.length}
  🔄 مكرر في الملف: $totalDuplicatesInFile
  🗄️ مكرر في قاعدة البيانات: $totalDuplicatesInDatabase
  ✅ سجلات فريدة: $uniqueRecords
''');
  
  return {
    'totalDuplicatesInFile': totalDuplicatesInFile,
    'totalDuplicatesInDatabase': totalDuplicatesInDatabase,
    'totalDuplicates': totalDuplicatesInFile + totalDuplicatesInDatabase,
    'duplicatesInFile': duplicatesInFile,
    'duplicatesInDatabase': duplicatesInDatabase,
    'uniqueRecords': uniqueRecords,
    'existingUsersCount': existingUserIDs.length,
  };
}
// 🔥 دالة مساعدة لجلب المستخدمين الحاليين
Future<List<UserModels>> _getExistingUsers() async {
  try {
    // استخدام الـ Bloc للحصول على المستخدمين الحاليين
    final userManagementBloc = context.read<UserManagementBloc>();
    final currentState = userManagementBloc.state;
    
    if (currentState.users.isNotEmpty) {
      return currentState.users;
    }
    
    // إذا لم تكن البيانات محملة، جلبها مباشرة
    final userRepository = context.read<UserManagementBloc>().userRepository;
    return await userRepository.getAllUsers();
  } catch (e) {
    print('❌ خطأ في جلب المستخدمين الحاليين: $e');
    return [];
  }
}
// 🔥 دالة جديدة لعرض الدور بالعربية في المعاينة
String _getRoleDisplayNameForPreview(String? role) {
  if (role == null) return 'طالب';
  
  switch (role.toLowerCase()) {
      case 'admin': return 'دراسة و الامتحانات';
      case 'Admin': return 'دراسة و الامتحانات';
      case 'doctor': return 'دكتور';
      case 'Doctor': return 'دكتور';
      case 'manager': return 'مدير';
      case 'Manager': return 'مدير';
      case 'student': return 'طالب';
      case 'Student': return 'طالب';
    default: return role;
  }
}

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          SizedBox(height: 16.h),
          Text('جاري معالجة البيانات...', style: font16black),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case   'admin': return Colors.red;
      case   'Admin': return Colors.red;
      case  'Doctor': return Colors.blue;
      case  'doctor': return Colors.blue;
      case 'Manager': return Colors.orange;
      case 'manager': return Colors.orange;
      case 'Student': return Colors.green;
      case 'student': return Colors.green;
      default: return Colors.green;
    }
  }

  void _importUsers() async {
  if (_excelData.isEmpty) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // 🔥 تحليل التكرارات قبل الإرسال
    final duplicateAnalysis = await _analyzeDuplicates();
    final uniqueRecordsCount = duplicateAnalysis['uniqueRecords'];
    final duplicateInFileCount = duplicateAnalysis['totalDuplicatesInFile'];
    final duplicateInDatabaseCount = duplicateAnalysis['totalDuplicatesInDatabase'];

    print('''
📊 تحليل البيانات قبل الاستيراد:
📋 إجمالي السجلات: ${_excelData.length}
🔄 مكرر في الملف: $duplicateInFileCount
🗄️ موجود في النظام: $duplicateInDatabaseCount
✅ سجلات فريدة: $uniqueRecordsCount
''');

    if (uniqueRecordsCount == 0) {
      setState(() {
        _isLoading = false;
      });
      ShowWidget.showMessage( 
        context, 
        '⚠️ لا توجد مستخدمين جدد للاستيراد\n'
        'جميع المستخدمين إما مكررين في الملف أو موجودين مسبقاً في النظام',
        Colors.orange, 
        font15White,
      );
      return;
    }

    // 🔥 تصفية البيانات لإرسال الفريدة فقط
    final uniqueData = _getUniqueData(duplicateAnalysis);
    final convertedData = uniqueData.map((row) => _mapArabicToEnglishColumns(row)).toList();
    
    print('📤 إرسال ${convertedData.length} مستخدم جديد إلى الـ Bloc');

    context.read<UserManagementBloc>().add(ImportUsersFromExcel(convertedData));

    // 🔥 عرض رسالة نجاح
    ShowWidget.showMessage( 
      context, 
      '✅ تم بدء استيراد $uniqueRecordsCount مستخدم جديد\n'
      '🔄 تم تخطي $duplicateInFileCount مكرر في الملف\n'
      '🗄️ تم تخطي $duplicateInDatabaseCount موجود في النظام',
      Colors.green, 
      font15White,
    );

    // محاكاة نجاح الاستيراد
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      widget.onImportSuccess();
    });

  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    print('❌ خطأ في تحليل البيانات: $e');
    ShowWidget.showMessage( 
      context, 
      '❌ فشل في تحليل البيانات: $e',
      Colors.red, 
      font15White
    );
  }
}
  // 🔥 دالة محسنة لتحويل الأعمدة العربية إلى الإنجليزية
Map<String, dynamic> _mapArabicToEnglishColumns(Map<String, dynamic> row) {
  final mappedRow = <String, dynamic>{};
  
  // قائمة التعيين الموسعة بين الأعمدة العربية والإنجليزية
  final columnMapping = {
    // الأعمدة الأساسية
    'رقم القيد': 'userID',
    'الاسم': 'name',
    'البريد الإلكتروني': 'email',
    'الدور': 'role',
    'الجنس': 'gender',
    'الرقم الوطني': 'na_Number',
    
    // أشكال بديلة للعناوين
    'اسم المستخدم': 'name',
    'ايميل': 'email',
    'دور': 'role',
    'جنس': 'gender',
    'رقم وطني': 'na_Number',
    'الرقم الجامعي': 'userID',
    'رقم الجامعة': 'userID',
    
    // التعامل مع الحروف المختلفة
    'البريد الالكتروني': 'email',
    'الايميل': 'email',
  };

  // 🔥 دالة لتحويل الأدوار من العربي إلى الإنجليزي
  String convertRoleToEnglish(String arabicRole) {
    switch (arabicRole.trim().toLowerCase()) {
      case 'طالب': return 'Student';
      case 'student': return 'Student';
      case 'دكتور': return 'Doctor';
      case 'doctor': return 'Doctor';
      case 'مدير': return 'Admin';
      case 'admin': return 'Admin';
      case 'مسئول': return 'Manager';
      case 'manager': return 'Manager';
      case 'رئيس': return 'Manager';
      default: return 'Student'; 
    }
  }

  // 🔥 دالة لتحويل الجنس من العربي إلى الإنجليزي
  String _convertGenderToEnglish(String arabicGender) {
    switch (arabicGender.trim().toLowerCase()) {
      case 'ذكر': return 'Male';
      case 'أنثى': return 'Female';
      case 'male': return 'Male';
      case 'female': return 'Female';
      default: return 'Male'; 
    }
  }

  row.forEach((key, value) {
    // تنظيف المفتاح من المسافات الزائدة
    final cleanKey = key.toString().trim();
    
    // البحث عن المفتاح المناسب
    String? englishKey = columnMapping[cleanKey];
    
    // إذا لم يتم العثور، البحث الجزئي
    if (englishKey == null) {
      for (final arabicKey in columnMapping.keys) {
        if (cleanKey.contains(arabicKey) || arabicKey.contains(cleanKey)) {
          englishKey = columnMapping[arabicKey];
          break;
        }
      }
    }
    
    // إذا لم يتم العثور بعد، استخدام المفتاح الأصلي
    englishKey ??= cleanKey;
    
    // فقط إذا كانت القيمة ليست فارغة
    if (value != null && value.toString().trim().isNotEmpty) {
      // 🔥 إذا كان العمود هو "الدور"، قم بتحويله إلى إنجليزي
      if (englishKey == 'role') {
        mappedRow[englishKey] = convertRoleToEnglish(value.toString());
        // 🔥 إذا كان العمود هو "الجنس"، قم بتحويله إلى إنجليزي
      }else if (englishKey == 'gender') {
        mappedRow[englishKey] = _convertGenderToEnglish(value.toString());
      
      } else {
        mappedRow[englishKey] = value;
      }
    }
  });
  // 🔥 تعيين قيم افتراضية إذا لم تكن موجودة
  if (!mappedRow.containsKey('role') || mappedRow['role'] == null) {
    mappedRow['role'] = 'Student';
  }
  if (!mappedRow.containsKey('gender') || mappedRow['gender'] == null) {
    mappedRow['gender'] = 'Male';
  }

  print('🔤 تحويل الأعمدة: $row → $mappedRow');
  return mappedRow;
}
}