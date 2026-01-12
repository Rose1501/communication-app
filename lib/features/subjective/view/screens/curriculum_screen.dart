import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/features/subjective/view/screens/new_curriculum_screen.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class CurriculumScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final String userId;

  const CurriculumScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.userId,
  });

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurricula();
  }

  void _loadCurricula() {
    context.read<SubjectiveBloc>().add(
      LoadCurriculaEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
      ),
    );
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: '${widget.group.name} - المناهج'),
      floatingActionButton: widget.userRole == 'Doctor'
          ? FloatingActionButton(
              onPressed: _addCurriculum,
              backgroundColor: ColorsApp.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: MultiBlocListener(
        listeners: [
          BlocListener<TeacherDataBloc, TeacherDataState>(
          listener: (context, state) {
            if (state is TeacherDataOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorsApp.green,
                ),
              );
            }
            if (state is TeacherDataError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorsApp.red,
                ),
              );
            }
          },
        ),
        ],
        child: BlocConsumer<SubjectiveBloc, SubjectiveState>(
          listener: (context, state) {
            if (state is SubjectiveOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorsApp.green,
                ),
              );
              _loadCurricula();
            }
            if (state is SubjectiveError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorsApp.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubjectiveLoading && state is! CurriculumLoadSuccess) {
              return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
            }
        
            if (state is SubjectiveError && state is! CurriculumLoadSuccess) {
              return _buildErrorState(state.message);
            }
        
            if (state is CurriculumLoadSuccess) {
              if (state.curricula.isEmpty) {
                return _buildEmptyState();
              }
        
              return RefreshIndicator(
                color: ColorsApp.primaryColor,
                onRefresh: () async => _loadCurricula(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.curricula.length,
                  itemBuilder: (context, index) {
                    final curriculum = state.curricula[index];
                    return _buildCurriculumCard(curriculum);
                  },
                ),
              );
            }
        
            return const SizedBox.shrink();
          },
        ),
      ),
    );
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
            onPressed: _loadCurricula,
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
          Icon(Icons.menu_book, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد مناهج',
            style: font18blackbold,
          ),
          const SizedBox(height: 8),
          Text(
            widget.userRole == 'Doctor'
                ? 'يمكنك إضافة المناهج من خلال زر الإضافة'
                : 'سيتم عرض المناهج هنا عندما يضيفها الأستاذ',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumCard(CurriculumModel curriculum) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curriculum.description.isNotEmpty 
                            ? curriculum.description 
                            : 'منهج تعليمي',
                        style: font16blackbold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(curriculum.time),
                            style: font12Grey,
                          ),
                          if (curriculum.file.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.attach_file, size: 14, color: ColorsApp.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'مرفق',
                              style: font12black.copyWith(color: ColorsApp.primaryColor),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.userRole == 'Doctor')
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCurriculumAction(value, curriculum),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      )),
                      const PopupMenuItem(
                      value: 'archive', 
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text('أرشفة'),
                        ],
                      ),),
                      const PopupMenuItem(value: 'delete', child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      )),
                    ],
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (curriculum.file.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openFile(curriculum.file),
                icon: const Icon(Icons.file_open, color: Colors.white),
                label: const Text('فتح الملف', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ========== دوال تنفيذ الأزرار ==========

  void _addCurriculum() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCurriculumScreen(
          course: widget.course,
          selectedGroups: [widget.group],
          doctorId: widget.userId,
        ),
      ),
    );
    if (result == true) {
      _loadCurricula();
    }
  }

  void _handleCurriculumAction(String action, CurriculumModel curriculum) {
    switch (action) {
      case 'edit':
        _editCurriculum(curriculum);
        break;
      case 'archive':
        _archiveCurriculum(curriculum);
        break;
      case 'delete':
        _deleteCurriculum(curriculum);
        break;
    }
  }

  void _editCurriculum(CurriculumModel curriculum) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewCurriculumScreen(
        course: widget.course,
        selectedGroups: [widget.group],
        doctorId: widget.userId,
        curriculumToEdit: curriculum, // 🔥 تمرير المنهج للتعديل
      ),
    ),
  ).then((result) {
    if (result == true) {
      _loadCurricula();
    }
  });
}

void _archiveCurriculum(CurriculumModel curriculum) async {
  // 1. عرض مربع حوار التأكيد
  final confirmed = await CustomDialog.showConfirmation(
    context: context,
    title: 'أرشفة المنهج',
    message: 'هل أنت متأكد من أرشفة هذا المنهج؟',
    confirmText: 'أرشفة',
    cancelText: 'إلغاء',
  );
  
  if (!confirmed) return;
  
  // 2. عرض مربع حوار لإدخال وصف الأرشفة (اختياري)
  final archiveDescription = await _showArchiveDescriptionDialog(context);
  // إذا ضغط المستخدم إلغاء في مربع الوصف، لا نتابع
  if (archiveDescription == null && context.mounted) {
    return;
  }
  
  // 3. جمع البيانات اللازمة من CourseModel و GroupModel
  final courseName = widget.course.name; // اسم المادة من CourseModel
  final doctorId = widget.group.idDoctor;  // بيانات الدكتور من GroupModel
  final doctorName = widget.group.nameDoctor;
  
  // 4. إنشاء نموذج الأرشيف
  final archivedCurriculum = ArchivedCurriculumModel(
    id: '', // سيتم توليده تلقائياً في الريبوستري
    fileUrl: curriculum.file, // رابط ملف المنهج (إجباري)
    archivedAt: DateTime.now(), // تاريخ الأرشفة الحالي
    courseName: courseName, // اسم المادة من CourseModel
    archiveDescription: archiveDescription?.trim().isEmpty == true 
        ? null 
        : archiveDescription?.trim(), // وصف الأرشفة (اختياري)
  );
  
  // 5. إرسال حدث الأرشيف إلى البلوك
  if (context.mounted) {
    context.read<TeacherDataBloc>().add(
      ArchiveCurriculaEvent(
        teacherId: doctorId,
        teacherName: doctorName,
        curricula: [archivedCurriculum],
      ),
    );
  }
  
  // 6. (اختياري) حذف المنهج من القائمة الحالية بعد الأرشفة
  final deleteConfirmed = await CustomDialog.showConfirmation(
    context: context,
    title: 'حذف المنهج',
    message: 'هل تريد حذف المنهج من القائمة الحالية بعد الأرشفة؟',
    confirmText: 'نعم، احذف',
    cancelText: 'لا، أبقيه',
  );
  
  if (deleteConfirmed && context.mounted) {
    context.read<SubjectiveBloc>().add(
      DeleteCurriculumEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
        curriculumId: curriculum.id,
      ),
    );
  }
}

  // دالة لعرض مربع حوار لإدخال وصف الأرشفة
Future<String?> _showArchiveDescriptionDialog(BuildContext context) async {
  String description = '';
  
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('وصف الأرشفة'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'أدخل وصفاً للأرشفة (اختياري)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => description = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, description),
            child: const Text('موافق'),
          ),
        ],
      );
    },
  );
}

  void _deleteCurriculum(CurriculumModel curriculum) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف المنهج',
      message: 'هل أنت متأكد من حذف هذا المنهج؟',
      confirmText: ' احذف',
      cancelText: 'إلغاء',
    );
    if (!confirmed) return;
    context.read<SubjectiveBloc>().add(
      DeleteCurriculumEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
        curriculumId: curriculum.id,
      ),
    );
  }

  Future<void> _openFile(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح الرابط: $fileUrl'),
            backgroundColor: ColorsApp.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} - ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}