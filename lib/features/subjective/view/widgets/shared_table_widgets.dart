import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

// ========== مكونات الجدول  ==========

class GroupsTabsWidget extends StatelessWidget {
  final List<String> groupNames;
  final int selectedIndex;
  final ValueChanged<int> onGroupSelected;

  const GroupsTabsWidget({
    super.key,
    required this.groupNames,
    required this.selectedIndex,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: groupNames.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(groupNames[index]),
              selected: isSelected,
              onSelected: (selected) => onGroupSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class StatItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatItemWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? ColorsApp.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: font12black.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: font10Grey),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.people_outline,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(title, style: font18blackbold),
          const SizedBox(height: 8),
          Text(message, style: font14grey),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add),
              label: Text(actionText ?? 'إضافة جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}