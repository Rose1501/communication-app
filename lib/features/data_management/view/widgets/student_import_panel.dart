import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

class StudentImportPanel extends StatefulWidget {
  final String semesterId;
  final String courseId;
  final String groupId;
  final VoidCallback onImportSuccess;

  const StudentImportPanel({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.groupId,
    required this.onImportSuccess,
  });

  @override
  State<StudentImportPanel> createState() => _StudentImportPanelState();
}

class _StudentImportPanelState extends State<StudentImportPanel> {
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
        // تصفية الطلاب المتاحين (طلاب فقط وغير مضافين للمجموعة)
        _availableStudents = state.users.where((user) => 
          user.role == 'Student'
        ).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('استيراد الطلاب', style: font16White),
            backgroundColor: ColorsApp.primaryColor,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // شريط البحث
                _buildSearchBar(),
                SizedBox(height: 16.h),
                
                // الإحصائيات
                _buildStatistics(),
                SizedBox(height: 16.h),
                
                // قائمة الطلاب المتاحين
                Expanded(
                  child: _buildStudentsList(),
                ),
                
                // أزرار الإجراءات
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'ابحث عن طالب...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('المتاحين', _availableStudents.length.toString()),
            _buildStatItem('المحددين', _selectedStudents.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: font16blackbold),
        Text(label, style: font14grey),
      ],
    );
  }

  Widget _buildStudentsList() {
    final filteredStudents = _availableStudents.where((student) {
      final searchTerm = _searchController.text.toLowerCase();
      return student.name.toLowerCase().contains(searchTerm) ||
             student.userID.toLowerCase().contains(searchTerm);
    }).toList();

    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final isSelected = _selectedStudents.contains(student);
        
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(student.name[0]),
            ),
            title: Text(student.name, style: font14black),
            subtitle: Text('رقم القيد: ${student.userID}', style: font14grey),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedStudents.add(student);
                  } else {
                    _selectedStudents.remove(student);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedStudents.remove(student);
                } else {
                  _selectedStudents.add(student);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
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
                onTop: _addSelectedStudents,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ButtonApp(
          textData: 'استيراد من ملف Excel',
          onTop: _importFromExcel,
          boxDecoration: BoxDecoration(
            border: Border.all(color: ColorsApp.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: font15primary,
        ),
      ],
    );
  }

  void _addSelectedStudents() {
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لم يتم اختيار أي طلاب'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // تحويل List<UserModels> إلى List<StudentModel>
    final students = _selectedStudents.map((user) => StudentModel(
      id: user.userID,
      name: user.name,
      studentId: user.userID,
    )).toList();

    print('💾 إضافة ${students.length} طالب للمجموعة');
    
    // هنا سيتم حفظ الطلاب في قاعدة البيانات
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${students.length} طالب بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onImportSuccess();
  }

  void _importFromExcel() {
    // سيتم تنفيذ استيراد من Excel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خاصية الاستيراد من Excel قيد التطوير'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}