
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/request/view/screen/send_request.dart';
import 'package:myproject/features/request/view/widget/request_service.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';
import 'package:myproject/features/request/view/widget/request_widgets.dart';
import 'package:user_repository/user_repository.dart';

class DisplayRequestStudent extends StatefulWidget {
  const DisplayRequestStudent({super.key});

  @override
  State<DisplayRequestStudent> createState() => _DisplayRequestStudentState();
}

class _DisplayRequestStudentState extends State<DisplayRequestStudent> {
  int _selectedIndex = 5;
  int? _previousRequestsCount;

  @override
  void initState() {
    super.initState();
    _loadRequestsOnInit(); 
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, getUserRole(context), context);
  }

  // 🔥 تحميل الطلبات تلقائياً عند فتح الشاشة
  void _loadRequestsOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUserState = context.read<MyUserBloc>().state;
      if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
        final user = myUserState.user!;
        print('🚀 تحميل الطلبات تلقائياً عند فتح الشاشة');
        context.read<RequestBloc>().add(LoadStudentRequestsEvent(user.userID));
      }
    });
  }

  String getUserRole(BuildContext context) {
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'student';
  }

  //🔄 سحب يدوي لتحديث الطلبات'
  Future<void> _handleRefresh() async {
    print('🔄 سحب يدوي لتحديث الطلبات');
    
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
      final user = myUserState.user!;
      context.read<RequestBloc>().add(LoadStudentRequestsEvent(user.userID));
    }
    
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        if (myUserState.status != MyUserStatus.success || myUserState.user == null) {
          return Scaffold(
            appBar: CustomAppBarTitle(title: 'طلباتي'),
            body: Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor)),
          );
        }

        final user = myUserState.user!;

        return Scaffold(
          appBar: CustomAppBarTitle(title: 'طلباتي'),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final isConnected = await RequestUtils.checkInternetConnection(context);
              if (!isConnected) {
                ShowWidget.showMessage(context, noNet, Colors.black, font11White);
                return;
              }
              try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SendRequest(),
          fullscreenDialog: true,
        ),
      );
      
      if (result == true) {
        print('✅ العودة من شاشة الإرسال - تحديث الطلبات تلقائياً');
        final myUserState = context.read<MyUserBloc>().state;
        if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
          final user = myUserState.user!;
          context.read<RequestBloc>().add(LoadStudentRequestsEvent(user.userID));
          
              ShowWidget.showMessage(
                context,
                'تم تحديث الطلبات',
              Colors.green,
                font13White,
              );
            }
          }
        } catch (e) {
          print('❌ خطأ في الانتقال لشاشة الإرسال: $e');
          // لا تفعل شيئاً - دع المستخدم يحاول مرة أخرى
        }
      },
            backgroundColor: ColorsApp.primaryColor,
            foregroundColor: ColorsApp.white,
            shape: const CircleBorder(),
            child: const Icon(CupertinoIcons.add, size: 28),
          ),
          body: BlocConsumer<RequestBloc, RequestState>(
            listener: (context, state) {
              // 🔥 معالجة حالة الحذف الناجح
                  if (state is RequestFailure) {
                    // التحقق إذا كان الخطأ متعلقاً بالحذف
                    if (state.error.contains('حذف')) {
                      print('❌ حدث خطأ أثناء الحذف: ${state.error}');
                      ShowWidget.showMessage(
                        context,
                        'فشل في حذف الطلب',
                        Colors.red,
                        TextStyle(color: Colors.white, fontSize: 13),
                      );
                    }
                  }
                  // 🔥 معالجة حالة التحميل بعد الحذف
                      if (state is StudentRequestsLoaded) {
                        print('✅ تم تحميل الطلبات بعد الحذف، العدد: ${state.requests.length}');
                        
                        // إظهار رسالة نجاح إذا كان هناك طلبات أقل من السابق
                        final previousCount = _previousRequestsCount;
                        if (previousCount != null && state.requests.length < previousCount) {
                          ShowWidget.showMessage(
                            context,
                            'تم حذف الطلب بنجاح',
                            Colors.green,
                            TextStyle(color: Colors.white, fontSize: 13),
                          );
                        }
                      }
              if (state is RequestSuccess) {
                print('✅ طلب جديد تم إرساله - تحديث القائمة تلقائياً');
                context.read<RequestBloc>().add(LoadStudentRequestsEvent(user.userID));
              }
            },
            builder: (context, state) {
              // 🔥 حفظ عدد الطلبات الحالي للمقارنة لاحقاً
              if (state is StudentRequestsLoaded) {
                _previousRequestsCount = state.requests.length;
              }
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                color: ColorsApp.primaryColor,
                backgroundColor: Colors.white,
                child: _buildBody(context, state, user),
              );
            },
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            userRole: getUserRole(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RequestState state, UserModels user) {
    if (state is RequestLoading) {
      return Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
    }

    if (state is RequestFailure) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: RequestWidgets.buildErrorWidget(
          state.error,
          () => context.read<RequestBloc>().add(LoadStudentRequestsEvent(user.userID)),
        ),
      );
    }

    final requests = state is StudentRequestsLoaded ? state.requests : [];

    print('🎯 بناء الواجهة بعدد ${requests.length} طلب'); 
    // 🔥 إحصائيات 
    final repliedRequests = requests.where((r) => r.adminReply != null && r.adminReply!.isNotEmpty).length;
    final pendingRequests = requests.where((r) => r.status == 'انتظار').length;
    final approvedRequests = requests.where((r) => r.status == 'موافقة').length;
    final rejectedRequests = requests.where((r) => r.status == 'رفض').length;

  print('🎯 بناء الواجهة بعدد ${requests.length} طلب');


    return Column(
      children: [
        // عرض بيانات الطالب
        RequestWidgets.buildStudentInfoCard(user),
        getHeight(5),
        // 🔥 عرض إحصائيات الطلبات
        _buildRequestsStats(requests.length, repliedRequests, pendingRequests, approvedRequests, rejectedRequests),
        getHeight(10),
        // عرض قائمة الطلبات
        Expanded(
          child: requests.isEmpty
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: RequestWidgets.buildEmptyRequestsDraggable(),
                )
              : _buildRequestsList(requests, user), 
        ),
      ],
    );
  }

  // 🔥 بناء إحصائيات الطلبات
  Widget _buildRequestsStats(int totalCount, int repliedCount, int pendingCount, int approvedCount, int rejectedCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الإجمالي', totalCount, ColorsApp.primaryColor),
          _buildStatItem('تم الرد', repliedCount, Colors.blue),
          _buildStatItem('موافقة', approvedCount, Colors.green),
          _buildStatItem('في الانتظار', pendingCount, Colors.orange),
          _buildStatItem(' رفض ', rejectedCount, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // 🔥 دالة  لبناء قائمة الطلبات
  Widget _buildRequestsList(List<dynamic> requests, UserModels user) {
    print('📋 بناء قائمة تحتوي على ${requests.length} طلب');
    // 🔥 ترتيب الطلبات من الأحدث إلى الأقدم
    final sortedRequests = List.from(requests)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    print('🔄 الطلبات بعد الترتيب: ${sortedRequests.length} طلب');
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: sortedRequests.length,
      itemBuilder: (context, index) {
        final request = sortedRequests[index];
        final hasReply = request.adminReply != null && request.adminReply!.isNotEmpty;
        print('🔄 بناء طلب ${index + 1}: ${request.id} - ${request.requestType} - ${hasReply ? "به رد" : "بدون رد"}');
        return RequestWidgets.buildRequestCard(
          request: request,
          onDelete: () => RequestService.showDeleteDialog(
            context: context,
            requestId: request.id,
            studentID: user.userID,
          ),
          showDelete: request.isWaiting,
        );
      },
    );
  }
}