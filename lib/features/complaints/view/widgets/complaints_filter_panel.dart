import 'package:flutter/material.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';

/// 📊 لوحة الفلترة والإحصائيات القابلة للسحب
class ComplaintsFilterPanel extends StatefulWidget {
  final List<ComplaintModel> complaints;
  final List<ComplaintModel> filteredComplaints;
  final String selectedFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showStats;
  final Function(String) onFilterChanged;
  final VoidCallback onDatePickerPressed;
  final VoidCallback onClearDateFilter;
  final Function(bool)? onPanelStateChanged;

  const ComplaintsFilterPanel({
    super.key,
    required this.complaints,
    required this.filteredComplaints,
    required this.selectedFilter,
    required this.startDate,
    required this.endDate,
    required this.showStats,
    required this.onFilterChanged,
    required this.onDatePickerPressed,
    required this.onClearDateFilter,
    this.onPanelStateChanged,

  });

  @override
  State<ComplaintsFilterPanel> createState() => _ComplaintsFilterPanelState();
}

class _ComplaintsFilterPanelState extends State<ComplaintsFilterPanel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // 🔄 نفس منطق السحب من الكود المطلوب
        if (details.primaryDelta! > 5 && !widget.showStats) {
          // سحب لأسفل لإظهار الإحصائيات
          if (widget.onPanelStateChanged != null) {
            widget.onPanelStateChanged!(true);
          }
        } else if (details.primaryDelta! < -5 && widget.showStats) {
          // سحب لأعلى لإخفاء الإحصائيات
          if (widget.onPanelStateChanged != null) {
            widget.onPanelStateChanged!(false);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: widget.showStats ? null : 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 مؤشر السحب
              _buildDragIndicator(),
              
              // 🔥 محتوى الإحصائيات
              widget.showStats 
                  ? _buildExpandedStatsContent()
                  : _buildCollapsedStatsContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📏 بناء مؤشر السحب
  Widget _buildDragIndicator() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 📊 بناء محتوى الإحصائيات المقلص
  Widget _buildCollapsedStatsContent() {
    final totalCount = widget.complaints.length;
    final pendingCount = widget.complaints.where((c) => c.status == 'pending').length;
    final inProgressCount = widget.complaints.where((c) => c.status == 'in_progress').length;
    final resolvedCount = widget.complaints.where((c) => c.status == 'resolved').length;
    final repliedCount = widget.complaints.where((c) => c.adminReply != null && c.adminReply!.isNotEmpty).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔢 الإحصائيات المصغرة
          Row(
            children: [
              _buildMiniStatItem('⏳', pendingCount, Colors.orange),
              const SizedBox(width: 12),
              _buildMiniStatItem('🔵', inProgressCount, Colors.blue),
              const SizedBox(width: 12),
              _buildMiniStatItem('✅', resolvedCount, Colors.green),
              const SizedBox(width: 12),
              _buildMiniStatItem('💬', repliedCount, Colors.blue),
            ],
          ),
          
          // 📈 العدد الإجمالي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsApp.primaryColor),
            ),
            child: Text(
              'الإجمالي: $totalCount',
              style: TextStyle(
                color: ColorsApp.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔢 بناء عنصر إحصائية مصغر
  Widget _buildMiniStatItem(String icon, int count, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// 📈 بناء محتوى الإحصائيات الممتد
  Widget _buildExpandedStatsContent() {
    final totalCount = widget.complaints.length;
    final repliedCount = widget.complaints.where((c) => c.adminReply != null && c.adminReply!.isNotEmpty).length;
    final pendingCount = widget.complaints.where((c) => c.status == 'pending').length;
    final inProgressCount = widget.complaints.where((c) => c.status == 'in_progress').length;
    final resolvedCount = widget.complaints.where((c) => c.status == 'resolved').length;
    final rejectedCount = widget.complaints.where((c) => c.status == 'rejected').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔥 العنوان والإجمالي
          _buildHeaderSection(totalCount),
          getHeight(12),
          
          // 🔥 الفلترة الزمنية
          _buildDateFilterSection(),
          getHeight(16),
          
          // 🔥 الإحصائيات
          _buildStatistics(pendingCount, inProgressCount, resolvedCount, rejectedCount, repliedCount),
          getHeight(16),
          
          // 🔥 أزرار التصفية
          _buildFilterButtons(pendingCount, inProgressCount, resolvedCount, rejectedCount, repliedCount),
        ],
      ),
    );
  }

  /// 🏷️ بناء قسم العنوان والرأس
  Widget _buildHeaderSection(int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'الإجمالي: $totalCount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.filteredComplaints.length != totalCount)
              Text(
                'المُصفى: ${widget.filteredComplaints.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 📅 بناء قسم الفلترة الزمنية
  Widget _buildDateFilterSection() {
    final hasDateFilter = widget.startDate != null || widget.endDate != null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // 🎛️ أزرار التحكم في التاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: ColorsApp.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'الفترة الزمنية:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  // ✏️ زر تعديل الفلترة
                  IconButton(
                    onPressed: widget.onDatePickerPressed,
                    icon: Icon(Icons.edit, color: ColorsApp.primaryColor),
                    tooltip: 'اختر فترة زمنية',
                  ),
                  // 🗑️ زر مسح الفلترة
                  if (hasDateFilter)
                    IconButton(
                      onPressed: widget.onClearDateFilter,
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: 'مسح الفلترة الزمنية',
                    ),
                ],
              ),
            ],
          ),
          // 📆 عرض الفترة المحددة
          if (hasDateFilter) ...[
            const SizedBox(height: 8),
            Text(
              _formatDateRange(widget.startDate, widget.endDate),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 📊 بناء قسم الإحصائيات
  Widget _buildStatistics(int pendingCount, int inProgressCount, int resolvedCount, int rejectedCount, int repliedCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('في الانتظار', pendingCount, Colors.orange, Icons.access_time),
        _buildStatItem('قيد المعالجة', inProgressCount, Colors.blue, Icons.autorenew),
        _buildStatItem('تم الحل', resolvedCount, Colors.green, Icons.check_circle),
        _buildStatItem('تم الرد', repliedCount, Colors.blue, Icons.reply),
      ],
    );
  }

  /// 🎯 بناء عنصر إحصائي فردي
  Widget _buildStatItem(String title, int count, Color color, IconData icon) {
    return Column(
      children: [
        // 🎪 دائرة الرمز
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Icon(icon, color: color, size: 23),
        ),
        const SizedBox(height: 8),
        // 🔢 العدد
        Text(
          '$count', 
          style: TextStyle(
            color: color, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        // 📝 العنوان
        Text(
          title, 
          style: const TextStyle(
            fontSize: 12, 
            color: Colors.grey
          ),
        ),
      ],
    );
  }

  /// 🎛️ بناء أزرار التصفية
  Widget _buildFilterButtons(int pendingCount, int inProgressCount, int resolvedCount, int rejectedCount, int repliedCount) {
    final filters = [
      {'label': 'الكل', 'count': pendingCount + inProgressCount + resolvedCount + rejectedCount, 'color': ColorsApp.primaryColor},
      {'label': 'في الانتظار', 'count': pendingCount, 'color': Colors.orange},
      {'label': 'قيد المعالجة', 'count': inProgressCount, 'color': Colors.blue},
      {'label': 'تم الحل', 'count': resolvedCount, 'color': Colors.green},
      {'label': 'مرفوض', 'count': rejectedCount, 'color': Colors.red},
      {'label': 'تم الرد', 'count': repliedCount, 'color': Colors.blue},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = widget.selectedFilter == filter['label'];
          final color = filter['color'] as Color;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📝 نص التصفية
                  Text(filter['label'] as String),
                  const SizedBox(width: 4),
                  // 🔢 دائرة العدد
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${filter['count']}',
                      style: TextStyle(
                        color: isSelected ? color : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                widget.onFilterChanged(filter['label'] as String);
              },
              backgroundColor: color.withOpacity(0.1),
              selectedColor: color.withOpacity(0.3),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 📅 تنسيق الفترة الزمنية للنص
  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'جميع الأوقات';
    if (start != null && end == null) return 'يوم ${_formatDate(start)}';
    if (start == null && end != null) return 'حتى ${_formatDate(end)}';
    if (_isSameDay(start!, end!)) return 'يوم ${_formatDate(start)}';
    return 'من ${_formatDate(start)} إلى ${_formatDate(end)}';
  }

  /// 📅 تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// 🔍 التحقق من أن اليوم نفسه
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }
  @override
  void dispose() {
    // 🧹 تنظيف الموارد
    super.dispose();
  }
}