import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/view/screens/marks_management_screen.dart';
import 'package:semester_repository/semester_repository.dart';

class EditGradeDialog extends StatefulWidget {
  final StudentModel student;
  final ExamColumn column;
  final double currentGrade;

  const EditGradeDialog({
    super.key,
    required this.student,
    required this.column,
    required this.currentGrade,
  });

  @override
  State<EditGradeDialog> createState() => _EditGradeDialogState();
  
}
class _EditGradeDialogState extends State<EditGradeDialog> {
  final TextEditingController _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gradeController.text = widget.currentGrade.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تعديل درجة ${widget.column.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الطالب: ${widget.student.name}'),
          Text('رقم القيد: ${widget.student.studentId}'),
          const SizedBox(height: 16),
          TextField(
            controller: _gradeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'الدرجة (0 - ${widget.column.maxGrade})',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveGrade,
          child: Text('حفظ'),
        ),
      ],
    );
  }

  void _saveGrade() {
    final grade = double.tryParse(_gradeController.text);
    
    if (grade == null || grade < 0 || grade > widget.column.maxGrade) {
      ShowWidget.showMessage(
        context, 
        'الدرجة يجب أن تكون بين 0 و ${widget.column.maxGrade}', 
        ColorsApp.red, 
        font13White
      );
      return;
    }

    Navigator.pop(context, grade);
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }
}