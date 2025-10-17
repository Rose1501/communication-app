import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
// كلاس يمثل أزرار الإجراءات (حفظ وإلغاء) في واجهة المستخدم
class ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ActionButtons({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCancelButton(),
          getWidth(5),
          _buildSaveButton(),
        ],
      ),
    );
  }
 // دالة لبناء زر الإلغاء
  Widget _buildCancelButton() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: OutlinedButton(
          onPressed: isLoading ? null : onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'إلغاء',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
// دالة لبناء زر الحفظ
  Widget _buildSaveButton() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        child: ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsApp.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: isLoading 
              ? const SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'حفظ',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}