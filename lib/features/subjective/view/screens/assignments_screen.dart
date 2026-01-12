import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/subjective/view/screens/homework_submission_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/screens/new_assignment_screen.dart';
import 'package:myproject/features/subjective/view/screens/homework_submissions_screen.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AssignmentsScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final String userId;
  final String studentname;

  const AssignmentsScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.userId,
    required this.studentname
  });

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadHomeworks();
  }

  void _loadHomeworks() {
    context.read<SubjectiveBloc>().add(
      LoadHomeworksEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: '${widget.group.name} - الواجبات'),
      floatingActionButton: widget.userRole == 'Doctor'
          ? FloatingActionButton(
              onPressed: _addHomework,
              backgroundColor: ColorsApp.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          if (state is SubjectiveOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsApp.green,
              ),
            );
            _loadHomeworks();
          }
          if (state is SubjectiveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsApp.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubjectiveLoading && state is! HomeworkLoadSuccess) {
            return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
          }

          if (state is SubjectiveError && state is! HomeworkLoadSuccess) {
            return _buildErrorState(state.message);
          }

          if (state is HomeworkLoadSuccess) {
            if (state.homeworks.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: ColorsApp.primaryColor,
              onRefresh: () async => _loadHomeworks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.homeworks.length,
                itemBuilder: (context, index) {
                  final homework = state.homeworks[index];
                  return _buildHomeworkCard(homework);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: font16black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadHomeworks,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد واجبات',
            style: font18blackbold,
          ),
          const SizedBox(height: 8),
          Text(
            widget.userRole == 'Doctor'
                ? 'يمكنك إضافة الواجبات من خلال زر الإضافة'
                : 'سيتم عرض الواجبات هنا عندما يضيفها الأستاذ',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(HomeworkModel homework) {
    final isExpired = homework.isExpired;
    final isActive = homework.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: isExpired ? Colors.grey[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.title,
                        style: font16blackbold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.userRole == 'Doctor') ...[
                        const SizedBox(height: 4),
                        _buildSubmissionStats(homework),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(isActive, isExpired),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(isActive, isExpired),
                        style: font11White.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (widget.userRole == 'Doctor') ...[
                      const SizedBox(height: 4),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleHomeworkAction(value, homework),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'submissions', child: Text('عرض التسليمات')),
                          const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                          const PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // الوصف
            if (homework.description.isNotEmpty) ...[
              Text(
                homework.description,
                style: font14black,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            
            // التواريخ
            _buildDateInfo('وقت البدء:', homework.start),
            _buildDateInfo('وقت التسليم:', homework.end),
            
            const SizedBox(height: 8),
            // معلومات تسليم الطالب
          if (widget.userRole == 'Student') 
            _buildStudentSubmissionInfo(homework),
            
            // المعلومات الإضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الدرجة الكاملة: ${homework.maxMark}',
                  style: font14black.copyWith(fontWeight: FontWeight.bold),
                ),
                if (widget.userRole == 'Doctor') 
                  Text(
                    '${homework.totalStudents} /${widget.group.students.length} طالب',
                    style: font12Grey,
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // الأزرار
            _buildHomeworkButtons(homework),
          ],
        ),
      ),
    );
  }

  // دالة جديدة لعرض معلومات تسليم الطالب
Widget _buildStudentSubmissionInfo(HomeworkModel homework) {
  final studentSubmission = _getStudentSubmission(homework);
  final hasSubmitted = studentSubmission != null;
  final isValidSubmission = hasSubmitted && 
                            studentSubmission!.file.isNotEmpty && 
                            studentSubmission.submitTime != null;
  final isGraded = studentSubmission?.isGraded ?? false;
  
  if (!isValidSubmission) return const SizedBox.shrink();
  
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isGraded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isGraded ? Colors.green : Colors.orange,
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Icon(
          isGraded ? Icons.grade : Icons.access_time,
          color: isGraded ? Colors.green : Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGraded ? '✅ تم تسليم وتقييم واجبك' : '⏳ تم تسليم واجبك',
                style: font14black.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isGraded ? Colors.green : Colors.orange,
                ),
              ),
              if (isGraded) ...[
                const SizedBox(height: 4),
                Text(
                  'الدرجة: ${studentSubmission.fromMark}/${homework.maxMark}',
                  style: font13black.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorsApp.primaryColor,
                  ),
                ),
              ],
              if (studentSubmission.submitTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  'وقت التسليم: ${_formatDateTime(studentSubmission.submitTime!)}',
                  style: font12Grey,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

  // الأزرار
Widget _buildHomeworkButtons(HomeworkModel homework) {
  // التحقق إذا كان الطالب قد سلم الواجب
  final studentSubmission = _getStudentSubmission(homework);

  return Row(
    children: [
      if (homework.file.isNotEmpty)
        ElevatedButton.icon(
          onPressed: () => _openFile(homework.file),
          icon: Icon(Icons.file_open, color: Colors.white),
          label: Text('فتح الملف', style: font13White),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsApp.primaryColor,
          ),
        ),
      const Spacer(),
      
      if (widget.userRole == 'Student')
        _buildStudentHomeworkButton(homework, studentSubmission),
      
      if (widget.userRole == 'Doctor' && homework.submittedCount > 0)
        ElevatedButton(
          onPressed: () => _viewSubmissions(homework),
          child: const Text('عرض التسليمات'),
        ),
    ],
  );
}

// بناء زر خاص بحالة الطالب
Widget _buildStudentHomeworkButton(HomeworkModel homework, StudentHomeworkModel? submission) {
  final hasSubmitted = submission != null;
  final isGraded = submission?.isGraded ?? false;
  final isExpired = homework.isExpired;
  final isActive = homework.isActive;

  // التحقق من بيانات التسليم للتأكد من صحتها
  final isValidSubmission = hasSubmitted && 
                            submission.file.isNotEmpty && 
                            submission.submitTime != null;

  // إذا تم التقييم
  if (isValidSubmission && isGraded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'تم التسليم والتقييم',
                style: font13black.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'الدرجة: ${submission.fromMark}/${homework.maxMark}',
          style: font14black.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorsApp.primaryColor,
          ),
        ),
      ],
    );
  }

  // إذا تم التسليم ولكن لم يتم التقييم
  if (isValidSubmission && !isGraded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            'بانتظار التقييم',
            style: font13black.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // إذا لم يسلم والواجب نشط
  if (isActive) {
    return ElevatedButton(
      onPressed: () => _submitHomework(homework),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsApp.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.send, color: Colors.white, size: 16),
          SizedBox(width: 8),
            Text('تسليم الواجب',
          style: font11White,
          ),
        ],
      ),
    );
  }

  // إذا انتهى الوقت ولم يسلم
  if (isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        'انتهى وقت التسليم',
        style: font13black.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // حالة افتراضية
  return Container();
}

// دالة مساعدة جديدة للتحقق من وجود تسليم
  bool _hasRealSubmission(HomeworkModel homework) {
    final submission = homework.students.firstWhere(
      (student) => student.idStudent == widget.userId,
      orElse: () => StudentHomeworkModel.empty,
    );
  
    return submission.isNotEmpty && 
          submission.file.isNotEmpty && 
          submission.submitTime != null;
  }

  // دالة مساعدة للحصول على تسليم الطالب
  StudentHomeworkModel? _getStudentSubmission(HomeworkModel homework) {
    if (_hasRealSubmission(homework)) {
      return homework.students.firstWhere(
        (student) => student.idStudent == widget.userId,
      );
    }
    return null;
  }

  Widget _buildSubmissionStats(HomeworkModel homework) {
    final submissionRate = (homework.submittedCount / homework.totalStudents * 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التسليمات: ${homework.totalStudents}/${widget.group.students.length}',
          style: font12Grey,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: homework.totalStudents > 0 ? homework.submittedCount / homework.totalStudents : 0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            submissionRate >= 80 ? Colors.green :
            submissionRate >= 50 ? Colors.orange : Colors.red
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: font12black.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(date),
            style: font12black,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool isActive, bool isExpired) {
    if (isExpired) return Colors.red;
    if (isActive) return Colors.green;
    return Colors.orange;
  }

  String _getStatusText(bool isActive, bool isExpired) {
    if (isExpired) return 'منتهي';
    if (isActive) return 'نشط';
    return 'قادم';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ========== دوال تنفيذ الأزرار ==========

  void _addHomework() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAssignmentScreen(
          course: widget.course,
          selectedGroups: [widget.group],
          doctorId: widget.userId,
        ),
      ),
    );
    if (result == true) {
      _loadHomeworks();
    }
  }

  void _handleHomeworkAction(String action, HomeworkModel homework) {
    switch (action) {
      case 'submissions':
        _viewSubmissions(homework);
        break;
      case 'edit':
        _editHomework(homework);
        break;
      case 'delete':
        _deleteHomework(homework);
        break;
    }
  }

  void _viewSubmissions(HomeworkModel homework) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeworkSubmissionsScreen(
          course: widget.course,
          group: widget.group,
          homework: homework,
          doctorId: widget.userId,
        ),
      ),
    );
  }

  void _editHomework(HomeworkModel homework) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewAssignmentScreen(
        course: widget.course,
        selectedGroups: [widget.group],
        doctorId: widget.userId,
        homeworkToEdit: homework, // 🔥 تمرير الواجب للتعديل
      ),
    ),
  ).then((result) {
    if (result == true) {
      _loadHomeworks();
    }
  });
}

  void _submitHomework(HomeworkModel homework) {
  // التنقل إلى شاشة تسليم الواجب
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomeworkSubmissionScreen(
        course: widget.course,
        group: widget.group,
        homework: homework,
        studentId: widget.userId,
        studentName:widget.studentname,
      ),
    ),
  ).then((_) {
    _loadHomeworks(); // إعادة تحميل الواجبات بعد التسليم
  });
}

  void _deleteHomework(HomeworkModel homework) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الواجب',
      message: 'هل أنت متأكد من حذف هذا الواجب؟\nسيتم حذف جميع التسليمات المرتبطة به.',
      confirmText: ' احذف',
      cancelText: 'إلغاء',
    );

    if (!confirmed) return;

    context.read<SubjectiveBloc>().add(
      DeleteHomeworkEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
        homeworkId: homework.id,
      ),
    );
  }

  Future<void> _openFile(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح الرابط: $fileUrl'),
            backgroundColor: ColorsApp.red,
          ),
        );
      }
    }
  }
}