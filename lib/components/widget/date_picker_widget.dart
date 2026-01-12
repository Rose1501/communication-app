import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  
  final List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month;
    _selectedYear = widget.initialDate.year;
  }

  void _incrementDay() {
    setState(() {
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      _selectedDay = _selectedDay < daysInMonth ? _selectedDay + 1 : 1;
    });
  }

  void _decrementDay() {
    setState(() {
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      _selectedDay = _selectedDay > 1 ? _selectedDay - 1 : daysInMonth;
    });
  }

  void _incrementMonth() {
    setState(() {
      _selectedMonth = _selectedMonth < 12 ? _selectedMonth + 1 : 1;
      if (_selectedMonth == 1) _selectedYear++;
      
      // تصحيح اليوم إذا كان أكبر من أيام الشهر الجديد
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
      }
    });
  }

  void _decrementMonth() {
    setState(() {
      _selectedMonth = _selectedMonth > 1 ? _selectedMonth - 1 : 12;
      if (_selectedMonth == 12) _selectedYear--;
      
      // تصحيح اليوم إذا كان أكبر من أيام الشهر الجديد
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
      }
    });
  }

  void _incrementYear() {
    setState(() {
      _selectedYear++;
    });
  }

  void _decrementYear() {
    setState(() {
      _selectedYear--;
    });
  }

  void _confirmSelection() {
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    Navigator.pop(context, selectedDate);
  }

  void _cancelSelection() {
    Navigator.pop(context);
  }

  Widget _buildNumberPicker({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: font14black.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorsApp.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // زر الزيادة
                InkWell(
                  onTap: onIncrement,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_drop_up,
                      color: ColorsApp.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                
                // حقل الإدخال
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: font18blackbold,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final newValue = int.tryParse(value) ?? (value.isEmpty ? 0 : _selectedDay);
                      if (label == 'اليوم' && newValue >= 1 && newValue <= 31) {
                        setState(() {
                          _selectedDay = newValue;
                        });
                      } else if (label == 'الشهر' && newValue >= 1 && newValue <= 12) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                      } else if (label == 'السنة' && newValue >= 1900 && newValue <= 2100) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      }
                    },
                  ),
                ),
                
                // زر النقصان
                InkWell(
                  onTap: onDecrement,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: ColorsApp.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final dayController = TextEditingController(text: _selectedDay.toString());
  final monthController = TextEditingController(text: _selectedMonth.toString());
  final yearController = TextEditingController(text: _selectedYear.toString());

  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر التاريخ',
              style: font20blackbold.copyWith(color: ColorsApp.primaryColor),
            ),
            const SizedBox(height: 20),
            
            // المربعات الثلاثة
            Row(
              children: [
                // اليوم
                _buildNumberPicker(
                  label: 'اليوم',
                  value: _selectedDay,
                  onIncrement: _incrementDay,
                  onDecrement: _decrementDay,
                  controller: dayController,
                ),
                const SizedBox(width: 12),
                
                // الشهر
                _buildNumberPicker(
                  label: 'الشهر',
                  value: _selectedMonth,
                  onIncrement: _incrementMonth,
                  onDecrement: _decrementMonth,
                  controller: monthController,
                ),
                const SizedBox(width: 12),
                
                // السنة
                _buildNumberPicker(
                  label: 'السنة',
                  value: _selectedYear,
                  onIncrement: _incrementYear,
                  onDecrement: _decrementYear,
                  controller: yearController,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // اسم الشهر الحالي
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsApp.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _months[_selectedMonth - 1],
                style: font16blackbold.copyWith(color: ColorsApp.primaryColor),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // التاريخ المحدد
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: ColorsApp.primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_selectedDay ${_months[_selectedMonth - 1]} $_selectedYear',
                style: font18blackbold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // الأزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelSelection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: font14black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsApp.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'تأكيد',
                      style: font13White,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
  @override
  void dispose() {
    // تنظيف الـ controllers
    TextEditingController().dispose();
    TextEditingController().dispose();
    TextEditingController().dispose();
    super.dispose();
  }
}