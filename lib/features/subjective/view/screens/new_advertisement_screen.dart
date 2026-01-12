import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class NewAdvertisementScreen extends StatefulWidget {
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final String doctorId;
  final AdvertisementModel? advertisementToEdit;

  const NewAdvertisementScreen({
    super.key,
    required this.course,
    required this.selectedGroups,
    required this.doctorId,
    this.advertisementToEdit,
  });

  @override
  State<NewAdvertisementScreen> createState() => _NewAdvertisementScreenState();
}

class _NewAdvertisementScreenState extends State<NewAdvertisementScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;
  bool _isImportant = false;
  
  @override
  void initState() {
    super.initState();
    print('🚀 بدء شاشة ${widget.advertisementToEdit != null ? 'تعديل' : 'إضافة'} إعلان جديد');
    
    // تعبئة البيانات إذا كان في وضع التعديل
    if (widget.advertisementToEdit != null) {
      _descriptionController.text = widget.advertisementToEdit!.description;
      _isImportant = widget.advertisementToEdit!.isImportant;
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

  Future<void> _publishAdvertisement() async {
    print('🎯 بدء عملية ${widget.advertisementToEdit != null ? 'تعديل' : 'نشر'} الإعلان...');
    
    // 🔥 التصحيح: التحقق من الوصف فقط (الملف والإعلان المهم اختياريان)
    if (_descriptionController.text.isEmpty) {
      print('❌ خطأ: وصف الإعلان فارغ');
      ShowWidget.showMessage(context, 'يرجى إدخال وصف الإعلان', ColorsApp.red, font13White);
      return;
    }

    print('✅ البيانات الأساسية صحيحة');
    print('📝 الوصف: ${_descriptionController.text}');
    print('📎 الملف: ${_selectedFile != null ? "مرفق" : "غير مرفق"}');
    print('🔴 الإعلان المهم: $_isImportant');

    final bool confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: widget.advertisementToEdit != null ? 'تعديل الإعلان' : 'نشر الإعلان',
      message: 'هل أنت متأكد من ${widget.advertisementToEdit != null ? 'تعديل' : 'نشر'} هذا الإعلان في ${widget.selectedGroups.length} مجموعة؟',
      confirmText: widget.advertisementToEdit != null ? 'تعديل' : 'نشر',
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
      String fileUrl = _selectedFile != null ? "رابط_ملف_مؤقت" : widget.advertisementToEdit?.file ?? "";

      final advertisement = AdvertisementModel(
        id: widget.advertisementToEdit?.id ?? '',
        title: _descriptionController.text,
        description: _descriptionController.text,
        time: DateTime.now(),
        file: fileUrl,
        isImportant: _isImportant,
      );

      final groupIds = widget.selectedGroups.map((group) => group.id).toList();
      print('👥 معرفات المجموعات: $groupIds');

      if (widget.advertisementToEdit != null) {
        // حدث التعديل
        print('✏️ إرسال حدث تعديل الإعلان...');
        context.read<SubjectiveBloc>().add(
          UpdateAdvertisementEvent(
            courseId: widget.course.id,
            groupId: widget.selectedGroups.first.id,
            advertisement: advertisement,
            file: _selectedFile,
          ),
        );
      } else {
        // حدث الإضافة
        print('🎯 إرسال حدث إضافة الإعلان...');
        context.read<SubjectiveBloc>().add(
          AddAdvertisementToMultipleGroupsEvent(
            courseId: widget.course.id,
            groupIds: groupIds,
            advertisement: advertisement,
            file: _selectedFile, 
          ),
        );
      }

      print('✅ تم إرسال الحدث بنجاح');

    } catch (e) {
      print('❌ خطأ في ${widget.advertisementToEdit != null ? 'تعديل' : 'نشر'} الإعلان: $e');
      ShowWidget.showMessage(context, 'خطأ في ${widget.advertisementToEdit != null ? 'تعديل' : 'نشر'} الإعلان: $e', ColorsApp.red, font13White);
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
      appBar: CustomAppBarTitle(
        title: widget.advertisementToEdit != null ? 'تعديل الإعلان' : 'إعلان جديد',
      ),
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          if (state is SubjectiveLoading) return;
          
          // العملية ناجحة
          if (state is SubjectiveOperationSuccess) {
            setState(() {
              _isLoading = false;
            });
            
            Navigator.pop(context, true);
            ShowWidget.showMessage(context, state.message, ColorsApp.green, font13White);
          }
          
          // إذا حدث خطأ
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
                // معلومات المجموعات المختارة
                _buildSelectedGroupsInfo(),
                const SizedBox(height: 20),
                
                // خيار الإعلان المهم (اختياري)
                _buildImportantOption(),
                const SizedBox(height: 20),
                
                // حقل وصف الإعلان (إلزامي)
                _buildDescriptionField(),
                const SizedBox(height: 20),
                
                // خيارات رفع الملفات (اختياري)
                _buildFileOptions(),
                const SizedBox(height: 20),
                
                // معاينة الملف المرفوع
                if (_selectedFile != null) _buildFilePreview(),
                const SizedBox(height: 20),
                
                // زر النشر
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
            Icon(Icons.group, color: ColorsApp.primaryColor),
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

  Widget _buildImportantOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _isImportant ? Icons.campaign : Icons.announcement,
              color: _isImportant ? ColorsApp.red : ColorsApp.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعلان مهم',
                    style: font14black.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'سيظهر هذا الإعلان بشكل مميز للطلاب',
                    style: font12Grey,
                  ),
                ],
              ),
            ),
            Switch(
              value: _isImportant,
              onChanged: (value) {
                setState(() {
                  _isImportant = value;
                });
              },
              activeColor: ColorsApp.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف الإعلان',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'أدخل وصف الإعلان هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            // 🔥 تحديث الواجهة عند تغيير النص لتحديث حالة الزر
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        Text(
          'هذا الحقل إلزامي',
          style: font12Grey,
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
    // 🔥 التصحيح: الزر يتفاعل فقط مع وجود الوصف
    final bool canPublish = _descriptionController.text.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || !canPublish ? null : _publishAdvertisement,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPublish ? ColorsApp.primaryColor : ColorsApp.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsApp.white),
                ),
              )
            : Text(
                widget.advertisementToEdit != null ? 'تعديل الإعلان' : 'نشر الإعلان',
                style: font16White.copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}