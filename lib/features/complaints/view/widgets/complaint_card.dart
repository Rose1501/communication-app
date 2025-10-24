import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:readmore/readmore.dart';
import 'package:user_repository/user_repository.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final UserModels currentUser;
  final Function(String, String?) onStatusUpdate;
  final Function() onDelete;
  final Function(String)? onReassign;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.currentUser,
    required this.onStatusUpdate,
    required this.onDelete, 
    this.onReassign,
    
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 معلومات المرسل والوقت
            _buildSenderInfo(),
            getHeight(8),
            // 🏷️ العنوان والفئة
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: font16blackbold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(complaint.status),
              ],
            ),
            getHeight(12),
            // 📝 وصف الشكوى
            _buildExpandableDescription(),
            getHeight(12),
            
            // 🎯 حالة الشكوى وأزرار التحكم
            _buildStatusSection(context),
          ],
        ),
      ),
    );
  }

  /// 📝 بناء وصف الشكوى القابل للتمديد
  Widget _buildExpandableDescription() {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'الوصف:',
        style: font14black.copyWith(fontWeight: FontWeight.bold),
      ),
      getHeight(4),
      ReadMoreText(
        complaint.description,
        trimLines: 2,
        trimMode: TrimMode.Line,
        trimCollapsedText: ' عرض المزيد',
        trimExpandedText: ' عرض أقل',
        moreStyle: TextStyle(
          color: ColorsApp.greylight,
          fontWeight: FontWeight.bold,
        ),
        lessStyle: TextStyle(
          color: ColorsApp.greylight,
          fontWeight: FontWeight.bold,
        ),
        style: font14black,
        textAlign: TextAlign.right,
      ),
    ],
  );
  }

  // 👤 معلومات المرسل
  Widget _buildSenderInfo() {
    return Row(
      children: [
        // صورة المستخدم
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsApp.primaryColor,
          ),
          child: Icon(
            Icons.person,
            color: ColorsApp.primaryLight,
            size: 16,
          ),
        ),
        getWidth(8),
        
        // اسم المرسل (إذا مسموح بعرضه)
        if (complaint.showStudentInfo)
          Expanded(
            child: Text(
              complaint.studentName,
              style: font12black,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            'مجهول الهوية',
            style: font12black.copyWith(color: Colors.grey),
          ),
        const Spacer(),
        // الوقت
        Text(
          _formatDate(complaint.createdAt),
          style: font14grey,
        ),
      ],
    );
  }

  // 🎯 قسم الحالة والأزرار
  Widget _buildStatusSection(BuildContext context) {
    return Column(
      children: [
        getHeight(8),
        // 🔥 الدور المستهدف (للمسؤولين والمديرين)
        if (_shouldShowReassignButtons())
          _buildTargetRoleSection(),
        
        getHeight(8),
        // 🔥 رد الإدارة (إذا وجد)
        if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty)
          _buildAdminReplySection(),
        
        getHeight(8),
        
        // 🎛️ أزرار التحكم (للمسؤولين فقط)
        if (_shouldShowActionButtons())
          _buildActionButtons(context),

          // زر الحذف (منفصل)
        if (currentUser.userID == complaint.studentID)
          _buildDeleteButton(),
      ],
    );
  }

  // 🏷️ شريط حالة الشكوى
  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = '⏳ قيد الانتظار';
        statusIcon = Icons.access_time;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = '🔵 قيد المعالجة';
        statusIcon = Icons.autorenew;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusText = '✅ تم الحل';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = '❌ مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير معروف';
        statusIcon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          getWidth(4),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔄 قسم إعادة التوجيه (للمسؤولين والمديرين)
  Widget _buildTargetRoleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.send, size: 14, color: Colors.grey),
              getWidth(4),
              Text(
                'موجهة إلى:',
                style: font12black.copyWith(fontWeight: FontWeight.bold),
              ),
              getWidth(8),
              Text(
                _getRoleDisplayText(complaint.targetRole),
                style: font12black,
              ),
              const Spacer(),
              
              // زر إعادة التوجيه
              if (onReassign != null)
                GestureDetector(
                  onTap: () {},//الارسال في الخاص لحل الشكوى
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.change_circle, size: 12, color: ColorsApp.primaryColor),
                        getWidth(4),
                        Text(
                          'إعادة توجيه',
                          style: TextStyle(
                            color: ColorsApp.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 💬 قسم رد الإدارة
  Widget _buildAdminReplySection() {
    final hasReply = complaint.adminReply != null && complaint.adminReply!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: ColorsApp.primaryColor,
              ),
              getWidth(4),
              Text(
                hasReply ? 'رد الإدارة:' : 'لا يوجد رد',
                style: hasReply ? font15bold : font15bold.copyWith(color: Colors.grey),
              ),
            ],
          ),
          getHeight(4),
        if (hasReply)
          Text(
            complaint.adminReply!,
            style: font12black,
          )
        else
          Text(
            'لم يتم إضافة رد حتى الآن',
            style: font12black.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // 🔧 التحقق من إظهار أزرار التحكم
  bool _shouldShowActionButtons() {
    return currentUser.role == 'Admin' || 
            currentUser.role == 'Manager';
  }

  // 🔧 التحقق من إظهار أزرار إعادة التوجيه
  bool _shouldShowReassignButtons() {
    return currentUser.role == 'Admin' || currentUser.role == 'Manager';
  }

  // 🎛️ أزرار التحكم
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 🔥 أزرار تغيير الحالة في صف واحد
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (complaint.status == 'pending')
              _buildStatusButton(context, 'قيد المعالجة', 'in_progress', Icons.autorenew, Colors.blue),
            
            if (complaint.status == 'pending' || complaint.status == 'in_progress')
              _buildStatusButton(context, 'تم الحل', 'resolved', Icons.check_circle, Colors.green),
            
            if (complaint.status == 'pending' || complaint.status == 'in_progress')
              _buildStatusButton(context, 'مرفوض', 'rejected', Icons.cancel, Colors.red),
            if (complaint.status == 'rejected' || complaint.status == 'resolved')
            // زر الرد
            _buildReplyButton(context),
          ],
        ),
        getHeight(8),
      ],
    );
  }

  // 🗑️ زر الحذف منفصل
  Widget _buildDeleteButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              getWidth(4),
              Text(
                'حذف الشكوى',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 زر تغيير الحالة
  Widget _buildStatusButton(BuildContext context,String text, String status, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleStatusUpdate(status, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,size: 12,color: color),
            getWidth(4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💬 فتح الرد بحالة محددة مسبقاً
void _showPreSelectedReplyDialog(BuildContext context, String preSelectedStatus, String? autoReply) {
  final replyController = TextEditingController(text: autoReply ?? complaint.adminReply ?? '');
  bool hasExistingReply = complaint.adminReply != null && complaint.adminReply!.isNotEmpty;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('إكمال الإجراء'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getHeight(12),
              // 💡 عرض الرد التلقائي إذا كان موجوداً
              if (autoReply != null && autoReply.isNotEmpty)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.green[700], size: 16),
                          getWidth(8),
                          Expanded(
                            child: Text(
                              'رد تلقائي مقترح:',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    getHeight(8),
                  ],
                ),
              TextFormField(
                controller: replyController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'رد الإدارة',
                  hintText: autoReply != null ? 'يمكنك تعديل الرد التلقائي أو ترك الحقل فارغاً' : 'اكتب ردك هنا ...',
                  border: OutlineInputBorder(),
                  suffixIcon: hasExistingReply ? IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[200]),
                    onPressed: () {
                      setState(() {
                        replyController.clear();
                        hasExistingReply = false;
                      });
                    },
                  ) : null,
                ),
                onChanged: (value) {
                  setState(() {
                    hasExistingReply = value.isNotEmpty;
                  });
                },
              ),
              // زر حذف الرد الحالي
              if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        replyController.clear();
                        hasExistingReply = false;
                      });
                    },
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    label: Text(
                      'حذف الرد الحالي',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final replyText = replyController.text.trim();
                Navigator.pop(context);
                final String? finalReply = replyText.isEmpty ? null : replyText;
                onStatusUpdate(preSelectedStatus, finalReply);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(preSelectedStatus),
              ),
              child: Text(
                'تأكيد ${_getStatusDisplayText(preSelectedStatus)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ),
  );
}

  // 💬 زر الرد
  Widget _buildReplyButton(BuildContext context) {
    return GestureDetector(
      onTap: () =>_showReplyDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ColorsApp.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorsApp.primaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reply, size: 12, color: ColorsApp.primaryColor),
            getWidth(4),
            Text(
              'رد',
              style: TextStyle(
                color: ColorsApp.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔄 معالجة تحديث الحالة
  void _handleStatusUpdate(String newStatus,BuildContext context) {
    String? adminReply;
    
    // إضافة رد افتراضي حسب الحالة
    switch (newStatus) {
      case 'resolved':
        adminReply = 'تم حل الشكوى بنجاح. شكراً لتواصلكم.';
        break;
      case 'rejected':
        adminReply = 'نعتذر، لا يمكن معالجة الشكوى في الوقت الحالي.';
        break;
      case 'in_progress':
        adminReply = 'جاري معالجة الشكوى وسيتم الرد قريباً.';
        break;
    default:
      adminReply = null;
    }
    _showPreSelectedReplyDialog(context, newStatus, adminReply);
  }

  // 💬 عرض نافذة الرد
  void _showReplyDialog(BuildContext context) {
    final replyController = TextEditingController(text: complaint.adminReply ?? '');
    String selectedStatus = complaint.status;
    bool hasExistingReply = complaint.adminReply != null && complaint.adminReply!.isNotEmpty;
    showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('الرد على الشكوى'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الشكوى: ${complaint.title}',
                  style: font14black.copyWith(fontWeight: FontWeight.bold),
                ),
                getHeight(12),
                // 🎯 اختيار الحالة
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          getWidth(8),
                          const Text('قيد الانتظار'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Row(
                        children: [
                          Icon(Icons.autorenew, color: Colors.blue),
                          getWidth(8),
                          const Text('قيد المعالجة'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          getWidth(8),
                          const Text('تم الحل'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          getWidth(8),
                          const Text('مرفوض'),
                        ],
                      ),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'تغيير الحالة',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                ),
                getHeight(16),
                // 📝 حقل الرد
                TextFormField(
                  controller: replyController,
                  maxLines: 4,
                  minLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration:  InputDecoration(
                    labelText: 'رد الإدارة',
                    hintText: 'اكتب ردك هنا...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    suffixIcon: hasExistingReply ? IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      onPressed: () {
                        setState(() {
                          replyController.clear();
                          hasExistingReply = false;
                        });
                      },
                    ) : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      hasExistingReply = value.isNotEmpty;
                    });
                  },
                ),
                getHeight(8),
                // 🗑️ زر حذف الرد (يظهر فقط إذا كان هناك رد موجود)
                if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          replyController.clear();
                          hasExistingReply = false;
                        });
                      },
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: Text(
                        'حذف الرد الحالي',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                
                getHeight(8),
                // 💡 تلميحات الرد التلقائي
                if (replyController.text.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 اقتراحات ردود تلقائية:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      getHeight(4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSuggestionChip('شكراً لتواصلكم', replyController),
                          _buildSuggestionChip('جاري المعالجة', replyController),
                          _buildSuggestionChip('تم حل المشكلة', replyController),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final replyText = replyController.text.trim();
                Navigator.pop(context);
                final String? finalReply = replyText;
                // 🎯 إرسال التحديث مع الحالة والرد
                onStatusUpdate(selectedStatus, finalReply);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(selectedStatus),
              ),
              child: Text(
                _getActionText(selectedStatus, replyController.text),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ),
  );
  }

  // 🎯 بناء شريط اقتراح الرد
  Widget _buildSuggestionChip(String text, TextEditingController controller) {
    return GestureDetector(
    onTap: () {
      controller.text = text;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ColorsApp.primaryColor,
          fontSize: 11,
        ),
      ),
    ),
  );
  }

  // 🎨 الحصول على لون الحالة
  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'in_progress': return Colors.blue;
      case 'pending': return Colors.orange;
      default: return ColorsApp.primaryColor;
    }
  }

  // 📝 الحصول على نص الزر
  String _getActionText(String status, String reply) {
    final hasReply = reply.trim().isNotEmpty;
    final statusText = _getStatusDisplayText(status);
  
    if (hasReply) {
      return 'حفظ $statusText';
    } else {
      return ' $statusText ';
    }
  }

  // 🏷️ الحصول على نص الحالة
String _getStatusDisplayText(String status) {
  switch (status) {
    case 'pending': return 'انتظار';
    case 'in_progress': return 'قيد المعالجة';
    case 'resolved': return 'تم الحل';
    case 'rejected': return 'مرفوض';
    default: return status;
  }
}

  // 📅 تنسيق التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
    if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} ي';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  // 🎯 الحصول على نص الدور
  String _getRoleDisplayText(String role) {
    switch (role) {
      case 'Admin':
        return 'الدراسة والامتحانات';
      case 'Manager':
        return 'رئيس القسم';
      default:
        return role;
    }
  }
}