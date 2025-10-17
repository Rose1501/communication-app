import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';
import 'package:myproject/features/manager/view/widget/advertisement_form_content.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdvertisementForm extends StatelessWidget {
  final UserModels currentUser;
  const AdvertisementForm({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertisementFormBloc(
        advertisementRepository: context.read<AdvertisementBloc>().advertisementRepository,
      ),
      child: AdvertisementFormContent(currentUser: currentUser),
    );
  }
}
