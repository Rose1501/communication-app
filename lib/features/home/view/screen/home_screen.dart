// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:myproject/features/home/view/widget/containre_line.dart';
import 'package:myproject/features/home/view/widget/home_bloc_listener.dart';
import 'package:myproject/features/home/view/widget/listview_home.dart';
import 'package:myproject/features/home/view/widget/new_post_bar.dart';
import 'package:myproject/features/profile/view/screen/profile_floating_page.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:myproject/features/manager/view/screen/Add_New_Advertisement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // مؤشر للعنصر المحدد في شريط التنقل

  @override
  void initState() {
    super.initState();
    // تحميل بيانات المستخدم والإعلانات عند بدء التشغيل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUserBloc = context.read<MyUserBloc>();
      final authBloc = context.read<AuthenticationBloc>();

      if (authBloc.state.status == AuthenticationStatus.authenticated) {
        // إذا كان المستخدم معتمدًا ولكن بياناته غير محملة
        if (myUserBloc.state.status != MyUserStatus.success) {
          myUserBloc.add(GetMyUser());
        }
      }
      context.read<AdvertisementBloc>().add(LoadAdvertisementsEvent());
    });
  }

  // دالة لتغيير الصفحة عند النقر على عنصر في شريط التنقل
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // التنقل بين الصفحات حسب العنصر المحدد ودور المستخدم
    navigateToScreen(index, _getUserRole(),context);
  }

  String _getUserRole() {
    // الحصول على دور المستخدم من الـBloc إذا كان متوفرًا
    final myUserState = context.read<MyUserBloc>().state;
    if (myUserState.status == MyUserStatus.success &&
        myUserState.user != null) {
      return myUserState.user!.role;
    }
    return 'User';
  }

  

  void _navigateToAddAdvertisement(BuildContext context) {
    final advertisementBloc = context.read<AdvertisementBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewAdvertisement()),
    ).then((_) {
      // عند العودة من شاشة الإضافة، تحديث قائمة المناشير
      advertisementBloc.add(LoadAdvertisementsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, authState) {
            if (authState.status == AuthenticationStatus.authenticated) {
              final myUserBloc = context.read<MyUserBloc>();
              if (myUserBloc.state.status != MyUserStatus.success) {
                myUserBloc.add(GetMyUser());
              }
            }
          },
        ),
        BlocListener<AdvertisementBloc, AdvertisementState>(
          listener: (context, state) {
            // يمكنك إضافة أي تفاعل مع تغيرات حالة AdvertisementBloc هنا
            if (state is AdvertisementError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AdvertisementDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الإعلان بنجاح')),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<MyUserBloc, MyUserState>(
        builder: (context, myUserState) {
          if (myUserState.status == MyUserStatus.failure) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('فشل في تحميل البيانات'),
                    ElevatedButton(
                      onPressed: () {
                        final authBloc = context.read<AuthenticationBloc>();
                        if (authBloc.state.status ==
                            AuthenticationStatus.authenticated) {
                          context.read<MyUserBloc>().add(GetMyUser());
                        }
                      },
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (myUserState.status != MyUserStatus.success ||
              myUserState.user == null) {
            return Scaffold(
              body: Center(
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
              ),
              backgroundColor: ColorsApp.white,
            );
          }
          final userModel = myUserState.user!;

          return HomeBlocListener(
            child: Scaffold(
              backgroundColor: ColorsApp.white,
              appBar: CustomAppBarTitle(
                title: "الصفحة الرئيسية",
                showButton: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                      Column(
                        children: [
                          NewPostBar(
                            onTap: () => _navigateToAddAdvertisement(context),
                            userModel: userModel,
                            onProfileTap: () {
                              // للذهاب إلى صفحة البروفايل عند النقر على الصورة
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BlocProvider.value(
                                        value: BlocProvider.of<AuthBloc>(
                                          context,
                                        ), // تمرير الـ AuthBloc الحالي
                                        child: UserProfileFloatingPage(),
                                      ),
                                ),
                              );
                            },
                          ),
                          ContainreLine(),
                        ],
                      ),
                    BlocBuilder<AdvertisementBloc, AdvertisementState>(
                      builder: (context, state) {
                        return ListViewHome(userModel: userModel);
                      },
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                userRole: userModel.role,
              ),
            ),
          );
        },
      ),
    );
  }
}
