// features/data_management/view/screens/course_groups_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/group_students_management_screen.dart';
import 'package:myproject/features/data_management/view/widgets/student_import_panel.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

class CourseGroupsManagementScreen extends StatefulWidget {
  final CoursesModel course;
  final String semesterId;

  const CourseGroupsManagementScreen({
    super.key,
    required this.course,
    required this.semesterId,
  });

  @override
  State<CourseGroupsManagementScreen> createState() => _CourseGroupsManagementScreenState();
}

class _CourseGroupsManagementScreenState extends State<CourseGroupsManagementScreen> {
  List<GroupModel> _groups = [];
  final TextEditingController _numOfGroupsController = TextEditingController();
  final TextEditingController _numOfChairsController = TextEditingController();
  UserModels? _selectedMainDoctor;

  @override
  void initState() {
    super.initState();
    _initializeGroups();
    _loadDoctors();
  }

  void _initializeGroups() {
    if (widget.course.groups.isEmpty) {
      _numOfGroupsController.text = '1';
      _numOfChairsController.text = '30';
      _groups = [
        GroupModel(
          id: '',
          name: 'المجموعة أ',
          idDoctor: '',
          nameDoctor: 'غير محدد',
        )
      ];
    } else {
      _groups = List.from(widget.course.groups);
      _numOfGroupsController.text = _groups.length.toString();
      _numOfChairsController.text = widget.course.numOfStudent.toString();
    }
  }

  void _loadDoctors() {
    context.read<UserManagementBloc>().add(const LoadAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة ${widget.course.name}', style: font16White),
        backgroundColor: ColorsApp.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // معلومات المادة
            _buildCourseInfo(),
            SizedBox(height: 24.h),
            
            // الإعدادات الأساسية
            _buildBasicSettings(),
            SizedBox(height: 24.h),
            
            // إدارة المجموعات
            Expanded(
              child: _buildGroupsManagement(),
            ),
            
            // أزرار الحفظ
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Icon(Icons.school, color: ColorsApp.primaryColor, size: 40.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.course.name, style: font18blackbold),
                  Text(widget.course.codeCs, style: font14grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإعدادات الأساسية', style: font16blackbold),
        SizedBox(height: 16.h),
        
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _numOfChairsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'عدد الكراسي',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: TextField(
                controller: _numOfGroupsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'عدد المجموعات',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _updateGroupsCount(int.tryParse(value) ?? 1);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        BlocBuilder<UserManagementBloc, UserManagementState>(
          builder: (context, state) {
            final doctors = state.users.where((user) => user.role == 'Doctor').toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الدكتور الأساسي', style: font14black),
                SizedBox(height: 8.h),
                DropdownButtonFormField<UserModels>(
                  value: _selectedMainDoctor,
                  items: doctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text('${doctor.name} (${doctor.userID})'),
                    );
                  }).toList(),
                  onChanged: (doctor) {
                    setState(() {
                      _selectedMainDoctor = doctor;
                      // تحديث الدكتور في جميع المجموعات
                      for (int i = 0; i < _groups.length; i++) {
                        _groups[i] = _groups[i].copyWith(
                          idDoctor: doctor?.userID ?? '',
                          nameDoctor: doctor?.name ?? 'غير محدد',
                        );
                      }
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'اختر الدكتور الأساسي',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupsManagement() {
    return Column(
      children: [
        Row(
          children: [
            Text('إدارة المجموعات', style: font16blackbold),
            Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: ColorsApp.primaryColor),
              onPressed: _addGroup,
            ),
            IconButton(
              icon: Icon(Icons.remove, color: Colors.red),
              onPressed: _removeGroup,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              return _buildGroupCard(_groups[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(GroupModel group, int index) {
    final groupLetters = ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح', 'ط', 'ي'];
    final groupName = 'المجموعة ${groupLetters[index]}';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(groupName, style: font16blackbold),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.person_search, color: ColorsApp.primaryColor),
                  onPressed: () => _showDoctorSelectionDialog(index),
                ),
                IconButton(
                  icon: Icon(Icons.people, color: Colors.green),
                  onPressed: () => _manageGroupStudents(group, index),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text('الدكتور: ${group.nameDoctor}', style: font14grey),
            SizedBox(height: 8.h),
            Row(
              children: [
                ButtonApp(
                  textData: 'استيراد الطلاب',
                  onTop: () => _importStudentsToGroup(group),
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: ColorsApp.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: font15primary,
                ),
                SizedBox(width: 8.w),
                ButtonApp(
                  textData: 'عرض الطلاب',
                  onTop: () => _viewGroupStudents(group),
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addGroup() {
    final newCount = int.tryParse(_numOfGroupsController.text) ?? 1;
    _numOfGroupsController.text = (newCount + 1).toString();
    _updateGroupsCount(newCount + 1);
  }

  void _removeGroup() {
    final newCount = int.tryParse(_numOfGroupsController.text) ?? 1;
    if (newCount > 1) {
      _numOfGroupsController.text = (newCount - 1).toString();
      _updateGroupsCount(newCount - 1);
    }
  }

  void _updateGroupsCount(int count) {
    final groupLetters = ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح', 'ط', 'ي'];
    
    setState(() {
      _groups = List.generate(count, (index) {
        if (index < _groups.length) {
          return _groups[index];
        } else {
          return GroupModel(
            id: '',
            name: 'المجموعة ${groupLetters[index]}',
            idDoctor: _selectedMainDoctor?.userID ?? '',
            nameDoctor: _selectedMainDoctor?.name ?? 'غير محدد',
          );
        }
      });
    });
  }

  void _showDoctorSelectionDialog(int groupIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر دكتور المجموعة', style: font16blackbold),
        content: BlocBuilder<UserManagementBloc, UserManagementState>(
          builder: (context, state) {
            final doctors = state.users.where((user) => user.role == 'Doctor').toList();
            
            return Container(
              width: double.maxFinite,
              height: 300.h,
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: ListTile(
                      title: Text(doctor.name, style: font14black),
                      subtitle: Text(doctor.userID, style: font14grey),
                      onTap: () {
                        setState(() {
                          _groups[groupIndex] = _groups[groupIndex].copyWith(
                            idDoctor: doctor.userID,
                            nameDoctor: doctor.name,
                          );
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _manageGroupStudents(GroupModel group, int groupIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupStudentsManagementScreen(
          semesterId: widget.semesterId,
          courseId: widget.course.id,
          group: group,
          groupIndex: groupIndex,
        ),
      ),
    );
  }

  void _importStudentsToGroup(GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: StudentImportPanel(
          semesterId: widget.semesterId,
          courseId: widget.course.id,
          groupId: group.id,
          onImportSuccess: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم استيراد الطلاب بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _viewGroupStudents(GroupModel group) {
    // سيتم تنفيذ شاشة عرض الطلاب
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('عرض طلاب ${group.name}'),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ButtonApp(
          textData: 'حفظ التغييرات',
          onTop: _saveCourseWithGroups,
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: font15primary),
        ),
      ],
    );
  }

  void _saveCourseWithGroups() {
    if (_selectedMainDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار الدكتور الأساسي'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final numOfChairs = int.tryParse(_numOfChairsController.text) ?? 0;
    if (numOfChairs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال عدد كراسي صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // تحديث المادة بالمعلومات الجديدة
    final updatedCourse = widget.course.copyWith(
      numOfStudent: numOfChairs,
      president: _selectedMainDoctor!.name,
      groups: _groups,
    );

    print('💾 حفظ المادة مع البيانات:');
    print('   📚 المادة: ${updatedCourse.name}');
    print('   👨‍🏫 الدكتور الأساسي: ${_selectedMainDoctor!.name}');
    print('   🪑 عدد الكراسي: $numOfChairs');
    print('   👥 عدد المجموعات: ${_groups.length}');

    // هنا سيتم إرسال البيانات لحفظها
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ البيانات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}