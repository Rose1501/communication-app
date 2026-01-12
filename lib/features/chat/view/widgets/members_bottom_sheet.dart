// lib/features/chat/view/widgets/members_bottom_sheet.dart (محدث)
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class MembersBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool showStudentId;
  
  const MembersBottomSheet({
    super.key,
    required this.members,
    this.showStudentId = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Text(
            'أعضاء المجموعة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            '(${members.length} عضو)',
            style: font12Grey,
            textAlign: TextAlign.right,
          ),
          const Divider(),
          Expanded(
            child: members.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberTile(member, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أعضاء',
            style: font16black,
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم تحميل بيانات الأعضاء',
            style: font14grey,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemberTile(Map<String, dynamic> member, int index) {
    final role = member['Role'] as String? ?? 'User';
    final isDoctor = role == 'Doctor';
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    final isstudent =role == 'Student';
    final studentId = member['studentId'] as String?;
     final memberName = member['Name'] as String? ?? 'عضو غير محدد'; // استخدام قيمة افتراضية
    
    // تحديد اللون والأيقونة بناءً على الدور
    Color avatarColor = ColorsApp.grey.withOpacity(0.3) ;
    Color tileColor = ColorsApp.grey.withOpacity(0.5) ;
    String roleText = 'عضو';
    IconData? roleIcon;
    
    if (isDoctor) {
      avatarColor = const Color(0xFF4CAF50);
      tileColor = const Color(0xFFE8F5E9);
      roleText = 'دكتور';
      roleIcon = Icons.school;
    } else if (isAdmin) {
      avatarColor = Colors.grey;
      tileColor = Colors.grey.withOpacity(0.1);
      roleText = 'دراسة و الامتحانات';
      roleIcon = Icons.admin_panel_settings;
    } else if (isManager) {
      avatarColor = Colors.purple;
      tileColor = Colors.grey.withOpacity(0.1);
      roleText = 'مدير';
      roleIcon = Icons.manage_accounts;
    } else if (isstudent){
      avatarColor = Colors.grey;
      tileColor = Colors.grey.withOpacity(0.1);
      roleText = 'طالب';
      roleIcon = Icons.person;
    }else  {
      avatarColor = Colors.blue;
      tileColor = Colors.blue.withOpacity(0.1);
      roleText = 'عضو';
      roleIcon = Icons.person;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: avatarColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            memberName.isNotEmpty 
              ? memberName.substring(0, 1).toUpperCase()
              : '?',
            style: font13White.copyWith(
              fontWeight: FontWeight.bold,
              color:  Colors.white ,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             // عرض شارة الدور 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:  avatarColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  roleText,
                  style: font10Primary.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                memberName,
                style: font14black.copyWith(
                  fontWeight: isDoctor || isAdmin || isManager ||isstudent ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showStudentId && studentId != null && studentId.isNotEmpty && member['Role'] == 'Student')
              Text(
                'الرقم القيد: $studentId',
                style: font12Grey,
                textAlign: TextAlign.right,
              ),
            if (!isDoctor && member['Role'] == 'Student')
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'طالب',
                  style: font10Grey.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing:  Icon(
                roleIcon,
                color: const Color(0xFF4CAF50),
                size: 20,
              )
      ),
    );
  }
}