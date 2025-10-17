  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';

Widget buildTargetDropdown(BuildContext context, AdvertisementFormState state) {
    final custom = state is AdvertisementFormData ? state.custom : 'الكل';
    
    return PopupMenuButton<String>(
      onSelected: (value) {
        context.read<AdvertisementFormBloc>().add(
          AdvertisementFormTargetChanged(value)
        );
      },
      itemBuilder: (BuildContext context) {
        return const [
          PopupMenuItem<String>(
            value: 'الكل',
            child: Text('الكل', style: TextStyle(fontSize: 18)),
          ),
          PopupMenuItem<String>(
            value: 'الطلاب',
            child: Text('الطلاب', style: TextStyle(fontSize: 18)),
          ),
          PopupMenuItem<String>(
            value: 'أعضاء هيئة التدريس',
            child: Text('أعضاء هيئة التدريس', style: TextStyle(fontSize: 18)),
          ),
          PopupMenuItem<String>(
            value: 'الموظفين',
            child: Text('الموظفين', style: TextStyle(fontSize: 18)),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(custom, style: font14black),
            getWidth(8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }