import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myproject/features/subjective/view/screens/attendance_management_screen.dart';
import 'package:myproject/features/subjective/view/widgets/add_edit_lecture_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
import 'package:excel/excel.dart' as excel;
import 'package:myproject/features/subjective/view/widgets/shared_table_widgets.dart';

class PreviousLecturesScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;

  const PreviousLecturesScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
  });

  @override
  State<PreviousLecturesScreen> createState() => _PreviousLecturesScreenState();
}

class _PreviousLecturesScreenState extends State<PreviousLecturesScreen> {
  List<AttendanceRecordModel> _lectures = [];
  int _selectedGroupIndex = 0;
  bool _isLoading = false;
  //bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadLecturesData();
  }

  Future<void> _loadLecturesData() async {
    if (widget.selectedGroups.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentGroup = widget.selectedGroups[_selectedGroupIndex];
      
      context.read<SubjectiveBloc>().add(
        LoadLecturesEvent(
          courseId: widget.course.id,
          groupId: currentGroup.id,
          doctorId: widget.doctorId,
        ),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ShowWidget.showMessage(context, 'خطأ في تحميل البيانات: $e', ColorsApp.red, font13White);
      }
    }
  }

  Future<void> _navigateToAddNewAttendance() async {
  if (mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceManagementScreen(
          course: widget.course,
          selectedGroups: widget.selectedGroups,
          doctorId: widget.doctorId,
          initialDate: DateTime.now(), // التاريخ الحالي
          lectureToEdit: null, // إضافة جديدة
        ),
      ),
    );
  }
}

Future<void> _navigateToEditAttendance(AttendanceRecordModel lecture) async {
  if (mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceManagementScreen(
          course: widget.course,
          selectedGroups: widget.selectedGroups,
          doctorId: widget.doctorId,
          initialDate: lecture.date, // تاريخ المحاضرة
          lectureToEdit: lecture, // المحاضرة للتعديل
        ),
      ),
    );
  }
}

  Future<void> _addNewLecture() async {
    // عرض تأكيد قبل الانتقال
    final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('إضافة محاضرة جديدة'),
      content: const Text('سيتم نقلك إلى شاشة إدارة الحضور لإضافة محاضرة جديدة.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsApp.primaryColor,
          ),
          child: Text('متابعة', style: font13White),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _navigateToAddNewAttendance();
    }
  }

  Future<void> _editLecture(AttendanceRecordModel lecture) async {
  final result = await showDialog<dynamic>(
    context: context,
    builder: (context) => AddEditLectureDialog(
      lecture: lecture,
      groupName: widget.selectedGroups[_selectedGroupIndex].name,
    ),
  );

  if (result != null && mounted) {
    if (result is AttendanceRecordModel) {
      // الانتقال لشاشة إدارة الحضور مع المحاضرة
      await _navigateToEditAttendance(lecture);
    }
  }
}

  Future<void> _deleteLecture(AttendanceRecordModel lecture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحاضرة'),
        content: Text('هل أنت متأكد من حذف محاضرة "${lecture.lectureTitle}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _lectures.removeWhere((l) => l.id == lecture.id);
      });
      
      // حذف المحاضرة عبر الـ BLoC
      _deleteLectureFromDatabase(lecture);
    }
  }

  void _deleteLectureFromDatabase(AttendanceRecordModel lecture) {
    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    
    context.read<SubjectiveBloc>().add(
      DeleteLectureEvent(
        courseId: widget.course.id,
        groupId: currentGroup.id,
        lectureId: lecture.id,
        doctorId: widget.doctorId,
      ),
    );
  }

  Future<void> _exportToExcel() async {
  if (widget.selectedGroups.isEmpty || _lectures.isEmpty) {
    ShowWidget.showMessage(context, 'لا توجد بيانات للتصدير', ColorsApp.orange, font13White);
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final currentGroup = widget.selectedGroups[_selectedGroupIndex];
    
    // إنشاء مصنف Excel
    final excelEngine = excel.Excel.createExcel();
    final sheet = excelEngine['سجل المحاضرات'];
    
    // معلومات العنوان - استخدم appendRow بدلاً من cell()
    sheet.appendRow([
      excel.TextCellValue('سجل المحاضرات السابقة'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
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
      excel.TextCellValue('تاريخ التصدير:'),
      excel.TextCellValue(DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())),
    ]);
    
    sheet.appendRow([
      excel.TextCellValue('عدد المحاضرات:'),
      excel.TextCellValue(_lectures.length.toString()),
    ]);
    
    sheet.appendRow([]); // سطر فارغ
    
    // رؤوس الأعمدة
    sheet.appendRow([
      excel.TextCellValue('م'),
      excel.TextCellValue('التاريخ'),
      excel.TextCellValue('اليوم'),
      excel.TextCellValue('عنوان المحاضرة'),
      excel.TextCellValue('عدد الحضور'),
      excel.TextCellValue('عدد الغياب'),
      excel.TextCellValue('عدد الملاحظات'),
      excel.TextCellValue('تاريخ الإنشاء'),
    ]);
    
    // بيانات المحاضرات
    for (int i = 0; i < _lectures.length; i++) {
      final lecture = _lectures[i];
      
      sheet.appendRow([
        excel.TextCellValue((i + 1).toString()),
        excel.TextCellValue(DateFormat('yyyy/MM/dd').format(lecture.date)),
        excel.TextCellValue(_getArabicDay(lecture.date)),
        excel.TextCellValue(lecture.lectureTitle),
        excel.TextCellValue(lecture.presentStudentIds.length.toString()),
        excel.TextCellValue(lecture.absentStudentIds.length.toString()),
        excel.TextCellValue(lecture.studentNotes.length.toString()),
        excel.TextCellValue(DateFormat('yyyy/MM/dd HH:mm').format(lecture.createdAt)),
      ]);
    }
    
    // إضافة إحصائيات
    sheet.appendRow([]);
    
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalNotes = 0;
    
    for (final lecture in _lectures) {
      totalPresent += lecture.presentStudentIds.length;
      totalAbsent += lecture.absentStudentIds.length;
      totalNotes += lecture.studentNotes.length;
    }
    
    final averageAttendance = _lectures.isNotEmpty ? totalPresent ~/ _lectures.length : 0;
    final totalStudents = totalPresent + totalAbsent;
    
    sheet.appendRow([excel.TextCellValue('الإحصائيات:')]);
    sheet.appendRow([
      excel.TextCellValue('إجمالي المحاضرات:'),
      excel.TextCellValue(_lectures.length.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('متوسط الحضور:'),
      excel.TextCellValue(averageAttendance.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('إجمالي الحضور:'),
      excel.TextCellValue(totalStudents.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('الملاحظات:'),
      excel.TextCellValue(totalNotes.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('إجمالي حضور:'),
      excel.TextCellValue(totalPresent.toString()),
    ]);
    sheet.appendRow([
      excel.TextCellValue('إجمالي غياب:'),
      excel.TextCellValue(totalAbsent.toString()),
    ]);
    
    // حفظ الملف
    final directory = await getTemporaryDirectory();
    final fileName = 'محاضرات_${currentGroup.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excelEngine.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'سجل محاضرات ${widget.course.name} - ${currentGroup.name}',
        subject: 'تصدير سجل المحاضرات',
      );
      
      ShowWidget.showMessage(context, '✅ تم تصدير الملف Excel بنجاح', ColorsApp.green, font13White);
      
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
      font13White
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  String _getArabicDay(DateTime date) {
    final days = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    return days[date.weekday % 7];
  }

  void _refreshData() {
    _loadLecturesData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is LecturesLoadSuccess) {
          setState(() {
            _lectures = state.lectures;
            _isLoading = false;
          });
        }
        
        if (state is SubjectiveOperationSuccess) {
          // إعادة تحميل البيانات بعد أي عملية ناجحة
          _loadLecturesData();
          ShowWidget.showMessage(context, state.message, ColorsApp.green, font13White);
        }
        
        if (state is SubjectiveError) {
          setState(() {
            _isLoading = false;
          });
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
              Text('سجل المحاضرات السابقة', style: font16White),
              Text(widget.course.name, style: font13White),
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
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _navigateToAddNewAttendance,
              tooltip: 'إضافة محاضرة جديدة',
            ),
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white),
              onPressed: _exportToExcel,
              tooltip: 'تصدير إلى ',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshData,
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: _buildContent(),
      ),
      ),
    );
  }

  // 🔥 دالة التعامل مع زر الرجوع
  Future<bool> _handleBackButton() async {
    // هذه الشاشة عادة لا تحتوي على تغييرات غير محفوظة
    // ولكن قد تكون هناك عمليات تحميل جارية
    if (_isLoading) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('تحميل البيانات'),
          content: Text('جاري تحميل البيانات، هل تريد الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('خروج', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('انتظار'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    }
    
    return true;
  }

  Widget _buildContent() {
    if (widget.selectedGroups.isEmpty) {
      return EmptyStateWidget(
        title: 'لا توجد مجموعات مختارة',
        message: 'يرجى اختيار مجموعة واحدة على الأقل',
        icon: Icons.people_outline,
      );
    }

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(child: _buildLecturesTable()),
      ],
    );
  }

  Widget _buildHeader() {
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
                _loadLecturesData();
              },
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.school, color: ColorsApp.primaryColor, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.course.name, style: font18blackbold),
                      Text('المجموعة: ${currentGroup.name}', style: font14grey),
                      Text('${_lectures.length} محاضرة مسجلة', style: font14grey),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_lectures.isEmpty) {
      return Text('لا توجد إحصائيات متاحة', style: font14grey);
    }
    
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalNotes = 0;
    
    for (final lecture in _lectures) {
      totalPresent += lecture.presentStudentIds.length;
      totalAbsent += lecture.absentStudentIds.length;
      totalNotes += lecture.studentNotes.length;
    }
    
    final averageAttendance = _lectures.isNotEmpty ? totalPresent ~/ _lectures.length : 0;
    final totalStudents = totalPresent + totalAbsent;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItemWidget(
          label: 'إجمالي المحاضرات',
          value: _lectures.length.toString(),
          icon: Icons.library_books,
        ),
        StatItemWidget(
          label: 'متوسط الحضور',
          value: averageAttendance.toString(),
          icon: Icons.people,
        ),
        StatItemWidget(
          label: 'إجمالي الحضور',
          value: totalStudents.toString(),
          icon: Icons.group,
        ),
        StatItemWidget(
          label: 'الملاحظات',
          value: totalNotes.toString(),
          icon: Icons.note,
        ),
      ],
    );
  }

  Widget _buildLecturesTable() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_lectures.isEmpty) {
      return EmptyStateWidget(
        title: 'لا توجد محاضرات مسجلة',
        message: 'قم بإضافة محاضرة جديدة',
        icon: Icons.library_books_outlined,
        onAction: _addNewLecture,
        actionText: 'إضافة محاضرة',
      );
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
                label: Text('التاريخ', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('اليوم', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('عنوان المحاضرة', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('الحضور', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('الغياب', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('ملاحظات', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('تاريخ الإنشاء', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('الإجراءات', style: font14black.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: _lectures.asMap().entries.map((entry) {
              final index = entry.key;
              final lecture = entry.value;
              
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(
                    Text(
                      DateFormat('yyyy/MM/dd').format(lecture.date),
                      style: font12black,
                    ),
                  ),
                  DataCell(
                    Text(
                      _getArabicDay(lecture.date),
                      style: font12black.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Tooltip(
                      message: lecture.lectureTitle,
                      child: Text(
                        lecture.lectureTitle,
                        style: font12black,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        lecture.presentStudentIds.length.toString(),
                        style: font12black.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        lecture.absentStudentIds.length.toString(),
                        style: font12black.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        lecture.studentNotes.length.toString(),
                        style: font12black.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      DateFormat('HH:mm').format(lecture.createdAt),
                      style: font12black,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: ColorsApp.primaryColor),
                          onPressed: () => _editLecture(lecture),
                          /*padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),*/
                          tooltip: 'تعديل',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => _deleteLecture(lecture),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: 'حذف',
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
}