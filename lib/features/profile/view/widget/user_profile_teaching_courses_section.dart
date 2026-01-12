import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';

class UserProfileTeachingCoursesSection extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final List<CoursesModel> selectedCourses;
  final Function(List<CoursesModel>) onUpdateSelectedCourses;
  final VoidCallback onSave;
  final VoidCallback onDeleteAll; // دالة جديدة لحذف جميع المواد
  final VoidCallback onLoad;
  final VoidCallback onCancel;

  const UserProfileTeachingCoursesSection({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.selectedCourses,
    required this.onUpdateSelectedCourses,
    required this.onSave,
    required this.onDeleteAll, // إضافة معامل جديد
    required this.onLoad,
    required this.onCancel,
  });

  @override
  State<UserProfileTeachingCoursesSection> createState() => _UserProfileTeachingCoursesSectionState();
}

class _UserProfileTeachingCoursesSectionState extends State<UserProfileTeachingCoursesSection> {
  List<CoursesModel> _availableCourses = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false; // حالة جديدة لحذف المواد
  String _searchQuery = '';
  String? _errorMessage;
  bool _autoSelectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableCourses();
    });
  }

  Future<void> _loadAvailableCourses() async {
    try {
      print('🔍 جلب المواد المتاحة للدكتور: ${widget.teacherId}');
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      widget.onLoad();
      
      context.read<SubjectiveBloc>().add(LoadDoctorGroupsEvent(widget.teacherId));
      
    } catch (e) {
      print('❌ خطأ في تحميل المواد المتاحة: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل المواد: ${e.toString()}';
      });
    }
  }

  List<CoursesModel> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return _availableCourses;
    }
    
    return _availableCourses.where((course) {
      return course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              course.codeCs.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool _isCourseSelected(CoursesModel course) {
    return widget.selectedCourses.any((c) => c.id == course.id);
  }

  void _toggleCourseSelection(CoursesModel course) {
    final updatedCourses = List<CoursesModel>.from(widget.selectedCourses);
    
    if (_isCourseSelected(course)) {
      updatedCourses.removeWhere((c) => c.id == course.id);
    } else {
      updatedCourses.add(course);
    }
    
    widget.onUpdateSelectedCourses(updatedCourses);
  }

  void _selectAllCourses() {
    if (widget.selectedCourses.length == _availableCourses.length) {
      widget.onUpdateSelectedCourses([]);
    } else {
      widget.onUpdateSelectedCourses(List.from(_availableCourses));
    }
  }

  void _autoSelectAllCourses() {
    if (_autoSelectAll) {
      widget.onUpdateSelectedCourses(List.from(_availableCourses));
    }
  }

  Future<void> _saveTeachingCourses() async {
    if (widget.selectedCourses.isEmpty) {
      _showMessage('الرجاء اختيار مادة واحدة على الأقل', ColorsApp.orange);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    widget.onSave();

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _deleteAllTeachingCourses() async {
    // طلب تأكيد من المستخدم قبل الحذف
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف جميع المواد', style: font16blackbold),
        content: Text(
          'هل أنت متأكد من حذف جميع المواد الدراسية؟',
          style: font14black,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: font14black),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.red,
            ),
            child: Text('حذف', style: font15White),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      // استدعاء دالة حذف جميع المواد
      widget.onDeleteAll();

      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _showMessage(String message, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: font13White),
          backgroundColor: color,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is DoctorGroupsLoadSuccess) {
          print('✅ تم جلب ${state.courses.length} مادة للدكتور');
          
          setState(() {
            _availableCourses = state.courses;
            _isLoading = false;
          });
          
          if (state.courses.isEmpty) {
            setState(() {
              _errorMessage = 'لا توجد مواد مسندة إليك في الفصل الحالي';
            });
          } else {
            _autoSelectAll = true;
            _autoSelectAllCourses();
          }
        } else if (state is SubjectiveError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9), // رمادي فاتح ثابت
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)), // رمادي فاتح للحدود
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'المواد الدراسية',
                style: font16blackbold.copyWith(color: ColorsApp.primaryColor),
              ),
            ),
            SizedBox(height: 10.h),

            Center(
              child: Text(
                'سيتم تلقائياً اختيار جميع المواد التي تدرسها في الفصل الحالي',
                style: font14grey,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.h),

            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: ColorsApp.primaryColor),
                    SizedBox(height: 16.h),
                    Text('جاري تحميل المواد...', style: font14grey),
                  ],
                ),
              )
            else if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(16.w),
                color: const Color(0xFFFFF3E0), // برتقالي فاتح ثابت
                child: Row(
                  children: [
                    Icon(Icons.warning, color: ColorsApp.orange),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: font14black,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadAvailableCourses,
                      child: Text('إعادة المحاولة', style: font14black.copyWith(color: ColorsApp.primaryColor)),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // بطاقة المعلومات
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المواد المتاحة',
                              style: font12Grey,
                            ),
                            Text(
                              '${_availableCourses.length}',
                              style: font16blackbold.copyWith(color: ColorsApp.primaryColor),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'المواد المحددة',
                              style: font12Grey,
                            ),
                            Text(
                              '${widget.selectedCourses.length}',
                              style: font16blackbold.copyWith(color: ColorsApp.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // أزرار التحكم
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectAllCourses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.selectedCourses.length == _availableCourses.length
                                ? const Color(0xFF757575) // رمادي داكن ثابت
                                : ColorsApp.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          icon: Icon(
                            Icons.check_circle_outline,
                            size: 18.w,
                            color: ColorsApp.white,
                          ),
                          label: Text(
                            widget.selectedCourses.length == _availableCourses.length
                                ? 'إلغاء اختيار الكل'
                                : 'اختيار الكل',
                            style: font13White,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // قائمة المواد المتاحة
                  Container(
                    constraints: BoxConstraints(maxHeight: 250.h),
                    child: _availableCourses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school, size: 60, color: const Color(0xFFBDBDBD)),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا توجد مواد متاحة حالياً',
                                  style: font16blackbold,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              final isSelected = _isCourseSelected(course);
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 8.h),
                                color: isSelected 
                                    ? ColorsApp.primaryColor.withOpacity(0.1)
                                    : ColorsApp.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? ColorsApp.primaryColor 
                                        : const Color(0xFFE0E0E0),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  leading: Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? ColorsApp.primaryColor.withOpacity(0.2)
                                          : const Color(0xFFF5F5F5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.school,
                                      color: isSelected 
                                          ? ColorsApp.primaryColor 
                                          : const Color(0xFF757575),
                                      size: 20.w,
                                    ),
                                  ),
                                  title: Text(
                                    course.name,
                                    style: isSelected 
                                        ? font14black.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: ColorsApp.primaryColor,
                                          )
                                        : font14black,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    course.codeCs,
                                    style: font12Grey,
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      _toggleCourseSelection(course);
                                    },
                                    activeColor: ColorsApp.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onTap: () {
                                    _toggleCourseSelection(course);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // زر الحفظ أو الحذف
                  SizedBox(
                    width: double.infinity,
                    child: widget.selectedCourses.isNotEmpty
                        ? _buildSaveButton()
                        : _buildDeleteAllButton(),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // زر الإلغاء
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF424242),
                        side: BorderSide(color: const Color(0xFFBDBDBD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text('إلغاء', style: font14black),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: !_isSaving ? _saveTeachingCourses : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsApp.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        elevation: 4,
      ),
      child: _isSaving
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: ColorsApp.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12.w),
                Text('جاري الحفظ...', style: font15White),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حفظ المواد الدراسية',
                  style: font15White.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }

  Widget _buildDeleteAllButton() {
    return ElevatedButton(
      onPressed: !_isDeleting ? _deleteAllTeachingCourses : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsApp.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        elevation: 4,
      ),
      child: _isDeleting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: ColorsApp.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12.w),
                Text('جاري الحذف...', style: font15White),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(
                  'حذف جميع المواد',
                  style: font15White.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}