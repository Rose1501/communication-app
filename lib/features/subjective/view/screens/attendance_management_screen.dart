import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myproject/features/subjective/view/screens/previous_lectures_screen.dart';
import 'package:myproject/features/subjective/view/widgets/shared_table_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
import 'package:excel/excel.dart' as excel;
import 'package:myproject/components/widget/date_picker_widget.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;
  final DateTime? initialDate; // تاريخ مبدئي
  final AttendanceRecordModel? lectureToEdit; // محاضرة للتعديل

  const AttendanceManagementScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
    this.initialDate,
    this.lectureToEdit,
  });

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  late DateTime _selectedDate;
  int _selectedGroupIndex = 0;
  bool _isLoading = false;
  Map<String, bool> _attendanceStatus = {};
  Map<String, String> _attendanceNotes = {};
  List<AttendanceRecordModel> _loadedAttendanceRecords = [];
  AttendanceRecordModel? _currentLectureToEdit;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    // استخدام التاريخ المبدئي إذا وجد
    _selectedDate = widget.initialDate ?? DateTime.now();
    
    // إذا تم تمرير محاضرة للتعديل
    if (widget.lectureToEdit != null) {
      _currentLectureToEdit = widget.lectureToEdit;
      _selectedDate = widget.lectureToEdit!.date;
      
      // تعبئة بيانات المحاضرة للتعديل
      _loadLectureForEdit();
    } else {
      _loadAttendanceData();
    }
  }

  void _loadLectureForEdit() {
    if (_currentLectureToEdit == null) return;

    setState(() {
      _isLoading = true;
      _attendanceStatus.clear();
      _attendanceNotes.clear();
      
      // تعبئة بيانات الحضور من المحاضرة
      for (final entry in _currentLectureToEdit!.presentStudentIds.entries) {
        _attendanceStatus[entry.key] = true;
      }
      
      for (final entry in _currentLectureToEdit!.absentStudentIds.entries) {
        _attendanceStatus[entry.key] = false;
      }
      
      for (final entry in _currentLectureToEdit!.studentNotes.entries) {
        _attendanceNotes[entry.key] = entry.value;
      }
      
      _isLoading = false;
    });
  }

  void _loadAttendanceData() {
    if (widget.selectedGroups.isEmpty) return;
    
    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    
    setState(() {
      _isLoading = true;
      // مسح البيانات السابقة
      _attendanceStatus.clear();
      _attendanceNotes.clear();
      _loadedAttendanceRecords.clear();
    });

    context.read<SubjectiveBloc>().add(
      LoadAttendanceEvent(
        courseId: widget.course.id,
        groupId: currentGroup.id,
        date: _selectedDate,
      ),
    );
  }

  void _toggleAttendance(String studentId) {
    setState(() {
      _attendanceStatus[studentId] = !(_attendanceStatus[studentId] ?? false);
      _hasUnsavedChanges = true;
    });
  }

  void _updateAttendanceNote(String studentId, String note) {
    setState(() {
      _attendanceNotes[studentId] = note;
      _hasUnsavedChanges = true;
    });
  }

  //لتتعامل مع التعديل والإضافة
  Future<void> _saveAttendance() async {
    if (widget.selectedGroups.isEmpty) return;
    
    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    
    if (currentGroup.students.isEmpty) {
      ShowWidget.showMessage(
        context, 
        'لا يوجد طلاب في المجموعة', 
        ColorsApp.orange, 
        font13White
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> presentStudentIds = {};
      Map<String, String> absentStudentIds = {};
      Map<String, String> studentNotes = {};
      
      for (final student in currentGroup.students) {
        final isPresent = _attendanceStatus[student.id] ?? true; // حاضر افتراضياً
        final note = _attendanceNotes[student.id] ?? '';
        
        if (isPresent) {
          presentStudentIds[student.id] = student.name;
        } else {
          absentStudentIds[student.id] = student.name;
        }
        
        if (note.isNotEmpty) {
          studentNotes[student.id] = note;
        }
      }

      // تحديد عنوان المحاضرة
      String lectureTitle;
      if (_currentLectureToEdit != null) {
        // في وضع التعديل: نستخدم العنوان الحالي
        lectureTitle = _currentLectureToEdit!.lectureTitle;
      } else {
        // في وضع الإضافة: نولد عنواناً تلقائياً
        lectureTitle = await _generateAutoLectureTitle();
      }
      // استخدام ID المحاضرة القديمة إذا كنا في وضع التعديل
      final lectureId = _currentLectureToEdit?.id ?? 
                        'attendance_${_selectedDate.millisecondsSinceEpoch}';

      final attendanceRecord = AttendanceRecordModel(
        id: lectureId,
        date: _selectedDate,
        lectureTitle: lectureTitle,
        presentStudentIds: presentStudentIds,
        absentStudentIds: absentStudentIds,
        studentNotes: studentNotes,
        createdAt: DateTime.now(),
      );

      context.read<SubjectiveBloc>().add(
        UpdateAttendanceEvent(
          courseId: widget.course.id,
          groupId: currentGroup.id,
          attendance: attendanceRecord,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
        _currentLectureToEdit = null; // تنظيف بعد الحفظ
      });

      ShowWidget.showMessage(
        context, 
        _currentLectureToEdit != null ? 
          'تم تعديل بيانات الحضور بنجاح' : 
          'تم حفظ المحاضرة "$lectureTitle" بنجاح', 
        ColorsApp.green, 
        font13White
      );
      // 🔥 إعادة تعيين حالة التغييرات بعد الحفظ الناجح
      setState(() {
        _hasUnsavedChanges = false;
      });
      // عرض العنوان التلقائي في حالة الإضافة
      if (_currentLectureToEdit == null) {
        await Future.delayed(const Duration(milliseconds: 800));
        ShowWidget.showMessage(
          context, 
          'تم تعيين العنوان التلقائي: $lectureTitle',
          ColorsApp.green,
          font13White,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowWidget.showMessage(
        context, 
        'خطأ في حفظ البيانات: $e', 
        ColorsApp.red, 
        font13White
      );
    }
  }


  // ✅ دالة جديدة: الحصول على رقم المحاضرة التالي
  Future<int> _getNextLectureNumber() async {
    try {
      if (widget.selectedGroups.isEmpty) return 1;
      // جلب المحاضرات السابقة لهذه المجموعة
      final lectures = await _getGroupLectures();
      
      // البحث عن أكبر رقم محاضرة موجود
      int maxNumber = 0;
      final regex = RegExp(r'المحاضرة (\d+)');
      
      for (final lecture in lectures) {
        final match = regex.firstMatch(lecture.lectureTitle);
        if (match != null) {
          final number = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }
      
      return maxNumber + 1;
      
    } catch (e) {
      print('❌ خطأ في حساب رقم المحاضرة: $e');
      return 1;
    }
  }

  // ✅ دالة مساعدة: جلب محاضرات المجموعة
  Future<List<AttendanceRecordModel>> _getGroupLectures() async {
    try {
      final currentGroup = widget.selectedGroups[_selectedGroupIndex];
      
      // استخدام Bloc لتحميل المحاضرات
      final completer = Completer<List<AttendanceRecordModel>>();
      
      final subscription = context.read<SubjectiveBloc>().stream.listen((state) {
        if (state is LecturesLoadSuccess) {
          completer.complete(state.lectures);
        } else if (state is SubjectiveError) {
          completer.complete([]);
        }
      });
      
      // إرسال حدث تحميل المحاضرات
      context.read<SubjectiveBloc>().add(
        LoadLecturesEvent(
          courseId: widget.course.id,
          groupId: currentGroup.id,
          doctorId: widget.doctorId,
        ),
      );
      
      final result = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => [],
      );
      
      subscription.cancel();
      return result;
      
    } catch (e) {
      print('❌ خطأ في جلب المحاضرات: $e');
      return [];
    }
  }

  // ✅ دالة جديدة: إنشاء عنوان تلقائي مع الرقم
  Future<String> _generateAutoLectureTitle() async {
    final nextNumber = await _getNextLectureNumber();
    return 'المحاضرة $nextNumber';
  }

  Future<void> _exportToExcel() async {
  if (widget.selectedGroups.isEmpty) return;
  
  final currentGroup = widget.selectedGroups[_selectedGroupIndex];
  
  if (currentGroup.students.isEmpty) {
    ShowWidget.showMessage(
      context, 
      'لا يوجد طلاب في المجموعة', 
      ColorsApp.orange, 
      font13White
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // إنشاء مصنف Excel
    final excelEngine = excel.Excel.createExcel();
    final sheet = excelEngine['سجل الحضور'];
    
    // معلومات العنوان
    sheet.appendRow([
      excel.TextCellValue('سجل الحضور والغياب'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue('')
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
      excel.TextCellValue(DateFormat('yyyy/MM/dd').format(_selectedDate)),
    ]);
    
    sheet.appendRow([
      excel.TextCellValue('تاريخ التصدير:'),
      excel.TextCellValue(DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())),
    ]);
    
    sheet.appendRow([]); // سطر فارغ
    
    // رؤوس الأعمدة
    sheet.appendRow([
      excel.TextCellValue('م'),
      excel.TextCellValue('اسم الطالب'),
      excel.TextCellValue('رقم القيد'),
      excel.TextCellValue('الحالة'),
      excel.TextCellValue('ملاحظات'),
      excel.TextCellValue('تاريخ التسجيل'),
    ]);
    
    // بيانات الطلاب
    for (int i = 0; i < currentGroup.students.length; i++) {
      final student = currentGroup.students[i];
      final isPresent = _attendanceStatus[student.id] ?? true;
      final note = _attendanceNotes[student.id] ?? '';
      
      sheet.appendRow([
        excel.TextCellValue((i + 1).toString()),
        excel.TextCellValue(student.name),
        excel.TextCellValue(student.studentId),
        excel.TextCellValue(isPresent ? 'حاضر' : 'غائب'),
        excel.TextCellValue(note),
        excel.TextCellValue(DateFormat('yyyy/MM/dd').format(_selectedDate)),
      ]);
    }
    
    // إضافة إحصائيات
    final presentCount = _attendanceStatus.values.where((status) => status).length;
    final absentCount = currentGroup.students.length - presentCount;
    final attendanceRate = currentGroup.students.isNotEmpty 
        ? (presentCount / currentGroup.students.length * 100) 
        : 0;
    
    sheet.appendRow([]);
    sheet.appendRow([excel.TextCellValue('الإحصائيات:')]);
    sheet.appendRow([
      excel.TextCellValue('عدد الحضور:'),
      excel.TextCellValue(presentCount.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('عدد الغياب:'),
      excel.TextCellValue(absentCount.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('نسبة الحضور:'),
      excel.TextCellValue('${attendanceRate.toStringAsFixed(1)}%'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('إجمالي الطلاب:'),
      excel.TextCellValue(currentGroup.students.length.toString()),
    ]);
    
    // حفظ الملف
    final directory = await getTemporaryDirectory();
    final fileName = 'حضور_${currentGroup.name}_${DateFormat('yyyyMMdd_HHmmss').format(_selectedDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excelEngine.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'سجل حضور ${widget.course.name} - ${currentGroup.name}',
        subject: 'تصدير سجل الحضور',
      );
      
      ShowWidget.showMessage(
        context, 
        ' تم تصدير الملف Excel بنجاح',
        ColorsApp.green, 
        font13White
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
      'خطأ في التصدير: ', 
      ColorsApp.red, 
      font13White
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _saveExcelToDevice() async {
  if (widget.selectedGroups.isEmpty) return;
  
  final currentGroup = widget.selectedGroups[_selectedGroupIndex];
  
  if (currentGroup.students.isEmpty) {
    ShowWidget.showMessage(
      context, 
      'لا يوجد طلاب في المجموعة', 
      ColorsApp.orange, 
      font13White
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // إنشاء مصنف Excel - استخدم نفس طريقة _exportToExcel
    final excelEngine = excel.Excel.createExcel();
    final sheet = excelEngine['سجل الحضور'];
    
    // معلومات العنوان - استخدم appendRow
    sheet.appendRow([
      excel.TextCellValue('سجل الحضور والغياب'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue('')
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
      excel.TextCellValue(DateFormat('yyyy/MM/dd').format(_selectedDate)),
    ]);
    
    sheet.appendRow([]); // سطر فارغ
    
    // رؤوس الأعمدة
    sheet.appendRow([
      excel.TextCellValue('م'),
      excel.TextCellValue('اسم الطالب'),
      excel.TextCellValue('رقم القيد'),
      excel.TextCellValue('الحالة'),
      excel.TextCellValue('ملاحظات'),
      excel.TextCellValue('تاريخ التسجيل'),
    ]);
    
    // بيانات الطلاب
    for (int i = 0; i < currentGroup.students.length; i++) {
      final student = currentGroup.students[i];
      final isPresent = _attendanceStatus[student.id] ?? true;
      final note = _attendanceNotes[student.id] ?? '';
      
      sheet.appendRow([
        excel.TextCellValue((i + 1).toString()),
        excel.TextCellValue(student.name),
        excel.TextCellValue(student.studentId),
        excel.TextCellValue(isPresent ? 'حاضر' : 'غائب'),
        excel.TextCellValue(note),
        excel.TextCellValue(DateFormat('yyyy/MM/dd').format(_selectedDate)),
      ]);
    }
    
    // حفظ الملف في مجلد Downloads
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('لا يمكن الوصول إلى مجلد التنزيلات');
    }
    
    final fileName = 'حضور_${currentGroup.name}_${DateFormat('yyyyMMdd_HHmmss').format(_selectedDate)}.xlsx';
    final filePath = '${downloadsDir.path}/$fileName';
    
    final fileBytes = excelEngine.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      ShowWidget.showMessage(
        context, 
        ' تم حفظ الملف Excel بنجاح',
        ColorsApp.green, 
        font13White,
      );
      
      print('📁 تم حفظ الملف Excel في: $filePath');
    } else {
      throw Exception('فشل في إنشاء ملف Excel');
    }
  } catch (e) {
    print('❌ خطأ في حفظ Excel: $e');
    
    // محاولة بديلة: حفظ في Documents باستخدام نفس الطريقة
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = 'حضور_${currentGroup.name}.xlsx';
      final filePath = '${documentsDir.path}/$fileName';
      
      // إنشاء Excel مبسط بنفس الطريقة
      final excelEngine = excel.Excel.createExcel();
      final sheet = excelEngine['سجل الحضور'];
      
      sheet.appendRow([excel.TextCellValue('سجل حضور ${widget.course.name}')]);
      sheet.appendRow([excel.TextCellValue('المجموعة: ${currentGroup.name}')]);
      sheet.appendRow([excel.TextCellValue('التاريخ: ${DateFormat('yyyy/MM/dd').format(_selectedDate)}')]);
      sheet.appendRow([]);
      
      int row = 5;
      for (int i = 0; i < currentGroup.students.length; i++) {
        final student = currentGroup.students[i];
        final isPresent = _attendanceStatus[student.id] ?? true;
        sheet.appendRow([excel.TextCellValue('${i + 1}. ${student.name} - ${isPresent ? 'حاضر' : 'غائب'}')]);
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePickerWidget(initialDate: _selectedDate),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is AttendanceLoadSuccess) {
          _processAttendanceData(state.attendanceRecords);
        }
        
        if (state is SubjectiveOperationSuccess) {
          setState(() {
            _isLoading = false;
          });
          ShowWidget.showMessage(
            context, 
            state.message, 
            ColorsApp.green, 
            font13White
          );
          // إعادة تحميل البيانات بعد الحفظ
          _loadAttendanceData();
        }
        
        if (state is SubjectiveError) {
          setState(() {
            _isLoading = false;
          });
          ShowWidget.showMessage(
            context, 
            state.message, 
            ColorsApp.red, 
            font13White
          );
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
              Text(
                _currentLectureToEdit != null ? 
                  'تعديل المحاضرة' : 
                  'إدارة الحضور والغياب', 
                style: font16White
              ),
              Text(widget.course.name, style: font13White),
              if (_currentLectureToEdit != null)
                Text(
                  _currentLectureToEdit!.lectureTitle,
                  style: font11White,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            if (_currentLectureToEdit != null)
              IconButton(
                icon: Icon(Icons.edit_note, color: ColorsApp.white),
                onPressed: _showEditTitleDialog,
                tooltip: 'تعديل عنوان المحاضرة',
              ),
            IconButton(
              icon: Icon(Icons.save, color: ColorsApp.white),
              onPressed: _saveAttendance,
              tooltip: 'حفظ البيانات',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.ios_share_outlined, color: ColorsApp.white),
              tooltip: 'خيارات التصدير',
              onSelected: (value) {
                if (value == 'Excel') {
                  _exportToExcel();
                } else if (value == 'device') {
                  _saveExcelToDevice();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Excel',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: ColorsApp.primaryColor),
                      const SizedBox(width: 8),
                      Text('تصدير إلى '),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'device',
                  child: Row(
                    children: [
                      Icon(Icons.save_alt, color: ColorsApp.primaryColor),
                      const SizedBox(width: 8),
                      Text('حفظ على الجهاز'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<SubjectiveBloc, SubjectiveState>(
          builder: (context, state) {
            if (state is SubjectiveLoading && _isLoading) {
              return const LoadingWidget();
            }

            return Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(child: _buildAttendanceTable()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviousLecturesScreen(
                  course: widget.course,
                  selectedGroups: widget.selectedGroups,
                  doctorId: widget.doctorId,
                ),
              ),
            );
          },
          icon: Icon(Icons.library_books),
          label: Text('المحاضرات السابقة', style: font13White),
          backgroundColor: ColorsApp.primaryColor,
        ),
      ),
      ),
    );
  }

  // 🔥 دالة التعامل مع زر الرجوع
  Future<bool> _handleBackButton() async {
  if (_hasUnsavedChanges) {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final bool isWideScreen = MediaQuery.of(context).size.width > 600;
        
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text('تأكيد الخروج')),
            ],
          ),
          content: Text('لديك تغييرات غير محفوظة في الشاشة . هل تريد حفظ التغييرات قبل الخروج؟'),
          actions: [
            // تصميم متجاوب حسب حجم الشاشة
            if (isWideScreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildDialogActions(context),
              )
            else
              Column(
                children: [
                  ..._buildDialogActions(context).map((button) => 
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 8),
                      child: button,
                    )
                  ).toList(),
                ],
              ),
          ],
        );
      },
    );

    if (result == null) {
      return false; // إلغاء
    } else if (result == true) {
      await _saveAttendance();
      return true;
    } else {
      return true;
    }
  }
  
  return true;
}

List<Widget> _buildDialogActions(BuildContext context) {
  return [
    OutlinedButton(
      onPressed: () => Navigator.pop(context, null),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 45),
      ),
      child: Text('إلغاء',style: font14black,),
    ),
    ElevatedButton(
      onPressed: () => Navigator.pop(context, false),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 45),
      ),
      child: Text('خروج دون حفظ',style: font14Error,),
    ),
    ElevatedButton(
      onPressed: () => Navigator.pop(context, true),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 45),
      ),
      child: Text('حفظ والخروج',style: font14Success,),
    ),
  ];
}

  void _showEditTitleDialog() {
    if (_currentLectureToEdit == null) return;
    
    final titleController = TextEditingController(text: _currentLectureToEdit!.lectureTitle);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل عنوان المحاضرة'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'عنوان المحاضرة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentLectureToEdit = _currentLectureToEdit!.copyWith(
                  lectureTitle: titleController.text.trim(),
                );
              });
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _processAttendanceData(List<AttendanceRecordModel> records) {
    setState(() {
      _loadedAttendanceRecords = records;
      _attendanceStatus.clear();
      _attendanceNotes.clear();
      
      // إذا كان هناك سجلات للحضور في هذا التاريخ، استخدمها
      if (records.isNotEmpty) {
        final latestRecord = records.first; // نأخذ أحدث سجل
        
        for (final entry in latestRecord.presentStudentIds.entries) {
          _attendanceStatus[entry.key] = true;
        }
        
        for (final entry in latestRecord.absentStudentIds.entries) {
          if (!_attendanceStatus.containsKey(entry.key)) {
            _attendanceStatus[entry.key] = false;
          }
        }
        
        for (final entry in latestRecord.studentNotes.entries) {
          _attendanceNotes[entry.key] = entry.value;
        }
      } else {
        // إذا لم يكن هناك سجلات، ضع كل الطلاب كحاضرين افتراضياً
        final currentGroup = widget.selectedGroups[_selectedGroupIndex];
        for (final student in currentGroup.students) {
          _attendanceStatus[student.id] = true; // حاضر افتراضياً
        }
      }
      
      _isLoading = false;
    });
  }

  Widget _buildHeader() {
    if (widget.selectedGroups.isEmpty) {
      return Container();
    }

    final currentGroup = widget.selectedGroups[_selectedGroupIndex];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GroupsTabsWidget(
              groupNames: widget.selectedGroups.map((g) => g.name).toList(),
              selectedIndex: _selectedGroupIndex,
              onGroupSelected: (index) {
                setState(() {
                  _selectedGroupIndex = index;
                });
                _loadAttendanceData();
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Icon(Icons.calendar_today, color: ColorsApp.primaryColor),
                const SizedBox(width: 8),
                Text('تاريخ الحضور:', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('yyyy/MM/dd').format(_selectedDate),
                          style: font14black.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_calendar, size: 16, color: ColorsApp.primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildAttendanceStats(currentGroup),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(GroupModel group) {
    final totalStudents = group.students.length;
    final presentCount = _attendanceStatus.values.where((status) => status).length;
    final absentCount = totalStudents - presentCount;
    final attendanceRate = totalStudents > 0 ? (presentCount / totalStudents * 100) : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItemWidget(
          label: 'إجمالي الطلاب',
          value: totalStudents.toString(),
          icon: Icons.people,
        ),
        StatItemWidget(
          label: 'الحضور',
          value: presentCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatItemWidget(
          label: 'الغياب',
          value: absentCount.toString(),
          icon: Icons.cancel,
          color: Colors.red,
        ),
        StatItemWidget(
          label: 'النسبة',
          value: '${attendanceRate.toStringAsFixed(1)}%',
          icon: Icons.analytics,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    if (widget.selectedGroups.isEmpty) {
      return EmptyStateWidget(
        title: 'لا توجد مجموعات مختارة',
        message: 'يرجى اختيار مجموعة واحدة على الأقل',
        icon: Icons.people_outline,
      );
    }

    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    final students = currentGroup.students;

    if (students.isEmpty) {
      return EmptyStateWidget(
        title: 'لا يوجد طلاب',
        message: 'لا توجد طلاب في المجموعة المختارة',
        icon: Icons.people_outline,
      );
    }

    if (_isLoading) {
      return const LoadingWidget();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(ColorsApp.primaryColor.withOpacity(0.1)),
            columns: [
              DataColumn(
                label: Text('م', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('اسم الطالب', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('رقم القيد', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('الحالة', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('ملاحظات', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: students.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              final isPresent = _attendanceStatus[student.id] ?? false;
              final note = _attendanceNotes[student.id] ?? '';
              
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
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
                  DataCell(
                    GestureDetector(
                      onTap: () => _toggleAttendance(student.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPresent ? Icons.check : Icons.close,
                              size: 14,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPresent ? 'حاضر' : 'غائب',
                              style: font12black.copyWith(
                                color: isPresent ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: note.isEmpty ? 'إضافة ملاحظة' : note,
                            child: Text(
                              note.isEmpty ? 'لا توجد ملاحظات' : _truncateNote(note),
                              style: font12black.copyWith(
                                color: note.isEmpty ? Colors.grey : Colors.black,
                                fontStyle: note.isEmpty ? FontStyle.italic : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_note, size: 18, color: ColorsApp.primaryColor),
                          onPressed: () => _showNoteDialog(student),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: 'تعديل الملاحظات',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _truncateNote(String note) {
    if (note.length <= 15) return note;
    return '${note.substring(0, 15)}...';
  }

  void _showNoteDialog(StudentModel student) {
    final currentNote = _attendanceNotes[student.id] ?? '';
    final noteController = TextEditingController(text: currentNote);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.note_add, color: ColorsApp.primaryColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'ملاحظات للطالب ${student.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'أدخل ملاحظات حول الحضور...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateAttendanceNote(student.id, noteController.text);
              Navigator.pop(context);
              ShowWidget.showMessage(
                context, 
                'تم حفظ الملاحظة', 
                ColorsApp.green, 
                font13White
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.primaryColor,
            ),
            child: Text('حفظ', style: font13White),
          ),
        ],
      ),
    );
  }
}