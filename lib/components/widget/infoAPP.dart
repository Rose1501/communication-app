// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/widget/cardInfo.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';


class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTitle(title: 'نبذة عن التطبيق'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبا بك في تطبيق التواصل الإلكتروني',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorsApp.primaryColor,
                  ),
                  textAlign: TextAlign.right, // محاذاة النص إلى اليمين
                ),
                const SizedBox(height: 16),
                const Text( 'هذا التطبيق مصمم لتلبية احتياجات الطلاب وأعضاء هيئة التدريس، حيث يوفر مجموعة من الخدمات المفيدة والمهمة', 
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right, // محاذاة النص إلى اليمين
                ),
              ],
            ),
            const SizedBox(height: 24),

            // خدمات الطلاب
            ExpansionTile(
              title: Align(
                alignment: Alignment.centerRight, // محاذاة النص إلى اليمين
                child: Text(
                  'خدمات الطلبة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: ColorsApp.primaryColor,
                  ),
                ),
              ),
              children:  [
                CustomCardInfo(
                  titleCard: 'عرض تقسيم درجات المواد',
                  titleSubCard: ' الوصول إلى درجات المادة',
                  icon: Icon(Icons.edit, color: ColorsApp.primaryColor),
                ),
                CustomCardInfo(
                  titleCard: 'عرض المناهج',
                  titleSubCard:
                      'استعرض المناهج الدراسية والتفاصيل الخاصة بكل مادة',
                  icon: Icon(Icons.library_books, color: ColorsApp.primaryColor),
                ),
                CustomCardInfo(
                  titleCard: 'عرض المجموعات الدراسية',
                  titleSubCard:
                      'يمكن الوصول للمجموعات الدراسية الخاصة بالطالب',
                  icon: Icon(Icons.group, color: ColorsApp.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // خدمات أعضاء هيئة التدريس
            ExpansionTile(
              title: Align(
                alignment: Alignment.centerRight, // محاذاة النص إلى اليمين
                child: Text(
                  'خدمات أعضاء هيئة التدريس',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: ColorsApp.primaryColor,
                  ),
                ),
              ),
              children: [
                CustomCardInfo(
                  titleCard: 'نشر إعلانات في مجموعات الدراسية',
                  titleSubCard:
                      'إضافة إعلان حول إضافة واجب جديد أو نشر إعلان حول محاضرات الدراسية',
                  icon: Icon(Icons.chrome_reader_mode, color: ColorsApp.primaryColor),
                ),
                CustomCardInfo(
                  titleCard: 'إرفاق المناهج الدراسية',
                  titleSubCard: 'تحديث وإدارة المناهج الدراسية',
                  icon: Icon(Icons.library_books, color: ColorsApp.primaryColor),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // خدمات الدروس والإمتحانات
            ExpansionTile(
              title: Align(
                alignment: Alignment.centerRight, // محاذاة النص إلى اليمين
                child: Text(
                  'خدمات الدراسة والإمتحانات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: ColorsApp.primaryColor,
                  ),
                ),
              ),
              children: [
                CustomCardInfo(
                  titleCard: 'رد على الطلبات',
                  titleSubCard: 'رد على طلبات التي تم إرسالها من طلبة',
                  icon: Icon(Icons.admin_panel_settings, color: ColorsApp.primaryColor),
                ),
                CustomCardInfo(
                  titleCard: ' إدارة الإعلانات خاصة بأعضاء هيئة التدريس',
                  titleSubCard:
                      'إضافة إعلانات خاصة لا يتم عرضها الإ الموظفين داخل القسم',
                  icon: Icon(Icons.chrome_reader_mode, color: ColorsApp.primaryColor),
                ),
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}
