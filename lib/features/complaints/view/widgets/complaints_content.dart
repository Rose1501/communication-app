import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/widget/date_range_picker.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:myproject/features/complaints/view/widgets/complaints_filter_panel.dart';
import 'package:myproject/features/complaints/view/widgets/complaints_list.dart';
import 'package:myproject/features/complaints/view/widgets/empty_complaints.dart';
import 'package:myproject/features/complaints/view/widgets/error_widget.dart';
import 'package:user_repository/user_repository.dart';

/// 📦 المكون الرئيسي لمحتوى الشكاوى
/// 🔄 يدير التحديث، الفلترة، وعرض القوائم
class ComplaintsContent extends StatefulWidget {
  final VoidCallback onRefresh;
  final UserModels user;

  const ComplaintsContent({
    super.key,
    required this.onRefresh,
    required this.user,
  });

  @override
  State<ComplaintsContent> createState() => _ComplaintsContentState();
}

class _ComplaintsContentState extends State<ComplaintsContent> {
  String _selectedFilter = 'الكل';
  DateTime? _startDate;
  DateTime? _endDate;
  final ScrollController _scrollController = ScrollController();
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  /// 👁️ إعداد مستمع لحركة السحب
  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  /// 🔄 تحديث حالة الإحصائيات بناءً على السحب
void _onPanelStateChanged(bool shouldShowStats) {
    setState(() {
      _showStats = shouldShowStats;
    });
}

  /// 🔄 التعامل مع حركة السحب إخفاء الإحصائيات
  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showStats) {
        setState(() => _showStats = false);
      }
    }
  }

  /// 🔄 سحب يدوي لتحديث الشكاوى
  Future<void> _handleRefresh() async {
    print('🔄 سحب يدوي لتحديث الشكاوى');
    widget.onRefresh();
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// 📅 فتح منتقي التاريخ
  void _openDatePicker() {
    showDialog(
      context: context,
      builder: (context) => DateRangePicker(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        onDateRangeSelected: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
        },
      ),
    );
  }

  /// 🗑️ مسح الفلترة الزمنية
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  /// 🎯 تصفية الشكاوى حسب الحالة والوقت
  List<ComplaintModel> _filterComplaints(List<ComplaintModel> complaints) {
    List<ComplaintModel> filtered = complaints;

    // التصفية حسب الحالة
    if (_selectedFilter != 'الكل') {
      filtered = filtered.where((complaint) {
        switch (_selectedFilter) {
          case 'في الانتظار':
            return complaint.status == 'pending';
          case 'قيد المعالجة':
            return complaint.status == 'in_progress';
          case 'تم الحل':
            return complaint.status == 'resolved';
          case 'مرفوض':
            return complaint.status == 'rejected';
          case 'تم الرد':
            return complaint.adminReply != null && complaint.adminReply!.isNotEmpty;
          default:
            return true;
        }
      }).toList();
    }

    // التصفية حسب التاريخ
    if (_startDate != null) {
      filtered = filtered.where((complaint) {
        final complaintDate = complaint.createdAt;
        final startDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final complaintDay = DateTime(complaintDate.year, complaintDate.month, complaintDate.day);
        print('$startDay');
        if (_endDate != null && !_isSameDay(_startDate!, _endDate!)) {
          final endDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day).add(const Duration(days: 1));
          return complaintDay.isAfter(startDay.subtract(const Duration(days: 1))) && complaintDay.isBefore(endDay);
        } else {
          return _isSameDay(complaintDate, _startDate!);
        }
      }).toList();
    }

    return filtered;
  }

  /// 🔍 التحقق من أن اليوم نفسه
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        print('🎧 Listener - الحالة الحالية: ${state.runtimeType}');
        if (state is ComplaintSuccess) {
          print('✅ شكوى جديدة تم إرسالها - تحديث القائمة تلقائياً');
          widget.onRefresh();
        }
      },
      builder: (context, state) {
        print('🏗️ Builder - بناء واجهة للحالة: ${state.runtimeType}');
        if (state is ComplaintLoading) {
          print('⏳ حالة التحميل...');
          return _buildLoadingState();
        }

        if (state is ComplaintFailure) {
          print('❌ حالة الفشل: ${state.error}');
          return ErrorComplaintsWidget(
            error: state.error,
            onRetry: widget.onRefresh,
          );
        }

        // 🔥 التأكد من معالجة جميع الحالات الناجحة
      if (state is StudentComplaintsLoaded || 
          state is RoleComplaintsLoaded ) {
        print('✅ حالة ناجحة - عدد الشكاوى: ${_extractComplaintsData(state).length}');
        return _buildComplaintsContent(state);
      }

      // ⚠️ حالة ابتدائية أو غير معروفة
      print('⚠️ حالة غير معروفة: ${state.runtimeType} - إعادة التحميل');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRefresh();
      });
      return _buildLoadingState();
        
      },
    );
  }

  /// 🏗️ بناء محتوى الشكاوى
Widget _buildComplaintsContent(ComplaintState state) {
  try {
    print('🔨 بدء بناء محتوى الشكاوى...');
    final complaintsData = _extractComplaintsData(state);
    print('📋 البيانات المستخرجة: ${complaintsData.length} شكوى');
    final filteredComplaints = _filterComplaints(complaintsData);
    print('🎯 الشكاوى المفلترة: ${filteredComplaints.length} شكوى');

    return Stack(
      children: [
        // 📜 قائمة الشكاوى (تأخذ كامل المساحة)
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: ColorsApp.primaryColor,
            backgroundColor: Colors.white,
            child: filteredComplaints.isEmpty
                ? EmptyComplaintsWidget(userRole: widget.user.role)
                : ComplaintsList(
                    complaints: filteredComplaints,
                    user: widget.user,
                    scrollController: _scrollController,
                    showStats: _showStats,
                  ),
          ),
        ),
        
        // 📊 شريط الإحصائيات والفلترة العائم من الأعلى (للمسؤولين والمدير فقط)
        if (widget.user.role == 'Admin' || widget.user.role == 'Manager')
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ComplaintsFilterPanel(
              complaints: complaintsData,
              filteredComplaints: filteredComplaints,
              selectedFilter: _selectedFilter,
              startDate: _startDate,
              endDate: _endDate,
              showStats: _showStats,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              onDatePickerPressed: _openDatePicker,
              onClearDateFilter: _clearDateFilter,
              onPanelStateChanged: _onPanelStateChanged,
            ),
          ),
      ],
    );
  } catch (e, stackTrace) {
    print('❌ خطأ في بناء محتوى الشكاوى: $e');
    print('📝 StackTrace: $stackTrace');
    return ErrorComplaintsWidget(
      error: 'خطأ في عرض الشكاوى: $e',
      onRetry: widget.onRefresh,
    );
  }
}

  /// ⏳ بناء حالة التحميل
  Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: ColorsApp.primaryColor),
        const SizedBox(height: 20),
        const Text('جاري تحميل الشكاوى...'),
        ],
      ),
    );
  }

  /// 📥 استخراج بيانات الشكاوى من الحالة
  List<ComplaintModel> _extractComplaintsData(ComplaintState state) {
  print('📥 استخراج البيانات من الحالة: ${state.runtimeType}');

    if (state is StudentComplaintsLoaded) {
      print('📊 إجمالي الشكاوى المستخرجة: ${state.complaints.length}');
      return state.complaints;
    } else if (state is RoleComplaintsLoaded) {
      print('📊 إجمالي الشكاوى المستخرجة: ${state.complaints.length}');
      return state.complaints;
    } 
    return [];
  }

}
