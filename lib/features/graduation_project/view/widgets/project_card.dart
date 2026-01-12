/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';

/// بطاقة عرض المشروع
/// تستخدم لعرض معلومات موجزة عن المشروع في القائمة
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final String userRole;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.userRole,
    this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: العنوان والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: font18blackbold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorsApp.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorsApp.primaryColor),
                    ),
                  ),
                ],
              ),
              getHeight(12),
              // الصف الأوسط: نبذة عن المشروع
              Text(
                project.description,
                style: font14grey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              getHeight(16),
              // الصف السفلي: إحصائيات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    icon: Icons.group,
                    label: '${project.supervisors.length} مشرف',
                    color: ColorsApp.primaryColor,
                  ),
                  _buildInfoChip(
                    icon: Icons.school,
                    label: '${project.studentIds.length} طالب',
                    color: Colors.teal,
                  ),
                  if (userRole == 'Manager')
                    BlocBuilder<ProjectBloc, ProjectState>(
                      builder: (context, state) {
                        if (state is ProjectSettingsLoaded) {
                          return _buildInfoChip(
                            icon: Icons.vpn_key,
                            label: state.settings.joinCode,
                            color: Colors.deepOrange,
                          );
                        }
                        return _buildInfoChip(
                          icon: Icons.vpn_key,
                          label: '----',
                          color: Colors.deepOrange,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء شريط المعلومات
  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        getWidth(5),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}*/