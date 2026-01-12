import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/student_selection_panel.dart';
import 'package:semester_repository/semester_repository.dart';

class GroupStudentsManagementScreen extends StatefulWidget {
  final String semesterId;
  final String courseId;
  final GroupModel group;
  final int groupIndex;

  const GroupStudentsManagementScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.group,
    required this.groupIndex,
  });

  @override
  State<GroupStudentsManagementScreen> createState() => _GroupStudentsManagementScreenState();
}

class _GroupStudentsManagementScreenState extends State<GroupStudentsManagementScreen> {
  List<StudentModel> _groupStudents = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroupStudents();
  }

  // ✅ التحديث: دالة جديدة لجلب الطلاب المضافين للمجموعة من قاعدة البيانات
  void _loadGroupStudents() {
    setState(() {
      _isLoading = true;
    });

    try {
      // هنا نستخدم الـ repository لجلب الطلاب المضافين لهذه المجموعة
      context.read<SemesterCoursesBloc>().add(
        LoadGroupStudents(
          courseId: widget.courseId,
          groupId: widget.group.id,
        )
      );
      
      print('✅ تم جلب طالب من المجموعة ${widget.group.name}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ خطأ في جلب طلاب المجموعة: $e');
      // عرض رسالة خطأ للمستخدم
      ShowWidget.showMessage(
        context,
        'فشل في تحميل الطلاب: $e',
        Colors.red,
        font15White,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SemesterCoursesBloc, SemesterCoursesState>(
      listener: (context, state) {
      _handleStudentsStateChanges(state);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة طلاب ${widget.group.name}', style: font16White),
          backgroundColor: ColorsApp.primaryColor,
        actions: [
            IconButton(
              icon: Icon(Icons.person_add, color: ColorsApp.white),
              onPressed: _showAddStudentsDialog,
            ),
          ],
        ),
        body:_isLoading 
            ? _buildLoadingState()
            : Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  // شريط البحث
                  _buildSearchBar(),
                  SizedBox(height: 16.h),
                  
                  // إحصائيات
                  _buildStatistics(),
                  SizedBox(height: 16.h),
                  
                  // قائمة الطلاب
                  Expanded(
                    child: _buildStudentsList(),
                  ),
                ],
            ),
        ),
      ),
    );
  }

  // ✅ دالة معالجة حالة الطلاب
void _handleStudentsStateChanges(SemesterCoursesState state) {
  // تحديث قائمة الطلاب عند تحميلها
  if (state.status == SemesterCoursesStatus.success && 
      state.selectedGroupId == widget.group.id) {
    setState(() {
      _groupStudents = state.groupStudents;
      _isLoading = false;
    });
  }
  
  // معالجة رسائل النجاح
  if (state.status == SemesterCoursesStatus.success && state.successMessage.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.successMessage),
        backgroundColor: Colors.green,
      ),
    );
    
    // إعادة تحميل الطلاب بعد العمليات
    if (state.successMessage.contains('تم حذف الطالب') || 
        state.successMessage.contains('تم إضافة')) {
      _loadGroupStudents();
    }
  }
  
  // معالجة رسائل الخطأ
  if (state.status == SemesterCoursesStatus.error && state.errorMessage.isNotEmpty) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          SizedBox(height: 16.h),
          Text('جاري تحميل الطلاب...', style: font16black),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
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
                hintText: 'ابحث عن طالب...',
                hintStyle: font14grey,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
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
    );
  }

  Widget _buildStatistics() {
    final filteredStudents = _getFilteredStudents();
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي الطلاب', _groupStudents.length.toString()),
          _buildStatItem('النتائج', filteredStudents.length.toString()),
        ],
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
    final filteredStudents = _getFilteredStudents();

    if (filteredStudents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadGroupStudents();
      },
      child: ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorsApp.primaryColor,
              child: Text(
                student.name.isNotEmpty ? student.name[0] : '?',
                style: font15White,
              ),
            ),
            title: Text(
              student.name.isNotEmpty ? student.name : 'طالب بدون اسم',
              style: font14black,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم القيد: ${student.studentId}', style: font14grey),
                if (student.id.isNotEmpty)
                  Text('المعرف: ${student.id}', style: font12Grey),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(student),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلاب في هذه المجموعة',
              style: font18blackbold,
            ),
            SizedBox(height: 8.h),
            Text(
              'انقر على زر (+) لإضافة طلاب',
              style: font14grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ButtonApp(
              textData: 'إضافة طلاب',
              onTop: _showAddStudentsDialog,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ التحديث: دالة جديدة لعرض ديالوج إضافة الطلاب
  void _showAddStudentsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: StudentSelectionPanel(
          semesterId: widget.semesterId,
          courseId: widget.courseId,
          groupId: widget.group.id,
          existingStudents: _groupStudents,
          onStudentsAdded: (newStudents) {
            // ✅ تحديث القائمة بعد إضافة طلاب جدد
            setState(() {
              _groupStudents.addAll(newStudents);
            });
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إضافة ${newStudents.length} طالب بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ التحديث: دالة جديدة لحذف طالب
  void _showDeleteConfirmation(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الطالب', style: font16blackbold),
        content: Text('هل أنت متأكد من حذف الطالب ${student.name} من المجموعة؟', style: font14black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: font14black),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<SemesterCoursesBloc>().add(
              RemoveStudentFromGroup(
                courseId: widget.courseId,
                groupId: widget.group.id,
                studentId: student.id,
                )
              );
            },
            child: Text('حذف', style: font14Error),
          ),
        ],
      ),
    );
  }
/*
  // ✅ التحديث: دالة جديدة لحذف طالب من قاعدة البيانات
  Future<void> _deleteStudent(StudentModel student) async {
    try {
      final semesterRepository = context.read<SemesterCoursesBloc>().semesterRepository;
      await semesterRepository.deleteStudent(
        widget.semesterId,
        widget.courseId,
        widget.group.id,
        student.id,
      );
      
      setState(() {
        _groupStudents.removeWhere((s) => s.id == student.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الطالب ${student.name} بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في حذف الطالب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
*/
  List<StudentModel> _getFilteredStudents() {
    if (_searchController.text.isEmpty) {
      return _groupStudents;
    }
    
    final searchTerm = _searchController.text.toLowerCase();
    return _groupStudents.where((student) {
      return  student.name.toLowerCase().contains(searchTerm) ||
              student.studentId.toLowerCase().contains(searchTerm);
    }).toList();
  }
/*
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // تصدير قائمة الطلاب
                  _exportStudentsList();
                },
                child: Text('تصدير القائمة', style: font15primary),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ButtonApp(
                textData: 'حفظ التغييرات',
                onTop: _saveStudents,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ButtonApp(
          textData: 'استيراد من ملف',
          onTop: _importStudentsFromFile,
          boxDecoration: borderAllPrimary,
          textStyle: font15primary,
        ),
      ],
    );
  }

  void _exportStudentsList() {
    // TODO: تنفيذ تصدير القائمة لملف Excel
    print('تصدير قائمة الطلاب للمجموعة ${widget.group.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم تصدير ${_groupStudents.length} طالب'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _importStudentsFromFile() {
    // TODO: تنفيذ استيراد الطلاب من ملف Excel
    print('استيراد طلاب للمجموعة ${widget.group.name}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استيراد الطلاب', style: font16blackbold),
        content: Text('هذه الخاصية قيد التطوير', style: font14black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: font15primary),
          ),
        ],
      ),
    );
  }

  void _saveStudents() {
    if (_groupStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لم يتم اختيار أي طلاب للمجموعة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // تحويل List<UserModels> إلى List<StudentModel>
    final students = _groupStudents.map((user) => StudentModel(
      id: user.userID, // استخدام userID كمعرف
      name: user.name,
      studentId: user.userID,
    )).toList();

    // TODO: حفظ الطلاب في قاعدة البيانات
    print('حفظ ${students.length} طالب في المجموعة ${widget.group.name}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ ${students.length} طالب في المجموعة'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
*/
}