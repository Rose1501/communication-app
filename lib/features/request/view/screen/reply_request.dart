import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/request/view/widget/date_range_picker.dart';
import 'package:myproject/features/request/view/widget/reply_request_service.dart';
import 'package:myproject/features/request/view/widget/reply_request_widgets.dart';
import 'package:myproject/features/request/view/widget/request_filter_utils.dart';
import 'package:request_repository/request_repository.dart';

class ReplyRequest extends StatefulWidget {
  const ReplyRequest({super.key});

  @override
  State<ReplyRequest> createState() => _ReplyRequestState();
}

class _ReplyRequestState extends State<ReplyRequest> {
  int _selectedIndex = 3;
  String _selectedFilter = 'الكل'; // 🔥 حالة التصفية
  DateTime? _startDate;
  DateTime? _endDate;
  final ScrollController _scrollController = ScrollController();
  bool _showStats = true;


  @override
  void initState() {
    super.initState();
    _loadRequests();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {});
  }

  void _loadRequests() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestBloc>().add(LoadAllRequestsEvent());
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, getUserRole(context), context);
  }

  // 🔥 فتح منتقي التاريخ
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

  // 🔥 مسح الفلترة الزمنية
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  // 🔥 تصفية الطلبات حسب الحالة والوقت معاً
  List<StudentRequestModel> _filterRequests(List<StudentRequestModel> requests) {
    return RequestFilterUtils.filterRequests(
      requests: requests,
      statusFilter: _selectedFilter,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'رد على الطلبات'),
      // 🔥 إضافة الزر العائم
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userRole: getUserRole(context),
      ),
    );
  }

  // 🔥 بناء الزر العائم
  Widget _buildFloatingActionButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // زر حذف الكل
        FloatingActionButton(
          onPressed: () => ReplyRequestService.deleteAllRequests(context),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          heroTag: 'delete_all',
          tooltip: 'حذف جميع الطلبات',
          child: const Icon(Icons.delete_forever),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, RequestState state) {
    if (state is RequestLoading) {
      return ReplyRequestWidgets.buildLoadingWidget();
    }

    if (state is RequestFailure) {
      return ReplyRequestWidgets.buildErrorWidget(
        state.error,
        () => context.read<RequestBloc>().add(LoadAllRequestsEvent()),
      );
    }

    if (state is AllRequestsLoaded) {
      final allRequests = state.requests;
      final filteredRequests = _filterRequests(allRequests);
      
      return Stack(
        children: [
          // 🔥 قائمة الطلبات (تأخذ كامل المساحة)
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<RequestBloc>().add(LoadAllRequestsEvent());
                await Future.delayed(const Duration(milliseconds: 1000));
              },
              child: filteredRequests.isEmpty
                  ? ReplyRequestWidgets.buildEmptyFilteredRequests(_selectedFilter)
                  : _buildRequestsList(filteredRequests),
            ),
          ),
          
          // 🔥 شريط الإحصائيات العائم من الأعلى
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildDraggableStatsPanel(allRequests),
          ),
        ],
      );
    }

    return ReplyRequestWidgets.buildLoadingWidget();
  }

  // 🔥 بناء لوحة الإحصائيات القابلة للسحب
  Widget _buildDraggableStatsPanel(List<StudentRequestModel> requests) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 5 && !_showStats) {
          // سحب لأسفل لإظهار الإحصائيات
          setState(() {
            _showStats = true;
          });
        } else if (details.primaryDelta! < -5 && _showStats) {
          // سحب لأعلى لإخفاء الإحصائيات
          setState(() {
            _showStats = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showStats ? null : 70, // ارتفاع مخفي / كامل
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
          physics: const NeverScrollableScrollPhysics(), // منع التمرير الداخلي
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 مؤشر السحب
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 🔥 محتوى الإحصائيات
              _showStats 
                  ? _buildExpandedStatsContent(requests)
                  : _buildCollapsedStatsContent(requests),
            ],
          ),
        ),
      ),
    );
  }

   // 🔥 محتوى الإحصائيات المقلص (مخفي)
  Widget _buildCollapsedStatsContent(List<StudentRequestModel> requests) {
    final totalCount = requests.length;
    final pendingCount = requests.where((r) => r.status == 'انتظار').length;
    final approvedCount = requests.where((r) => r.status == 'موافقة').length;
    final rejectedCount = requests.where((r) => r.status == 'رفض').length;
    final repliedCount = requests.where((r) => r.adminReply != null && r.adminReply!.isNotEmpty).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الإحصائيات المصغرة
          Row(
            children: [
              _buildMiniStatItem('⏳', pendingCount, Colors.orange),
              const SizedBox(width: 12),
              _buildMiniStatItem('✅', approvedCount, Colors.green),
              const SizedBox(width: 12),
              _buildMiniStatItem('❌', rejectedCount, Colors.red),
              const SizedBox(width: 12),
              _buildMiniStatItem('💬', repliedCount, Colors.blue),
            ],
          ),
          
          // المجموع
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

  // 🔥 بناء عنصر إحصائية مصغر
  Widget _buildMiniStatItem(String icon, int count, Color color) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
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

  // 🔥 محتوى الإحصائيات الممتد (مفصّل)
  Widget _buildExpandedStatsContent(List<StudentRequestModel> requests) {
    final totalCount = requests.length;
    final repliedRequests = requests.where((r) => r.adminReply != null && r.adminReply!.isNotEmpty).length;
    final pendingCount = requests.where((r) => r.status == 'انتظار').length;
    final approvedCount = requests.where((r) => r.status == 'موافقة').length;
    final rejectedCount = requests.where((r) => r.status == 'رفض').length;
    final filteredRequests = _filterRequests(requests);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔥 العنوان والإجمالي
          Row(
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
                  if (filteredRequests.length != totalCount)
                    Text(
                      'المُصفى: ${filteredRequests.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 🔥 الفلترة الزمنية
          _buildDateFilterSection(),
          const SizedBox(height: 16),
          
          // 🔥 الإحصائيات
          _buildStatistics(pendingCount, approvedCount, rejectedCount,repliedRequests),
          const SizedBox(height: 16),
          
          // 🔥 أزرار التصفية
          _buildFilterButtons(pendingCount, approvedCount, rejectedCount,repliedRequests),
        ],
      ),
    );
  }

  // 🔥 قسم الفلترة الزمنية
Widget _buildDateFilterSection() {
  final filterType = RequestFilterUtils.getFilterType(_startDate, _endDate);
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ColorsApp.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'نوع الفلترة: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  filterType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getFilterTypeColor(filterType),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _openDatePicker,
                  icon: Icon(Icons.edit, color: ColorsApp.primaryColor),
                  tooltip: 'اختر فترة زمنية',
                ),
                if (_startDate != null || _endDate != null)
                  IconButton(
                    onPressed: _clearDateFilter,
                    icon: const Icon(Icons.clear, color: Colors.red),
                    tooltip: 'مسح الفلترة الزمنية',
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          RequestFilterUtils.formatDateRange(_startDate, _endDate),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Color _getFilterTypeColor(String filterType) {
  switch (filterType) {
    case 'يوم واحد':
      return ColorsApp.green;
    case 'فترة زمنية':
      return ColorsApp.orange;
    case 'يوم محدد':
      return ColorsApp.primaryColor;
    case 'حتى تاريخ':
      return ColorsApp.primaryLight;
    default:
      return ColorsApp.greylight;
  }
}

  // 🔥 أزرار التصفية
  Widget _buildFilterButtons(int pendingCount, int approvedCount, int rejectedCount,int repliedRequests) {
    final filters = [
      {'label': 'الكل', 'count': pendingCount + approvedCount + rejectedCount, 'color': ColorsApp.primaryColor},
      {'label': 'في الانتظار', 'count': pendingCount, 'color': Colors.orange},
      {'label': 'تم الموافقة', 'count': approvedCount, 'color': Colors.green},
      {'label': 'تم الرفض', 'count': rejectedCount, 'color': Colors.red},
      {'label': 'تم الرد', 'count': repliedRequests, 'color': Colors.blue},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['label'];
          final color = filter['color'] as Color;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter['label'] as String),
                  const SizedBox(width: 4),
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
                setState(() {
                  _selectedFilter = filter['label'] as String;
                });
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

  // 🔥 عرض الإحصائيات
  Widget _buildStatistics(int pendingCount, int approvedCount, int rejectedCount,int repliedRequests) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('في الانتظار', pendingCount, Colors.orange, Icons.access_time),
        _buildStatItem('تم الموافقة', approvedCount, Colors.green, Icons.check_circle),
        _buildStatItem('تم الرفض', rejectedCount, Colors.red, Icons.cancel),
        _buildStatItem('تم الرد', repliedRequests, Colors.blue, Icons.admin_panel_settings),
      ],
    );
  }

  Widget _buildStatItem(String title, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  // 🔥 بناء قائمة الطلبات
  Widget _buildRequestsList(List<StudentRequestModel> requests) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: _showStats ? 280 : 80, // 🔥 مسافة متغيرة حسب حالة الإحصائيات
      ),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return ReplyRequestWidgets.buildRequestCard(
          request: request,
          onApprove: () => ReplyRequestService.updateRequestStatus(
            context: context,
            requestId: request.id,
            studentName: request.name,
            requestType: request.requestType,
            newStatus: 'موافقة',
          ),
          onReject: () => ReplyRequestService.updateRequestStatus(
            context: context,
            requestId: request.id,
            studentName: request.name,
            requestType: request.requestType,
            newStatus: 'رفض',
          ),
          onReply: () => ReplyRequestService.showAdminReplyDialog(
            context: context,
            requestId: request.id,
            studentName: request.name,
            requestType: request.requestType,
            currentStatus: request.status,
            existingReply: request.adminReply,
          ),
          context: context,
        );
      },
    );
  }
}