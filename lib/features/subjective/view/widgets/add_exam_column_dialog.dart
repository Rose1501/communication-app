import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/view/screens/marks_management_screen.dart';

class AddExamColumnDialog extends StatefulWidget {
  final ExamColumn? initialColumn;

  const AddExamColumnDialog({super.key, this.initialColumn});

  @override
  State<AddExamColumnDialog> createState() => _AddExamColumnDialogState();
}

class _AddExamColumnDialogState extends State<AddExamColumnDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _maxGradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialColumn != null) {
      _nameController.text = widget.initialColumn!.name;
      _maxGradeController.text = widget.initialColumn!.maxGrade.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialColumn == null ? 'إضافة عمود امتحان' : 'تعديل عمود امتحان'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'اسم الامتحان',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxGradeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'الدرجة القصوى',
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
          onPressed: _saveColumn,
          child: Text('حفظ'),
        ),
      ],
    );
  }

  void _saveColumn() {
    final name = _nameController.text.trim();
    final maxGrade = double.tryParse(_maxGradeController.text);

    if (name.isEmpty || maxGrade == null || maxGrade <= 0) {
      ShowWidget.showMessage(context, 'يرجى إدخال بيانات صحيحة', ColorsApp.red, font13White);
      return;
    }

    final column = ExamColumn(
      id: widget.initialColumn?.id ?? 'exam_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      maxGrade: maxGrade,
    );

    Navigator.pop(context, column);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxGradeController.dispose();
    super.dispose();
  }
}