import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/chat/view/screens/group_chat_screen.dart';
import 'package:myproject/features/subjective/view/screens/attendance_management_screen.dart';
import 'package:myproject/features/subjective/view/screens/new_advertisement_screen.dart';
import 'package:myproject/features/subjective/view/screens/new_assignment_screen.dart';
import 'package:myproject/features/subjective/view/screens/new_curriculum_screen.dart';
import 'package:myproject/features/subjective/view/screens/marks_management_screen.dart';
import 'package:semester_repository/semester_repository.dart';

class DoctorControlPanel extends StatefulWidget {
  final String doctorId;
  final CoursesModel course;
  final List<GroupModel> selectedGroups;
  final Function(List<GroupModel>) onGroupsChanged;
  final Function(List<GroupModel>) onChatSelected;

  const DoctorControlPanel({
    super.key,
    required this.doctorId,
    required this.course,
    required this.selectedGroups,
    required this.onGroupsChanged,
    required this.onChatSelected,
  });

  @override
  State<DoctorControlPanel> createState() => _DoctorControlPanelState();
}

class _DoctorControlPanelState extends State<DoctorControlPanel> {
  List<GroupModel> _courseGroups = []; // 🔥 تخزين مجموعات المادة فقط

  @override
  void initState() {
    super.initState();
    _courseGroups = widget.course.groups;
  }


  void _toggleGroupSelection(GroupModel group) {
    final newList = List<GroupModel>.from(widget.selectedGroups);
    
    if (newList.contains(group)) {
      newList.remove(group);
    } else {
      newList.add(group);
    }
    
    // ✅ استدعاء دالة التحديث في الشاشة الرئيسية
    widget.onGroupsChanged(newList);
    print('✅ تم ${widget.selectedGroups.contains(group) ? 'إضافة' : 'إزالة'} المجموعة: ${group.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // قسم اختيار المجموعات
          _buildGroupsSelection(),
          const SizedBox(height: 16),
          // قسم أدوات الإضافة
          Expanded(
            child: _buildToolsGrid(),
          ),
        ],
      );
  }

  Widget _buildGroupsSelection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموعات المختارة',
                  style: font16blackbold,
                ),
                Text(
                  '(${ widget.selectedGroups.length}/${_courseGroups.length})',
                  style: font14black.copyWith(
                    color: ColorsApp.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _courseGroups.isEmpty
                ? _buildEmptyState()
                : _buildGroupsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 48, color: ColorsApp.grey),
          const SizedBox(height: 8),
          Text(
            'لا توجد مجموعات في هذه المادة',
            style: font14grey,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return SizedBox(
      height: 140, // 🔥 زيادة الارتفاع لعرض معلومات أكثر
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _courseGroups.length,
        itemBuilder: (context, index) {
          final group = _courseGroups[index];
          final isSelected =  widget.selectedGroups.contains(group);
          
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              elevation: 2,
              color: isSelected ? ColorsApp.primaryColor.withOpacity(0.15) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? ColorsApp.primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => _toggleGroupSelection(group),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔥 أيقونة الحالة
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? ColorsApp.primaryColor : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.group,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 🔥 اسم المجموعة
                      Text(
                        group.name,
                        style: font12black.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? ColorsApp.primaryColor : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // 🔥 عدد الطلاب
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${group.students.length} طالب',
                          style: font12Grey.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // 🔥 اسم الدكتور
                      Text(
                        group.nameDoctor.split(' ').take(2).join(' '), // 🔥 اختصار اسم الدكتور
                        style: font12Grey,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildToolCard(
          icon: Icons.announcement,
          title: 'إضافة إعلان',
          color: ColorsApp.primaryColor,
          onTap: () => _navigateToAddAdvertisement(),
        ),
        _buildToolCard(
          icon: Icons.assignment,
          title: 'إضافة واجب',
          color: ColorsApp.primaryColor,
          onTap: () => _navigateToAddAssignment(),
        ),
        _buildToolCard(
          icon: Icons.menu_book,
          title: 'إضافة منهج',
          color: ColorsApp.primaryColor,
          onTap: () => _navigateToAddCurriculum(),
        ),
        _buildToolCard(
          icon: Icons.grade,
          title: 'إدارة الدرجات',
          color: ColorsApp.primaryColor,
          onTap: () => _navigateToMarksManagement(),
        ),
        _buildToolCard(
          icon: Icons.people,
          title: 'إدارة الطلاب',
          color: ColorsApp.primaryColor,
          onTap: _showStudentsManagement,
        ),
        _buildToolCard(
          icon: Icons.chat_sharp,
          title: 'دردشات',
          color: ColorsApp.primaryColor,
          onTap: _showchat_room,
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDisabled =  widget.selectedGroups.isEmpty;
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDisabled ? Colors.grey[100] : color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDisabled ? Colors.grey : color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: font14black.copyWith(
                  color: isDisabled ? Colors.grey : color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (isDisabled) ...[
                const SizedBox(height: 4),
                Text(
                  'اختر مجموعة أولاً',
                  style: font12Grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddAdvertisement() {
    if ( widget.selectedGroups.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAdvertisementScreen(
          course: widget.course,
          selectedGroups:  widget.selectedGroups,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToAddAssignment() {
    if ( widget.selectedGroups.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAssignmentScreen(
          course: widget.course,
          selectedGroups:  widget.selectedGroups,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToAddCurriculum() {
    if ( widget.selectedGroups.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCurriculumScreen(
          course: widget.course,
          selectedGroups:  widget.selectedGroups,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToMarksManagement() {
    if ( widget.selectedGroups.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarksManagementScreen(
          course: widget.course,
          selectedGroups:  widget.selectedGroups,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _showStudentsManagement() {
  if ( widget.selectedGroups.isEmpty) return;
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AttendanceManagementScreen(
        course: widget.course,
        selectedGroups:  widget.selectedGroups,
        doctorId: widget.doctorId,
      ),
    ),
  );
}

  // في DoctorControlPanel عند الضغط على زر الدردشة
void _showchat_room() {
  if (widget.selectedGroups.isEmpty) {
    ShowWidget.showMessage(
      context,
      'يرجى اختيار مجموعة على الأقل',
      ColorsApp.primaryColor,
      font13White,
    );
    return;
  }

  if (widget.selectedGroups.length == 1) {
    // إذا كانت مجموعة واحدة فقط
    _navigateToGroupChat(widget.selectedGroups.first);
  } 
}

void _navigateToGroupChat(GroupModel group) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupChatScreen(
        userId: widget.doctorId,
        groupId: group.id,
        title: '${widget.course.name} - ${group.name}',
        course: widget.course,
        groupModel: group,
        userRole: 'Doctor',
      ),
    ),

  );
}

}