import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myproject/features/request/view/widget/request_filter_utils.dart';

/// نافذة حوار لاختيار نطاق تاريخ أو تاريخ واحد
class DateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  /// معالجة اختيار يوم في التقويم
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      
      if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
        // وضع الفترة الزمنية
        if (_startDate == null) {
          _startDate = selectedDay;
        } else if (_endDate == null && !selectedDay.isBefore(_startDate!)) {
          _endDate = selectedDay;
        } else {
          _startDate = selectedDay;
          _endDate = null;
        }
      } else {
        // وضع اليوم الواحد
        _startDate = selectedDay;
        _endDate = selectedDay;
      }
    });

    widget.onDateRangeSelected(_startDate, _endDate);
  }

  /// مسح جميع التواريخ المحددة
  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onDateRangeSelected(null, null);
  }

  /// تبديل بين وضع اليوم الواحد والفترة الزمنية
  void _toggleSelectionMode() {
    setState(() {
      _rangeSelectionMode = _rangeSelectionMode == RangeSelectionMode.toggledOn
          ? RangeSelectionMode.disabled
          : RangeSelectionMode.toggledOn;
      
      if (_rangeSelectionMode == RangeSelectionMode.disabled && _startDate != null) {
        _endDate = _startDate;
      }
    });
    
    widget.onDateRangeSelected(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView( // 🔥 الحل الرئيسي لمنع الـ overflow
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الحوار - العنوان وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اختر فترة زمنية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // زر تبديل وضع الاختيار
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _rangeSelectionMode == RangeSelectionMode.toggledOn
                        ? 'وضع الفترة الزمنية'
                        : 'وضع اليوم الواحد',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _rangeSelectionMode == RangeSelectionMode.toggledOn,
                    onChanged: (value) => _toggleSelectionMode(),
                    activeColor: ColorsApp.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // التقويم الرئيسي
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2050),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              onDaySelected: _onDaySelected,
              selectedDayPredicate: (day) {
                if (_rangeSelectionMode == RangeSelectionMode.disabled) {
                  return _isSameDay(_startDate, day);
                } else {
                  return _isSameDay(_startDate, day) || _isSameDay(_endDate, day);
                }
              },
              rangeStartDay: _rangeSelectionMode == RangeSelectionMode.toggledOn ? _startDate : null,
              rangeEndDay: _rangeSelectionMode == RangeSelectionMode.toggledOn ? _endDate : null,
              rangeSelectionMode: _rangeSelectionMode,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _buildDay(day),
                selectedBuilder: (context, day, focusedDay) => _buildSelectedDay(day),
                rangeStartBuilder: (context, day, focusedDay) => _buildRangeStartDay(day),
                rangeEndBuilder: (context, day, focusedDay) => _buildRangeEndDay(day),
                withinRangeBuilder: (context, day, focusedDay) => _buildWithinRangeDay(day),
                todayBuilder: (context, day, focusedDay) => _buildToday(day),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              locale: 'ar',
            ),
            const SizedBox(height: 16),
            
            // قسم عرض الفترة المحددة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSelectionTypeText(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_startDate != null || _endDate != null)
                        TextButton(
                          onPressed: _clearSelection,
                          child: Text(
                            'مسح',
                            style: TextStyle(color: ColorsApp.primaryColor),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    RequestFilterUtils.formatDateRange(_startDate, _endDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorsApp.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_rangeSelectionMode == RangeSelectionMode.disabled && _startDate != null)
                    Text(
                      'يوم ${RequestFilterUtils.getArabicDayName(_startDate!.weekday)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // أزرار الإجراء - إلغاء وتطبيق
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// نص يوضح نوع الاختيار الحالي
  String _getSelectionTypeText() {
    if (_startDate == null && _endDate == null) return 'لم يتم اختيار تاريخ';
    if (_rangeSelectionMode == RangeSelectionMode.disabled) return 'يوم محدد';
    if (_startDate != null && _endDate == null) return 'فترة زمنية (اختر تاريخ النهاية)';
    if (_startDate != null && _endDate != null) return 'فترة زمنية محددة';
    return 'اختيار التاريخ';
  }

  /// بناء واجهة اليوم العادي
  Widget _buildDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: _getDayColor(day)),
        ),
      ),
    );
  }

  /// بناء واجهة اليوم الحالي
  Widget _buildToday(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: ColorsApp.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// بناء واجهة اليوم المحدد
  Widget _buildSelectedDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// بناء واجهة بداية الفترة
  Widget _buildRangeStartDay(DateTime day) {
    return _buildSelectedDay(day); // نفس التصميم
  }

  /// بناء واجهة نهاية الفترة
  Widget _buildRangeEndDay(DateTime day) {
    return _buildSelectedDay(day); // نفس التصميم
  }

  /// بناء واجهة الأيام ضمن الفترة
  Widget _buildWithinRangeDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: ColorsApp.primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// تحديد لون النص بناءً على نوع اليوم
  Color _getDayColor(DateTime day) {
    if (day.weekday == DateTime.friday) {
      return ColorsApp.red;
    } else if (day.weekday == DateTime.saturday) {
      return ColorsApp.primaryColor;
    }
    return ColorsApp.blackDark;
  }

  /// مقارنة يومين
  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }
}