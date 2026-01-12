import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class HomeworkSubmissionScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final HomeworkModel homework;
  final String studentId;
  final String? studentName; // يمكن تمريره إذا كان متاحاً

  const HomeworkSubmissionScreen({
    super.key,
    required this.course,
    required this.group,
    required this.homework,
    required this.studentId,
    this.studentName,
  });

  @override
  State<HomeworkSubmissionScreen> createState() => _HomeworkSubmissionScreenState();
}

class _HomeworkSubmissionScreenState extends State<HomeworkSubmissionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  String? _filePath;
  String? _fileName;
  bool _isSubmitting = false;
  bool _hasExistingSubmission = false;
  StudentHomeworkModel? _existingSubmission;

  @override
  void initState() {
    super.initState();
    _checkExistingSubmission();
    //_loadStudentName();
    _setupAutomaticTitle();
  }

  // دالة جديدة لإعداد العنوان التلقائي
void _setupAutomaticTitle() {
  // إذا كان العنوان فارغاً ولم يكن هناك تسليم سابق
  if (_titleController.text.isEmpty && !_hasExistingSubmission) {
    // استخدام اسم الواجب كعنوان افتراضي
    final defaultTitle = '${widget.homework.title} - ${_getStudentName()}';
    _titleController.text = defaultTitle;
  }
}

// دالة للحصول على اسم الطالب
String _getStudentName() {
  if (widget.studentName != null && widget.studentName!.isNotEmpty) {
    return widget.studentName!;
  }
  
  return 'طالب';
}

  // 🔍 التحقق من وجود تسليم سابق
  void _checkExistingSubmission() {
    final existing = widget.homework.students.firstWhere(
      (s) => s.idStudent == widget.studentId,
      orElse: () => StudentHomeworkModel.empty,
    );
    
    if (existing.isNotEmpty) {
      setState(() {
        _hasExistingSubmission = true;
        _existingSubmission = existing;
        _titleController.text = existing.title;
        _descriptionController.text = existing.title; // يمكن استخدام حقل description
      });
    }
  }

  // 📤 اختيار ملف
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip', 'rar', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFile = File(file.path!);
          _filePath = file.path;
          _fileName = file.name;
        });
        // بدلاً من ذلك، نعرض رسالة توضيحية
      if (_titleController.text.isEmpty) {
        _showTitleHint();
        }
      }
    } catch (e) {
      _showError('خطأ في اختيار الملف: $e');
    }
  }

  // دالة جديدة لعرض تلميح العنوان
  void _showTitleHint() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إدخال عنوان مناسب للتسليم'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // 📋 عرض معلومات الواجب
  Widget _buildHomeworkInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الواجب',
              style: font18blackbold.copyWith(color: ColorsApp.primaryColor),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('عنوان الواجب:', widget.homework.title),
            _buildInfoRow('الوصف:', widget.homework.description),
            _buildInfoRow('الدرجة الكاملة:', '${widget.homework.maxMark}'),
            _buildInfoRow('تاريخ التسليم:', _formatDateTime(widget.homework.end)),
            const SizedBox(height: 8),
            _buildTimeRemaining(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: font14black.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: font14black,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining() {
    final remaining = widget.homework.timeRemaining;
    final isExpired = widget.homework.isExpired;
    
    Color color;
    String status;
    
    if (isExpired) {
      color = Colors.red;
      status = 'انتهى وقت التسليم';
    } else if (remaining.inHours < 24) {
      color = Colors.orange;
      status = 'متبقي: ${remaining.inHours} ساعة';
    } else {
      color = Colors.green;
      status = 'متبقي: ${remaining.inDays} يوم';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            status,
            style: font12black.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Icon(
            isExpired ? Icons.error_outline : Icons.access_time,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }

  // 📝 نموذج التسليم
  Widget _buildSubmissionForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسليم الواجب',
              style: font18blackbold.copyWith(color: ColorsApp.primaryColor),
            ),
            const SizedBox(height: 16),
            
            // حقل العنوان
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان التسليم ',
                hintText: 'أدخل عنواناً وصفياً للتسليم',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.title, color: ColorsApp.primaryColor),
                // نجمة حمراء للإشارة للإلزامية
                suffixIcon: _titleController.text.isEmpty
                    ? Icon(Icons.error, color: Colors.red, size: 16)
                    : Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
              maxLength: 100,
              onChanged: (value) {
                setState(() {}); // تحديث الواجهة للتحقق من الصحة
              },
            ),
            // إضافة رسالة توضيحية تحت حقل العنوان
            if (_titleController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'عنوان الوصف يساعد الأستاذ في تصنيف تسليمك',
                      style: font12Grey,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // حقل الوصف (اختياري)
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                hintText: 'يمكنك إضافة أي ملاحظات توضيحية',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.description, color: ColorsApp.primaryColor),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            
            // اختيار الملف
            _buildFilePicker(),
            const SizedBox(height: 16),
            
            // معلومات الملف المحدد
            if (_fileName != null) _buildFileInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رفع الملف ',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: ColorsApp.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _fileName ?? 'انقر لاختيار ملف',
                  style: _fileName != null ? font14black : font14grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'الملفات المسموحة: PDF, Word, Text, Images, ZIP',
          style: font12Grey,
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName!,
                  style: font14black.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedFile != null)
                  Text(
                    '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} كيلوبايت',
                    style: font12Grey,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _fileName = null;
                _filePath = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // ⚠️ بناء حالة الخطأ
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
            const SizedBox(height: 20),
            Text(
              'لا يمكن تسليم الواجب',
              style: font18blackbold.copyWith(color: ColorsApp.red),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: font16black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ إرسال الواجب
  Future<void> _submitAssignment() async {
    // التحقق من صحة البيانات
    if (_titleController.text.isEmpty || _titleController.text.trim().isEmpty) {
    _showError('يرجى إدخال عنوان مناسب للتسليم');
    // اقتراح عنوان تلقائي
    _suggestAutomaticTitle();
    return;
    }

    // منع استخدام اسم الملف كعنوان
  if (_fileName != null && _titleController.text.contains(_fileName!.split('.').first)) {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'عنوان غير مناسب',
      message: 'يبدو أنك استخدمت اسم الملف كعنوان. هل تريد تغييره؟',
      confirmText: 'تغيير العنوان',
      cancelText: 'المتابعة',
    );
    
    if (confirmed) {
      _titleController.text = '${widget.homework.title} ';
      _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
      return;
    }
  }
    
    if (_selectedFile == null) {
      _showError('يرجى اختيار ملف للتسليم');
      return;
    }
    
    // التحقق من وقت التسليم
    if (widget.homework.isExpired) {
      final confirmed = await CustomDialog.showConfirmation(
        context: context,
        title: 'انتهى وقت التسليم',
        message: 'لقد انتهى وقت تسليم هذا الواجب. هل تريد التسليم مع العلم أن الدرجة قد تتأثر؟',
        confirmText: 'تسليم',
        cancelText: 'إلغاء',
      );
      if (!confirmed) return;
    }
    
    // التحقق من وجود تسليم سابق
    if (_hasExistingSubmission) {
      final confirmed = await CustomDialog.showConfirmation(
        context: context,
        title: 'تسليم سابق موجود',
        message: 'لديك تسليم سابق لهذا الواجب. هل تريد استبداله؟',
        confirmText: 'استبدال',
        cancelText: 'إلغاء',
      );
      if (!confirmed) return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // إنشاء نموذج التسليم
      final submission = StudentHomeworkModel(
        idStudent: widget.studentId,
        name: _getStudentName(),
        file: _filePath!, // في الواقع، يجب رفع الملف أولاً والحصول على رابط
        title: _titleController.text,
        fromMark: 0, // درجة ابتدائية صفر
        submitTime: DateTime.now(),
      );
      
      // إرسال الحدث إلى الـ BLoC
      context.read<SubjectiveBloc>().add(
        SubmitHomeworkEvent(
          courseId: widget.course.id,
          groupId: widget.group.id,
          homeworkId: widget.homework.id,
          submission: submission,
        ),
      );
      
    } catch (e) {
      _showError('خطأ في إعداد التسليم: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // دالة جديدة لاقتراح عنوان تلقائي
void _suggestAutomaticTitle() {
  final suggestedTitle = '${widget.homework.title}';
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('اقتراح عنوان'),
      content: Text('هل تريد استخدام العنوان التالي؟\n\n$suggestedTitle'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لا، سأدخله يدوياً'),
        ),
        ElevatedButton(
          onPressed: () {
            _titleController.text = suggestedTitle;
            Navigator.pop(context);
          },
          child: const Text('نعم، استخدم هذا العنوان'),
        ),
      ],
    ),
  );
}

  // 📤 رفع الملف (دالة مساعدة - تحتاج للتكامل مع FileUploadService)
  Future<String> _uploadFile(File file) async {
    // TODO: تكامل مع FileUploadService
    // return await FileUploadService.uploadHomeworkFile(file);
    return 'uploaded_file_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsApp.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is SubjectiveOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorsApp.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // العودة بعد نجاح التسليم
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(context, true);
          });
        }
        
        if (state is SubjectiveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorsApp.red,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() => _isSubmitting = false);
        }
      },
      child: Scaffold(
        appBar: CustomAppBarTitle( title: 'تسليم الواجب',),
        body: widget.homework.isExpired && !_hasExistingSubmission
            ? _buildErrorState('لقد انتهى وقت تسليم هذا الواجب.')
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    // معلومات الواجب
                    _buildHomeworkInfo(),
                    
                    // نموذج التسليم
                    _buildSubmissionForm(),
                    
                    // رسالة إذا كان هناك تسليم سابق
                    if (_hasExistingSubmission)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'لديك تسليم سابق. سيتم استبداله عند إرسال التسليم الجديد.',
                                  style: font12black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          color: ColorsApp.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          child: Row(
            children: [
              // زر الإلغاء
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: ColorsApp.primaryColor),
                  ),
                  child: Text(
                    'إلغاء',
                    style: font16black.copyWith(color: ColorsApp.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // زر الإرسال
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('جاري الإرسال...', style: font16White),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _hasExistingSubmission ? 'تحديث التسليم' : 'تسليم الواجب',
                              style: font16White,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}