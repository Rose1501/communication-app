import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';
import 'package:myproject/features/signup/view/singnup_data.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: context.read<SignUpBloc>().formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            CustomTextFiled(
              validator: (value) {
                    String error = FunctionApp.validateStudentId(value.toString());
                    if (error.isNotEmpty) return error;
                    return null;
                  },
              hintText: SingnupData.textOne,
              icon: SingnupData.idName,
              keyboardType: TextInputType.number,
              controller: context.read<SignUpBloc>().id,
            ),
            getHeight(20),
            CustomTextFiled(
              validator: (value) {
                    String error = FunctionApp.validateEmail(value.toString());
                    if (error.isNotEmpty) return error;
                    return null;
                  },
              hintText: SingnupData.textTwo,
              icon: SingnupData.email,
              controller: context.read<SignUpBloc>().email,
            ),
            getHeight(20),
            CustomTextFiled(
                validator: (value) {
                  String error = FunctionApp.validatePassword(value.toString());
                  if (error.isNotEmpty) return error;
                  return null;
                },
              hintText: SingnupData.textThree,
              icon: SingnupData.password,
              isPassword: true,
              controller: context.read<SignUpBloc>().password,
            ),
          ],
        ),
      ),
    );
  }
}