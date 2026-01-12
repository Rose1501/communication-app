import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:uuid/uuid.dart';

/// شاشة إنشاء إعلان جديد
/// تسمح للمستخدم بإنشاء إعلان جديد وتحديد أولويته
class NewAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcement; // إضافة إعلان اختياري للتعديل

  const NewAnnouncementScreen({super.key, this.announcement});

  @override
  State<NewAnnouncementScreen> createState() => _NewAnnouncementScreenState();
}

class _NewAnnouncementScreenState extends State<NewAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AnnouncementPriority _selectedPriority = AnnouncementPriority.normal;
  bool _isLoading = false;
  bool _isEditing = false; // متغير لتحديد ما إذا كنا في وضع التعديل

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير إعلان، فنحن في وضع التعديل
    if (widget.announcement != null) {
      _isEditing = true;
      _titleController.text = widget.announcement!.title;
      _contentController.text = widget.announcement!.content;
      _selectedPriority = widget.announcement!.priority;
    }
  }

  /// إرسال بيانات الإعلان لإنشائه أو تحديثه
  void _submitAnnouncement() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ShowWidget.showMessage(context, 'الرجاء ملء جميع الحقول المطلوبة', Colors.orange, font13White);
      return;
    }

    setState(() { _isLoading = true; });

    if (_isEditing) {
      // تحديث الإعلان الموجود
      final updatedAnnouncement = widget.announcement!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        priority: _selectedPriority,
      );
      
      // استخدام الحدث الجديد لتحديث الإعلان
    context.read<ProjectBloc>().add(UpdateAnnouncement(announcement: updatedAnnouncement));
      
      Navigator.pop(context);
      ShowWidget.showMessage(context, 'تم تحديث الإعلان بنجاح', Colors.green, font13White);
    } else {
      // إنشاء إعلان جديد
      final announcement = AnnouncementModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
      );

      context.read<ProjectBloc>().add(AddAnnouncement(announcement: announcement));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(
        title: _isEditing ? 'تعديل الإعلان' : 'إضافة إعلان جديد'
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('معلومات الإعلان'),
            _buildTextField(_titleController, 'عنوان الإعلان', Icons.title),
            getHeight(16),
            _buildTextField(_contentController, 'محتوى الإعلان', Icons.description, maxLines: 5),
            getHeight(16),
            _buildSectionTitle('التفاصيلات الإضافية'),
            _buildPrioritySelector(),
            getHeight(24),
            _buildSubmitButton(),
          ],
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

  /// بناء منتقي الأولوية
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أولوية الإعلان:',
          style: font14black.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnnouncementPriority>(
          value: _selectedPriority,
          onChanged: (AnnouncementPriority? newValue) {
            setState(() {
              _selectedPriority = newValue!;
            });
          },
          items: AnnouncementPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Icon(
                    _getPriorityIcon(priority),
                    color: _getPriorityColor(priority),
                  ),
                  const SizedBox(width: 8),
                  Text(_getPriorityText(priority)),
                ],
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  /// الحصول على أيقونة الأولوية
  IconData _getPriorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Icons.priority_high;
      case AnnouncementPriority.important:
        return Icons.priority_high;
      default:
        return Icons.notifications;
    }
  }

  /// الحصول على لون الأولوية
  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Colors.red;
      case AnnouncementPriority.important:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// الحصول على نص الأولوية
  String _getPriorityText(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return 'عاجل';
      case AnnouncementPriority.important:
        return 'مهم';
      default:
        return 'عادي';
    }
  }

  /// بناء زر الإرسال
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAnnouncement,
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
            : Text(_isEditing ? 'تحديث الإعلان' : 'نشر الإعلان', style: font16White),
      ),
    );
  }
}