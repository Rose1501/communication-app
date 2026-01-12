import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/image_utils.dart';
import 'package:myproject/features/graduation_project/bloc/user/user_bloc.dart';
import 'package:myproject/features/graduation_project/view/screen/create_project_screen.dart';
import 'package:myproject/features/profile/view/screen/floating_user_profile_screen.dart';
import 'package:user_repository/user_repository.dart';

/// شاشة عرض نتائج البحث
class SearchResultsScreen extends StatefulWidget {
  final UserModels currentUser;
  final String searchQuery;

  const SearchResultsScreen({
    super.key,
    required this.currentUser,
    required this.searchQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _isSearching = true;
  UserModels? _searchedUser;
  late StreamSubscription _userBlocSubscription; // تعريف المتغير هنا

  @override
  void initState() {
    super.initState();
    // بدء البحث عند تحميل الشاشة
    context.read<UserBloc>().add(GetUserById(widget.searchQuery));
    
    // الاستماع لأحداث البحث
    _setupSearchListener();
  }

  void _setupSearchListener() {
    final userBloc = context.read<UserBloc>();
    _userBlocSubscription = userBloc.stream.listen((state) {
      if (state is UserLoaded) {
        if (mounted) { // إضافة فحص mounted لتجنب الأخطاء
          setState(() {
            _isSearching = false;
            _searchedUser = state.user;
          });
        }
      } else if (state is UserError) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchedUser = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // إلغاء الاشتراك عند تدمير الشاشة
    _userBlocSubscription.cancel();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Dialog(
    backgroundColor: Colors.transparent, // خلفية شفافة للـ Dialog
    insetPadding: const EdgeInsets.all(16), // هوامش داخلية للـ Dialog
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس الشاشة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'نتائج البحث: "${widget.searchQuery}"',
                    style: font15Whitebold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // محتوى النتائج
          Flexible(
            child: _buildSearchResultsContent(),
          ),
        ],
      ),
    ),
  );
}

  /// بناء محتوى نتائج البحث
  Widget _buildSearchResultsContent() {
    if (_isSearching) {
      return  Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,)),
      );
    }

    if (_searchedUser == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'لم يتم العثور على مستخدم',
                style: font16Grey,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('عودة'),
            ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الملف الشخصي للمستخدم الذي تم البحث عنه
          _buildSearchedUserProfile(),
          
          const SizedBox(height: 16),
          
          // أزرار الإجراءات
          if (widget.currentUser.role == 'Admin' || widget.currentUser.role == 'Manager')
            if (_searchedUser!.role == 'Doctor')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddSupervisorDialog(context, _searchedUser!);
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text('إضافة مشرف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// بناء بطاقة الملف الشخصي للمستخدم الذي تم البحث عنه
  Widget _buildSearchedUserProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => _showUserProfileDialog(context, _searchedUser!.userID),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // محاذاة الأعلى
          children: [
            // صورة المستخدم
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorsApp.primaryColor.withOpacity(0.3)),
              ),
              child: ClipOval(
                child: _buildUserImage(_searchedUser!),
              ),
            ),
            const SizedBox(width: 16),
            
            // معلومات المستخدم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _searchedUser!.name,
                    style: font18blackbold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _searchedUser!.email,
                    style: font14grey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(_searchedUser!.role),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleLabel(_searchedUser!.role),
                          style: font11White.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // **الإضافة الجديدة: زر الدردشة الصغير**
            if (_searchedUser!.userID != widget.currentUser.userID)
              Container(
                decoration: BoxDecoration(
                  color: ColorsApp.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: ColorsApp.primaryColor,
                    size: 22,
                  ),
                  onPressed: () => _startPrivateChat(_searchedUser!),
                  tooltip: 'دردشة',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
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

  /// الحصول على لون الدور
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return ColorsApp.primaryColor;
      case 'admin':
        return Colors.red;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على نص الدور
  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'دكتور';
      case 'admin':
        return 'دراسةوالامتحانات';
      case 'student':
        return 'طالب';
      case 'manager':
        return 'رئيس القسم';
      default:
        return role;
    }
  }

  /// عرض مربع حوار لإضافة مشرف
  void _showAddSupervisorDialog(BuildContext context, UserModels doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مشرف'),
        content: Text('هل تريد إضافة الدكتور/ ${doctor.name} كمشرف على مشروع جديد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectScreen(),
                ),
              );
            },
            child: const Text('إنشاء مشروع'),
          ),
        ],
      ),
    );
  }

  /// بدء دردشة خاصة مع المستخدم
  void _startPrivateChat(UserModels targetUser) {
    Navigator.pushNamed(
      context,
      '/private-chat',
      arguments: {
        'userId': widget.currentUser.userID,
        'receiverId': targetUser.userID,
        'title': targetUser.name,
      },
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
