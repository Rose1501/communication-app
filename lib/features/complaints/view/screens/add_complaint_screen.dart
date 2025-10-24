import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart'; 
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:myproject/features/complaints/view/complaints_data.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

class AddComplaintScreen extends StatefulWidget {
  final UserModels currentUser;

  const AddComplaintScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedTargetRole = 'Admin';
  bool _showStudentInfo = true;
  bool _isLoading = false;
  bool _hasNavigatedBack = false;

  // قائمة الأدوار المستهدفة
  final List<String> _targetRoles = [
    'Admin',
    'Manager',
  ];

  void _safePopBack() {
    if (!_hasNavigatedBack && mounted) {
      _hasNavigatedBack = true;
      Navigator.pop(context, true);
    }
  }

  // 📤 تقديم الشكوى
  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // إنشاء شكوى جديدة
        final complaint = ComplaintModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          status: 'pending',
          studentID: widget.currentUser.userID,
          studentName: widget.currentUser.name,
          showStudentInfo: _showStudentInfo,
          targetRole: _selectedTargetRole,
          createdAt: DateTime.now(),
        );

        print('🚀 إرسال شكوى جديدة:');
        print('   - العنوان: ${complaint.title}');
        print('   - المستهدف: ${complaint.targetRole}');
        print('   - عرض البيانات: ${complaint.showStudentInfo}');

        // إضافة الشكوى عبر الـ BLoC
        context.read<ComplaintBloc>().add(
          SendComplaintEvent(complaint),
        );

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إضافة الشكوى: $e')),
        );
      }
    }
  }

  // تحويل قيمة الدور لنص مقروء
  String _getRoleDisplayText(String role) {
    switch (role) {
      case 'Manager':
        return 'مدير القسم ';
      case 'Admin':
        return 'الدراسة و الامتحانات';
      default:
        return role;
    }
  }

  Widget _buildSubmitButton() {
    return Center(
      child: _isLoading
          ? const CupertinoActivityIndicator(radius: 15)
          : ElevatedButton(
              onPressed: _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'إضافة الشكوى',
                style: font16White,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintSuccess) {
          print('✅ تم إرسال الشكوى بنجاح - العودة للشاشة السابقة');
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال الشكوى بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          
          // العودة بعد تأخير بسيط
          Future.delayed(const Duration(milliseconds: 500), () {
            _safePopBack();
          });
        } else if (state is ComplaintFailure) {
          print('❌ فشل إرسال الشكوى: ${state.error}');
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في إرسال الشكوى: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBarTitle(title: "إرسال شكوى "),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.10,
                  child: Center(
                    child: Image.asset(
                      color: ColorsApp.primaryColor,
                      ComplaintsData.complaints,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getHeight( 10),
                      Text('شاركنا مشكلتك', style: font18blackbold),
                      getHeight( 5),
                      Text(
                        'أخبرنا عن المشكلة التي تواجهك بدقة وسنعمل على حلها في أسرع وقت',
                        style: font12black,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                getHeight( 10),
                // حقل العنوان
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الشكوى',
                    border: OutlineInputBorder(),
                    hintText: 'أدخل عنواناً واضحاً للشكوى',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال عنوان الشكوى';
                    }
                    if (value.length < 3) {
                      return 'العنوان يجب أن يكون على الأقل 2 أحرف';
                    }
                    return null;
                  },
                ),
                
                getHeight(16),
                // اختيار الدور المستهدف
                DropdownButtonFormField<String>(
                  value: _selectedTargetRole,
                  items: _targetRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayText(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTargetRole = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'موجهة إلى',
                    border: OutlineInputBorder(),
                    hintText: 'اختر المسؤول المناسب',
                  ),
                ),

                getHeight(16),

                // اختيار عرض بيانات الطالب
                SwitchListTile(
                  title:  Text('عرض بياناتك في الشكوى',style: font15bold,),
                  subtitle:  Text('سيتم إخفاء اسمك إذا قمت بإلغاء التحديد',style: font12black,),
                  value: _showStudentInfo,
                  onChanged: (value) {
                    setState(() {
                      _showStudentInfo = value;
                    });
                  },
                  activeColor: ColorsApp.primaryColor,
                ),

                getHeight(16),
                
                // حقل الوصف
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'وصف الشكوى',
                    border: OutlineInputBorder(),
                    hintText: 'صف مشكلتك بالتفصيل...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال وصف الشكوى';
                    }
                    if (value.length < 10) {
                      return 'الوصف يجب أن يكون على الأقل 10 أحرف';
                    }
                    return null;
                  },
                ),
                
                getHeight(40),
                
                // زر الإرسال
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}