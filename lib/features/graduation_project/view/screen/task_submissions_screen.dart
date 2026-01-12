import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:intl/intl.dart';
import 'dart:io';

/// شاشة عرض تسليمات المهمة
/// تسمح للطلاب بتسليم المهام وللمشرفين بمراجعة التسليمات
class TaskSubmissionsScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const TaskSubmissionsScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<TaskSubmissionsScreen> createState() => _TaskSubmissionsScreenState();
}

class _TaskSubmissionsScreenState extends State<TaskSubmissionsScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<TaskSubmissionModel> _submissions = [];
  final _gradeController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل تسليمات المهمة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubmissions();
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  /// تحميل تسليمات المهمة
  void _loadSubmissions() {
    setState(() {
      _isLoading = true;
    });
    
    context.read<ProjectBloc>().add(LoadTaskSubmissions(taskId: widget.taskId));
  }

  /// اختيار ملف من الجهاز
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ShowWidget.showMessage(context, 'خطأ في اختيار الملف: $e', Colors.red, font13White);
    }
  }

  /// تسليم المهمة
  void _submitTask() {
    if (_selectedFile == null) {
      ShowWidget.showMessage(context, 'الرجاء اختيار ملف للتسليم', Colors.orange, font13White);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      final submission = TaskSubmissionModel(
        id: widget.taskId + '_' + myUserState.user!.userID,
        taskId: widget.taskId,
        studentId: myUserState.user!.userID,
        studentName: myUserState.user!.name,
        submissionDate: DateTime.now(),
        attachmentUrl: _selectedFile!.path,
        fileName: _fileName!,
        isGraded: false,
      );

      context.read<ProjectBloc>().add(SubmitTask(submission: submission));
    }
  }

  /// تقييم تسليم المهمة
  void _gradeSubmission(TaskSubmissionModel submission) {
    _gradeController.text = submission.grade?.toString() ?? '';
    _feedbackController.text = submission.feedback ?? '';

    showDialog(
      context: context,
      builder: (context) => GradeSubmissionDialog(
        submission: submission,
        gradeController: _gradeController,
        feedbackController: _feedbackController,
        onSave: (grade, feedback) {
          Navigator.pop(context);
          context.read<ProjectBloc>().add(GradeTaskSubmission(
            submissionId: submission.id,
            grade: grade ?? 0,
            feedback: feedback ?? '',
          ));
        },
      ),
    );
  }

  /// التحقق مما إذا كان المستخدم الحالي طالبًا
  bool _isCurrentUserStudent() {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      final userRole = myUserState.user!.role;
      return userRole == 'Student';
    }
    return false;
  }

  /// التحقق مما إذا كان المستخدم الحالي مشرفًا
  bool _isCurrentUserSupervisor() {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      final userRole = myUserState.user!.role;
      return userRole == 'Doctor';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: 'تسليمات: ${widget.taskTitle}'),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is TaskSubmissionsLoaded) {
                setState(() {
                  _submissions = state.submissions;
                  _isLoading = false;
                  _isSubmitting = false;
                });
              }
              if (state is TaskSubmissionOperationSuccess) {
                setState(() {
                  _isSubmitting = false;
                });
                ShowWidget.showMessage(context, state.message, Colors.green, font13White);
                _loadSubmissions(); // إعادة تحميل التسليمات بعد التسليم الناجح
              }
              if (state is ProjectError) {
                setState(() {
                  _isLoading = false;
                  _isSubmitting = false;
                });
                ShowWidget.showMessage(context, state.error, Colors.red, font13White);
              }
            },
          ),
          // إضافة مستمع آخر لحالة ProjectOperationSuccess
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is ProjectOperationSuccess && state.message.contains('تقييم')) {
                ShowWidget.showMessage(context, state.message, Colors.green, font13White);
                _loadSubmissions(); // إعادة تحميل التسليمات بعد التقييم
              }
            },
          ),
        ],
        child: Column(
          children: [
            // قسم تسليم المهمة (للطلاب فقط)
            if (_isCurrentUserStudent()) _buildSubmissionSection(),
            
            // قسم عرض التسليمات
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor))
                  : _submissions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد تسليمات حالياً',
                                style: font18blackbold,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isCurrentUserStudent()
                                    ? 'قم بتسليم مهمتك باستخدام الزر أدناه'
                                    : 'سيتم عرض التسليمات هنا عند قيام الطلاب بتسليم مهامهم',
                                style: font14grey,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _submissions.length,
                          itemBuilder: (context, index) {
                            final submission = _submissions[index];
                            return _buildSubmissionCard(submission);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قسم تسليم المهمة (للطلاب فقط)
  Widget _buildSubmissionSection() {
    // التحقق إذا كان الطالب قد سلم بالفعل
    final myUserState = context.read<MyUserBloc>().state;
    bool hasSubmitted = false;
    TaskSubmissionModel? existingSubmission;
    
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      existingSubmission = _submissions.firstWhere(
        (submission) => submission.studentId == myUserState.user!.userID,
        orElse: () => TaskSubmissionModel(
          id: '',
          taskId: widget.taskId,
          studentId: '',
          studentName: '',
          submissionDate: DateTime.now(),
          attachmentUrl: '',
          fileName: '',
        ),
      );
      hasSubmitted = existingSubmission.id.isNotEmpty;
    }
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسليم المهمة',
              style: font18blackbold,
            ),
            const SizedBox(height: 16),
            if (hasSubmitted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: existingSubmission!.isGraded 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: existingSubmission.isGraded ? Colors.green : Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          existingSubmission.isGraded 
                              ? Icons.check_circle 
                              : Icons.pending,
                          color: existingSubmission.isGraded ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          existingSubmission.isGraded 
                              ? 'تم تقييم تسليمك'
                              : 'تم تسليم مهمتك وينتظر التقييم',
                          style: font14black.copyWith(
                            color: existingSubmission.isGraded ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (existingSubmission.isGraded) ...[
                      const SizedBox(height: 8),
                      if (existingSubmission.grade != null)
                        Text(
                          'التقييم: ${existingSubmission.grade}/100',
                          style: font14black.copyWith(fontWeight: FontWeight.bold),
                        ),
                      if (existingSubmission.feedback != null && existingSubmission.feedback!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ملاحظات: ${existingSubmission.feedback}',
                          style: font14grey,
                        ),
                      ],
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'ملف: ${existingSubmission.fileName}',
                      style: font12Grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تاريخ التسليم: ${_formatDate(existingSubmission.submissionDate)}',
                      style: font12Grey,
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildFilePicker(),
              if (_selectedFile != null) _buildFilePreview(),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// بناء منتقي الملفات
  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(_fileName ?? 'اختر ملف التسليم', style: font14grey),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  /// بناء معاينة الملف المختار
  Widget _buildFilePreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: ColorsApp.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _fileName!,
              style: font14black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() {
              _selectedFile = null;
              _fileName = null;
            }),
          ),
        ],
      ),
    );
  }

  /// بناء زر التسليم
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('تسليم المهمة', style: font16White),
      ),
    );
  }

  /// بناء بطاقة التسليم
  Widget _buildSubmissionCard(TaskSubmissionModel submission) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: submission.isGraded 
              ? Colors.green.withOpacity(0.1)
              : ColorsApp.primaryColor.withOpacity(0.1),
          child: Icon(
            submission.isGraded ? Icons.check_circle : Icons.person,
            color: submission.isGraded ? Colors.green : ColorsApp.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(submission.studentName, style: font16blackbold),
            ),
            if (submission.isGraded && submission.grade != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${submission.grade}/100',
                  style: font12black.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تاريخ التسليم: ${_formatDate(submission.submissionDate)}',
              style: font12Grey,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    submission.fileName,
                    style: font12Grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'ملاحظات: ${submission.feedback}',
                style: font12Grey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _isCurrentUserSupervisor()
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.download, color: ColorsApp.primaryColor),
                    onPressed: () => _downloadSubmission(submission),
                    tooltip: 'تحميل الملف',
                  ),
                  if (!submission.isGraded)
                    IconButton(
                      icon: Icon(Icons.grade, color: Colors.orange),
                      onPressed: () => _gradeSubmission(submission),
                      tooltip: 'تقييم التسليم',
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _gradeSubmission(submission),
                      tooltip: 'تعديل التقييم',
                    ),
                ],
              )
            : IconButton(
                icon: Icon(Icons.download, color: ColorsApp.primaryColor),
                onPressed: () => _downloadSubmission(submission),
                tooltip: 'تحميل الملف',
              ),
        onTap: () {
          // يمكن إضافة التنقل إلى تفاصيل التسليم هنا
        },
      ),
    );
  }

  /// تحميل ملف التسليم
  void _downloadSubmission(TaskSubmissionModel submission) {
    // هنا يمكنك إضافة كود لتحميل الملف
    ShowWidget.showMessage(context, 'جاري تحميل الملف: ${submission.fileName}', Colors.blue, font13White);
    
    // محاكاة تحميل الملف
    Future.delayed(const Duration(seconds: 1), () {
      ShowWidget.showMessage(context, 'تم تحميل الملف بنجاح', Colors.green, font13White);
    });
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
// خيارات التقييم
  enum GradeOption { gradeOnly, feedbackOnly, both }
/// حوار تقييم التسليم
class GradeSubmissionDialog extends StatefulWidget {
  final TaskSubmissionModel submission;
  final TextEditingController gradeController;
  final TextEditingController feedbackController;
  final Function(int?, String?) onSave;

  const GradeSubmissionDialog({
    super.key,
    required this.submission,
    required this.gradeController,
    required this.feedbackController,
    required this.onSave,
  });

  @override
  State<GradeSubmissionDialog> createState() => _GradeSubmissionDialogState();
}

class _GradeSubmissionDialogState extends State<GradeSubmissionDialog> {

  GradeOption _selectedOption = GradeOption.both;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تقييم تسليم: ${widget.submission.studentName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملف: ${widget.submission.fileName}'),
            const SizedBox(height: 16),
            
            // خيارات التقييم
            Text(
              'نوع التقييم:',
              style: font14black.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<GradeOption>(
              title: const Text('تقييم رقمي فقط'),
              value: GradeOption.gradeOnly,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            RadioListTile<GradeOption>(
              title: const Text('ملاحظات فقط'),
              value: GradeOption.feedbackOnly,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            RadioListTile<GradeOption>(
              title: const Text('تقييم وملاحظات'),
              value: GradeOption.both,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // حقل التقييم (يظهر حسب الخيار المحدد)
            if (_selectedOption == GradeOption.gradeOnly || _selectedOption == GradeOption.both)
              TextField(
                controller: widget.gradeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'التقييم (من 100)',
                  border: OutlineInputBorder(),
                ),
              ),
            
            // حقل الملاحظات (يظهر حسب الخيار المحدد)
            if (_selectedOption == GradeOption.feedbackOnly || _selectedOption == GradeOption.both) ...[
              const SizedBox(height: 16),
              TextField(
                controller: widget.feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            int? grade;
            String? feedback;
            
            // التحقق من القيم المدخلة حسب الخيار المحدد
            if (_selectedOption == GradeOption.gradeOnly) {
              grade = int.tryParse(widget.gradeController.text);
              if (grade == null || grade < 0 || grade > 100) {
                ShowWidget.showMessage(context, 'الرجاء إدخال تقييم صحيح (من 0 إلى 100)', Colors.orange, font13White);
                return;
              }
            } else if (_selectedOption == GradeOption.feedbackOnly) {
              feedback = widget.feedbackController.text.trim();
              if (feedback.isEmpty) {
                ShowWidget.showMessage(context, 'الرجاء إدخال ملاحظات', Colors.orange, font13White);
                return;
              }
            } else {
              grade = int.tryParse(widget.gradeController.text);
              feedback = widget.feedbackController.text.trim();
              
              if (grade != null && (grade < 0 || grade > 100)) {
                ShowWidget.showMessage(context, 'الرجاء إدخال تقييم صحيح (من 0 إلى 100)', Colors.orange, font13White);
                return;
              }
              
              if (grade == null && feedback.isEmpty) {
                ShowWidget.showMessage(context, 'الرجاء إدخال تقييم أو ملاحظات', Colors.orange, font13White);
                return;
              }
            }
            
            widget.onSave(grade, (feedback == null || feedback.isEmpty) ? null : feedback);
          },
          child: const Text('حفظ التقييم'),
        ),
      ],
    );
  }
}