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
        widget.onReplySubmitted(_selectedStatus, replyText);
        Navigator.pop(context);
      }
    });
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
                          'يوجد رد سابق. يمكنك تعديله أو ترك الحقل فارغاً لحذف الرد.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 16),
            // أزرار الإجراء
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                        _replyFocusNode.unfocus();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width:12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedStatus == 'موافقة' ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.existingReply != null ? 'تحديث الرد' : 
                      _selectedStatus == 'موافقة' ? 'موافقةوإرسال' : 'رفض وإرسال',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _replyController.dispose();
    super.dispose();
  }
}