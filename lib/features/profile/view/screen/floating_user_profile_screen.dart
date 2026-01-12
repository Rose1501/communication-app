import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:user_repository/user_repository.dart';
/// Widget لعرض الملف الشخصي للمستخدم في نافذة منبثقة
/// 
/// يأخذ رقم قيد المستخدم (userID) كمعامل إجباري ويعرض:
/// - المعلومات الأساسية للمستخدم
/// - الساعات المكتبية (إذا كان دكتوراً أو مسؤولاً)
/// - المواد الدراسية (إذا كان دكتوراً)
class FloatingUserProfileScreen extends StatefulWidget {
  final String userID; // رقم قيد المستخدم المراد عرضه
  
  const FloatingUserProfileScreen({
    super.key,
    required this.userID,
  });

  @override
  State<FloatingUserProfileScreen> createState() => _FloatingUserProfileScreenState();
}

class _FloatingUserProfileScreenState extends State<FloatingUserProfileScreen> {
  late UserModels _user;
  bool _isLoadingUser = true;
  String? _errorMessage;
  bool _hasLoadedData = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() async {
    try {
      print('🔄 جلب بيانات المستخدم: ${widget.userID}');
      
      setState(() {
        _isLoadingUser = true;
        _errorMessage = null;
      });
      
      // البحث عن المستخدم
      context.read<UpdateUserInfoBloc>().add(SearchUserByUserID(widget.userID));
      
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
      setState(() {
        _isLoadingUser = false;
        _errorMessage = 'فشل في تحميل البيانات: ${e.toString()}';
      });
    }
  }
  
  bool _isUserDoctorOrAdmin() {
    if (!_isLoadingUser ) {
      return _user.role == 'Doctor' || 
              _user.role == 'doctor' || 
              _user.role == 'Admin' || 
              _user.role == 'admin';
    }
    return false;
  }
  
  bool _isUserDoctor() {
    if (!_isLoadingUser ) {
      return _user.role == 'Doctor' || _user.role == 'doctor';
    }
    return false;
  }
  
  void _closeScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
        listener: (context, state) {
          if (state is SearchUserSuccess) {
            print('✅ تم العثور على المستخدم: ${state.user.name}');
            setState(() {
              _user = state.user;
              _isLoadingUser = false;
            });
            
          } else if (state is SearchUserFailure) {
            print('❌ فشل في البحث: ${state.error}');
            setState(() {
              _isLoadingUser = false;
              _errorMessage = state.error;
            });
          }
        },
        child: _isLoadingUser
            ? _buildLoadingView('جاري تحميل بيانات المستخدم...')
            : _errorMessage != null
                ? _buildErrorView()
                : _buildUserProfileView(),
      ),
    );
  }

  Widget _buildLoadingView(String message) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          SizedBox(height: 20.h),
          Text(
            message,
            style: font14black,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      constraints: BoxConstraints(maxWidth: 300.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 50.w,
            color: ColorsApp.red,
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage ?? 'حدث خطأ غير متوقع',
            style: font14black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('إعادة المحاولة', style: font15White),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: _closeScreen,
            child: Text('إغلاق', style: font14black),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView() {
  return Container(
    constraints: BoxConstraints(
      maxWidth: 320.w,
      maxHeight: MediaQuery.of(context).size.height * 0.6, // أقصى ارتفاع 90%
    ),
    decoration: BoxDecoration(
      color: ColorsApp.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس الشاشة (ارتفاع ثابت)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: ColorsApp.white, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isUserDoctor() ? 'الملف الأكاديمي' : 'بيانات المستخدم',
                    style: font15Whitebold,
                  ),
                ),
                GestureDetector(
                  onTap: _closeScreen,
                  child: Icon(
                    Icons.close,
                    color: ColorsApp.white,
                    size: 20.w,
                  ),
                ),
              ],
            ),
          ),
          
          // المحتوى القابل للتمرير
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // صورة المستخدم
                  _buildProfileImageSection(),
                  SizedBox(height: 20.h),
                  
                  // المعلومات الأساسية
                  _buildBasicInfoSection(),
                  SizedBox(height: 20.h),
                  
                  // الساعات المكتبية (للدكتور أو الإدمن)
                  if (_isUserDoctorOrAdmin())
                    _buildOfficeHoursSection(),
                  
                  // المواد الدراسية (للدكتور فقط)
                  if (_isUserDoctor())
                    _buildTeachingCoursesSection(),
                  
                  // مسافة إضافية في الأسفل
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOfficeHoursSection() {
  return BlocBuilder<TeacherDataBloc, TeacherDataState>(
    builder: (context, state) {
      // تحميل البيانات عند أول مرة إذا لم يتم تحميلها
      if (!_hasLoadedData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🚀 إرسال طلب تحميل جميع البيانات');
          context.read<TeacherDataBloc>().add(LoadTeacherProfileDataEvent(widget.userID));
          setState(() {
            _hasLoadedData = true;
          });
        });
        
        return _buildLoadingSection('جاري تحميل البيانات...');
      }
      
      if (state is TeacherDataLoading) {
        return _buildLoadingSection('جاري تحميل الساعات المكتبية...');
      } else if (state is TeacherProfileDataLoaded) {
        return _buildOfficeHoursContent(state.officeHours);
      } else if (state is TeacherDataError) {
        return _buildErrorSection('فشل تحميل الساعات المكتبية');
      }
      
      return _buildLoadingSection('جاري تحميل البيانات...');
    },
  );
}

Widget _buildTeachingCoursesSection() {
  return BlocBuilder<TeacherDataBloc, TeacherDataState>(
    builder: (context, state) {
      // تحميل البيانات عند أول مرة إذا لم يتم تحميلها
      if (!_hasLoadedData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🚀 إرسال طلب تحميل جميع البيانات');
          context.read<TeacherDataBloc>().add(LoadTeacherProfileDataEvent(widget.userID));
          setState(() {
            _hasLoadedData = true;
          });
        });
        
        return _buildLoadingSection('جاري تحميل البيانات...');
      }
      
      if (state is TeacherDataLoading) {
        return _buildLoadingSection('جاري تحميل المواد الدراسية...');
      } else if (state is TeacherProfileDataLoaded) {
        print('📊 عدد المواد في الواجهة: ${state.teachingCourses.length}');
        if (state.teachingCourses.isNotEmpty) {
          print('📚 عرض المادة: ${state.teachingCourses.first.courseCode} - ${state.teachingCourses.first.courseName}');
        }
        return _buildTeachingCoursesContent(state.teachingCourses);
      } else if (state is TeacherDataError) {
        return _buildErrorSection('فشل تحميل المواد الدراسية');
      }
      
      return _buildLoadingSection('جاري تحميل البيانات...');
    },
  );
}

  Widget _buildOfficeHoursContent(List<OfficeHoursModel> officeHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Row(
          children: [
            Icon(Icons.access_time, size: 18.w, color: ColorsApp.primaryColor),
            SizedBox(width: 8.w),
            Text(
              'الساعات المكتبية',
              style: font16blackbold,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // محتوى القسم
        if (officeHours.isEmpty)
          _buildEmptySection('لا توجد ساعات مكتبية')
        else
          _buildOfficeHoursList(officeHours),
        
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildTeachingCoursesContent(List<TeachingCourseModel> courses) {
  // طباعة تفاصيل المواد للتأكد
  print('🔍 _buildTeachingCoursesContent: ${courses.length} مادة');
  for (var course in courses) {
    print('📖 ${course.courseCode} - ${course.courseName}');
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // عنوان القسم
      Row(
        children: [
          Icon(Icons.school, size: 18.w, color: ColorsApp.primaryColor),
          SizedBox(width: 8.w),
          Text(
            'المواد الدراسية',
            style: font16blackbold,
          ),
        ],
      ),
      SizedBox(height: 12.h),
      
      // محتوى القسم
      if (courses.isEmpty)
        _buildEmptySection('لا توجد مواد دراسية')
      else
        _buildTeachingCoursesList(courses),
    ],
  );
}

  Widget _buildOfficeHoursList(List<OfficeHoursModel> officeHours) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsApp.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: officeHours.map((hour) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                // اليوم
                Container(
                  width: 40.w,
                  child: Text(
                    hour.dayOfWeek,
                    style: font12black.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsApp.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '${hour.startTime} - ${hour.endTime}',
                    style: font14black.copyWith(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeachingCoursesList(List<TeachingCourseModel> courses) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsApp.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: courses.map((course) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                // رمز المادة
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: ColorsApp.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.courseCode,
                    style: font12black.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsApp.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    course.courseName,
                    style: font14black.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingSection(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsApp.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorsApp.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            message,
            style: font14grey,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsApp.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16.w, color: ColorsApp.red),
          SizedBox(width: 8.w),
          Text(
            message,
            style: font14black,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsApp.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          message,
          style: font14grey,
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // إطار الصورة
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorsApp.primaryColor,
              width: 3.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildProfileImage(),
        ),
        
        // شارة الدور
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _getRoleColor(_user.role),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getRoleLabel(_user.role),
              style: font11White.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_user.urlImg != null && _user.urlImg!.isNotEmpty) {
      try {
        if (_user.urlImg!.length > 100 && !_user.urlImg!.contains('http')) {
          return ClipOval(
            child: Image.memory(
              _decodeBase64(_user.urlImg!),
              width: 94.w,
              height: 94.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultImage();
              },
            ),
          );
        } else if (_user.urlImg!.startsWith('http')) {
          return ClipOval(
            child: Image.network(
              _user.urlImg!,
              width: 94.w,
              height: 94.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultImage();
              },
            ),
          );
        }
      } catch (e) {
        print('❌ خطأ في تحميل الصورة: $e');
      }
    }
    
    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return CircleAvatar(
      radius: 58.w,
      backgroundColor: ColorsApp.white,
      backgroundImage: _user.gender == "Male" ||_user.gender == "male"
          ? const AssetImage(HomeData.man)
          : const AssetImage(HomeData.woman),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      return base64Decode(cleanBase64);
    } catch (e) {
      throw Exception('فشل في فك تشفير Base64');
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // الاسم
        Text(
          _user.name,
          style: font20blackbold.copyWith(color: ColorsApp.primaryColor),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        
        // البريد الإلكتروني
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 14.w, color: ColorsApp.grey),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                _user.email,
                style: font14grey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return ColorsApp.primaryColor;
      case 'admin':
        return ColorsApp.red;
      case 'student':
        return ColorsApp.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'دكتور';
      case 'admin':
        return 'دراسةوالامتحانات';
      case 'student':
        return 'طالب';
      case 'manager':
        return 'رئيس القسم';
      default:
        return role;
    }
  }
}

// دالة الاستدعاء
void showUserProfileDialog(BuildContext context, String userID) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: true,
    builder: (context) {
      return FloatingUserProfileScreen(userID: userID);
    },
  );
}