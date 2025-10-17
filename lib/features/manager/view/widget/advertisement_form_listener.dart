import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';

class AdvertisementFormListener extends StatelessWidget {
  const AdvertisementFormListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdvertisementFormBloc, AdvertisementFormState>(
      listenWhen: (previous, current) =>
          current is AdvertisementFormSuccess || current is AdvertisementFormFailure,
      listener: (context, state) {
        if (state is AdvertisementFormSuccess) {
          // تأخير الإغلاق قليلاً لإظهار رسالة النجاح
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pop();
          });
          ShowWidget.showMessage(
            context,
            'تم نشر الإعلان بنجاح',
            Colors.green,
            font13White,
          );
          Navigator.of(context).pop();
        } else if (state is AdvertisementFormFailure) {
          ShowWidget.showMessage(
            context,
            state.error,
            Colors.red,
            font13White,
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}