import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/components/widget/date_picker_widget.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';

/*
 * ➕ نافذة إضافة فصل دراسي جديد
 * 
 * الوظائف:
 * ✅ اختيار نوع الفصل (ربيع، خريف، صيفي)
 * ✅ تحديد الفترة الزمنية
 * ✅ إعداد الساعات المعتمدة
 * ✅ حفظ الفصل الجديد
 */

class AddSemesterDialog extends StatefulWidget {
  const AddSemesterDialog({super.key});

  @override
  State<AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<AddSemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minCreditsController = TextEditingController();
  final TextEditingController _maxCreditsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'ربيع';

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  /// 🗓️ تعيين التواريخ الافتراضية (الفصل الحالي)
  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = now;
    _endDate = now.add(const Duration(days: 120)); // 4 أشهر
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
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildSemesterTypeSection(),
                SizedBox(height: 16.h),
                _buildDateRangeSection(),
                SizedBox(height: 16.h),
                _buildCreditsSection(),
                SizedBox(height: 24.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ بناء رأس النافذة
  Widget _buildHeader() {
    return Text('إضافة فصل دراسي جديد', style: font18blackbold);
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
        _buildDateRangeDisplay(),
        SizedBox(height: 8.h),
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

  /// 📆 عرض الفترة المحددة
  Widget _buildDateRangeDisplay() {
    return Container(
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
    );
  }

  /// 📅 عرض منتقي تاريخ البداية
  void _showStartDatePicker(BuildContext context) async {
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
  void _showEndDatePicker(BuildContext context) async {
    final initialDate = _endDate ?? _startDate?.add(const Duration(days: 30)) ?? DateTime.now();
    
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

  Widget _buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الساعات المعتمدة', style: font16blackbold),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildMinCreditsField(),
            SizedBox(width: 12.w),
            _buildMaxCreditsField(),
          ],
        ),
      ],
    );
  }

  /// 🔽 حقل أقل ساعات
  Widget _buildMinCreditsField() {
    return Expanded(
      child: CustomTextFiled(
        hintText: 'أقل ساعات',
        iconData: Icons.arrow_downward,
        controller: _minCreditsController,
        keyboardType: TextInputType.number,
        validator: _validateCredits,
      ),
    );
  }

  /// 🔼 حقل أكثر ساعات
  Widget _buildMaxCreditsField() {
    return Expanded(
      child: CustomTextFiled(
        hintText: 'أكثر ساعات',
        iconData: Icons.arrow_upward,
        controller: _maxCreditsController,
        keyboardType: TextInputType.number,
        validator: _validateCredits,
      ),
    );
  }

  /// 🔘 أزرار الإجراءات
  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildCancelButton(),
        SizedBox(width: 12.w),
        _buildSaveButton(),
      ],
    );
  }

  /// ❌ زر الإلغاء
  Widget _buildCancelButton() {
    return Expanded(
      child: ButtonApp(
        textData: 'إلغاء',
        onTop: () => Navigator.pop(context),
        boxDecoration: bordererLinePrimary,
        textStyle: font15primary,
      ),
    );
  }

  /// 💾 زر الحفظ
  Widget _buildSaveButton() {
    return Expanded(
      child: ButtonApp(
        textData: 'حفظ',
        onTop: _saveSemester,
      ),
    );
  }

void _showDateError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: ColorsApp.red,
    ),
  );
}

  /// 📝 تنسيق الفترة الزمنية للنص
  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return 'لم يتم اختيار فترة';
    return 'من ${_formatDate(_startDate!)} إلى ${_formatDate(_endDate!)}';
  }

  /// 📅 تنسيق التاريخ للنص
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// ✅ التحقق من صحة الساعات المعتمدة
  String? _validateCredits(String? value) {
    if (value?.isEmpty ?? true) return 'هذا الحقل مطلوب';
    if (int.tryParse(value!) == null) return 'يرجى إدخال رقم صحيح';
    return null;
  }

  /// 💾 حفظ الفصل الدراسي الجديد
  void _saveSemester() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        _showDateRequiredError();
        return;
      }

      _createNewSemester();
    }
  }

  /// ⚠️ عرض خطأ عدم اختيار الفترة
  void _showDateRequiredError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('يرجى اختيار الفترة الزمنية'),
        backgroundColor: ColorsApp.red,
      ),
    );
  }

  /// 🆕 إنشاء فصل دراسي جديد
  void _createNewSemester() {
    final newSemester = SemesterModel(
      id: '',
      typeSemester: _selectedType,
      startTime: _startDate!,
      endTime: _endDate!,
      maxCredits: int.parse(_maxCreditsController.text),
      minCredits: int.parse(_minCreditsController.text),
      courses: [],
    );
    
    context.read<DataManagementBloc>().add(AddSemester(newSemester));
    Navigator.pop(context);
  }
}