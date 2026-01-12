import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/chat/view/screens/group_chat_screen.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/widgets/doctor_control_panel.dart';
import 'package:semester_repository/semester_repository.dart';

class GroupContentScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final String userId;
  final String studentname;

  const GroupContentScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.userId,
    required this.studentname,
  });

  @override
  State<GroupContentScreen> createState() => _GroupContentScreenState();
}

class _GroupContentScreenState extends State<GroupContentScreen> {
  List<GroupModel> _selectedGroups = [];
  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'Student') {
      // تحميل محتوى المجموعة للطالب فقط
      context.read<SubjectiveBloc>().add(
        LoadGroupSubjectiveContentEvent(
          courseId: widget.course.id, 
          groupId: widget.group.id,
        ),
      );
    }
    if (widget.userRole == 'Doctor' && widget.group.isEmpty) {
      _selectedGroups.add(widget.group);
    }
  }

  void _selectAllGroups() {
    setState(() {
      _selectedGroups = List.from(widget.course.groups);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedGroups.clear();
    });
  }

  // ✅ تحديث دالة _showGroupChat
  void _showGroupChat(List<GroupModel> groups) {
    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار مجموعة على الأقل'),
          backgroundColor: ColorsApp.primaryColor,
        ),
      );
      return;
    }

    // إذا كانت مجموعة واحدة فقط
    if (groups.length == 1) {
      _navigateToGroupChat(groups.first);
    } else {
      // إذا كانت مجموعات متعددة، عرض خيارات
      _showGroupsSelectionDialog(groups);
    }
  }

  // ✅ دالة التنقل لشاشة الدردشة
  void _navigateToGroupChat(GroupModel group) {
  
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => GroupChatScreen(
          userId: widget.userId,
          groupId: group.id,
          title: '${widget.course.name} - ${group.name}',
          course: widget.course,
          groupModel: group,
          userRole: widget.userRole,
        ),
      ),
  );
}

  // ✅ حوار اختيار المجموعة (للدكتور)
  void _showGroupsSelectionDialog(List<GroupModel> groups) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر مجموعة للدردشة'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: Icon(Icons.group, color: ColorsApp.primaryColor),
                title: Text(group.name),
                subtitle: Text('${group.students.length} طالب'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToGroupChat(group);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == 'Doctor') {
      return _buildDoctorScreen();
    } else {
      return GroupChatScreen(
      userId: widget.userId,
      groupId: widget.group.id,
      title: '${widget.course.name} - ${widget.group.name}',
      course: widget.course,
      groupModel: widget.group,
      userRole: widget.userRole,
    );
    }
  }

  Widget _buildDoctorScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة تحكم - ${widget.course.name}', style: font16White),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all, color: ColorsApp.white),
            onPressed: _selectAllGroups,
            tooltip: 'تحديد الكل',
          ),
          IconButton(
            icon: Icon(Icons.clear_all, color: ColorsApp.white),
            onPressed: _clearSelection,
            tooltip: 'إلغاء التحديد',
          ),
        ],
      ),
      body: DoctorControlPanel(
        doctorId: widget.userId,
        course: widget.course,
        selectedGroups: _selectedGroups,
        onGroupsChanged: (groups) {
          setState(() {
            _selectedGroups = groups;
          });
        },
        onChatSelected: _showGroupChat,
      ),
    );
  }
}