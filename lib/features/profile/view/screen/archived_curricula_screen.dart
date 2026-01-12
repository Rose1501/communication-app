import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:myproject/features/profile/view/widget/archived_curriculum_card.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

class ArchivedCurriculaScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const ArchivedCurriculaScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<ArchivedCurriculaScreen> createState() => _ArchivedCurriculaScreenState();
}

class _ArchivedCurriculaScreenState extends State<ArchivedCurriculaScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadArchivedCurricula();
  }

  void _loadArchivedCurricula() {
    context.read<TeacherDataBloc>().add(
      LoadArchivedCurriculaEvent(widget.teacherId),
    );
  }

  void _searchCurricula(String query) {
    if (query.isEmpty) {
      _loadArchivedCurricula();
    } else {
      context.read<TeacherDataBloc>().add(
        SearchArchivedCurriculaEvent(
          teacherId: widget.teacherId,
          query: query,
        ),
      );
    }
  }

  void _deleteArchivedCurriculum(String archiveId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنهج المؤرشف'),
        content: const Text('هل أنت متأكد من حذف هذا المنهج المؤرشف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<TeacherDataBloc>().add(
                DeleteArchivedCurriculumEvent(
                  teacherId: widget.teacherId,
                  archiveId: archiveId,
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openFile(String fileUrl) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فتح الملف: $fileUrl'),
        backgroundColor: ColorsApp.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: 'المناهج المؤرشفة'),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),
          
          // قائمة المناهج المؤرشفة
          Expanded(
            child: BlocConsumer<TeacherDataBloc, TeacherDataState>(
              listener: (context, state) {
                if (state is TeacherDataOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ColorsApp.green,
                    ),
                  );
                  _loadArchivedCurricula();
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
              builder: (context, state) {
                if (state is TeacherDataLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeacherDataError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: font16black,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: _loadArchivedCurricula,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                List<ArchivedCurriculumModel> curricula = [];
                
                if (state is ArchivedCurriculaLoaded) {
                  curricula = state.curricula;
                } else if (state is SearchArchivedCurriculaResult) {
                  curricula = state.results;
                  _isSearching = true;
                } else {
                  curricula = [];
                }

                if (curricula.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadArchivedCurricula(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: curricula.length,
                    itemBuilder: (context, index) {
                      final curriculum = curricula[index];
                      return ArchivedCurriculumCard(
                        curriculum: curriculum,
                        onDelete: () => _deleteArchivedCurriculum(curriculum.id),
                        onOpenFile: () => _openFile(curriculum.fileUrl),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في المناهج المؤرشفة...',
                prefixIcon: Icon(Icons.search, color: ColorsApp.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: ColorsApp.red),
                        onPressed: () {
                          _searchController.clear();
                          _searchCurricula('');
                          setState(() => _isSearching = false);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorsApp.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorsApp.primaryColor, width: 2),
                ),
              ),
              onChanged: (value) {
                _searchCurricula(value);
                setState(() => _isSearching = value.isNotEmpty);
              },
            ),
          ),
          if (_isSearching)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  _searchCurricula('');
                  setState(() => _isSearching = false);
                },
                child: Text('إلغاء', style: font14black.copyWith(color: ColorsApp.primaryColor)),
              ),
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
          Icon(Icons.archive, size: 80, color: ColorsApp.grey),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مناهج مؤرشفة',
            style: font18blackbold,
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم عرض المناهج المؤرشفة هنا',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}