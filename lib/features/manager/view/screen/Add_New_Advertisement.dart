import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';
import 'package:myproject/features/manager/view/widget/advertisement_form.dart';
import 'package:myproject/features/manager/view/widget/advertisement_form_listener.dart';

class AddNewAdvertisement extends StatelessWidget {
  const AddNewAdvertisement({super.key});

  @override
  Widget build(BuildContext context) {
    final myUserState = context.watch<MyUserBloc>().state;
    if (myUserState.status != MyUserStatus.success || myUserState.user == null) {
      return Scaffold(
        appBar: CustomAppBarTitle(title: 'إضافة إعلان جديد'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = myUserState.user!;

    return BlocProvider.value(
      value: context.read<AdvertisementFormBloc>(),
    child:  Scaffold(
    appBar:  CustomAppBarTitle(title: 'إضافة إعلان جديد'),
    body: Stack( 
      children: [
        AdvertisementForm(currentUser: user),
        const AdvertisementFormListener(),
          ],
        ),
      ),
    );
  }
}
