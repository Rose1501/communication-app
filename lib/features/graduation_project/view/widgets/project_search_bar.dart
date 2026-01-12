import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/view/widgets/search_results_screen.dart';
import 'package:user_repository/user_repository.dart';

/// شريط البحث عن المشاريع
/// يسمح للطلاب بالانضمام إلى المشاريع باستخدام كود الانضمام
/// ويسمح للمشرفين بالبحث عن مستخدمين وإظهار ملفهم الشخصي
class ProjectSearchBar extends StatefulWidget {
  final UserModels currentUser;

  const ProjectSearchBar({super.key, required this.currentUser});

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  final _searchController = TextEditingController();
  bool _isJoined = false; // لتتبع ما إذا كان الطالب قد انضم بالفعل

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// مسح البحث
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isJoined = false;
    });
  }

  /// معالجة البحث عند الضغط على زر البحث
  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // إذا كان المستخدم طالبًا والاستعلام يبدو ككود (مثلاً 8 أحرف)، حاول الانضمام
    if (widget.currentUser.role == 'Student' && query.length == 8 && RegExp(r'^[A-Z0-9]+$').hasMatch(query)) {
      context.read<ProjectBloc>().add(JoinProject(joinCode: query, studentId: widget.currentUser.userID));
      setState(() {
        _isJoined = true;
      });
    } 
    // خلاف ذلك، ابحث عن مستخدم وانتقل إلى شاشة النتائج
    else {
      // في المكان الذي تستدعي فيه الشاشة
      showDialog(
        context: context,
        builder: (context) => SearchResultsScreen(
        currentUser: widget.currentUser,
        searchQuery: query,
        ),
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط البحث
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearchSubmitted(),
                  decoration: InputDecoration(
                    hintText:'ابحث عن مستخدم بالاسم أو رقم القيد...',
                    prefixIcon: Icon(Icons.search, color: ColorsApp.primaryColor),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (value.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward, color: ColorsApp.primaryColor),
                                onPressed: _onSearchSubmitted,
                              ),
                            ],
                          );
                        },
                      ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      
        // عرض رسالة الانضمام الناجحة للطلاب
        if (_isJoined)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: Text('أنت الآن عضو في المشروع', style: font14black)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _isJoined = false;
                          });
                          context.pushAndRemoveUntil(Routes.home);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


