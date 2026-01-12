import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/components/widget/date_picker_widget.dart'; // تأكد من المسار الصحيح
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';

/*
 * ✏️ نافذة تعديل الفصل الدراسي
 * 
 * الوظائف:
 * ✅ تعديل نوع الفصل
 * ✅ تعديل الفترة الزمنية
 * ✅ تعديل الساعات المعتمدة
 * ✅ حفظ التعديلات
 */

class EditSemesterDialog extends StatefulWidget {
  final SemesterModel semester;

  const EditSemesterDialog({super.key, required this.semester});

  @override
  State<EditSemesterDialog> createState() => _EditSemesterDialogState();
}

class _EditSemesterDialogState extends State<EditSemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minCreditsController = TextEditingController();
  final TextEditingController _maxCreditsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'ربيع';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// 🏁 تهيئة النموذج ببيانات الفصل الحالية
  void _initializeForm() {
    _selectedType = widget.semester.typeSemester;
    _startDate = widget.semester.startTime;
    _endDate = widget.semester.endTime;
    _minCreditsController.text = widget.semester.minCredits.toString();
    _maxCreditsController.text = widget.semester.maxCredits.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.r),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تعديل الفصل الدراسي', style: font18blackbold),
                SizedBox(height: 24.h),
                
                // 🎯 نوع الفصل
                _buildSemesterTypeSection(),
                SizedBox(height: 16.h),
                
                // 📅 الفترة الزمنية
                _buildDateRangeSection(),
                SizedBox(height: 16.h),
                
                // ⏰ الساعات المعتمدة
                _buildCreditsSection(),
                SizedBox(height: 24.h),
                
                // 🔘 أزرار الحفظ والإلغاء
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 قسم نوع الفصل الدراسي
  Widget _buildSemesterTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نوع الفصل', style: font16blackbold),
        SizedBox(height: 8.h),
        CustomDropdown(
          items: const ['ربيع', 'خريف', 'صيفي'],
          hint: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value ?? 'ربيع';
            });
          },
        ),
      ],
    );
  }

  /// 📅 قسم الفترة الزمنية
  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الفترة الزمنية', style: font16blackbold),
        SizedBox(height: 8.h),
        
        // عرض الفترة المحددة
        if (_startDate != null || _endDate != null) ...[
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: ColorsApp.primaryColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _formatDateRange(),
                    style: font14black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        
        // أزرار اختيار التواريخ
        Row(
          children: [
            Expanded(
              child: ButtonApp(
                textData: 'تاريخ البداية',
                onTop: () => _showStartDatePicker(context),
                boxDecoration: borderAllPrimary,
                textStyle: font15primary,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ButtonApp(
                textData: 'تاريخ النهاية',
                onTop: () => _showEndDatePicker(context),
                boxDecoration: borderAllPrimary,
                textStyle: font15primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ⏰ قسم الساعات المعتمدة
  Widget _buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الساعات المعتمدة', style: font16blackbold),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: CustomTextFiled(
                hintText: 'أقل ساعات',
                iconData: Icons.arrow_downward,
                controller: _minCreditsController,
                keyboardType: TextInputType.number,
                validator: _validateCredits,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextFiled(
                hintText: 'أكثر ساعات',
                iconData: Icons.arrow_upward,
                controller: _maxCreditsController,
                keyboardType: TextInputType.number,
                validator: _validateCredits,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔘 أزرار الإجراءات
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ButtonApp(
            textData: 'إلغاء',
            onTop: () => Navigator.pop(context),
            boxDecoration: bordererLinePrimary,
            textStyle: font15primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ButtonApp(
            textData: 'حفظ التعديلات',
            onTop: _updateSemester,
          ),
        ),
      ],
    );
  }

  /// 📅 عرض منتقي تاريخ البداية
  Future<void> _showStartDatePicker(BuildContext context) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePickerWidget(
        initialDate: _startDate ?? DateTime.now(),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        // إذا كان تاريخ النهاية قبل تاريخ البداية، تحديثه
        if (_endDate != null && _endDate!.isBefore(selectedDate)) {
          _endDate = selectedDate.add(const Duration(days: 30));
        }
      });
    }
  }

  /// 📅 عرض منتقي تاريخ النهاية
  Future<void> _showEndDatePicker(BuildContext context) async {
    final initialDate = _endDate ?? 
        (_startDate != null ? _startDate!.add(const Duration(days: 30)) : DateTime.now());
    
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePickerWidget(
        initialDate: initialDate,
      ),
    );

    if (selectedDate != null) {
      if (_startDate != null && selectedDate.isBefore(_startDate!)) {
        _showDateError('تاريخ النهاية يجب أن يكون بعد تاريخ البداية');
        return;
      }
      
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  /// 📝 تنسيق الفترة الزمنية للنص
  String _formatDateRange() {
    if (_startDate == null && _endDate == null) return 'لم يتم اختيار فترة';
    if (_startDate != null && _endDate == null) return 'من ${_formatDate(_startDate!)}';
    if (_startDate != null && _endDate != null) {
      return 'من ${_formatDate(_startDate!)} إلى ${_formatDate(_endDate!)}';
    }
    return 'الفترة الزمنية';
  }

  /// 📅 تنسيق التاريخ للنص
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// ✅ التحقق من صحة الساعات المعتمدة
  String? _validateCredits(String? value) {
    if (value?.isEmpty ?? true) return 'هذا الحقل مطلوب';
    if (int.tryParse(value!) == null) return 'يرجى إدخال رقم صحيح';
    
    final intValue = int.parse(value);
    if (intValue < 1) return 'يجب أن يكون الرقم أكبر من 0';
    if (intValue > 30) return 'الرقم كبير جداً';
    
    return null;
  }

  /// ⚠️ عرض رسالة خطأ في التاريخ
  void _showDateError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsApp.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 💾 تحديث بيانات الفصل الدراسي
  void _updateSemester() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_startDate == null || _endDate == null) {
      _showError('يرجى اختيار تاريخ البداية والنهاية');
      return;
    }

    final minCredits = int.parse(_minCreditsController.text);
    final maxCredits = int.parse(_maxCreditsController.text);
    
    if (maxCredits < minCredits) {
      _showError('أكثر ساعات يجب أن يكون أكبر أو يساوي أقل ساعات');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('تاريخ النهاية يجب أن يكون بعد تاريخ البداية');
      return;
    }

    _createUpdatedSemester();
  }

  /// ⚠️ عرض رسالة خطأ عامة
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsApp.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 🆕 إنشاء فصل دراسي معدل
  void _createUpdatedSemester() {
    final updatedSemester = widget.semester.copyWith(
      typeSemester: _selectedType,
      startTime: _startDate!,
      endTime: _endDate!,
      maxCredits: int.parse(_maxCreditsController.text),
      minCredits: int.parse(_minCreditsController.text),
    );
    
    context.read<DataManagementBloc>().add(UpdateSemester(updatedSemester));
    Navigator.pop(context);
  }
}