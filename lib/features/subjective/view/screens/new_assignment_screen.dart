import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/components/widget/date_picker_widget.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class NewAssignmentScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;
  final HomeworkModel? homeworkToEdit;

  const NewAssignmentScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
    this.homeworkToEdit,
  });

  @override
  State<NewAssignmentScreen> createState() => _NewAssignmentScreenState();
}

class _NewAssignmentScreenState extends State<NewAssignmentScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxMarkController = TextEditingController(text: '100');
  File? _selectedFile;
  String? _fileName;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🚀 بدء شاشة ${widget.homeworkToEdit != null ? 'تعديل' : 'إضافة'} واجب جديد');
    
    // 🔥 تعبئة البيانات إذا كان في وضع التعديل
    if (widget.homeworkToEdit != null) {
      _titleController.text = widget.homeworkToEdit!.title;
      _descriptionController.text = widget.homeworkToEdit!.description;
      _maxMarkController.text = widget.homeworkToEdit!.maxMark.toString();
      _dueDate = widget.homeworkToEdit!.end;
      // TODO: تحتاج لتحميل الملف الحالي إذا كان موجوداً
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileName = 'صورة من الكاميرا';
        });
        ShowWidget.showMessage(context, 'تم اختيار الصورة بنجاح', ColorsApp.green, font13White);
      }
    } catch (e) {
      ShowWidget.showMessage(context, 'خطأ في اختيار الصورة: $e', ColorsApp.red, font13White);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileName = 'صورة من المعرض';
        });
        ShowWidget.showMessage(context, 'تم اختيار الصورة بنجاح', ColorsApp.green, font13White);
      }
    } catch (e) {
      ShowWidget.showMessage(context, 'خطأ في اختيار الصورة: $e', ColorsApp.red, font13White);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
        ShowWidget.showMessage(context, 'تم اختيار الملف بنجاح', ColorsApp.green, font13White);
      }
    } catch (e) {
      ShowWidget.showMessage(context, 'خطأ في اختيار الملف: $e', ColorsApp.red, font13White);
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePickerWidget(
        initialDate: _dueDate ?? DateTime.now(),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _publishAssignment() async {
    print('🎯 بدء عملية ${widget.homeworkToEdit != null ? 'تعديل' : 'نشر'} الواجب...');
    
    // ... التحقق من البيانات الحالي ...

    final bool confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: widget.homeworkToEdit != null ? 'تعديل الواجب' : 'نشر الواجب',
      message: 'هل أنت متأكد من ${widget.homeworkToEdit != null ? 'تعديل' : 'نشر'} هذا الواجب في ${widget.selectedGroups.length} مجموعة؟',
      confirmText: widget.homeworkToEdit != null ? 'تعديل' : 'نشر',
      cancelText: 'إلغاء',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
    // TODO: قم بتنفيذ رفع الملف واحصل على الرابط
    String fileUrl = _selectedFile != null ? "رابط_ملف_مؤقت" : widget.homeworkToEdit?.file ?? "";

    final double parsedMaxMark = double.tryParse(_maxMarkController.text) ?? widget.homeworkToEdit?.maxMark ?? 100.0;

    final homework = HomeworkModel(
        id: widget.homeworkToEdit?.id ?? '',
        title: _titleController.text,
        start: widget.homeworkToEdit?.start ?? DateTime.now(),
        end: _dueDate!,
        description: _descriptionController.text,
        file: fileUrl,
        maxMark: parsedMaxMark,
      );

      final groupIds = widget.selectedGroups.map((group) => group.id).toList();

      if (widget.homeworkToEdit != null) {
        // 🔥 حدث التعديل
        print('✏️ إرسال حدث تعديل الواجب...');
        context.read<SubjectiveBloc>().add(
          UpdateHomeworkEvent(
            courseId: widget.course.id,
            groupId: widget.selectedGroups.first.id,
            homework: homework,
          ),
        );
      } else {
        // 🔥 حدث الإضافة
        print('🎯 إرسال حدث إضافة الواجب...');
        context.read<SubjectiveBloc>().add(
          AddHomeworkToMultipleGroupsEvent(
            courseId: widget.course.id,
            groupIds: groupIds,
            homework: homework,
          ),
        );
      }

    } catch (e) {
      print('❌ خطأ في ${widget.homeworkToEdit != null ? 'تعديل' : 'نشر'} الواجب: $e');
      ShowWidget.showMessage(context, 'خطأ في ${widget.homeworkToEdit != null ? 'تعديل' : 'نشر'} الواجب: $e', ColorsApp.red, font13White);
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.homeworkToEdit != null ? 'تعديل الواجب' : 'واجب جديد', style: font18blackbold),
            Text(
              '${widget.course.name} - ${widget.selectedGroups.length} مجموعة',
              style: font12Grey,
            ),
          ],
        ),
      ),
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          if (state is SubjectiveLoading) return;

          if (state is SubjectiveOperationSuccess) {
            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context, true);
            ShowWidget.showMessage(context, state.message, ColorsApp.green, font13White);
          }

          if (state is SubjectiveError) {
            setState(() {
              _isLoading = false;
            });
            ShowWidget.showMessage(context, state.message, ColorsApp.red, font13White);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectedGroupsInfo(),
                const SizedBox(height: 20),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDetailsRow(),
                const SizedBox(height: 20),
                _buildFileOptions(),
                const SizedBox(height: 20),
                if (_selectedFile != null) _buildFilePreview(),
                const SizedBox(height: 20),
                _buildPublishButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedGroupsInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.assignment, color: ColorsApp.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموعات المختارة',
                    style: font14black.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.selectedGroups.map((g) => g.name).join('، '),
                    style: font12Grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عنوان الواجب ',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'أدخل عنوان الواجب...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف الواجب (اختياري)',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل وصف الواجب...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الدرجة الكاملة ',
                style: font12black.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                'موعد التسليم ',
                style: font12black.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _maxMarkController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectDueDate,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: ColorsApp.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? _formatDateTime(_dueDate!)
                              : 'اختر التاريخ',
                          style: font12black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إرفاق ملف (اختياري)',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFileOption(
                icon: Icons.camera_alt,
                label: 'الكاميرا',
                onTap: _pickImageFromCamera,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFileOption(
                icon: Icons.photo,
                label: 'المعرض',
                onTap: _pickImageFromGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFileOption(
                icon: Icons.attach_file,
                label: 'ملف',
                onTap: _pickFile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: ColorsApp.primaryColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: font12black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Card(
      color: ColorsApp.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _fileName?.contains('صورة') == true
                  ? Icons.image
                  : Icons.insert_drive_file,
              color: ColorsApp.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName ?? 'ملف مرفق',
                    style: font12black.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedFile != null)
                    Text(
                      '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                      style: font12Grey,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: ColorsApp.red),
              onPressed: _removeFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    final bool canPublish = _titleController.text.isNotEmpty && _dueDate != null;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || !canPublish ? null : _publishAssignment,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPublish ? ColorsApp.primaryColor : ColorsApp.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ?  SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsApp.white),
                ),
              )
            : Text(
                widget.homeworkToEdit != null ? 'تعديل الواجب' : 'نشر الواجب',
                style: font16White.copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxMarkController.dispose();
    super.dispose();
  }
}