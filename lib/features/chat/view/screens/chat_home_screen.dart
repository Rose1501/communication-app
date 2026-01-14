// lib/features/chat/view/screens/chat_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/chat/bloc/chat_bloc.dart';
import 'package:myproject/features/chat/view/screens/user_search_screen.dart';
import 'package:myproject/features/chat/view/widgets/chat_tile.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:user_repository/user_repository.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({
    super.key,
  });

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 3; // مؤشر للعنصر المحدد في شريط التنقل (التواصل)
  late TabController _tabController;
  String _currentUserId = '';
  String _currentUserRole = '';
  bool _isLoadingUserData = true;
  bool _isCheckingDoctorsGroup = false;
   bool _isRefreshing = false; // إضافة متغير لتتبع حالة التحديث
  
  List<ChatRoomModel> _cachedGroupChats = []; // تخزين مؤقت للمجموعات
  List<ChatRoomModel> _cachedPrivateChats = []; // تخزين مؤقت للمحادثات الخاصة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // تهيئة التبويبات: 0 للمجموعات، 1 للمحادثات الخاصة
    _tabController = TabController(length: 2, vsync: this);
    _currentUserRole = _getUserRole();
    // جلب بيانات المستخدم الحالي
    _loadCurrentUser();
  }

  // دالة لجلب بيانات المستخدم الحالي
  Future<void> _loadCurrentUser() async {
    try {
      final userRepo = context.read<UserRepository>();
      final user = await userRepo.getCurrentUser();
      
      if (mounted && user.userID.isNotEmpty) {
        setState(() {
          _currentUserId = user.userID;
          _currentUserRole = user.role;
          _isLoadingUserData = false;
        });
        
        // الآن بعد الحصول على المعرف، قم بجلب المحادثات
        _loadChats();
        
        // التحقق من وجود مجموعة الأطباء وإنشاؤها إذا لم تكن موجودة
        // التحقق من وجود مجموعة الأطباء للمستخدمين الإداريين
      if (_currentUserRole == 'Admin' || 
          _currentUserRole == 'Manager' || 
          _currentUserRole == 'Doctor') {
        _checkDoctorsGroup();
      }
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  String _getUserRole() {
    // الحصول على دور المستخدم من الـBloc إذا كان متوفرًا
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success &&
        myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'User';
  }

   // دالة لجلب المحادثات
  void _loadChats() {
    if (_currentUserId.isNotEmpty) {
      print('🔄 جلب المحادثات للمستخدم: $_currentUserId');
      context.read<ChatBloc>().add(LoadMyChats(userId: _currentUserId, userRole: _currentUserRole));
    }
  }

  // دالة للتحقق من وجود مجموعة الأطباء وإنشاؤها إذا لم تكن موجودة
  Future<void> _checkDoctorsGroup() async {
    try {
        
        setState(() {
          _isCheckingDoctorsGroup = true;
        });
        print(' التحقق من وجود مجموعة الأطباء');
         // التحقق من وجود مجموعة الأطباء مع تمرير userId و userRole
    context.read<ChatBloc>().add(CheckDoctorsGroup(
      userId: _currentUserId,
      userRole: _currentUserRole,
    ));
      
    } catch (e) {
      print('❌ خطأ في التحقق من مجموعة الأطباء: $e');
      setState(() {
        _isCheckingDoctorsGroup = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  // دالة لتغيير الصفحة عند النقر على عنصر في شريط التنقل
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // التنقل بين الصفحات حسب العنصر المحدد ودور المستخدم
    navigateToScreen(index, _currentUserRole, context);
  }

  // هذه الدالة لمراقبة تغييرات دورة حياة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // عند العودة للتطبيق، قم بتحديث المحادثات
      _refreshChats();
    }
  }

  // دالة لتحديث المحادثات
  void _refreshChats() {
    if (_currentUserId.isNotEmpty && !_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
      print('🔄 تحديث المحادثات عند العودة للتطبيق');
      _loadChats();
      
      // إعادة تعيين حالة التحديث بعد فترة
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان المستخدم لديه صلاحية الوصول للمجموعات
    final hasGroupAccess = _currentUserRole == 'Admin' || 
                            _currentUserRole == 'Manager' || 
                            _currentUserRole == 'Doctor';
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.primaryColor,
        title: const Text('الرسائل', style: TextStyle(color: Colors.white)),
        bottom: hasGroupAccess ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'المجموعات'),
            Tab(text: 'المحادثات الخاصة'),
          ],
        ): null, // لا يظهر TabBar إذا لم يكن لديه صلاحية
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserSearchScreen(
                    currentUserId: _currentUserId,
                    userRole: _currentUserRole,
                  ),
                ),
              ).then((_) {
                // عند العودة من شاشة البحث، قم بتحديث المحادثات
                _refreshChats();
              });
            },
            tooltip: 'بحث عن مستخدم',
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is DoctorsGroupChecked) {
            setState(() {
              _isCheckingDoctorsGroup = false;
            });
            
            // إذا لم تكن المجموعة موجودة، قم بإنشائها
            if (!state.exists) {
              context.read<ChatBloc>().add(const CreateDoctorsGroup());
            }
          }
          
          if (state is DoctorsGroupCreated) {
            setState(() {
              _isCheckingDoctorsGroup = false;
            });
            // إعادة تحميل المحادثات بعد إنشاء المجموعة
            _loadChats();
          }
          // إعادة تعيين حالة التحديث عند انتهاء التحميل
          if (state is MyChatsLoaded || state is ChatError) {
            setState(() {
              _isRefreshing = false;
            });
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            // عرض المحادثات المخزنة مؤقتاً أثناء التحميل
            if (state is MyChatsLoaded) {
              final allChats = state.chats;
              
              // تحديث التخزين المؤقت
              _cachedGroupChats = allChats.where((c) => c.isGroup).toList();
              _cachedPrivateChats = allChats.where((c) => c.isPrivate).toList();
              
              // إذا كان المستخدم لديه صلاحية، استخدم TabBarView
              if (hasGroupAccess) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroupChatsList(_cachedGroupChats, state),
                    _buildChatList(_cachedPrivateChats, 'لا توجد محادثات خاصة', state),
                  ],
                );
              } else {
                // إذا لم يكن لديه صلاحية، اعرض المحادثات الخاصة فقط
                return _buildChatList(_cachedPrivateChats, 'لا توجد محادثات خاصة', state);
              }
            }
            // عرض المحادثات المخزنة مؤقتاً أثناء التحميل
            if (state is ChatLoading && (_cachedGroupChats.isNotEmpty || _cachedPrivateChats.isNotEmpty)) {
              // إذا كان المستخدم لديه صلاحية، استخدم TabBarView
              if (hasGroupAccess) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroupChatsList(_cachedGroupChats, state),
                    _buildChatList(_cachedPrivateChats, 'لا توجد محادثات خاصة', state),
                  ],
                );
              } else {
                // إذا لم يكن لديه صلاحية، اعرض المحادثات الخاصة فقط
                return _buildChatList(_cachedPrivateChats, 'لا توجد محادثات خاصة', state);
              }
            }
            if (state is ChatLoading ) {
              return Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
            }
            if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حدث خطأ', style: font16blackbold),
                    const SizedBox(height: 8),
                    Text(state.message, style: font14grey),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ChatBloc>()
                          .add(LoadMyChats(userId: _currentUserId, userRole: _currentUserRole)),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is MyChatsLoaded) {
              final allChats = state.chats;

              // تصفية الدردشات حسب النوع
              final groupChats = allChats.where((c) => c.isGroup).toList();
              final privateChats = allChats.where((c) => c.isPrivate).toList();

              // إذا كان المستخدم لديه صلاحية، استخدم TabBarView
              if (hasGroupAccess) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroupChatsList(groupChats, state),
                    _buildChatList(privateChats, 'لا توجد محادثات خاصة', state),
                  ],
                );
              } else {
                // إذا لم يكن لديه صلاحية، اعرض المحادثات الخاصة فقط
                return _buildChatList(privateChats, 'لا توجد محادثات خاصة', state);
              }
            }

            return Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userRole: _currentUserRole,
      ),
    );
  }

  // دالة لعرض قائمة المجموعات
Widget _buildGroupChatsList(List<ChatRoomModel> groupChats, ChatState state) {
  // إزالة التكرارات بناءً على المعرف
  final uniqueGroups = <String, ChatRoomModel>{};
  for (final group in groupChats) {
    uniqueGroups[group.id] = group;
  }
  final deduplicatedGroups = uniqueGroups.values.toList();
  
  // طباعة معلومات مفصلة للتصحيح
  print('🔍 === بدء تصفية المجموعات ===');
  print('🔍 العدد الإجمالي للمجموعات الواردة: ${groupChats.length}');
  print('🔍 العدد بعد إزالة التكرار: ${deduplicatedGroups.length}');
  print('🔍 دور المستخدم الحالي: $_currentUserRole');
  
  for (int i = 0; i < deduplicatedGroups.length; i++) {
    final chat = deduplicatedGroups[i];
    print('📋 المجموعة ${i + 1}: ${chat.name} (النوع: ${chat.type})');
    print('   - المعرف: ${chat.id}');
    print('   - عدد الأعضاء: ${chat.memberIds.length}');
    print('   - آخر نشاط: ${chat.lastActivity}');
  }
  
  final filteredGroups = deduplicatedGroups.where((chat) {
    bool shouldShow = false;
    
    // عرض مجموعة الأطباء دائمًا للمستخدمين المصرح لهم
    if (chat.type == 'doctors_group') {
      shouldShow = (_currentUserRole == 'Admin' || 
                    _currentUserRole == 'Manager' || 
                    _currentUserRole == 'Doctor');
      print('🔍 التحقق من مجموعة الأطباء "${chat.name}": النوع=${chat.type}, دور=$_currentUserRole, يجب العرض=$shouldShow');
    }
    
    // عرض المجموعات التعليمية حسب الدور
    else if (chat.type == 'educational_group') {
      shouldShow = (_currentUserRole == 'Admin' || 
                    _currentUserRole == 'Manager' || 
                    _currentUserRole == 'Doctor');
      print('🔍 التحقق من مجموعة تعليمية "${chat.name}": النوع=${chat.type}, دور=$_currentUserRole, يجب العرض=$shouldShow');
    }
    
    // عرض المجموعات العامة الأخرى
    else if (chat.type == 'group') {
      shouldShow = (_currentUserRole == 'Admin' || 
                    _currentUserRole == 'Manager');
      print('🔍 التحقق من مجموعة عامة "${chat.name}": النوع=${chat.type}, دور=$_currentUserRole, يجب العرض=$shouldShow');
    }
    
    else {
      print('🔍 نوع مجموعة غير معروف "${chat.name}": النوع=${chat.type}, دور=$_currentUserRole, يجب العرض=false');
    }
    
    return shouldShow;
  }).toList();
  
  print('🔍 === نتيجة التصفية ===');
  print('🔍 عدد المجموعات بعد التصفية: ${filteredGroups.length}');
  
  for (int i = 0; i < filteredGroups.length; i++) {
    final chat = filteredGroups[i];
    print('✅ المجموعة المعروضة ${i + 1}: ${chat.name} (النوع: ${chat.type})');
  }
  print('🔍 === نهاية التصفية ===');
  
  // إضافة مؤشر تحميل أثناء التحقق من مجموعة الأطباء
  final isLoading = _isCheckingDoctorsGroup || (state is ChatLoading && _cachedGroupChats.isEmpty);

  if (filteredGroups.isEmpty && !isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 60, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text('لا توجد مجموعات متاحة', style: font16black),
          const SizedBox(height: 8),
          Text('جاري تحميل مجموعة الأطباء...', style: font14grey),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // أولاً، تحقق من مجموعة الأطباء
              _checkDoctorsGroup();
              // ثم أعد تحميل المحادثات
              _loadChats();
            },
            style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
            child: Text('تحديث', style: font15White),
          ),
        ],
      ),
    );
  }
  
  if (isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          const SizedBox(height: 16),
          Text('جاري التحقق من مجموعة الأطباء...', style: font14grey),
        ],
      ),
    );
  }
  
  return RefreshIndicator(
    color: ColorsApp.primaryColor,
    onRefresh: () async {
      setState(() {
          _isRefreshing = true;
        });
      // أولاً، تحقق من مجموعة الأطباء
      _checkDoctorsGroup();
      // ثم أعد تحميل المحادثات
      _loadChats();
    },
    child: Column(
      children: [
        // عرض عدد المجموعات في الأعلى
        if (filteredGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${filteredGroups.length} مجموعة',
                style: font14grey,
              ),
            ),
          ),
        
        // قائمة المجموعات
        Expanded(
          child: ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final chat = filteredGroups[index];
              print('🏗️ بناء بطاقة الدردشة للمجموعة: ${chat.name}');
              return ChatTile(
                chat: chat,
                currentUserId: _currentUserId,
                onTap: () => _navigateToChat(context, chat),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildChatList(List<ChatRoomModel> chats, String emptyMessage, ChatState state) {
    if (chats.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: font14grey,
        ),
      );
    }

    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });
        context.read<ChatBloc>().add(LoadMyChats(userId: _currentUserId, userRole: _currentUserRole));
      },
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatTile(
            chat: chat,
            currentUserId: _currentUserId,
            onTap: () => _navigateToChat(context, chat),
          );
        },
      ),
    );
  }

  void _navigateToChat(BuildContext context, ChatRoomModel chat) {
  print('🚀 التنقل إلى الدردشة: ${chat.name} (النوع: ${chat.type})');
  
  if (chat.type == 'private') {
    // الانتقال للمحادثة الخاصة
    final receiverId = chat.memberIds.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
    
    if (receiverId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        Routes.privateChat,
        arguments: {
          'userId': _currentUserId,
          'receiverId': receiverId,
          'title': chat.name,
        },
        ).then((_) {
          // عند العودة من المحادثة، قم بتحديث المحادثات
          _refreshChats();
        }
      );
    }
  } else if (chat.type == 'doctors_group') {
    Navigator.pushNamed(
      context,
      Routes.doctorsChat,
      arguments: {
        'userId': _currentUserId,
      },
      ).then((_) {
          // عند العودة من المحادثة، قم بتحديث المحادثات
          _refreshChats();
        }
    );
  } else if (chat.type == 'educational_group') {
    // استخراج معرف المجموعة من اسم المستند
    String groupId = chat.id;
    if (groupId.startsWith('educational_group_')) {
      groupId = groupId.substring('educational_group_'.length);
    }
    
    Navigator.pushNamed(
      context,
      Routes.groupchat,
      arguments: {
        'userId': _currentUserId,
        'groupId': groupId,
        'title': chat.name,
        'userRole': _currentUserRole,
      },
      ).then((_) {
          // عند العودة من المحادثة، قم بتحديث المحادثات
          _refreshChats();
        }
    );
  } else {
    print('⚠️ نوع مجموعة غير معروف للتنقل: ${chat.type}');
  }
}

}