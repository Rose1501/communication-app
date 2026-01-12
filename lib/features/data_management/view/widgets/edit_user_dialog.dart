import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:user_repository/user_repository.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';

class EditUserDialog extends StatefulWidget {
  final UserModels user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIDController = TextEditingController();
  String _selectedRole = 'Student';
  String _selectedGender = 'Male';
  String _originalUserID = '';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _userIDController.text = widget.user.userID;
    _selectedRole = widget.user.role;
    _originalUserID = widget.user.userID;
    _selectedGender = _convertGenderToEnglish(widget.user.gender);
  }

  // 🔥 دالة لتحويل الجنس من العربية إلى الإنجليزية
  String _convertGenderToEnglish(String gender) {
    switch (gender.toLowerCase()) {
      case 'ذكر': return 'Male';
      case 'أنثى': return 'Female';
      case 'male': return 'Male';
      case 'female': return 'Female';
      default: return 'Male';
    }
  }

  // 🔥 دالة لتحويل الجنس من الإنجليزية إلى العربية للعرض
  String _convertGenderToArabic(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return 'ذكر';
      case 'Male': return 'ذكر';
      case 'female': return 'أنثى';
      case 'Female': return 'أنثى';
      default: return gender;
    }
  }

  // 🔥 دالة لتحويل الدور من الإنجليزية إلى العربية للعرض
  String _convertRoleToArabic(String role) {
    switch (role.toLowerCase()) {
      case 'Admin': return 'دراسة و الامتحانات';
      case 'admin': return 'دراسة و الامتحانات';
      case 'Manager': return 'مدير';
      case 'manager': return 'مدير';
      case 'Doctor': return 'دكتور';
      case 'doctor': return 'دكتور';
      case 'Student': return 'طالب';
      case 'student': return 'طالب';
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تعديل بيانات المستخدم', style: font18blackbold),
              SizedBox(height: 24.h),
              CustomTextFiled(
                hintText: 'رقم القيد',
                controller: _userIDController,
                validator: _validateField,
              ),
              SizedBox(height: 16.h),
                
              CustomTextFiled(
                hintText: 'الاسم',
                controller: _nameController,
                validator: _validateField,
              ),
              SizedBox(height: 16.h),
              
              CustomTextFiled(
                hintText: 'البريد الإلكتروني',
                controller: _emailController,
                validator: _validateEmail,
              ),
              SizedBox(height: 16.h),
              
              _buildDropdowns(),
              SizedBox(height: 24.h),
              
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدور', style: font14black),
            SizedBox(height: 8.h),
            CustomDropdown(
              items: const ['Admin', 'Manager', 'Doctor', 'Student'],
              hint: _convertRoleToArabic(_selectedRole),
              onChanged: (value) => setState(() => _selectedRole = value ?? 'Student'),
              displayMapper: (value) => _convertRoleToArabic(value),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الجنس', style: font14black),
            SizedBox(height: 8.h),
            CustomDropdown(
              items: const ['Male', 'Female'],
              hint: _convertGenderToArabic(_selectedGender),
              onChanged: (value) => setState(() => _selectedGender = value ?? 'Male'),
              displayMapper: (value) => _convertGenderToArabic(value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            child: Text('إلغاء', style: font15primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ButtonApp(
            textData: 'حفظ',
            onTop: _updateUser,
          ),
        ),
      ],
    );
  }

  String? _validateField(String? value) {
    return (value?.isEmpty ?? true) ? 'هذا الحقل مطلوب' : null;
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'البريد الإلكتروني مطلوب';
    if (!value!.contains('@')) return 'بريد إلكتروني غير صالح';
    return null;
  }

  void _updateUser() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        userID: _userIDController.text,
        role: _selectedRole,
        gender: _selectedGender,
      );
      
      context.read<UserManagementBloc>().add(UpdateUser(
        user: updatedUser,
        originalUserID: _originalUserID,
        ));
      Navigator.pop(context);
    }
  }
}