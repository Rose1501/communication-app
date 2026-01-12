/*import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class ContentCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String? fileUrl;
  final bool hasFile;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final Color? color;

  const ContentCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    this.fileUrl,
    this.hasFile = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color ?? ColorsApp.primaryColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرأس
              _buildHeader(),
              const SizedBox(height: 12),
              // الوصف
              _buildDescription(),
              const SizedBox(height: 12),
              // المعلومات السفلية
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: font16blackbold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: font12Grey,
              ),
            ],
          ),
        ),
        if (showActions) _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('تعديل')),
        const PopupMenuItem(value: 'delete', child: Text('حذف')),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      style: font14black,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (hasFile) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorsApp.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, size: 16, color: ColorsApp.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'مرفق',
                  style: font11White.copyWith(color: ColorsApp.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        const Spacer(),
        Icon(Icons.access_time, size: 14, color: ColorsApp.grey),
        const SizedBox(width: 4),
        Text(
          _getTimeAgo(),
          style: font11White.copyWith(color: ColorsApp.grey),
        ),
      ],
    );
  }

  String _getTimeAgo() {
    // تحويل date string إلى time ago
    // هذا تنفيذ مبسط - يمكن تحسينه
    return 'منذ وقت';
  }
}*/