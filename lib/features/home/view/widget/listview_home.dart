import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/loading.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:myproject/features/home/view/widget/card_home.dart';
import 'package:myproject/features/home/view/widget/edit_advertisement_form.dart';
import 'package:myproject/features/home/view/widget/republish_advertisement_dialog.dart';
import 'package:user_repository/user_repository.dart';
// قائمة عرض الإعلانات الرئيسية
class ListViewHome extends StatelessWidget {
  final UserModels userModel;
  const ListViewHome({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    print('🔄 بناء ListViewHome');
    var media = MediaQuery.of(context).size;
    
    return Expanded(
      child: BlocBuilder<AdvertisementBloc, AdvertisementState>(
        builder: (context, state) {
          print('📊 حالة الـ Bloc: ${state.runtimeType}');
          
          if (state is AdvertisementLoading) {
            return Center(
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: ColorsApp.primaryColor),
                        SizedBox(height: 16), 
                        Text(
                        'جاري تحميل ...', 
                        style: font20primary,
                        ),
                      ],
                    ),
            );
          } else if (state is AdvertisementLoaded) {
             // 🔍 فلترة الإعلانات حسب المستخدم
            final filteredAdvertisements = _filterAdvertisements(state.advertisements, userModel);
            print('📋 عدد الإعلانات الكلي: ${state.advertisements.length}');
            print('🎯 عدد الإعلانات المفلترة: ${filteredAdvertisements.length}');
            if (filteredAdvertisements.isEmpty) {
              return LoadingWidget(
                url: HomeData.animationHomeLoading,
                height: media.height * .70,
                widget: Text(
                  HomeData.emptyList,//
                  style: font16black.copyWith(fontWeight: FontWeight.w500),
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                print('🔄 سحب للتحديث');
                context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
              },
              color: ColorsApp.primaryColor,
              backgroundColor: Colors.white,
              child: ListView.builder(
                itemCount: filteredAdvertisements.length,
                itemBuilder: (context, index) {
                  final adv = filteredAdvertisements[index];
                  print('📄 بناء إعلان ${index + 1}: ${adv.id}');
                  
                  return _buildAdvertisementCard(context, adv);
                },
              ),
            );
          } else if (state is AdvertisementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('خطأ في التحميل: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
                    },
                    child: const Text(HomeData.errorLoadData),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('لا توجد إعلانات'));
          }
        },
      ),
    );
  }

  // 🔍 دالة فلترة الإعلانات حسب role المستخدم و custom الإعلان
List<AdvertisemenModel> _filterAdvertisements(
  List<AdvertisemenModel> advertisements, 
  UserModels currentUser
) {
  return advertisements.where((adv) {
    // الإعلانات الخاصة بالمستخدم نفسه دائماً معروضة
    final isMyPost = adv.user.email == currentUser.email;
    if (isMyPost) return true;

    // تحليل الـ custom للإعلان
    final advertisementCustom = adv.custom ;
    
    // حسب دور المستخدم الحالي
    switch (currentUser.role) {
      case 'Admin':
        // المدير يرى كل الإعلانات
        print('👑 Admin: يرى جميع الإعلانات');
        return true;
      
      case 'Manager':
        // المدير يرى إعلانات المديرين والإعلانات العامة
        print('👔 Manager: يرى إعلانات المديرين والعامة');
        final isForManagers = advertisementCustom == 'الموظفين' || advertisementCustom == 'Manager';
        final isForDoctors = advertisementCustom == 'أعضاء هيئة التدريس' || advertisementCustom == 'Doctor';
        final isPublic = advertisementCustom == 'الكل' || advertisementCustom == 'عام';
        return isForManagers || isForDoctors || isPublic;
      
      case 'Doctor':
        // أعضاء هيئة التدريس يرون إعلانات التدريس والإعلانات العامة
        print('🎓 Doctor: يرى إعلانات التدريس والعامة');
        final isForDoctors = advertisementCustom == 'أعضاء هيئة التدريس' || advertisementCustom == 'Doctor';
        final isPublic = advertisementCustom == 'الكل' || advertisementCustom == 'عام';
        return isForDoctors || isPublic;
      
      case 'Student':
        // الطلاب يرون إعلانات الطلاب والإعلانات العامة
        print('📚 Student: يرى إعلانات الطلاب والعامة');
        final isForStudents = advertisementCustom == 'الطلاب' || advertisementCustom == 'Student';
        final isPublic = advertisementCustom == 'الكل' || advertisementCustom == 'عام';
        return isForStudents || isPublic;
      
      case 'User':
      default:
        // المستخدم العادي يرى الإعلانات العامة فقط
        print('👤 User: يرى الإعلانات العامة فقط');
        final isPublic = advertisementCustom == 'الكل' || advertisementCustom == 'عام';
        return isPublic;
    }
  }).toList();
}
// بناء بطاقة الإعلان
  Widget _buildAdvertisementCard(BuildContext context, AdvertisemenModel adv) {
    return CardHome(
      userModel: adv.user,
      adv: adv,
      onEdit: () => _showEditDialog(context, adv),
      onDelete: () => _showDeleteConfirmation(context, adv.id),
      onRepublish: () => _showRepublishDialog(context, adv),
      showDepartmentInfo: _shouldShowTargetingInfo(adv, userModel),
    );
  }

  // عرض نافذة إعادة النشر
  void _showRepublishDialog(BuildContext context, AdvertisemenModel advertisement) {
    showDialog(
      context: context,
      builder: (context) {
        return RepublishAdvertisementDialog(
          advertisement: advertisement,
          currentUser: userModel,
        );
      },
    );
  }
}

// 🔧 التحقق إذا كان يجب عرض أزرار التعديل والحذف
  bool _shouldShowTargetingInfo(AdvertisemenModel adv, UserModels currentUser) {
    // عرض للمديرين والإداريين أو لناشر الإعلان
    return (currentUser.role == 'Admin' || 
            currentUser.role == 'Manager' ) &&
            adv.custom.isNotEmpty ;
  }
  // عرض تأكيد الحذف
  void _showDeleteConfirmation(BuildContext context, String advertisementId) async {
    print('🗑️ بدء عملية الحذف للإعلان: $advertisementId');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من أنك تريد حذف هذا الإعلان؟'),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ تم إلغاء الحذف');
              Navigator.pop(context, false);
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              print('✅ تم تأكيد الحذف');
              Navigator.pop(context, true);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeDelete(context, advertisementId);
    }
  }
  
// تنفيذ الحذف
  void _executeDelete(BuildContext context, String advertisementId) {
    try {
      print('🚀 إرسال حدث الحذف إلى Bloc');
      final advertisementBloc = BlocProvider.of<AdvertisementBloc>(context, listen: false);
      advertisementBloc.add(DeleteAdvertisementEvent(advertisementId: advertisementId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري حذف الإعلان...')),
      );
    } catch (e) {
      print('💥 خطأ في إرسال حدث الحذف: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }
// عرض نافذة تعديل الإعلان
  void _showEditDialog(BuildContext context, AdvertisemenModel advertisement) {
    print('✏️ فتح نافذة التعديل للإعلان: ${advertisement.id}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الإعلان'),
          insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.1,
        ),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
          content: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 500.w,
            ),
            child: EditAdvertisementForm(advertisement: advertisement,currentUser:advertisement.user,),
          ),
        ),
        );
      },
    );
  }