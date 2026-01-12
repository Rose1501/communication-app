import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/widgets/group_card_widget.dart';
import 'package:myproject/features/subjective/view/widgets/groups_cache_service.dart';
import 'package:semester_repository/semester_repository.dart';

class DoctorGroupsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorGroupsScreen({super.key, required this.doctorId});

  @override
  State<DoctorGroupsScreen> createState() => _DoctorGroupsScreenState();
}

class _DoctorGroupsScreenState extends State<DoctorGroupsScreen> {
  final GroupsCacheService _cacheService = GroupsCacheService();
  List<CoursesModel> _cachedCourses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorGroups();
  }

  void _loadDoctorGroups({bool forceRefresh = false}) {
    if (!forceRefresh) {
      final cachedData = _cacheService.getDoctorGroups(widget.doctorId);
      if (cachedData != null && cachedData.isNotEmpty) {
        setState(() {
          _cachedCourses = cachedData;
        });
        print('✅ تم تحميل ${_cachedCourses.length} مادة من التخزين المحلي للدكتور');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectiveBloc>().add(LoadDoctorGroupsEvent(widget.doctorId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubjectiveBloc, SubjectiveState>(
      listener: (context, state) {
        if (state is DoctorGroupsLoadSuccess) {
          setState(() {
            _isLoading = false;
            _cachedCourses = state.courses;
          });
          _cacheService.cacheDoctorGroups(widget.doctorId, state.courses);
          _cacheService.printCacheInfo();
        }

        if (state is SubjectiveError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (_isLoading && _cachedCourses.isEmpty) {
          return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
        }

        if (state is SubjectiveError && _cachedCourses.isEmpty) {
          return _buildErrorState(state.message);
        }

        final allGroups = _cachedCourses.expand((course) => course.groups).toList();
        
        if (allGroups.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: ColorsApp.primaryColor,
          onRefresh: () async {
            _loadDoctorGroups(forceRefresh: true);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allGroups.length,
            itemBuilder: (context, index) {
              final group = allGroups[index];
              final course = _findCourseForGroup(group);
              
              if (course == null) {
                return const SizedBox.shrink();
              }

              return GroupCardWidget(
                course: course,
                group: group,
                userRole: 'Doctor',
                onTap: () => _navigateToGroupContent(context, course, group),
                onStudentsTap: () => _showStudentsList(context, group),
                onAdvertisementsTap: () => _navigateToAdvertisements(context, course, group),
                onCurriculumTap: () => _navigateToCurriculum(context, course, group),
                onAssignmentsTap: () => _navigateToAssignments(context, course, group),
                onMarksTap: () => _navigateToMarks(context, course, group),
              );
            },
          ),
        );
      },
    );
  }

  CoursesModel? _findCourseForGroup(GroupModel group) {
    for (final course in _cachedCourses) {
      final groupInCourse = course.groups.firstWhere(
        (g) => g.id == group.id,
        orElse: () => GroupModel.empty,
      );
      if (groupInCourse.isNotEmpty) {
        return course;
      }
    }
    return null;
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: font16black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadDoctorGroups(forceRefresh: true),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد مجموعات مسندة إليك',
            style: font18blackbold,
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض المجموعات هنا عندما يتم إسنادها إليك',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🧭 دوال التنقل باستخدام NavigatorExtension
  void _navigateToGroupContent(BuildContext context, CoursesModel course, GroupModel group) {
    context.pushNamed(
      Routes.groupContent,
      arguments: {
        'course': course,
        'group': group,
        'userRole': 'Doctor',
        'userId': widget.doctorId,
      },
    );
  }

  void _showStudentsList(BuildContext context, GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قائمة الطلاب'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: group.students.isEmpty
              ? const Center(child: Text('لا يوجد طلاب في هذه المجموعة'))
              : ListView.builder(
                  itemCount: group.students.length,
                  itemBuilder: (context, index) {
                    final student = group.students[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorsApp.primaryColor,
                        child: Text(
                          student.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text('رقم القيد: ${student.studentId}'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _navigateToAdvertisements(BuildContext context, CoursesModel course, GroupModel group) {
    context.pushNamed(
      Routes.advertisements,
      arguments: {
        'course': course,
        'group': group,
        'userRole': 'Doctor',
        'userId': widget.doctorId,
      },
    );
  }

  void _navigateToCurriculum(BuildContext context, CoursesModel course, GroupModel group) {
    context.pushNamed(
      Routes.curriculum,
      arguments: {
        'course': course,
        'group': group,
        'userRole': 'Doctor',
        'userId': widget.doctorId,
      },
    );
  }

  void _navigateToAssignments(BuildContext context, CoursesModel course, GroupModel group) {
    context.pushNamed(
      Routes.assignments,
      arguments: {
        'course': course,
        'group': group,
        'userRole': 'Doctor',
        'userId': widget.doctorId,
      },
    );
  }

  void _navigateToMarks(BuildContext context, CoursesModel course, GroupModel group) {
    context.pushNamed(
      Routes.marks,
      arguments: {
        'course': course,
        'group': group,
        'userRole': 'Doctor',
        'userId': widget.doctorId,
      },
    );
  }
}