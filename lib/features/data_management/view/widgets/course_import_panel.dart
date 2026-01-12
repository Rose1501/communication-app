import 'package:course_repository/course_repository.dart';
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
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
/*
 * 📤 لوحة استيراد المواد من ملف Excel
 * 
 * التسلسل:
 * 1. اختيار الملف ← FilePicker
 * 2. معالجة البيانات ← Excel.decodeBytes
 * 3. تحليل التكرارات ← _analyzeDuplicates()
 * 4. المعاينة ← _buildPreviewTable()
 * 5. الإرسال ← DataManagementBloc
 */
class CourseImportPanel extends StatefulWidget {
  final VoidCallback onImportSuccess;

  const CourseImportPanel({super.key, required this.onImportSuccess});

  @override
  State<CourseImportPanel> createState() => _CourseImportPanelState();
}

class _CourseImportPanelState extends State<CourseImportPanel> {
  List<Map<String, dynamic>> _excelData = [];
  bool _isLoading = false;
  String? _fileName;

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

  Future<void> _processExcelFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      final List<Map<String, dynamic>> data = [];
      
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        if (sheet.rows.isEmpty) continue;
        
        final headers = _extractHeaders(sheet.rows.first);

        print('🏷️ عناوين الأعمدة المكتشفة:');
        headers.asMap().forEach((index, header) {
          print('   $index: "$header"');
        });
        
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final rowData = _processDataRow(row, headers);
          
          if (rowData.isNotEmpty) {
            data.add(rowData);
          }
        }
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
        String cleanedValue = cellValue;
        if (_isNumericColumn(headers[j])) {
          cleanedValue = cleanedValue.replaceAll(RegExp(r'\.0$'), '');
        }
        rowData[headers[j]] = cellValue;
      }
    }
    
    return rowData;
  }

  bool _isNumericColumn(String header) {
    final numericHeaders = ['الساعات_المعتمدة', 'credits'];
    return numericHeaders.any(header.contains);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('استيراد المواد', style: font18blackbold),
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
                  onTop: _excelData.isNotEmpty ? _importCourses : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportGuide() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 24.h),
          Text(
            'استيراد المواد من ملف Excel',
            style: font20blackbold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'اختر ملف Excel يحتوي على بيانات المواد',
            style: font16black,
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
                Text('الأعمدة المدعومة:', style: font16blackbold),
                SizedBox(height: 12.h),
                _buildColumnGuideItem('اسم_المادة', 'name', 'مطلوب'),
                _buildColumnGuideItem('رمز_المادة', 'code_cs', 'مطلوب'),
                _buildColumnGuideItem('الساعات_المعتمدة', 'credits', 'مطلوب (رقم)'),
                _buildColumnGuideItem('المتطلبات_السابقة', 'requset_courses', 'اختياري (رموز مفصولة بفواصل)'),
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
        final totalDuplicates = duplicateInfo['uniqueRecords'] + duplicateInfo['totalDuplicatesInDatabase'] as int;
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
                        child: Text('المواد الجديدة التي سيتم إضافتها', style: font16White),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('${uniqueData.length} مادة', style: font13White),
                            Text('جديدة', style: font11White),

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
                                  '${duplicateInfo['uniqueRecords']} مادة جديدة سيتم إضافتها من ${totalDuplicates}',
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
                                          mappedRow['code_cs']?.toString() ?? 'بدون رمز',
                                          style: font12Grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                    width: 40.w,
                                    child: Text(
                                      '${mappedRow['credits']} ساعة',
                                      style: font12black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              if (mappedRow['requset_courses']?.toString().isNotEmpty ?? false)
                                Text(
                                  'المتطلبات: ${mappedRow['requset_courses']}',
                                  style: font12Grey,
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
    
    print('✅ المواد الفريدة الجديدة: ${uniqueData.length} سجل');
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
              'لا توجد مواد جديدة',
              style: font18blackbold,
            ),
            getHeight(8.h),
            Text(
              'جميع المواد في الملف إما مكررة أو موجودة مسبقاً في النظام',
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

  // 🔥 دالة لتحليل التكرارات للمواد
  Future<Map<String, dynamic>> _analyzeDuplicates() async {
    final courseCodes = <String>{}; 
    final duplicatesInFile = <int, Map<String, dynamic>>{};
    final duplicatesInDatabase = <int, Map<String, dynamic>>{};
    int totalDuplicatesInFile = 0;
    int totalDuplicatesInDatabase = 0;
    
    // 🔥 جلب المواد الحالية من قاعدة البيانات
    final existingCourses = await _getExistingCourses();
    final existingCourseCodes = existingCourses.map((course) => course.codeCs).toSet();
    
    print('🔍 التحقق من التكرار في قاعدة البيانات: ${existingCourseCodes.length} مادة موجودة');
    
    for (int i = 0; i < _excelData.length; i++) {
      final row = _excelData[i];
      final mappedRow = _mapArabicToEnglishColumns(row);
      
      // 🔥 تنظيف البيانات قبل التحقق
      final courseCode = (mappedRow['code_cs']?.toString().trim() ?? '').replaceAll(RegExp(r'\.0$'), '');
      final courseName = (mappedRow['name']?.toString().trim() ?? '');
      
      print('🔍 فحص السجل $i: code="$courseCode", name="$courseName"');
      
      final duplicateReasonsInFile = <String>[];
      final duplicateReasonsInDatabase = <String>[];
      bool isDuplicateInFile = false;
      bool isDuplicateInDatabase = false;
      
      // 🔥 التحقق من التكرار في الملف نفسه
      if (courseCodes.contains(courseCode) && courseCode.isNotEmpty) {
        duplicateReasonsInFile.add('رمز المادة مكرر في الملف: $courseCode');
        isDuplicateInFile = true;
      }
      
      // 🔥 التحقق من التكرار في قاعدة البيانات
      if (existingCourseCodes.contains(courseCode) && courseCode.isNotEmpty) {
        duplicateReasonsInDatabase.add('رمز المادة موجود مسبقاً: $courseCode');
        isDuplicateInDatabase = true;
      }
      
      if (isDuplicateInFile) {
        duplicatesInFile[i] = {
          'reasons': duplicateReasonsInFile,
          'code': courseCode,
          'name': courseName,
          'type': 'file_duplicate'
        };
        totalDuplicatesInFile++;
      }
      
      if (isDuplicateInDatabase) {
        duplicatesInDatabase[i] = {
          'reasons': duplicateReasonsInDatabase,
          'code': courseCode,
          'name': courseName,
          'type': 'database_duplicate'
        };
        totalDuplicatesInDatabase++;
      }
      
      courseCodes.add(courseCode);
    }
    
    final uniqueRecords = _excelData.length - totalDuplicatesInFile - totalDuplicatesInDatabase;
    
    print('''
  📊 تحليل التكرارات للمواد:
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
      'existingCoursesCount': existingCourseCodes.length,
    };
  }

  // 🔥 دالة مساعدة لجلب المواد الحالية
  Future<List<CourseModel>> _getExistingCourses() async {
    try {
      // استخدام الـ Bloc للحصول على المواد الحالية
      final dataManagementBloc = context.read<DataManagementBloc>();
      final currentState = dataManagementBloc.state;
      
      if (currentState.courses.isNotEmpty) {
        return currentState.courses;
      }
      
      // إذا لم تكن البيانات محملة، جلبها مباشرة
      final courseRepository = context.read<DataManagementBloc>().courseRepository;
      return await courseRepository.getAllCourses();
    } catch (e) {
      print('❌ خطأ في جلب المواد الحالية: $e');
      return [];
    }
  }
  
  Map<String, dynamic> _mapArabicToEnglishColumns(Map<String, dynamic> row) {
    final mappedRow = <String, dynamic>{};
    
    final columnMapping = {
      'اسم_المادة': 'name',
      'رمز_المادة': 'code_cs',
      'الساعات_المعتمدة': 'credits',
      'المتطلبات_السابقة': 'requset_courses',
      
      // أشكال بديلة
      'اسم المادة': 'name',
      'رمز المادة': 'code_cs',
      'ساعات معتمدة': 'credits',
      'متطلبات سابقة': 'requset_courses',
    };

    row.forEach((key, value) {
      final cleanKey = key.toString().trim();
      String? englishKey = columnMapping[cleanKey];
      
      if (englishKey == null) {
        for (final arabicKey in columnMapping.keys) {
          if (cleanKey.contains(arabicKey) || arabicKey.contains(cleanKey)) {
            englishKey = columnMapping[arabicKey];
            break;
          }
        }
      }
      
      englishKey ??= cleanKey;
      
      if (value != null && value.toString().trim().isNotEmpty) {
        mappedRow[englishKey] = value;
      }
    });

    return mappedRow;
  }

  void _importCourses() async {
    if (_excelData.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final convertedData = _excelData.map((row) => _mapArabicToEnglishColumns(row)).toList();
      
      print('📤 إرسال ${convertedData.length} مادة جديدة إلى الـ Bloc');

      // استخدام الـ Bloc لاستيراد المواد
      context.read<DataManagementBloc>().add(ImportCoursesFromExcel(convertedData));

      ShowWidget.showMessage( 
        context, 
        '✅ تم بدء استيراد ${convertedData.length} مادة جديدة',
        Colors.green, 
        font15White,
      );

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
      print('❌ خطأ في استيراد المواد: $e');
      ShowWidget.showMessage( 
        context, 
        '❌ فشل في استيراد المواد: $e',
        Colors.red, 
        font15White
      );
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
}