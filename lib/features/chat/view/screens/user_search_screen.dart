import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/image_utils.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/chat/bloc/chat_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/profile/view/screen/floating_user_profile_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:chat_repository/chat_repository.dart';

class UserSearchScreen extends StatefulWidget {
  final String currentUserId;
  final String userRole;

  const UserSearchScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModels> _allUsers = [];
  List<ChatRoomModel> _myChats = [];
  List<UserModels> _filteredUsers = [];
  String _currentUserId = '';
  bool _isLoadingUserId = true;

  @override
  void initState() {
    super.initState();
    // تهيئة معرف المستخدم الحالي
    _currentUserId = widget.currentUserId;
    // التحقق من أن معرف المستخدم ليس فارغاً
    // التحقق من أن معرف المستخدم ليس فارغاً
    if (_currentUserId.isEmpty) {
      print('❌ خطأ: currentUserId فارغ في UserSearchScreen');
      // محاولة جلب معرف المستخدم من UserRepository
      _getCurrentUserId();
    } else {
      _isLoadingUserId = false;
    }
    // جلب كل المستخدمين
    context.read<UserManagementBloc>().add(const LoadAllUsers());
    // جلب محادثاتي لمعرفة من تحدثت معهم سابقاً
    if (_currentUserId.isNotEmpty) {
      context.read<ChatBloc>().add(LoadMyChats(userId: _currentUserId, userRole: ''));
    }
    _searchController.addListener(_filterUsers);
  }

  // دالة جديدة لجلب معرف المستخدم الحالي
  Future<void> _getCurrentUserId() async {
    try {
      final userRepo = context.read<UserRepository>();
      final user = await userRepo.getCurrentUser();
      if (user.userID.isNotEmpty) {
        setState(() {
          _currentUserId = user.userID;
          _isLoadingUserId = false;
        });
        // الآن بعد الحصول على المعرف، قم بجلب المحادثات
        context.read<ChatBloc>().add(LoadMyChats(userId: _currentUserId, userRole: ''));
      }
    } catch (e) {
      print('❌ خطأ في جلب معرف المستخدم: $e');
      setState(() {
        _isLoadingUserId = false;
      });
    }
  }

  // دالة لتحويل دور المستخدم إلى نص عربي
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'Admin':
        return 'دراسة و الامتحانات';
      case 'Manager':
        return 'مدير';
      case 'Doctor':
        return 'دكتور';
      case 'Student':
        return 'طالب';
      default:
        return role;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.userID.toLowerCase().contains(query);
        }).toList();
      }
      // إعادة الترتيب بناءً على وجود المحادثات السابقة
      _sortUsersByChatHistory();
    });
  }

  void _sortUsersByChatHistory() {
    // استخراج قائمة المستخدمين الذين لدي محادثات معهم
    final existingChatUserIds = _myChats
        .where((chat) => chat.isPrivate)
        .expand((chat) => chat.memberIds)
        .toSet();

    _filteredUsers.sort((a, b) {
      final aHasChat = existingChatUserIds.contains(a.userID);
      final bHasChat = existingChatUserIds.contains(b.userID);

      if (aHasChat && !bHasChat) return -1;
      if (!aHasChat && bHasChat) return 1;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'بحث وتواصل'),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن المستخدم...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorsApp.grey),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          // قائمة المستخدمين
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<UserManagementBloc, UserManagementState>(
                  listener: (context, state) {
                    if (state.status == UserManagementStatus.success) {
                      // فلترة المستخدمين لإزالة المستخدم الحالي
                      setState(() {
                        _allUsers = state.users
                            .where((u) => u.userID != _currentUserId)
                            .toList();
                        _filterUsers();
                      });
                    }
                  },
                ),
                BlocListener<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is MyChatsLoaded) {
                      setState(() {
                        _myChats = state.chats;
                        _sortUsersByChatHistory();
                      });
                    }
                  },
                ),
              ],
              child: BlocBuilder<UserManagementBloc, UserManagementState>(
                builder: (context, userState) {
                  if (userState.status == UserManagementStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userState.status == UserManagementStatus.error) {
                    return Center(
                      child: Text(
                        'خطأ في تحميل المستخدمين: ${userState.errorMessage}',
                        style: font14grey,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (_filteredUsers.isEmpty && _searchController.text.isEmpty && userState.status == UserManagementStatus.success) {
                     // الحالة الافتراضية قبل التصفية
                      return _buildUserList(_allUsers, _myChats);
                  }

                  return _buildUserList(_filteredUsers, _myChats);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModels> users, List<ChatRoomModel> chats) {
    if (users.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج', style: font16black),
      );
    }

    final existingChatUserIds = chats
        .where((chat) => chat.isPrivate)
        .expand((chat) => chat.memberIds)
        .toSet();

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final hasChat = existingChatUserIds.contains(user.userID);

        return ListTile(
          leading: GestureDetector(
            onTap: () => _showUserProfileDialog(context, user.userID),
            child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
                ),
                child: ClipOval(
                  child: _buildUserImage(user),
                ),
              ),
          ),
          title: Text(user.name, style: font16black),
          subtitle: Text(_getRoleDisplayName(user.role), style: font12Grey),
          trailing: hasChat
              ?  Icon(Icons.message, color: ColorsApp.primaryColor)
              : const Icon(Icons.chat_bubble_outline, color: Colors.grey),
          onTap: () => _startPrivateChat(user),
        );
      },
    );
  }

  void _startPrivateChat(UserModels targetUser) {
    // التحقق من أن معرفات المستخدمين غير فارغة
  if (_currentUserId.isEmpty || targetUser.userID.isEmpty) {
    print('❌ خطأ: معرف المستخدم فارغ في _startPrivateChat');
    print('currentUserId: ${_currentUserId}');
    print('targetUserId: ${targetUser.userID}');
    // محاولة جلب المعرف مرة أخرى إذا كان فارغاً
      if (_currentUserId.isEmpty&& !_isLoadingUserId) {
        _getCurrentUserId().then((_) {
          if (_currentUserId.isNotEmpty) {
            _startPrivateChat(targetUser);
          }
        });
      }
      return;
  }
    Navigator.pushNamed(
      context,
      '/private-chat',
      arguments: {
        'userId': _currentUserId,
        'receiverId': targetUser.userID,
        'title': targetUser.name,
      },
      ).then((_) {
      // عند العودة من الدردشة، قم بالعودةإلى الشاشة الرئيسية
      Navigator.pop(context); // العودة إلى الشاشة السابقة (ChatHomeScreen)
    });
  }
  /// بناء صورة المستخدم
  Widget _buildUserImage(UserModels user) {
    // الحالة الأولى: الصورة من شبكة الإنترنت (URL)
  if (user.urlImg != null && user.urlImg!.startsWith('http')) {
    return Image.network(
      user.urlImg!,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultImage(user);
      },
    );
  } 
  // الحالة الثانية: الصورة هي نص Base64
  if (user.urlImg != null && user.urlImg!.isNotEmpty) {
    // نستخدم دالة ImageUtils مباشرة لتحويل Base64 إلى صورة
    return ImageUtils.base64ToImageWidget(
      user.urlImg!,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorWidget: _buildDefaultImage(user), // عرض الصورة الافتراضية في حالة الخطأ
    );
  }

  // الحالة الافتراضية: لا توجد صورة
  return _buildDefaultImage(user);
}

  Widget _buildDefaultImage(UserModels user) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      backgroundImage: user.gender == "Male" || user.gender == "male"
          ? const AssetImage('assets/images/man.png')
          : const AssetImage('assets/images/woman.png'),
    );
  }

  /// عرض مربع حوار الملف الشخصي للمستخدم
  void _showUserProfileDialog(BuildContext context, String userID) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (context) {
        return FloatingUserProfileScreen(userID: userID);
      },
    );
  }
}