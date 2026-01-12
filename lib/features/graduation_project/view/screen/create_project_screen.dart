import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:user_repository/user_repository.dart';

/// شاشة إنشاء مشروع جديد
/// تسمح للمستخدم بإنشاء مشروع جديد وإدخال جميع المعلومات المطلوبة
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _goalsController = TextEditingController();
  
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;
  
  // قوائم لتخزين المشرفين والطلاب
  List<Map<String, String>> _supervisors = []; // كل عنصر يحتوي على name و id
  List<Map<String, String>> _students = []; // كل عنصر يحتوي على name و id

  @override
  void initState() {
    super.initState();
    
    // تهيئة متحكمات الحقول الرئيسية
    _supervisorNameController = TextEditingController();
    _studentNameController = TextEditingController();
    _studentIdController = TextEditingController();
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

  /// إضافة مشرف إلى قائمة المشرفين
  void _addSupervisor() {
    if (_supervisorNameController.text.trim().isNotEmpty ) {
      setState(() {
        _supervisors.add({
          'name': _supervisorNameController.text.trim(),
        });
        _supervisorNameController.clear();
      });
      ShowWidget.showMessage(context, 'تم إضافة المشرف بنجاح', Colors.green, font13White);
    } else {
      ShowWidget.showMessage(context, 'الرجاء ملء جميع حقول المشرف', Colors.orange, font13White);
    }
  }

  /// إزالة مشرف من القائمة
  void _removeSupervisor(int index) {
    setState(() {
      _supervisors.removeAt(index);
    });
  }

  /// إضافة طالب إلى قائمة الطلاب
  void _addStudent() {
    if (_studentNameController.text.trim().isNotEmpty && _studentIdController.text.trim().isNotEmpty) {
      setState(() {
        _students.add({
          'name': _studentNameController.text.trim(),
          'id': _studentIdController.text.trim(),
        });
        _studentNameController.clear();
        _studentIdController.clear();
      });
      ShowWidget.showMessage(context, 'تم إضافة الطالب بنجاح', Colors.green, font13White);
    } else {
      ShowWidget.showMessage(context, 'الرجاء ملء جميع حقول الطالب', Colors.orange, font13White);
    }
  }

  /// إزالة طالب من القائمة
  void _removeStudent(int index) {
    setState(() {
      _students.removeAt(index);
    });
  }

  /// إرسال بيانات المشروع لإنشائه
  Future<void> _submitProject() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ShowWidget.showMessage(context, 'الرجاء ملء جميع الحقول المطلوبة', Colors.orange, font13White);
      return;
    }

    if (_supervisors.isEmpty) {
      ShowWidget.showMessage(context, 'الرجاء إضافة مشرف على الأقل', Colors.orange, font13White);
      return;
    }

    setState(() { _isLoading = true; });

    try {
    String? attachmentUrl;
    
    // تحميل الملف المرفق إذا تم اختياره
    if (_selectedFile != null) {
      ShowWidget.showMessage(context, 'جاري تحميل الملف...', Colors.blue, font13White);

      try {
        // استدعاء دالة تحميل الملف
        attachmentUrl = await _uploadFile(_selectedFile!);
        ShowWidget.showMessage(context, 'تم تحميل الملف بنجاح', Colors.green, font13White);
      } catch (e) {
        // في حالة فشل تحميل الملف، نستمر مع إنشاء المشروع بدون ملف
        print('فشل في تحميل الملف: $e');
        ShowWidget.showMessage(context, 'فشل في تحميل الملف، سيتم إنشاء المشروع بدون ملف مرفق', Colors.orange, font13White);
      }
    }

    // تحويل قوائم المشرفين والطلاب إلى القوائم المطلوبة
    final supervisors = _supervisors.map((s) => s['name']!).toList();
    final studentIds = _students.map((s) => s['id']!).toList();
    final studentsName = _students.map((s) => s['name']!).toList();

    context.read<ProjectBloc>().add(
      CreateProject(
        title: _titleController.text,
        description: _descriptionController.text,
        projectType: _typeController.text,
        projectGoals: _goalsController.text,
        supervisors: supervisors,
        studentIds: studentIds,
        studentsName: studentsName,
        attachmentFile: attachmentUrl,
      ),
    );
  } catch (e) {
    setState(() { _isLoading = false; });
    ShowWidget.showMessage(context, 'حدث خطأ: $e', Colors.red, font13White);
  }
  }

  /// دالة لتحميل الملف والحصول على رابطه
Future<String> _uploadFile(File file) async {
  // محاكاة تحميل الملف
  await Future.delayed(const Duration(seconds: 2));
  // للتجربة، سنرجع رابطًا وهميًا
  return 'https://example.com/files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
}

  // متحكمات الحقول الديناميكية
  final List<TextEditingController> _supervisorNameControllers = [];
  final List<TextEditingController> _studentNameControllers = [];
  final List<TextEditingController> _studentIdControllers = [];
  
  // متحكمات الحقول الرئيسية
  late final TextEditingController _supervisorNameController;
  late final TextEditingController _studentNameController;
  late final TextEditingController _studentIdController;


  @override
  void dispose() {
    // التخلص من جميع المتحكمات
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _goalsController.dispose();
    _supervisorNameController.dispose();
    _studentNameController.dispose();
    _studentIdController.dispose();
    
    for (var controller in _supervisorNameControllers) {
      controller.dispose();
    }
    for (var controller in _studentNameControllers) {
      controller.dispose();
    }
    for (var controller in _studentIdControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          setState(() { _isLoading = false; });
          Navigator.pop(context);
          ShowWidget.showMessage(context, 'تم إنشاء المشروع بنجاح', Colors.green, font13White);
        }
        if (state is ProjectError) {
          setState(() { _isLoading = false; });
          ShowWidget.showMessage(context, state.error, Colors.red, font13White);
        }
      },
      child: Scaffold(
        appBar: const CustomAppBarTitle(title: 'إنشاء مشروع جديد'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('معلومات المشروع'),
              _buildTextField(_titleController, 'عنوان المشروع*', Icons.title),
              getHeight(16),
              _buildTextField(_descriptionController, 'وصف المشروع*', Icons.description, maxLines: 5),
              getHeight(16),
              _buildTextField(_typeController, 'نوع المشروع', Icons.category),
              getHeight(16),
              _buildTextField(_goalsController, 'أهداف المشروع', Icons.flag, maxLines: 4),
              getHeight(24),
              
              _buildSectionTitle('المشرفون'),
              _buildSupervisorsSection(),
              getHeight(24),
              
              _buildSectionTitle('الطلاب'),
              _buildStudentsSection(),
              getHeight(24),
              
              _buildSectionTitle('ملف المشروع (اختياري)'),
              _buildFilePicker(),
              if (_selectedFile != null) _buildFilePreview(),
              getHeight(40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء قسم المشرفين
  Widget _buildSupervisorsSection() {
    return Column(
      children: [
        // عرض المشرفين المضافين
        ..._supervisors.asMap().entries.map((entry) {
          final index = entry.key;
          final supervisor = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColorsApp.primaryColor,
                    child: Text('${index + 1}', style: font15White),
                  ),
                  getWidth(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم: ${supervisor['name']}', style: font14black),
                      ],
                    ),
                  ),
                  if (index > 0) // لا يمكن حذف المشرف الرئيسي
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSupervisor(index),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        
        // حقول إضافة مشرف جديد
        Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _supervisorNameController,
                        'اسم المشرف',
                        Icons.person,
                      ),
                    ),
                  ],
                ),
                getHeight(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addSupervisor,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('إضافة مشرف', style: font15White),
                      style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قسم الطلاب
  Widget _buildStudentsSection() {
    return Column(
      children: [
        // عرض الطلاب المضافين
        ..._students.asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('${index + 1}', style: font15White),
                  ),
                  getWidth(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم: ${student['name']}', style: font14black),
                        Text('رقم القيد: ${student['id']}', style: font12Grey),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeStudent(index),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        // حقول إضافة طالب جديد
        Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _studentNameController,
                        'اسم الطالب',
                        Icons.person,
                      ),
                    ),
                    getWidth(12),
                    Expanded(
                      child: _buildTextField(
                        _studentIdController,
                        'رقم القيد',
                        Icons.badge,
                      ),
                    ),
                  ],
                ),
                getHeight(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addStudent,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('إضافة طالب', style: font15White),
                      style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
            Text(_fileName ?? 'اختر ملف المشروع', style: font14grey),
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

  /// بناء زر الإرسال
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('إنشاء المشروع', style: font16White),
      ),
    );
  }
}