import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:myproject/features/profile/view/widget/user_profile_actions.dart';
import 'package:myproject/features/profile/view/widget/user_profile_content.dart';
import 'package:myproject/features/profile/view/widget/user_profile_listeners.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileFloatingPage extends StatefulWidget {
  const UserProfileFloatingPage({super.key,});

  @override
  State<UserProfileFloatingPage> createState() => _UserProfileFloatingPageState();
}

class _UserProfileFloatingPageState extends State<UserProfileFloatingPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _resetCodeController;
  
  bool _isEditingPassword = false;
  bool _isEditingOfficeHours = false;
  bool _isEditingCourses = false;
  bool _isChangingImage = false;
  bool _isResetMode = false;
  List<CoursesModel> _selectedCourses = [];
  List<OfficeHoursModel> _existingOfficeHours = [];
  List<OfficeHoursModel> _officeHoursToAdd = [];
  String? _selectedImagePath;
  UserModels? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _resetCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resetCodeController.dispose();
    super.dispose();
  }

  // تبديل وضع تعديل كلمة المرور
  void _toggleEditPasswordMode() {
    setState(() {
      _isEditingPassword = !_isEditingPassword;
      _isResetMode = false; 
      if (!_isEditingPassword) {
        _clearAllFields();
      }
    });
  }

  // تبديل وضع الساعات المكتبية
  void _toggleEditOfficeHoursMode() {
    setState(() {
      _isEditingOfficeHours = !_isEditingOfficeHours;
      if (_isEditingOfficeHours) {
        // إغلاق الأقسام الأخرى
        _isEditingPassword = false;
        _isEditingCourses = false;
      }
    });
  }

  // تبديل وضع المواد الدراسية
  void _toggleEditCoursesMode() {
    setState(() {
      _isEditingCourses = !_isEditingCourses;
      if (_isEditingCourses) {
        // إغلاق الأقسام الأخرى
        _isEditingPassword = false;
        _isEditingOfficeHours = false;
        // تحميل الدورات عند فتح قسم المواد الدراسية
        _loadAvailableCourses();
      } else {
        // تنظيف الدورات المختارة عند الإغلاق
        _selectedCourses.clear();
      }
    });
  }

  void _switchToResetMode() {
    setState(() {
      _isResetMode = true;
      _clearAllFields();
    });
  }

  void _switchToNormalMode() {
    setState(() {
      _isResetMode = false;
      _clearAllFields();
    });
  }

  void _clearAllFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _resetCodeController.clear();
  }

  // دالة لتحميل الدورات المتاحة
  Future<void> _loadAvailableCourses() async {
    try {
      if (_currentUser == null) return;
      
      final semesterRepo = RepositoryProvider.of<SemesterRepository>(context, listen: false);
      final doctorCourses = await semesterRepo.getCoursesByGroupDoctor(_currentUser!.userID);
      
      print('✅ تم تحميل ${doctorCourses.length} دورة متاحة');
      
      // يمكنك حفظ الدورات في حالة إذا كنت بحاجة إليها في مكان آخر
    } catch (e) {
      print('❌ خطأ في تحميل الدورات المتاحة: $e');
    }
  }

  // تغيير صورة الملف الشخصي
  Future<void> _changeProfileImage() async {
    setState(() => _isChangingImage = true);
    print('🔄 بدء _changeProfileImage - userModel.urlImg: ${_currentUser!.urlImg != null}');
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديد الصورة'),
        content: const Text('الصورة الشخصية'),
        actions: [
          // 🔥 زر إزالة الصورة (يظهر فقط إذا كانت هناك صورة حالية)
        if (_currentUser!.urlImg != null && _currentUser!.urlImg!.isNotEmpty)
          TextButton(
            onPressed: () {
              print('🗑️ اختيار إزالة الصورة الحالية');
              Navigator.pop(context, 'remove');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إزالة الصورة'),
          ),
          TextButton(
            onPressed: () {
              print('📁 اختيار الصورة من المعرض');
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
            child: const Text('المعرض'),
          ),
          TextButton(
            onPressed: () {
              print('📷 اختيار الصورة من الكاميرا');
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
            child: const Text('الكاميرا'),
          ),
        ],
      ),
  ).then((value) async {
  print('🔄 قيمة الإرجاع من الـ Dialog: $value');
    if (value == 'remove') {
    print('🎯 استدعاء removeProfilePicture...');
      // 🔥 استدعاء دالة إزالة الصورة
      final actions = UserProfileActions(context, _currentUser!);
      await actions.removeProfilePicture();
    print('✅ انتهى استدعاء removeProfilePicture');
    }
    }
  );
    setState(() => _isChangingImage = false);
  }

Future<void> _pickImage(ImageSource source) async {
    final myUserBloc = context.read<MyUserBloc>();
    final currentUser = myUserBloc.state.user;
    print('📸 بدء اختيار الصورة من $source');
    print('📱 معرف المستخدم: ${currentUser?.userID ?? "غير متوفر"}');
    
    if (currentUser == null || currentUser.userID.isEmpty) {
      print('❌ خطأ: بيانات المستخدم غير متوفرة');
      return;
    }

    final actions = UserProfileActions(context, currentUser);
    await actions.pickImage(source);
  }
  // 🔥 دالة السحب للتحديث
  Future<void> _handleRefresh() async {
    print('🔄 سحب يدوي لتحديث البروفايل');
    // إعادة تحميل بيانات المستخدم
    context.read<MyUserBloc>().add(GetMyUser());
    // انتظار اكتمال التحديث
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  void _printOfficeHoursInfo() {
  print('🔍 === معلومات الساعات المكتبية ===');
  print('👤 معرّف الأستاذ: ${_currentUser?.userID}');
  print('📊 عدد الساعات المؤقتة: ${_officeHoursToAdd.length}');
  print('📊 عدد الساعات الموجودة: ${_existingOfficeHours.length}');
  
  if (_officeHoursToAdd.isNotEmpty) {
    print('📋 الساعات الجديدة:');
    for (var i = 0; i < _officeHoursToAdd.length; i++) {
      final hour = _officeHoursToAdd[i];
      print('  ${i + 1}. ${hour.dayOfWeek}: ${hour.startTime} - ${hour.endTime}');
    }
  }
}

  // حفظ الساعات المكتبية
  void _saveOfficeHours() {
    _printOfficeHoursInfo();
  if (_currentUser == null || _officeHoursToAdd.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
    ShowWidget.showMessage(
      context,
      'الرجاء إضافة ساعات مكتبية على الأقل',
      ColorsApp.orange,
      font13White,
    );
  });
      return;
    }
    // تنظيف القائمة المؤقتة بعد الإرسال
    setState(() {
        _officeHoursToAdd.clear();
    });
    // إرسال حدث إضافة الساعات المكتبية
    context.read<TeacherDataBloc>().add(
      AddOfficeHoursEvent(
        teacherId: _currentUser!.userID,
        officeHoursList: _officeHoursToAdd,
      ),
    );
  
    // استخدام addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
    ShowWidget.showMessage(
      context,
      'جاري حفظ الساعات المكتبية...',
      ColorsApp.primaryColor,
      font13White,
      );
    });
  }

  // حفظ المواد الدراسية
  void _saveTeachingCourses() {
    if (_currentUser == null || _selectedCourses.isEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار مادة واحدة على الأقل', style: font13White),
          backgroundColor: ColorsApp.orange,
        ),
      );
    });
    return;
  }
  
  // تحويل CoursesModel إلى TeachingCourseModel
  final teachingCourses = _selectedCourses.map((course) {
    return TeachingCourseModel(
      id: '', // سيتم توليده في الـ Repository
      courseCode: course.codeCs,
      courseName: course.name,
    );
  }).toList();

  // إرسال حدث لتحديث المواد الدراسية
  context.read<TeacherDataBloc>().add(
    UpdateTeachingCoursesEvent(
      teacherId: _currentUser!.userID,
      courses: teachingCourses,
    ),
  );
  }

  // تحميل المواد الدراسية
  void _loadTeachingCourses() {
    if (_currentUser == null) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
    ShowWidget.showMessage(
      context,
      'جاري تحميل المواد الدراسية...',
      ColorsApp.primaryColor,
      font13White,
    );
  });
  }

  // دالة حذف جميع المواد الدراسية
void _deleteAllTeachingCourses() {
  if (_currentUser == null) return;
  
  print('🗑️ طلب حذف جميع المواد الدراسية');
  
  // إرسال حدث حذف جميع المواد الدراسية
  context.read<TeacherDataBloc>().add(
    DeleteAllTeachingCoursesEvent(_currentUser!.userID),
  );
  
  // تنظيف القائمة المختارة
  setState(() {
    _selectedCourses.clear();
  });
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ShowWidget.showMessage(
      context,
      'جاري حذف جميع المواد الدراسية...',
      ColorsApp.primaryColor,
      font13White,
    );
  });
}

  // دالة لتحديث الدورات المختارة (سيتم استدعاؤها من مكون المواد الدراسية)
  void _updateSelectedCourses(List<CoursesModel> courses) {
    setState(() {
      _selectedCourses = courses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        _currentUser = myUserState.user ?? UserModels.empty;
        final actions = UserProfileActions(context, _currentUser!);
        
        return Builder(
          builder: (context) {
            return MultiBlocListener(
              listeners: [
                BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
                  listener: (context, state) {
                    if (state is RemovePictureSuccess || state is UploadPictureSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshIndicatorKey.currentState?.show();
                      });
                    }
                  },
                ),
                BlocListener<TeacherDataBloc, TeacherDataState>(
                  listener: (context, state) {
                    print('🎧 TeacherDataBloc State: ${state.runtimeType}');
                    if (state is TeacherDataOperationSuccess) {
                      print('✅ نجاح العملية: ${state.message}');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                      ShowWidget.showMessage(
                          context,
                          state.message,
                          ColorsApp.green,
                          font13White,
                        );
                      if (state.message.contains('المواد الدراسية')) {
                        setState(() {
                          _isEditingCourses = false;
                          _selectedCourses.clear(); // تنظيف القائمة بعد الحفظ
                        });
                      }
                      });
                    } else if (state is TeacherDataError) {
                      print('❌ خطأ في العملية: ${state.message}');
                      ShowWidget.showMessage(
                          context,
                          state.message,
                          ColorsApp.red,
                          font13White,
                        );
                    }
                  },
                ),
              ],
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                child: UserProfileListeners(
                  onToggleEditPasswordMode: _toggleEditPasswordMode,
                  onLogoutSuccess: () => context.pushAndRemoveUntil(Routes.onboarding),
                  child: UserProfileContent(
                    userModel: _currentUser!,
                    isEditingPassword: _isEditingPassword,
                    isEditingOfficeHours: _isEditingOfficeHours,
                    isEditingCourses: _isEditingCourses,
                    isChangingImage: _isChangingImage,
                    isResetMode: _isResetMode,
                    selectedImagePath: _selectedImagePath,
                    selectedCourses: _selectedCourses,
                    currentPasswordController: _currentPasswordController,
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    resetCodeController: _resetCodeController,
                    onToggleEditPasswordMode: _toggleEditPasswordMode,
                    onToggleEditOfficeHoursMode: _toggleEditOfficeHoursMode,
                    onToggleEditCoursesMode: _toggleEditCoursesMode,
                    onChangeImage: _changeProfileImage,
                    onLogout: () => actions.logoutUser(),
                    onSendResetCode: () => actions.sendResetCode(),
                    onVerifyResetCode: () => actions.verifyResetCode(_resetCodeController.text),
                    onChangePassword: () => actions.changePassword(
                      currentPassword: _currentPasswordController.text,
                      newPassword: _newPasswordController.text,
                      confirmPassword: _confirmPasswordController.text,
                    ),
                    onResetPasswordWithCode: () => actions.resetPasswordWithCode(
                      code: _resetCodeController.text,
                      newPassword: _newPasswordController.text,
                      confirmPassword: _confirmPasswordController.text,
                    ),
                    onSwitchToNormalMode: _switchToNormalMode,
                    onSwitchToResetMode: _switchToResetMode,
                    onSaveOfficeHours: _saveOfficeHours,
                    onSaveTeachingCourses: _saveTeachingCourses,
                    onDeleteAllTeachingCourses: _deleteAllTeachingCourses,
                    onLoadTeachingCourses: _loadTeachingCourses,
                    onUpdateSelectedCourses: _updateSelectedCourses,
                    onRefresh: _handleRefresh,
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}