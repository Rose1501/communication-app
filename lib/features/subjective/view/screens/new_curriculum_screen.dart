import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class NewCurriculumScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;
  final CurriculumModel? curriculumToEdit;

  const NewCurriculumScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
    this.curriculumToEdit,
  });

  @override
  State<NewCurriculumScreen> createState() => _NewCurriculumScreenState();
}

class _NewCurriculumScreenState extends State<NewCurriculumScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    print('🚀 بدء شاشة ${widget.curriculumToEdit != null ? 'تعديل' : 'إضافة'} منهج جديد');
    
    if (widget.curriculumToEdit != null) {
      _titleController.text = widget.curriculumToEdit!.description;
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

  Future<void> _publishCurriculum() async {
    print('🎯 بدء عملية ${widget.curriculumToEdit != null ? 'تعديل' : 'نشر'} المنهج...');

    // التحقق من وجود مرفق
    if (_selectedFile == null) {
      print('❌ خطأ: لم يتم إضافة مرفق');
      ShowWidget.showMessage(context, 'يرجى إضافة مرفق للمنهج', ColorsApp.red, font13White);
      return;
    }

    print('✅ البيانات الأساسية صحيحة');
    print('📝 العنوان: ${_titleController.text}');

    final bool confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: widget.curriculumToEdit != null ? 'تعديل المنهج' : 'نشر المنهج',
      message: 'هل أنت متأكد من ${widget.curriculumToEdit != null ? 'تعديل' : 'نشر'} هذا المنهج في ${widget.selectedGroups.length} مجموعة؟',
      confirmText: widget.curriculumToEdit != null ? 'تعديل' : 'نشر',
      cancelText: 'إلغاء',
    );

    if (!confirmed) {
      print('❌ المستخدم ألغى العملية');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: قم بتنفيذ رفع الملف واحصل على الرابط
      String fileUrl = _selectedFile != null ? "رابط_ملف_مؤقت" : "";

      final curriculum = CurriculumModel(
        id: widget.curriculumToEdit?.id ?? '',
        description: _titleController.text,
        time: DateTime.now(),
        file: fileUrl,
      );

      final groupIds = widget.selectedGroups.map((group) => group.id).toList();
      print('👥 معرفات المجموعات: $groupIds');

      if (widget.curriculumToEdit != null) {
        // 🔥 حدث التعديل
        print('✏️ إرسال حدث تعديل المنهج...');
        context.read<SubjectiveBloc>().add(
          UpdateCurriculumEvent(
            courseId: widget.course.id,
            groupId: widget.selectedGroups.first.id,
            curriculum: curriculum,
          ),
        );
      } else {
        // 🔥 حدث الإضافة
        print('🎯 إرسال حدث إضافة المنهج...');
        context.read<SubjectiveBloc>().add(
          AddCurriculumToMultipleGroupsEvent(
            courseId: widget.course.id,
            groupIds: groupIds,
            curriculum: curriculum,
          ),
        );
      }

      print('✅ تم إرسال الحدث بنجاح');

    } catch (e) {
      print('❌ خطأ في ${widget.curriculumToEdit != null ? 'تعديل' : 'نشر'} المنهج: $e');
      ShowWidget.showMessage(context, 'خطأ في ${widget.curriculumToEdit != null ? 'تعديل' : 'نشر'} المنهج: $e', ColorsApp.red, font13White);
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
    print('🗑️ تم إزالة الملف المرفق');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.curriculumToEdit != null ? 'تعديل المنهج' : 'منهج جديد', style: font18blackbold),
            Text(
              '${widget.course.name} - ${widget.selectedGroups.length} مجموعة',
              style: font12Grey,
            ),
          ],
        ),
      ),
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          print('🎧 حالة الـ BLoC: ${state.runtimeType}');
          
          if (state is SubjectiveLoading) {
            print('🔄 حالة التحميل...');
            return;
          }

          if (state is SubjectiveOperationSuccess) {
            print('✅ نجاح العملية: ${state.message}');
            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context, true);
            ShowWidget.showMessage(context, state.message, ColorsApp.green, font13White);
          }

          if (state is SubjectiveError) {
            print('❌ خطأ في العملية: ${state.message}');
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
            Icon(Icons.menu_book, color: ColorsApp.primaryColor),
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
          'عنوان المنهج ',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'أدخل عنوان المنهج...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildFileOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إرفاق ملف ',
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
    final bool canPublish =  _selectedFile != null;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || !canPublish ? null : _publishCurriculum,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPublish ? ColorsApp.primaryColor : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.curriculumToEdit != null ? 'تعديل المنهج' : 'نشر المنهج',
                    style: font16White.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}