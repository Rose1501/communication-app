import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:semester_repository/semester_repository.dart';

class GroupCardWidget extends StatelessWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final VoidCallback onTap;
  final VoidCallback? onStudentsTap;
  final VoidCallback? onAdvertisementsTap;
  final VoidCallback? onCurriculumTap;
  final VoidCallback? onAssignmentsTap;
  final VoidCallback? onMarksTap;

  const GroupCardWidget({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.onTap,
    this.onStudentsTap,
    this.onAdvertisementsTap,
    this.onCurriculumTap,
    this.onAssignmentsTap,
    this.onMarksTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorsApp.primaryColor,
                ColorsApp.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ رأس البطاقة - كود المادة واسمها
              _buildCourseHeader(),
              const SizedBox(height: 12),
              
              // 👥 اسم المجموعة والمشرف
              _buildGroupInfo(),
              const SizedBox(height: 16),
              
              // 🎯 شريط الأيقونات السريعة
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // كود المادة
        Text(
          course.codeCs,
          style: font16White.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        
        // اسم المادة
        Text(
          course.name,
          style: font20whitebold.copyWith(
            fontSize: 18,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGroupInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // اسم المجموعة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: font16White.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  group.nameDoctor,
                  style: font16White.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // عدد الطلاب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${group.students.length}',
                  style: font11White.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        // الأيقونات
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionIcon(
              icon: Icons.people_alt,
              label: 'الطلاب',
              onTap: onStudentsTap,
            ),
            _buildActionIcon(
              icon: Icons.campaign,
              label: 'الإعلانات',
              onTap: onAdvertisementsTap,
            ),
            _buildActionIcon(
              icon: Icons.menu_book,
              label: 'المناهج',
              onTap: onCurriculumTap,
            ),
            _buildActionIcon(
              icon: Icons.assignment,
              label: 'الواجبات',
              onTap: onAssignmentsTap,
            ),
            _buildActionIcon(
              icon: Icons.grade,
              label: 'الدرجات',
              onTap: onMarksTap,
            ),
          ],
        ),
        
        // التسميات
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionLabel('الطلاب'),
            _buildActionLabel('الإعلانات'),
            _buildActionLabel('المناهج'),
            _buildActionLabel('الواجبات'),
            _buildActionLabel('الدرجات'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildActionLabel(String text) {
    return Text(
      text,
      style: font11White.copyWith(
        fontSize: 9,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}