import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

/// شاشة إنشاء/تعديل مهمة
/// تسمح للمستخدم بإنشاء مهمة جديدة أو تعديل مهمة موجودة مع إمكانية إرفاق ملف
class NewTaskScreen extends StatefulWidget {
  final TaskModel? task; // إضافة مهمة اختيارية للتعديل

  const NewTaskScreen({super.key, this.task});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;
  bool _isEditing = false; // متغير لتحديد ما إذا كنا في وضع التعديل

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير مهمة، فنحن في وضع التعديل
    if (widget.task != null) {
      _isEditing = true;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      // لا يمكن تعيين ملف من attachmentUrl مباشرة، لكن يمكن عرض اسم الملف إذا كان موجودًا
      if (widget.task!.attachmentUrl != null && widget.task!.attachmentUrl!.isNotEmpty) {
        _fileName = widget.task!.attachmentUrl!.split('/').last;
      }
    }
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

  /// إرسال بيانات المهمة لإنشائها أو تحديثها
  void _submitTask() {
    if (_titleController.text.isEmpty) {
      ShowWidget.showMessage(context, 'الرجاء ملء جميع الحقول المطلوبة', Colors.orange, font13White);
      return;
    }

    setState(() { _isLoading = true; });

    if (_isEditing) {
      // تحديث المهمة الموجودة
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        attachmentUrl: _selectedFile?.path ?? widget.task!.attachmentUrl,
      );
      
      // استخدام الحدث الجديد لتحديث المهمة
      context.read<ProjectBloc>().add(UpdateTask(task: updatedTask));
    } else {
      // إنشاء مهمة جديدة
      final task = TaskModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        attachmentUrl: _selectedFile?.path ?? '',
        createdAt: DateTime.now(),
      );

      context.read<ProjectBloc>().add(AddTask(task: task));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(
        title: _isEditing ? 'تعديل المهمة' : 'إضافة مهمة جديدة'
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectOperationSuccess) {
            setState(() { _isLoading = false; });
            // عرض رسالة نجاح
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // العودة إلى الشاشة السابقة بعد نجاح العملية
            Navigator.pop(context);
          }
          if (state is ProjectError) {
            setState(() { _isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('معلومات المهمة'),
              _buildTextField(_titleController, 'عنوان المهمة', Icons.title),
              getHeight(16),
              _buildTextField(_descriptionController, 'وصف المهمة', Icons.description, maxLines: 5),
              getHeight(16),
              _buildSectionTitle('ملف المهمة (اختياري)'),
              _buildFilePicker(),
              if (_selectedFile != null || (_isEditing && widget.task!.attachmentUrl != null && widget.task!.attachmentUrl!.isNotEmpty)) 
                _buildFilePreview(),
              getHeight(40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: font20blackbold),
    );
  }

  /// بناء حقل نصي
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: ColorsApp.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: ColorsApp.primaryColor, width: 2.0),
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
            Text(_fileName ?? 'اختر ملف المهمة', style: font14grey),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  /// بناء معاينة الملف المختار
  Widget _buildFilePreview() {
    String fileName = _fileName ?? '';
    if (_isEditing && fileName.isEmpty && widget.task!.attachmentUrl != null && widget.task!.attachmentUrl!.isNotEmpty) {
      fileName = widget.task!.attachmentUrl!.split('/').last;
    }
    
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
              fileName,
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

  /// بناء زر الإرسال
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorsApp.primaryColor),
              )
            : Text(_isEditing ? 'تحديث المهمة' : 'إضافة المهمة', style: font16White),
      ),
    );
  }
}