import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/bloc/user/user_bloc.dart';
import 'package:user_repository/user_repository.dart';

/// شاشة إدارة المشرفين
/// تسمح بتوليد كود الانضمام واختيار المشرفين للمشاريع
class SupervisorManagementScreen extends StatefulWidget {
  const SupervisorManagementScreen({super.key});

  @override
  State<SupervisorManagementScreen> createState() => _SupervisorManagementScreenState();
}

class _SupervisorManagementScreenState extends State<SupervisorManagementScreen> {
  String _generatedCode = '';
  final Set<String> _selectedDoctorIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تحميل قائمة الأطباء عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(GetUsersByIdsOrRole(role:'Doctor'));
      // تحميل إعدادات المشروع للحصول على كود الانضمام الحالي
      context.read<ProjectBloc>().add(GetProjectSettings());
    });
  }

  /// توليد كود انضمام جديد
  void _generateNewCode() {
    setState(() { _isLoading = true; });
    context.read<ProjectBloc>().add(GenerateJoinCodeEvent());
  }

  /// نسخ الكود إلى الحافظة
  void _copyToClipboard() {
    if (_generatedCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedCode));
      ShowWidget.showMessage(context, 'تم نسخ الكود: $_generatedCode', Colors.green, font13White);
    }
  }

  /// تعيين المشرفين المختارين
void _assignSupervisors() {
  if (_selectedDoctorIds.isEmpty) {
    ShowWidget.showMessage(context, 'يرجى اختيار مشرف واحد على الأقل', Colors.orange, font13White);
    return;
  }
  
  // عرض مربع تأكيد
  CustomDialog.showConfirmation(
    context: context,
    title: 'تعيين المشرفين',
    message: 'سيتم تعيين ${_selectedDoctorIds.length} مشرفين للمشاريع الجديدة.',
    confirmText: 'موافق',
    cancelText: 'إلغاء',
  ).then((confirmed) {
    if (confirmed) {
      // إضافة كل مشرف محدد على حدة
      for (final doctorId in _selectedDoctorIds) {
        // البحث عن المستخدم في قائمة المستخدمين المحملة
        final userState = context.read<UserBloc>().state;
        if (userState is UsersLoaded) {
          final doctor = userState.users.firstWhere(
            (user) => user.userID == doctorId,
            orElse: () => UserModels.empty,
          );
          
          if (doctor.userID.isNotEmpty) {
            // إضافة المشرف إلى إعدادات المشروع
            context.read<ProjectBloc>().add(AddAdminUser(user: doctor));
          }
        }
      }
      
      // إفراغ قائمة المحددين بعد الحفظ
      setState(() {
        _selectedDoctorIds.clear();
      });
      
      ShowWidget.showMessage(context, 'تم إضافة المشرفين بنجاح', Colors.green, font13White);
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'إدارة المشرفين'),
      body: MultiBlocListener(
        listeners: [
          // مستمع لأحداث ProjectBloc
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is JoinCodeGenerated) {
                setState(() {
                  _generatedCode = state.joinCode;
                  _isLoading = false;
                });
                // تحديث كود الانضمام في إعدادات المشروع
                context.read<ProjectBloc>().add(UpdateJoinCode(newJoinCode: state.joinCode));
                ShowWidget.showMessage(context, 'تم توليد كود جديد', Colors.green, font13White);
              }
              if (state is ProjectSettingsLoaded) {
                setState(() {
                  _generatedCode = state.settings.joinCode;
                });
              }
              if (state is ProjectError) {
                setState(() { _isLoading = false; });
                ShowWidget.showMessage(context, state.error, Colors.red, font13White);
              }
            },
          ),
        ],
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
            }
            if (state is UsersLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildCodeGeneratorCard(),
                    const SizedBox(height: 20),
                    _buildDoctorSelectionList(state.users),
                  ],
                ),
              );
            }
            return const Center(child: Text('حدث خطأ ما'));
          },
        ),
      ),
    );
  }

  /// بناء بطاقة توليد الكود
  Widget _buildCodeGeneratorCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.vpn_key, size: 50, color: ColorsApp.primaryColor),
            const SizedBox(height: 16),
            Text(
              'كود البحث للمشاريع',
              style: font20blackbold,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكن للطلاب استخدام هذا الكود للانضمام إلى المشاريع التي تشرف عليها.',
              style: font14grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_generatedCode.isEmpty)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateNewCode,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh),
                label: Text('توليد كود جديد'),
                style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _generatedCode,
                      style: font18blackbold.copyWith(letterSpacing: 2.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, color: Colors.black),
                          label: Text('نسخ الكود',style: font13black,),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateNewCode,
                          icon:  Icon(Icons.new_label,color: ColorsApp.white,),
                          label:  Text('كود جديد',style: font13White,),
                          style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
                        ),
                      ),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// بناء قائمة اختيار الأطباء
  Widget _buildDoctorSelectionList(List<UserModels> doctors) {
    return Expanded(
      child: doctors.isEmpty
          ? const Center(child: Text('لا يوجد أطباء مسجلون حالياً'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'اختر المشرفين',
                        style: font18blackbold,
                      ),
                      const Spacer(),
                      if (_selectedDoctorIds.isNotEmpty)
                        TextButton(
                          onPressed: _assignSupervisors,
                          child: Text(
                            'تعيين (${_selectedDoctorIds.length})',
                            style: font16White.copyWith(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsApp.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final isSelected = _selectedDoctorIds.contains(doctor.userID);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          checkColor: ColorsApp.primaryColor,
                          activeColor: ColorsApp.primaryColor.withOpacity(0.2),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDoctorIds.add(doctor.userID);
                              } else {
                                _selectedDoctorIds.remove(doctor.userID);
                              }
                            });
                          },
                          title: Text(doctor.name, style: font16black),
                          //subtitle: Text('رقم القيد: ${doctor.userID}', style: font14grey),
                          secondary: CircleAvatar(
                            backgroundColor: ColorsApp.primaryColor,
                            child: Text(doctor.name[0], style: font16White),
                          ),
                        ),
                      );
                    }),
                ),
              ],
            ),
    );
  }
}