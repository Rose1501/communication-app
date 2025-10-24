import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myproject/features/request/view/widget/request_filter_utils.dart';

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
    _focusedDay = DateTime.now();
  }

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
        _endDate = selectedDay; // نفس اليوم للنهاية
      }
    });

    widget.onDateRangeSelected(_startDate, _endDate);
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onDateRangeSelected(null, null);
  }

  void _toggleSelectionMode() {
    setState(() {
      _rangeSelectionMode = _rangeSelectionMode == RangeSelectionMode.toggledOn
          ? RangeSelectionMode.disabled
          : RangeSelectionMode.toggledOn;
      
      // إذا تحولنا إلى وضع اليوم الواحد، نجعل النهاية نفس البداية
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
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
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
            
            // 🔥 زر تبديل وضع الاختيار
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
            
            // التقويم
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
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDay(day);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildSelectedDay(day);
                },
                rangeStartBuilder: (context, day, focusedDay) {
                  return _buildRangeStartDay(day);
                },
                rangeEndBuilder: (context, day, focusedDay) {
                  return _buildRangeEndDay(day);
                },
                withinRangeBuilder: (context, day, focusedDay) {
                  return _buildWithinRangeDay(day);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildToday(day);
                },
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
            
            // الفترة المحددة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child:Column(
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
                      child: Text('مسح', selectionColor: ColorsApp.primaryColor,),
                    ),
                ],
              ),
            const SizedBox(height: 8),
                  Text(
                    RequestFilterUtils.formatDateRange(_startDate, _endDate),
                    style:  TextStyle(
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
            // أزرار الإجراء
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

  String _getSelectionTypeText() {
    if (_startDate == null && _endDate == null) return 'لم يتم اختيار تاريخ';
    if (_rangeSelectionMode == RangeSelectionMode.disabled) return 'يوم محدد';
    if (_startDate != null && _endDate == null) return 'فترة زمنية (اختر تاريخ النهاية)';
    if (_startDate != null && _endDate != null) return 'فترة زمنية محددة';
    return 'اختيار التاريخ';
  }

  Widget _buildDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: _getDayColor(day),
          ),
        ),
      ),
    );
  }

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
          style:  TextStyle(
            color: ColorsApp.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration:  BoxDecoration(
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

  Widget _buildRangeStartDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration:  BoxDecoration(
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

  Widget _buildRangeEndDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration:  BoxDecoration(
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

  Color _getDayColor(DateTime day) {
    if (day.weekday == DateTime.friday) {
      return ColorsApp.red;
    } else if (day.weekday == DateTime.saturday) {
      return ColorsApp.primaryColor;
    }
    return ColorsApp.blackDark;
  }

  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }
}