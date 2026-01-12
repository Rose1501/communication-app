import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';
/*
 * ✅ لوحة اختيار الطلاب يدوياً من قاعدة البيانات
 * 
 * التسلسل:
 * 1. جلب جميع الطلاب المتاحين
 * 2. التحديد بواسطة Checkbox
 * 3. الإضافة ← SemesterCoursesBloc
 */
class StudentSelectionPanel extends StatefulWidget {
  final String semesterId;
  final String courseId;
  final String groupId;
  final List<StudentModel> existingStudents;
  final Function(List<StudentModel>) onStudentsAdded;

  const StudentSelectionPanel({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.groupId,
    required this.existingStudents,
    required this.onStudentsAdded,
  });

  @override
  State<StudentSelectionPanel> createState() => _StudentSelectionPanelState();
}

class _StudentSelectionPanelState extends State<StudentSelectionPanel> {
  List<UserModels> _availableStudents = [];
  List<UserModels> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  void _loadAvailableStudents() {
    context.read<UserManagementBloc>().add(const LoadAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementBloc, UserManagementState>(
      builder: (context, state) {
        // ✅ فلترة الطلاب: طلاب فقط وغير مضافين مسبقاً للمجموعة
        _availableStudents = state.users.where((user) {
          final isStudent = user.role == 'Student';
          final isNotAlreadyAdded = !widget.existingStudents
              .any((existing) => existing.studentId == user.userID);
          return isStudent && isNotAlreadyAdded;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('اختيار الطلاب للمجموعة', style: font16White),
            backgroundColor: ColorsApp.primaryColor,
            actions: [
              if (_selectedStudents.isNotEmpty)
                Chip(
                  label: Text('${_selectedStudents.length}', style: font13White),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
            ],
          ),
          body: Column(
            children: [
              // 🔍 شريط البحث
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16.w),
                      Icon(Icons.search, color: Colors.grey[500]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن طالب بالاسم أو رقم القيد...',
                            hintStyle: font14grey,
                            border: InputBorder.none,
                          ),
                          style: font14black,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500], size: 20.sp),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              // 📊 الإحصائيات
              _buildStatistics(),
              
              // 👥 قائمة الطلاب المتاحين
              Expanded(
                child: _buildStudentsList(),
              ),
              
              // 🔘 أزرار الإجراءات
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    final filteredStudents = _getFilteredStudents();
    
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('المتاحين', filteredStudents.length, Icons.people_outline),
          _buildStatItem('المحددين', _selectedStudents.length, Icons.check_circle),
          _buildStatItem('المضافين', widget.existingStudents.length, Icons.group),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: ColorsApp.primaryColor),
            SizedBox(width: 4.w),
            Text('$count', style: font16blackbold),
          ],
        ),
        Text(label, style: font12Grey),
      ],
    );
  }

  Widget _buildStudentsList() {
    final filteredStudents = _getFilteredStudents();

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلاب متاحين',
              style: font18blackbold,
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                widget.existingStudents.isEmpty
                    ? 'لا توجد حسابات طلاب في النظام'
                    : 'جميع الطلاب مضافين مسبقاً لهذه المجموعة',
                style: font14grey,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final studentUser = filteredStudents[index];
        final isSelected = _selectedStudents.contains(studentUser);
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? ColorsApp.primaryColor : Colors.grey[400],
              child: Text(
                studentUser.name.isNotEmpty ? studentUser.name[0] : '?',
                style: font15White,
              ),
            ),
            title: Text(
              studentUser.name.isNotEmpty ? studentUser.name : 'طالب بدون اسم',
              style: font14black.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم القيد: ${studentUser.userID}', style: font14grey),
                Text('البريد: ${studentUser.email}', style: font12Grey),
              ],
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedStudents.add(studentUser);
                  } else {
                    _selectedStudents.remove(studentUser);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedStudents.remove(studentUser);
                } else {
                  _selectedStudents.add(studentUser);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedStudents.isEmpty ? null : () {
                    setState(() {
                      _selectedStudents.clear();
                    });
                  },
                  child: Text('إلغاء التحديد', style: font15primary),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ButtonApp(
                  textData: 'إضافة المحددين',
                  onTop: _selectedStudents.isEmpty ? null : _addSelectedStudents,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('رجوع', style: font15primary),
          ),
        ],
      ),
    );
  }
// ✅  دالة إضافة الطلاب المحددين
  void _addSelectedStudents() {
  if (_selectedStudents.isEmpty) {
    ShowWidget.showMessage(
      context,
      'لم يتم اختيار أي طلاب',
      Colors.orange,
      font15White,
    );
    return;
  }

  // ✅ تحويل UserModels إلى StudentModel
  final studentsToAdd = _selectedStudents.map((user) => StudentModel(
    id: '', // سيتم توليده تلقائياً
    name: user.name,
    studentId: user.userID,
  )).toList();

  print('💾 إضافة ${studentsToAdd.length} طالب للمجموعة ${widget.groupId}');
  
  // ✅ استخدام البلوك لإضافة الطلاب
  context.read<SemesterCoursesBloc>().add(
    AddStudentsToGroup(
      courseId: widget.courseId,
      groupId: widget.groupId,
      students: studentsToAdd,
    )
  );

  // إغلاق البانل بعد الإضافة
  widget.onStudentsAdded(studentsToAdd);
}

  List<UserModels> _getFilteredStudents() {
    if (_searchController.text.isEmpty) {
      return _availableStudents;
    }
    
    final searchTerm = _searchController.text.toLowerCase();
    return _availableStudents.where((student) {
      return  student.name.toLowerCase().contains(searchTerm) ||
              student.userID.toLowerCase().contains(searchTerm) ||
              student.email.toLowerCase().contains(searchTerm);
    }).toList();
  }
}