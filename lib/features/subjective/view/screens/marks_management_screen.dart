import 'dart:io';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel;
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/widgets/add_exam_column_dialog.dart';
import 'package:myproject/features/subjective/view/widgets/edit_grade_dialog.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class MarksManagementScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;

  const MarksManagementScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
  });

  @override
  State<MarksManagementScreen> createState() => _MarksManagementScreenState();
}

class _MarksManagementScreenState extends State<MarksManagementScreen> {
  final List<ExamColumn> _examColumns = [];
  final Map<String, Map<String, double>> _studentGrades = {};
  final Map<String, Map<String, String>> _gradeIds = {};
  int _selectedGroupIndex = 0;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false; // 🔥 متغير جديد لتتبع التغييرات

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadExistingGrades();
    _initializeDefaultColumns();
  }

  void _initializeDefaultColumns() {
    _examColumns.addAll([
      ExamColumn(id: 'midterm', name: 'نصفي', maxGrade: 20.0),
      ExamColumn(id: 'final', name: 'نهائي', maxGrade: 40.0),
      ExamColumn(id: 'practical', name: 'عملي', maxGrade: 10.0),
    ]);
  }

  void _loadExistingGrades() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectiveBloc>().add(
        LoadExamGradesEvent(
          courseId: widget.course.id,
          groupId: widget.selectedGroups.first.id,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is ExamGradesLoadSuccess) {
          _processLoadedGrades(state.examGrades);
        }
        if (state is SubjectiveOperationSuccess) {
          if (state.message.contains('حذف') || state.message.contains('تمت')) {
            ShowWidget.showMessage(context, state.message, ColorsApp.green, font13White);
            Future.delayed(Duration(milliseconds: 500), () {
              _loadExistingGrades();
            });
          }
        }
        if (state is SubjectiveError) {
          ShowWidget.showMessage(context, state.message, ColorsApp.red, font13White);
        }
      },
      child: WillPopScope( // 🔥 إضافة WillPopScope
        onWillPop: () async {
          return await _handleBackButton();
        },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إدارة الدرجات', style: font16White),
              Text(
                '${widget.course.name} - ${widget.selectedGroups.length} مجموعة',
                style: font11White,
              ),
            ],
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back,),
              onPressed: () async {
                bool canPop = await _handleBackButton();
                if (canPop && mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          backgroundColor: ColorsApp.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.add_chart, color: ColorsApp.white),
              onPressed: _addNewExamColumn,
              tooltip: 'إضافة عمود امتحان',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.save, color: ColorsApp.white),
              tooltip: 'خيارات الحفظ',
              onSelected: (value) {
                if (value == 'save') {
                  _saveAllGrades();
                } else if (value == 'export') {
                  _exportToExcel();
                } else if (value == 'export_local') {
                  _saveExcelToDevice();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.save, color: ColorsApp.primaryColor),
                      SizedBox(width: 8),
                      Text('حفظ الدرجات'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: ColorsApp.primaryColor),
                      SizedBox(width: 8),
                      Text('تصدير إلى Excel'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export_local',
                  child: Row(
                    children: [
                      Icon(Icons.save_alt, color: ColorsApp.primaryColor),
                      SizedBox(width: 8),
                      Text('حفظ Excel على الجهاز'),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: ColorsApp.white),
              onPressed: _refreshData,
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: BlocBuilder<SubjectiveBloc, SubjectiveState>(
          builder: (context, state) {
            if (state is SubjectiveLoading && _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildGradesTable(),
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  // 🔥 دالة التعامل مع زر الرجوع
  Future<bool> _handleBackButton() async {
    // التحقق مما إذا كان هناك تغييرات غير محفوظة
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('تأكيد الخروج'),
          content: Text('لديك تغييرات غير محفوظة في الدرجات. هل تريد حفظ التغييرات قبل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('خروج دون حفظ', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('حفظ والخروج'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('إلغاء'),
            ),
          ],
        ),
      );
      
      if (result == null) {
        return false; // إلغاء الخروج
      } else if (result == true) {
        // حفظ ثم الخروج
        await _saveAllGrades();
        return true;
      } else {
        // الخروج دون حفظ
        return true;
      }
    }
    
    return true; // لا توجد تغييرات، الخروج مباشرة
  }

  // 🔥 تصدير إلى Excel (مشاركة)
  Future<void> _exportToExcel() async {
    if (widget.selectedGroups.isEmpty) return;

    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    final students = currentGroup.students;

    if (students.isEmpty) {
      ShowWidget.showMessage(
        context,
        'لا يوجد طلاب في المجموعة',
        ColorsApp.orange,
        font13White,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إنشاء مصنف Excel
      final excelEngine = excel.Excel.createExcel();
      final sheet = excelEngine['سجل الدرجات'];

      // معلومات العنوان
      sheet.appendRow([
        excel.TextCellValue('سجل الدرجات'),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
      ]);

      sheet.appendRow([
        excel.TextCellValue('المادة:'),
        excel.TextCellValue(widget.course.name),
      ]);

      sheet.appendRow([
        excel.TextCellValue('المجموعة:'),
        excel.TextCellValue(currentGroup.name),
      ]);

      sheet.appendRow([
        excel.TextCellValue('التاريخ:'),
        excel.TextCellValue(DateFormat('yyyy/MM/dd').format(DateTime.now())),
      ]);

      sheet.appendRow([]); // سطر فارغ

      // رؤوس الأعمدة
      final headers = ['م', 'اسم الطالب', 'رقم القيد'];
      for (final column in _examColumns) {
        headers.add('${column.name} (${column.maxGrade})');
      }
      headers.addAll(['المجموع', 'النسبة']);

      sheet.appendRow(headers.map((h) => excel.TextCellValue(h)).toList());

      // بيانات الطلاب
      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        final studentId = student.id;
        final studentGrades = _studentGrades[studentId] ?? {};

        // حساب المجموع
        double total = 0.0;
        double maxTotal = 0.0;
        for (final column in _examColumns) {
          final grade = studentGrades[column.id] ?? 0.0;
          total += grade;
          maxTotal += column.maxGrade;
        }
        final percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;

        // إنشاء صف البيانات
        final rowData = [
          excel.TextCellValue((i + 1).toString()),
          excel.TextCellValue(student.name),
          excel.TextCellValue(student.studentId),
        ];

        // إضافة درجات الأعمدة
        for (final column in _examColumns) {
          final grade = studentGrades[column.id] ?? 0.0;
          rowData.add(excel.TextCellValue(grade.toStringAsFixed(1)));
        }

        // إضافة المجموع والنسبة
        rowData.add(excel.TextCellValue(total.toStringAsFixed(1)));
        rowData.add(excel.TextCellValue('${percentage.toStringAsFixed(1)}%'));

        sheet.appendRow(rowData);
      }

      sheet.appendRow([]); // سطر فارغ

      // إضافة الإحصائيات
      sheet.appendRow([excel.TextCellValue('الإحصائيات:')]);

      // إحصاءات لكل عمود
      for (final column in _examColumns) {
        double columnTotal = 0.0;
        int count = 0;

        for (final student in students) {
          final grade = _studentGrades[student.id]?[column.id] ?? 0.0;
          if (grade > 0) {
            columnTotal += grade;
            count++;
          }
        }

        final average = count > 0 ? columnTotal / count : 0.0;
        final successRate = (count / students.length) * 100;

        sheet.appendRow([
          excel.TextCellValue('${column.name}:'),
          excel.TextCellValue('المعدل: ${average.toStringAsFixed(1)}'),
          excel.TextCellValue('نسبة النجاح: ${successRate.toStringAsFixed(1)}%'),
        ]);
      }

      // حفظ الملف مؤقتاً
      final directory = await getTemporaryDirectory();
      final fileName = 'درجات_${widget.course.name}_${currentGroup.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excelEngine.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // مشاركة الملف
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'سجل درجات ${widget.course.name} - ${currentGroup.name}',
          subject: 'تصدير سجل الدرجات',
        );

        ShowWidget.showMessage(
          context,
          '✅ تم تصدير الملف Excel بنجاح',
          ColorsApp.green,
          font13White,
        );

        print('📁 تم حفظ الملف: $filePath');
      } else {
        throw Exception('فشل في إنشاء ملف Excel');
      }
    } catch (e, stackTrace) {
      print('❌ خطأ في تصدير Excel: $e');
      print('📋 StackTrace: $stackTrace');

      ShowWidget.showMessage(
        context,
        'خطأ في التصدير: ${e.toString().split('\n').first}',
        ColorsApp.red,
        font13White,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 حفظ Excel على الجهاز (بدون مشاركة)
  Future<void> _saveExcelToDevice() async {
    if (widget.selectedGroups.isEmpty) return;

    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    final students = currentGroup.students;

    if (students.isEmpty) {
      ShowWidget.showMessage(
        context,
        'لا يوجد طلاب في المجموعة',
        ColorsApp.orange,
        font13White,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إنشاء مصنف Excel بنفس الطريقة
      final excelEngine = excel.Excel.createExcel();
      final sheet = excelEngine['سجل الدرجات'];

      // معلومات العنوان
      sheet.appendRow([
        excel.TextCellValue('سجل الدرجات'),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
      ]);

      sheet.appendRow([
        excel.TextCellValue('المادة:'),
        excel.TextCellValue(widget.course.name),
      ]);

      sheet.appendRow([
        excel.TextCellValue('المجموعة:'),
        excel.TextCellValue(currentGroup.name),
      ]);

      sheet.appendRow([
        excel.TextCellValue('التاريخ:'),
        excel.TextCellValue(DateFormat('yyyy/MM/dd').format(DateTime.now())),
      ]);

      sheet.appendRow([]);

      // رؤوس الأعمدة
      final headers = ['م', 'اسم الطالب', 'رقم القيد'];
      for (final column in _examColumns) {
        headers.add('${column.name} (${column.maxGrade})');
      }
      headers.addAll(['المجموع', 'النسبة', 'التقدير']);

      sheet.appendRow(headers.map((h) => excel.TextCellValue(h)).toList());

      // بيانات الطلاب
      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        final studentId = student.id;
        final studentGrades = _studentGrades[studentId] ?? {};

        // حساب المجموع والنسبة
        double total = 0.0;
        double maxTotal = 0.0;
        for (final column in _examColumns) {
          final grade = studentGrades[column.id] ?? 0.0;
          total += grade;
          maxTotal += column.maxGrade;
        }
        final percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;
        final gradeLetter = _getGradeLetter(percentage);

        // إنشاء صف البيانات
        final rowData = [
          excel.TextCellValue((i + 1).toString()),
          excel.TextCellValue(student.name),
          excel.TextCellValue(student.studentId),
        ];

        // إضافة درجات الأعمدة
        for (final column in _examColumns) {
          final grade = studentGrades[column.id] ?? 0.0;
          rowData.add(excel.TextCellValue(grade.toStringAsFixed(1)));
        }

        // إضافة المجموع والنسبة والتقدير
        rowData.add(excel.TextCellValue(total.toStringAsFixed(1)));
        rowData.add(excel.TextCellValue('${percentage.toStringAsFixed(1)}%'));
        rowData.add(excel.TextCellValue(gradeLetter));

        sheet.appendRow(rowData);
      }

      // إضافة ملخص الإحصائيات
      sheet.appendRow([]);
      sheet.appendRow([excel.TextCellValue('ملخص الإحصائيات')]);
      
      final stats = _calculateStatistics(students);
      sheet.appendRow([
        excel.TextCellValue('أعلى درجة:'),
        excel.TextCellValue(stats.highestGrade.toStringAsFixed(1)),
      ]);
      sheet.appendRow([
        excel.TextCellValue('أقل درجة:'),
        excel.TextCellValue(stats.lowestGrade.toStringAsFixed(1)),
      ]);
      sheet.appendRow([
        excel.TextCellValue('المعدل العام:'),
        excel.TextCellValue(stats.average.toStringAsFixed(1)),
      ]);
      sheet.appendRow([
        excel.TextCellValue('الانحراف المعياري:'),
        excel.TextCellValue(stats.standardDeviation.toStringAsFixed(2)),
      ]);

      // حفظ الملف في مجلد التنزيلات
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('لا يمكن الوصول إلى مجلد التنزيلات');
      }

      final fileName = 'درجات_${widget.course.name.replaceAll(' ', '_')}_${currentGroup.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${downloadsDir.path}/$fileName';

      final fileBytes = excelEngine.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        ShowWidget.showMessage(
          context,
          ' تم حفظ ملف Excel بنجاح',
          ColorsApp.green,
          font13White,
        );

        print('📁 تم حفظ الملف Excel في: $filePath');
      } else {
        throw Exception('فشل في إنشاء ملف Excel');
      }
    } catch (e) {
      print('❌ خطأ في حفظ Excel: $e');

      // محاولة بديلة: حفظ في Documents
      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        final fileName = 'درجات_${currentGroup.name}.xlsx';
        final filePath = '${documentsDir.path}/$fileName';

        // إنشاء Excel مبسط
        final excelEngine = excel.Excel.createExcel();
        final sheet = excelEngine['سجل الدرجات'];

        sheet.appendRow([excel.TextCellValue('سجل درجات ${widget.course.name}')]);
        sheet.appendRow([excel.TextCellValue('المجموعة: ${currentGroup.name}')]);
        sheet.appendRow([excel.TextCellValue('التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}')]);
        sheet.appendRow([]);

        int row = 5;
        for (int i = 0; i < students.length; i++) {
          final student = students[i];
          sheet.appendRow([excel.TextCellValue('${i + 1}. ${student.name}')]);
        }

        final fileBytes = excelEngine.save();
        if (fileBytes != null) {
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);

          ShowWidget.showMessage(
            context,
            'تم حفظ نسخة مبسطة في:\n${documentsDir.path}',
            ColorsApp.green,
            font13White,
          );
        }
      } catch (e2) {
        ShowWidget.showMessage(
          context,
          '❌ فشل حفظ الملف\n$e',
          ColorsApp.red,
          font13White,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 دوال مساعدة للإحصائيات

  Statistics _calculateStatistics(List<StudentModel> students) {
    final grades = <double>[];

    for (final student in students) {
      double studentTotal = 0.0;
      for (final column in _examColumns) {
        studentTotal += _studentGrades[student.id]?[column.id] ?? 0.0;
      }
      grades.add(studentTotal);
    }

    if (grades.isEmpty) {
      return Statistics(
        highestGrade: 0,
        lowestGrade: 0,
        average: 0,
        standardDeviation: 0,
      );
    }

    final highest = grades.reduce((a, b) => a > b ? a : b);
    final lowest = grades.reduce((a, b) => a < b ? a : b);
    final sum = grades.reduce((a, b) => a + b);
    final average = sum / grades.length;

    // حساب الانحراف المعياري
    double variance = 0;
    for (final grade in grades) {
      variance += pow(grade - average, 2);
    }
    variance /= grades.length;
    final standardDeviation = sqrt(variance);

    return Statistics(
      highestGrade: highest,
      lowestGrade: lowest,
      average: average,
      standardDeviation: standardDeviation,
    );
  }

  String _getGradeLetter(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'راسب';
  }

  // ========== باقي دوال الصفحة ==========

  void _processLoadedGrades(List<ExamGradeModel> grades) {
    print('🔄 معالجة ${grades.length} درجة محملة');
    setState(() {
      _updateExamColumnsFromGrades(grades);
      _populateStudentGrades(grades);
    });
  }

  void _updateExamColumnsFromGrades(List<ExamGradeModel> grades) {
    final existingColumns = <String, ExamColumn>{};

    for (final grade in grades) {
      if (!existingColumns.containsKey(grade.examType)) {
        existingColumns[grade.examType] = ExamColumn(
          id: _generateColumnId(grade.examType),
          name: grade.examType,
          maxGrade: grade.maxGrade,
        );
      }
    }

    final defaultColumns = _getDefaultColumns();
    for (final column in defaultColumns) {
      if (!existingColumns.containsKey(column.name)) {
        existingColumns[column.name] = column;
      }
    }

    _examColumns.clear();
    _examColumns.addAll(existingColumns.values);
  }

  void _populateStudentGrades(List<ExamGradeModel> grades) {
    for (final grade in grades) {
      final studentId = grade.studentId;
      final columnName = grade.examType;

      final column = _examColumns.firstWhere(
        (col) => col.name == columnName,
        orElse: () => ExamColumn(
          id: _generateColumnId(columnName),
          name: columnName,
          maxGrade: grade.maxGrade,
        ),
      );

      _studentGrades.putIfAbsent(studentId, () => {});
      _studentGrades[studentId]![column.id] = grade.grade;

      _gradeIds.putIfAbsent(studentId, () => {});
      _gradeIds[studentId]![column.id] = grade.id;
    }
  }

  String _generateColumnId(String examType) {
    return examType.toLowerCase().replaceAll(' ', '_');
  }

  List<ExamColumn> _getDefaultColumns() {
    return [
      ExamColumn(id: 'midterm', name: 'نصفي', maxGrade: 20.0),
      ExamColumn(id: 'final', name: 'نهائي', maxGrade: 40.0),
      ExamColumn(id: 'practical', name: 'عملي', maxGrade: 10.0),
    ];
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.grade, color: ColorsApp.primaryColor, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.course.name, style: font18blackbold),
                      Text('${widget.selectedGroups.length} مجموعة مختارة', style: font14grey),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildColumnsControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnsControl() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._examColumns.map((column) => _buildColumnChip(column)),
          SizedBox(width: 8),
          ActionChip(
            avatar: Icon(Icons.add, size: 16),
            label: Text('إضافة عمود'),
            onPressed: _addNewExamColumn,
          ),
        ],
      ),
    );
  }

  Widget _buildColumnChip(ExamColumn column) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text('${column.name} (${column.maxGrade})'),
        avatar: Icon(Icons.assignment, size: 16),
        deleteIcon: Icon(Icons.close, size: 16),
        onDeleted: () => _deleteExamColumn(column),
        onPressed: () => _showColumnDetails(column),
      ),
    );
  }

  void _deleteExamColumn(ExamColumn column) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف عمود الامتحان'),
        content: Text('هل أنت متأكد من حذف عمود "${column.name}"؟ سيتم حذف جميع الدرجات المرتبطة به.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _examColumns.removeWhere((c) => c.id == column.id);
        for (final studentId in _studentGrades.keys) {
          _studentGrades[studentId]?.remove(column.id);
          _gradeIds[studentId]?.remove(column.id);
        }
        _hasUnsavedChanges = true; 
      });

      _deleteColumnGradesFromDatabase(column);
    }
  }

  void _deleteColumnGradesFromDatabase(ExamColumn column) {
    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    context.read<SubjectiveBloc>().add(
      DeleteExamColumnGradesEvent(
        courseId: widget.course.id,
        groupId: currentGroup.id,
        examType: column.name,
      ),
    );
    print('🗑️ تم إرسال حدث حذف عمود: ${column.name}');
  }

  Widget _buildGradesTable() {
    if (widget.selectedGroups.isEmpty) {
      return _buildEmptyState();
    }

    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    final students = currentGroup.students;

    if (students.isEmpty) {
      return _buildNoStudentsState();
    }

    return Column(
      children: [
        _buildGroupsTabs(),
        SizedBox(height: 8),
        Expanded(
          child: _buildDataTable(students),
        ),
      ],
    );
  }

  Widget _buildGroupsTabs() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedGroups.length,
        itemBuilder: (context, index) {
          final group = widget.selectedGroups[index];
          final isSelected = index == _selectedGroupIndex;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(group.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGroupIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(List<StudentModel> students) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(ColorsApp.primaryColor.withOpacity(0.1)),
            columns: _buildTableColumns(),
            rows: students.map((student) => _buildStudentRow(student)).toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    final columns = <DataColumn>[
      DataColumn(
        label: Text('م', style: font14black.copyWith(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('اسم الطالب', style: font14black.copyWith(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('رقم القيد', style: font14black.copyWith(fontWeight: FontWeight.bold)),
      ),
      ..._examColumns.map((column) => DataColumn(
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(column.name, style: font12black.copyWith(fontWeight: FontWeight.bold)),
                Text('${column.maxGrade}', style: font12Grey),
              ],
            ),
          )),
      DataColumn(
        label: Text('المجموع', style: font14black.copyWith(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('النسبة', style: font14black.copyWith(fontWeight: FontWeight.bold)),
      ),
    ];

    return columns;
  }

  DataRow _buildStudentRow(StudentModel student) {
    final studentId = student.id;
    final studentGrades = _studentGrades[studentId] ?? {};
    double total = 0.0;
    double maxTotal = 0.0;

    for (final column in _examColumns) {
      final grade = studentGrades[column.id] ?? 0.0;
      total += grade;
      maxTotal += column.maxGrade;
    }

    final percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;

    return DataRow(
      cells: [
        DataCell(Text((widget.selectedGroups[_selectedGroupIndex].students.indexOf(student) + 1).toString())),
        DataCell(
          Tooltip(
            message: student.name,
            child: Text(
              student.name,
              style: font12black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(student.studentId, style: font12black)),
        ..._examColumns.map((column) {
          final grade = studentGrades[column.id] ?? 0.0;
          return DataCell(
            GestureDetector(
              onTap: () => _editStudentGrade(student, column),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  grade.toStringAsFixed(1),
                  style: font12black.copyWith(
                    color: _getGradeColor(grade, column.maxGrade),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
        DataCell(
          Text(
            total.toStringAsFixed(1),
            style: font12black.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTotalColor(total, maxTotal),
            ),
          ),
        ),
        DataCell(
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: font12black.copyWith(
              fontWeight: FontWeight.bold,
              color: _getPercentageColor(percentage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade, size: 80, color: ColorsApp.grey),
          SizedBox(height: 16),
          Text('لا توجد مجموعات مختارة', style: font18blackbold),
          SizedBox(height: 8),
          Text('يرجى اختيار مجموعة واحدة على الأقل', style: font14grey),
        ],
      ),
    );
  }

  Widget _buildNoStudentsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: ColorsApp.grey),
          SizedBox(height: 16),
          Text('لا يوجد طلاب', style: font18blackbold),
          SizedBox(height: 8),
          Text('لا توجد طلاب في المجموعة المختارة', style: font14grey),
        ],
      ),
    );
  }

  void _addNewExamColumn() async {
    final result = await showDialog<ExamColumn>(
      context: context,
      builder: (context) => AddExamColumnDialog(),
    );

    if (result != null) {
      setState(() {
        _examColumns.add(result);
        _hasUnsavedChanges = true; 
      });
    }
  }

  void _editExamColumn(ExamColumn column) async {
    final result = await showDialog<ExamColumn>(
      context: context,
      builder: (context) => AddExamColumnDialog(
        initialColumn: column,
      ),
    );

    if (result != null) {
      setState(() {
        final index = _examColumns.indexWhere((c) => c.id == column.id);
        if (index != -1) {
          _examColumns[index] = result;
          if (result.maxGrade != column.maxGrade) {
            _updateStudentGradesForColumn(result);
          }
          _hasUnsavedChanges = true;
        }
      });
    }
  }

  void _updateStudentGradesForColumn(ExamColumn column) {
    for (final studentId in _studentGrades.keys) {
      final currentGrade = _studentGrades[studentId]?[column.id] ?? 0.0;
      if (currentGrade > column.maxGrade) {
        _studentGrades[studentId]![column.id] = column.maxGrade;
      }
    }
  }

  void _showColumnDetails(ExamColumn column) {
    final stats = _getColumnStats(column);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(column.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدرجة القصوى: ${column.maxGrade}', style: font14black),
            Text('عدد الطلاب: ${stats.studentCount}', style: font14black),
            Text('المعدل المتوسط: ${stats.average.toStringAsFixed(1)}', style: font14black),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editExamColumn(column);
            },
            child: Text('تعديل', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExamColumn(column);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  ColumnStats _getColumnStats(ExamColumn column) {
    int studentCount = 0;
    double total = 0.0;

    for (final student in widget.selectedGroups[_selectedGroupIndex].students) {
      final grade = _studentGrades[student.id]?[column.id] ?? 0.0;
      if (grade > 0) {
        studentCount++;
        total += grade;
      }
    }

    final average = studentCount > 0 ? total / studentCount : 0.0;

    return ColumnStats(
      studentCount: studentCount,
      average: average,
    );
  }

  void _editStudentGrade(StudentModel student, ExamColumn column) async {
    final currentGrade = _studentGrades[student.id]?[column.id] ?? 0.0;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => EditGradeDialog(
        student: student,
        column: column,
        currentGrade: currentGrade,
      ),
    );

    if (result != null) {
      setState(() {
        _studentGrades.putIfAbsent(student.id, () => {});
        _studentGrades[student.id]![column.id] = result;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveAllGrades() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentGroup = widget.selectedGroups[_selectedGroupIndex];
      final batchResults = <bool>[];
      for (final student in currentGroup.students) {
        final studentGrades = _studentGrades[student.id];
        if (studentGrades != null) {
          for (final entry in studentGrades.entries) {
            final column = _examColumns.firstWhere((col) => col.id == entry.key);
            final existingGradeId = _gradeIds[student.id]?[column.id];
            final examGrade = ExamGradeModel(
              id: '${student.id}_${column.id}',
              studentId: student.id,
              studentName: student.name,
              examType: column.name,
              grade: entry.value,
              maxGrade: column.maxGrade,
              examDate: DateTime.now(),
            );

            final success = await _saveOrUpdateGrade(currentGroup, examGrade);
            batchResults.add(success);
            if (existingGradeId == null && success) {
              _gradeIds.putIfAbsent(student.id, () => {});
              _gradeIds[student.id]![column.id] = examGrade.id;
            }
          }
        }
      }
      final successCount = batchResults.where((r) => r).length;
       // 🔥 تحديث حالة التغييرات بعد الحفظ الناجح
      if (successCount > 0) {
        setState(() {
          _hasUnsavedChanges = false;
        });
      }
      ShowWidget.showMessage(
        context,
        'تم حفظ $successCount درجة بنجاح',
        ColorsApp.green,
        font13White,
      );
    } catch (e) {
      ShowWidget.showMessage(context, 'خطأ في حفظ الدرجات: $e', ColorsApp.red, font13White);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _saveOrUpdateGrade(GroupModel group, ExamGradeModel examGrade) async {
    try {
      context.read<SubjectiveBloc>().add(
        AddExamGradeEvent(
          courseId: widget.course.id,
          groupId: group.id,
          examGrade: examGrade,
        ),
      );
      return true;
    } catch (e) {
      print('خطأ في حفظ درجة الطالب ${examGrade.studentName}: $e');
      return false;
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });

    _loadExistingGrades();

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Color _getGradeColor(double grade, double maxGrade) {
    final percentage = (grade / maxGrade) * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _getTotalColor(double total, double maxTotal) {
    final percentage = (total / maxTotal) * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }
}

// ========== نماذج البيانات ==========

class ExamColumn {
  final String id;
  final String name;
  final double maxGrade;

  ExamColumn({
    required this.id,
    required this.name,
    required this.maxGrade,
  });
}

class ColumnStats {
  final int studentCount;
  final double average;

  ColumnStats({
    required this.studentCount,
    required this.average,
  });
}

  class Statistics {
    final double highestGrade;
    final double lowestGrade;
    final double average;
    final double standardDeviation;

    Statistics({
      required this.highestGrade,
      required this.lowestGrade,
      required this.average,
      required this.standardDeviation,
    });
  }