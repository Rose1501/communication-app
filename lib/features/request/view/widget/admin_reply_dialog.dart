import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class AdminReplyDialog extends StatefulWidget {
  final String studentName;
  final String requestType;
  final String currentStatus;
  final String? existingReply;
  final Function(String, String) onReplySubmitted;

  const AdminReplyDialog({
    super.key,
    required this.studentName,
    required this.requestType,
    required this.currentStatus,
    required this.onReplySubmitted,
    this.existingReply,
  });

  @override
  State<AdminReplyDialog> createState() => _AdminReplyDialogState();
}

class _AdminReplyDialogState extends State<AdminReplyDialog> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  String _selectedStatus = 'موافقة';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    // 🔥 تعبئة الرد الحالي إذا وجد
    if (widget.existingReply != null && widget.existingReply!.isNotEmpty) {
      _replyController.text = widget.existingReply!;
    }
    // تأخير فتح لوحة المفاتيح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _replyFocusNode.requestFocus();
        }
      });
    });
  }

  void _submitReply() {
    final replyText = _replyController.text.trim();

    // 🔥 إخفاء الكيبورد أولاً
    _replyFocusNode.unfocus();
    
    // 🔥 تأخير الإغلاق قليلاً لضمان إخفاء الكيبورد
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        final bool shouldDeleteReply = widget.existingReply != null && widget.existingReply!.isNotEmpty && replyText.isEmpty;
        // 🎯 تحديد نص الزر بناءً على الإجراء
      String actionMessage;
      if (shouldDeleteReply) {
        actionMessage = 'حذف الرد';
      } else if (widget.existingReply != null) {
        actionMessage = replyText.isEmpty ? 'حذف الرد' : 'تحديث الرد';
      } else {
        actionMessage = 'إرسال الرد';
      }
      
      // 🔥 إظهار تأكيد إذا كان هناك حذف
      if (shouldDeleteReply) {
        _showDeleteConfirmation(actionMessage);
      } else {
        _proceedWithSubmission(replyText, actionMessage);
      }
      }
    });
  }

  /// 🎯 المتابعة في إرسال البيانات
void _proceedWithSubmission(String replyText, String actionMessage) {
  widget.onReplySubmitted(_selectedStatus, replyText);
  Navigator.pop(context);
  
  // 💫 إظهار رسالة تأكيد
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم $actionMessage بنجاح'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// 🗑️ عرض تأكيد الحذف
void _showDeleteConfirmation(String actionMessage) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text('هل أنت متأكد من حذف الرد؟ لا يمكن التراجع عن هذا الإجراء.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // إغلاق حوار التأكيد
            _proceedWithSubmission('', actionMessage); // المتابعة بالحذف
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingReply != null ? 'تعديل رد الطالب' : 'إرسال رد للطالب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorsApp.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                      _replyFocusNode.unfocus();
                      Navigator.pop(context);
                    },
                  icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            
            // معلومات الطلب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الطالب: ${widget.studentName}'),
                  Text('نوع الطلب: ${widget.requestType}'),
                  if (widget.existingReply != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الحالة: ${_selectedStatus}',
                        style: TextStyle(
                          color: _selectedStatus == 'موافقة' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // اختيار الحالة
            // اختيار الحالة (يظهر فقط إذا لم يكن هناك رد سابق أو للطلبات في الانتظار)
              if (widget.existingReply == null || widget.currentStatus == 'انتظار')
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'موافقة',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('موافقة'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'رفض',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('رفض'),
                            ],
                          ),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'تحديد الحالة',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            // حقل الرد
            TextFormField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitReply(),
              decoration:  InputDecoration(
                labelText: widget.existingReply != null ? 'تعديل رد الطالب' : 'اكتب ردك للطالب هنا...',
                  hintText: widget.existingReply != null ? 'قم بتعديل الرد...' : 'اكتب ردك...',
                border:const OutlineInputBorder(),
                alignLabelWithHint: true,
                contentPadding:const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                // 🔄 إضافة زر حذف إذا كان هناك رد سابق
                suffixIcon: widget.existingReply != null && widget.existingReply!.isNotEmpty
                  ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _clearReply,
                  tooltip: 'حذف الرد السابق',
                  )
                : null,
              ),
            ),
            const SizedBox(height: 16),
            // 🔥 مؤشر إذا كان هناك رد سابق
              if (widget.existingReply != null && widget.existingReply!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '• تعديل النص للحفظ\n• استخدام زر الحذف 🗑️\n• ترك الحقل فارغاً للحذف',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 16),
            // أزرار الإجراء
            Container(
              width: double.infinity,
              child: Wrap(
                spacing: 12, // المسافة بين الأزرار
                runSpacing: 8, // المسافة بين الصفوف إذا اضطروا للتفاف
                alignment: WrapAlignment.center, // توزيع متساوي
                children: [
                  // زر الإلغاء
                  OutlinedButton(
                    onPressed: () {
                      _replyFocusNode.unfocus();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('إلغاء'),
                  ),
                  // زر الإرسال/التحديث
                  ElevatedButton(
                    onPressed: _submitReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedStatus == 'موافقة' ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      widget.existingReply != null ? 'تحديث الرد' : 
                      _selectedStatus == 'موافقة' ? 'موافقة و إرسال' : 'رفض و إرسال',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 🗑️ مسح الرد السابق
void _clearReply() {
  setState(() {
    _replyController.clear();
  });
}

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _replyController.dispose();
    super.dispose();
  }
}