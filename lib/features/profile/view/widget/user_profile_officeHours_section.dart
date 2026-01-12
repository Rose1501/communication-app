import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_time_field.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

class UserProfileOfficeHoursSection extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const UserProfileOfficeHoursSection({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<UserProfileOfficeHoursSection> createState() => _UserProfileOfficeHoursSectionState();
}

class _UserProfileOfficeHoursSectionState extends State<UserProfileOfficeHoursSection> {
  bool _isAddMode = true;
  List<OfficeHoursModel> _existingHours = [];
  List<OfficeHoursModel> _officeHoursToAdd = [];
  
  final _dayController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  List<String> daysOfWeek = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء',
    'الخميس', 'الجمعة', 'السبت'
  ];
  
  String? _selectedDay;
  bool _isLoading = false;
  bool _isSaving = false; // حالة جديدة لتتبع عملية الحفظ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingHours();
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingHours() async {
    try {
      print('🔄 جلب الساعات المكتبية الحالية...');
      
      setState(() {
        _isLoading = true;
      });
      
      // استخدام الـ Bloc لجلب الساعات المكتبية
      context.read<TeacherDataBloc>().add(
        LoadOfficeHoursEvent(widget.teacherId),
      );
      
    } catch (e) {
      print('❌ خطأ في تحميل الساعات المكتبية: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('فشل في تحميل الساعات المكتبية: ${e.toString()}');
    }
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: font13White),
          backgroundColor: ColorsApp.red,
        ),
      );
    });
  }

  void _showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: font13White),
          backgroundColor: ColorsApp.green,
        ),
      );
    });
  }

  void _switchToAddMode() {
    setState(() {
      _isAddMode = true;
      _clearForm();
    });
  }

  void _switchToViewMode() {
    setState(() {
      _isAddMode = false;
    });
  }

  void _clearForm() {
    _selectedDay = null;
    _startTimeController.clear();
    _endTimeController.clear();
  }

  void _addOfficeHour() {
    print('➕ محاولة إضافة ساعة مكتبية جديدة');
    print('📝 اليوم: $_selectedDay');
    print('⏰ وقت البدء: ${_startTimeController.text}');
    print('⏰ وقت الانتهاء: ${_endTimeController.text}');
    
    if (_selectedDay == null || 
        _startTimeController.text.isEmpty || 
        _endTimeController.text.isEmpty) {
      _showError('الرجاء ملء جميع الحقول');
      return;
    }

    // تحقق من أن وقت الانتهاء بعد وقت البدء
    final startParts = _startTimeController.text.split(':');
    final endParts = _endTimeController.text.split(':');
    
    if (startParts.length == 2 && endParts.length == 2) {
      final startHour = int.tryParse(startParts[0]) ?? 0;
      final startMinute = int.tryParse(startParts[1]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 0;
      final endMinute = int.tryParse(endParts[1]) ?? 0;
      
      if (startHour > endHour || 
          (startHour == endHour && startMinute >= endMinute)) {
        _showError('وقت الانتهاء يجب أن يكون بعد وقت البدء');
        return;
      }
    }

    // إنشاء ساعة مكتبية جديدة
    final newHour = OfficeHoursModel(
      id: 'oh_${DateTime.now().millisecondsSinceEpoch}',
      dayOfWeek: _selectedDay!,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      createdAt: DateTime.now(),
    );

    print('✅ إنشاء ساعة مكتبية جديدة: $newHour');
    
    setState(() {
      _officeHoursToAdd.add(newHour);
      _clearForm();
    });
    
    _showSuccess('تمت إضافة الساعة المكتبية بنجاح');
  }

  void _removeOfficeHourToAdd(int index) {
    print('🗑️ حذف ساعة مكتبية مؤقتة في الفهرس: $index');
    
    setState(() {
      _officeHoursToAdd.removeAt(index);
    });
    
    _showSuccess('تم حذف الساعة المكتبية');
  }

  void _removeExistingHour(String officeHoursId) {
    // إرسال حدث حذف الساعة المكتبية
    context.read<TeacherDataBloc>().add(
      DeleteOfficeHoursEvent(
        teacherId: widget.teacherId,
        officeHoursId: officeHoursId,
      ),
    );
    
    _showSuccess('تم طلب حذف الساعة المكتبية');
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    print('⏰ اختيار الوقت - نوع: ${isStartTime ? "البدء" : "الانتهاء"}');
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final time = '$hour:$minute';
      
      setState(() {
        if (isStartTime) {
          _startTimeController.text = time;
        } else {
          _endTimeController.text = time;
        }
      });
    }
  }

  void _saveOfficeHours() {
    print('💾 محاولة حفظ الساعات المكتبية...');
    print('📊 عدد الساعات المضافة مؤقتاً: ${_officeHoursToAdd.length}');
    
    if (_officeHoursToAdd.isEmpty) {
      print('❌ لا توجد ساعات مكتبية للحفظ');
      _showError('الرجاء إضافة ساعات مكتبية على الأقل');
      return;
    }

    print('📋 الساعات المضافة:');
    for (var hour in _officeHoursToAdd) {
      print('  - ${hour.dayOfWeek}: ${hour.startTime} - ${hour.endTime}');
    }

    setState(() {
      _isSaving = true;
    });

    // إرسال حدث إضافة الساعات المكتبية
    context.read<TeacherDataBloc>().add(
      AddOfficeHoursEvent(
        teacherId: widget.teacherId,
        officeHoursList: List.from(_officeHoursToAdd), // نسخة جديدة من القائمة
      ),
    );
    
    _showSuccess('جاري حفظ الساعات المكتبية...');
  }

  // دالة لمعالجة نجاح الحفظ
  void _handleSaveSuccess() {
    print('🎉 تم حفظ الساعات المكتبية بنجاح');
    
    // تنظيف القائمة المؤقتة
    setState(() {
      _officeHoursToAdd.clear();
      _isSaving = false;
    });
    
    // إعادة تحميل الساعات الحالية من قاعدة البيانات
    _loadExistingHours();
    
    // التبديل إلى وضع العرض بعد 1 ثانية (لإعطاء وقت للتحديث)
    Future.delayed(const Duration(milliseconds: 500), () {
      _switchToViewMode();
    });
    
    _showSuccess('تم حفظ الساعات المكتبية بنجاح!');
  }

  // دالة لمعالجة فشل الحفظ
  void _handleSaveError(String error) {
    print('❌ فشل في حفظ الساعات المكتبية: $error');
    
    setState(() {
      _isSaving = false;
    });
    
    _showError('فشل في حفظ الساعات المكتبية: $error');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherDataBloc, TeacherDataState>(
      listener: (context, state) {
        print('🎧 State in OfficeHoursSection: ${state.runtimeType}');
        
        // الاستماع لتحميل الساعات
        if (state is OfficeHoursLoaded) {
          print('📥 تم تحميل ${state.officeHours.length} ساعة مكتبية');
          setState(() {
            _existingHours = state.officeHours;
            _isLoading = false;
          });
        }
        
        // الاستماع لنجاح عملية الحفظ
        if (state is TeacherDataOperationSuccess) {
          print('✅ نجاح العملية: ${state.message}');
          
          if (state.message.contains('الساعات المكتبية')) {
            _handleSaveSuccess();
          }
        }
        
        // الاستماع لأخطاء الحفظ
        if (state is TeacherDataError) {
          print('❌ خطأ في العملية: ${state.message}');
          
          if (state.message.contains('الساعات المكتبية')) {
            _handleSaveError(state.message);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Center(
              child: Text(
                ' الساعات المكتبية',
                style: fount14Bold.copyWith(color: ColorsApp.primaryColor),
              ),
            ),
            SizedBox(height: 16.h),

            // أزرار التبديل بين الوضعين
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:  _switchToAddMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddMode 
                          ? ColorsApp.primaryColor 
                          : Colors.grey[300],
                      foregroundColor: _isAddMode ? Colors.white : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'إضافة ساعات ',
                      style: _isAddMode ? font15White : font14black,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:  _switchToViewMode ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddMode 
                          ? Colors.grey[300] 
                          : ColorsApp.primaryColor,
                      foregroundColor: _isAddMode ? Colors.grey : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      ' الساعات الحالية',
                      style: _isAddMode ? font14black : font15White,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text('جاري تحميل الساعات المكتبية...', style: font14grey),
                  ],
                ),
              )
            else if (_isAddMode)
              _buildAddMode()
            else
              _buildViewMode(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMode() {
    return Column(
      children: [
        // نموذج إضافة ساعة مكتبية
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // اختيار اليوم
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: InputDecoration(
                    labelText: 'اليوم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.calendar_today, color: ColorsApp.primaryColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  items: daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day, style: font14black),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                
                // وقت البدء والانتهاء
                Row(
                  children: [
                    Expanded(
                      child: CustomTimeField(
                        hintText: 'وقت البدء',
                        controller: _startTimeController,
                        iconData: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context, true),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomTimeField(
                        hintText: 'وقت الانتهاء',
                        controller: _endTimeController,
                        iconData: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // زر إضافة الساعة
                ElevatedButton(
                  onPressed: _addOfficeHour,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    minimumSize: Size(double.infinity, 45.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18.w, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text('إضافة الساعة المكتبية', style: font15White),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 20.h),
        
        // قائمة الساعات المضافة مؤقتاً
        if (_officeHoursToAdd.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الساعات المضافة مؤقتاً (${_officeHoursToAdd.length})',
                style: font14black.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _officeHoursToAdd.length,
                itemBuilder: (context, index) {
                  final hour = _officeHoursToAdd[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Icon(Icons.access_time, color: ColorsApp.primaryColor),
                      title: Text('${hour.dayOfWeek}', style: font14black),
                      subtitle: Text('${hour.startTime} - ${hour.endTime}', style: font12Grey),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20.w),
                        onPressed: _isSaving ? null : () => _removeOfficeHourToAdd(index),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        
        SizedBox(height: 20.h),
        
        // أزرار الإجراءات
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: _isSaving 
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text('جاري الحفظ...', style: font14black),
                        ],
                      )
                    : Text('إلغاء', style: font14black),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving || _officeHoursToAdd.isEmpty ? null : _saveOfficeHours,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text('جاري الحفظ...', style: font15White),
                        ],
                      )
                    : Text(
                        'حفظ  ',
                        style: font15White,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewMode() {
    return Column(
      children: [
        // قائمة الساعات الحالية
        if (_existingHours.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.access_time, size: 60, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد ساعات مكتبية مضافة',
                  style: font16blackbold,
                ),
                SizedBox(height: 8.h),
                Text(
                  'اضغط على زر "إضافة ساعات جديدة" للإضافة',
                  style: font14grey,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: _switchToAddMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  ),
                  child: Text('إضافة ساعات مكتبية', style: font15White),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _existingHours.length,
            itemBuilder: (context, index) {
              final hour = _existingHours[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDayIcon(hour.dayOfWeek),
                      color: ColorsApp.primaryColor,
                      size: 20.w,
                    ),
                  ),
                  title: Text(
                    hour.dayOfWeek,
                    style: font14black.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${hour.startTime} - ${hour.endTime}',
                        style: font12Grey,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'تم الإضافة: ${_formatDate(hour.createdAt)}',
                        style: font10Grey,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20.w),
                    onPressed: () => _removeExistingHour(hour.id),
                  ),
                ),
              );
            },
          ),
        SizedBox(height: 52.h),
      ],
    );
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'الأحد':
        return Icons.calendar_today;
      case 'الاثنين':
        return Icons.date_range;
      case 'الثلاثاء':
        return Icons.event;
      case 'الأربعاء':
        return Icons.calendar_month;
      case 'الخميس':
        return Icons.event_note;
      case 'الجمعة':
        return Icons.weekend;
      case 'السبت':
        return Icons.weekend_outlined;
      default:
        return Icons.access_time;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }
}