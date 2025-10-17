import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:myproject/features/profile/view/widget/user_profile_actions.dart';
import 'package:myproject/features/profile/view/widget/user_profile_content.dart';
import 'package:myproject/features/profile/view/widget/user_profile_listeners.dart';
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
  bool _isChangingImage = false;
  bool _isResetMode = false;
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        _currentUser  = myUserState.user ?? UserModels.empty;
        final actions = UserProfileActions(context, _currentUser! );
        print('🖼️ عرض محتوى الملف الشخصي للمستخدم: ${_currentUser }');
        
    return Builder(
      builder: (context) {
        return BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
            listener: (context, state) {
              print('🔔 Direct Listener - State: ${state.runtimeType}');
              
              if (state is RemovePictureSuccess || state is UploadPictureSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshIndicatorKey.currentState?.show();
                });
              }
            },
            child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child: UserProfileListeners(
                      onToggleEditPasswordMode: _toggleEditPasswordMode,
                      onLogoutSuccess: () => context.pushAndRemoveUntil(Routes.onboarding),
                      child: UserProfileContent(
            userModel: _currentUser!,
            isEditingPassword: _isEditingPassword,
            isChangingImage: _isChangingImage,
            isResetMode: _isResetMode,
            selectedImagePath: _selectedImagePath,
            currentPasswordController: _currentPasswordController,
            newPasswordController: _newPasswordController,
            confirmPasswordController: _confirmPasswordController,
            resetCodeController: _resetCodeController,
            onToggleEditPasswordMode: _toggleEditPasswordMode,
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