import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/user_import_panel.dart';
import 'package:myproject/features/data_management/view/widgets/users_list.dart';
/*
 * 👥 شاشة إدارة المستخدمين (طلاب، دكاترة، مدراء)
 * 
 * الوظائف:
 * ✅ عرض إحصائيات سريعة حسب الدور
 * ✅ بحث متقدم في المستخدمين
 * ✅ استيراد مستخدمين من Excel
 * ✅ تعديل وحذف المستخدمين
 */
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _clearMessages();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadUsers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserManagementBloc>().add(const LoadAllUsers());
    });
  }

  void _clearMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserManagementBloc>().add(const ClearMessages());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ShowWidget.showMessage(
            context,
            state.errorMessage,
            Colors.red,
            font15White,
          );
          // 🔥 تنظيف الرسالة بعد العرض
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              context.read<UserManagementBloc>().add(const ClearMessages());
            }
          });
        }
        if (state.successMessage.isNotEmpty) {
          ShowWidget.showMessage(
            context,
            state.successMessage,
            Colors.green,
            font15White,
          );
          // 🔥 تنظيف الرسالة بعد العرض
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              context.read<UserManagementBloc>().add(const ClearMessages());
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea( 
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  // 🔥 شريط البحث والإجراءات
                  _buildActionBar(context, state),
                  SizedBox(height: 16.h),
                  
                  // 🔥 إحصائيات سريعة
                  _buildQuickStats(state),
                  SizedBox(height: 16.h),
                  
                  // 🔥 قائمة المستخدمين أو نتائج البحث
                  Expanded(
                    child: _buildSearchResults(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBar(BuildContext context, UserManagementState state) {
    return Row(
      children: [
        // 🔍 حقل البحث
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Icon(Icons.search, color: Colors.grey[500]),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مستخدم...',
                      hintStyle: font14grey,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: font14black,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      print('⌨️ تغيير النص: "$value"');
                      _debounceSearch(value);
                    },
                    onSubmitted: (value) {
                      print('🔍 إرسال البحث: "$value"');
                      _performSearch(value);
                      _searchFocusNode.unfocus();
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500], size: 20.sp),
                    onPressed: () {
                      print('🗑️ مسح البحث');
                      _searchController.clear();
                      _performSearch('');
                    },
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.w),
        
        // 📤 زر استيراد المستخدمين
        Container(
          width: 50.h,
          height: 50.h,
          decoration: BoxDecoration(
            color: ColorsApp.primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: Icon(Icons.upload_file, color: Colors.white, size: 24.sp),
            onPressed: () => _showImportOptions(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _debounceSearch(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(value);
    });
  }

  void _performSearch(String value) {
    print('🔍 إجراء البحث عن: "$value"');
    context.read<UserManagementBloc>().add(SearchUsers(value));
  }

  Widget _buildQuickStats(UserManagementState state) {
    final admins = state.users.where((user) => user.role == 'Admin').length;
    final doctors = state.users.where((user) => user.role == 'Doctor').length;
    final students = state.users.where((user) => user.role == 'Student').length;
    final managers = state.users.where((user) => user.role == 'Manager').length;

    return Container(
      height: 100.h, 
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatItem('مسؤول', admins, Icons.admin_panel_settings),
          _buildStatItem('دكاترة', doctors, Icons.school),
          _buildStatItem('طلاب', students, Icons.person),
          _buildStatItem('مدراء', managers, Icons.manage_accounts),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon) {
    return Container( 
      width: 70.w,
      height: 75.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 35.w, // 🔥 عرض ثابت
            height: 35.h, // 🔥 ارتفاع ثابت
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          // 🔥 العدد
          Text(
            count.toString(),
            style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'tajawal',
            height: 1.0,
          ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          // 🔥 العنوان
          Text(
            title,
            style: TextStyle( 
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.normal,
            fontFamily: 'tajawal',
            height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(UserManagementState state) {
    print('🎨 بناء واجهة نتائج البحث: isSearching=${state.isSearching}, results=${state.searchResults.length}');
    
    final hasSearchText = _searchController.text.trim().isNotEmpty;
    final hasSearchResults = state.searchResults.isNotEmpty;
    
    print('🔍 حالة البحث: hasSearchText=$hasSearchText, hasSearchResults=$hasSearchResults');

    // إذا كان هناك نص بحث ولكن لا توجد نتائج
    if (hasSearchText && !hasSearchResults) {
      return SingleChildScrollView( 
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64.sp, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد نتائج',
                  style: font18blackbold,
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    'لم يتم العثور على مستخدمين مطابقين لـ "${_searchController.text}"',
                    style: font14grey,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
                ButtonApp(
                  textData: 'مسح البحث',
                  onTop: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔥 إذا كان هناك نص بحث ونتائج، عرض النتائج
    if (hasSearchText && hasSearchResults) {
      print('🎯 عرض نتائج البحث: ${state.searchResults.length} مستخدم');
      return Column(
        children: [
          // 🔥 شريط معلومات نتائج البحث - محسن
          Container(
            padding: EdgeInsets.all(12.r),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 🔥 لمنع الـ overflow
              children: [
                Icon(Icons.search, color: ColorsApp.primaryColor, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.searchResults.length} نتيجة للبحث',
                        style: font13black.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'عن: "${_searchController.text}"',
                        style: font12Grey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('مسح', style: font15primary),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: UsersList(users: state.searchResults),
          ),
        ],
      );
    }

    // إذا لم يكن هناك نص بحث، عرض جميع المستخدمين
    print('📋 عرض جميع المستخدمين: ${state.users.length}');
    return UsersList(users: state.users);
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.r),
        child: UserImportPanel(
          onImportSuccess: () {
            Navigator.pop(context);
            _loadUsers();
          },
        ),
      ),
    );
  }
}