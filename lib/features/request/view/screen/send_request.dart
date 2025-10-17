import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/request/view/request_data.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';
import 'package:myproject/features/request/view/widget/texts_send.dart';
import 'package:request_repository/request_repository.dart';
import 'package:uuid/uuid.dart';

class SendRequest extends StatefulWidget {
  const SendRequest({super.key});

  @override
  State<SendRequest> createState() => _SendRequestState();
}

class _SendRequestState extends State<SendRequest> {
  String? selectedRequestType;
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isLoading = false; 
  bool _hasNavigatedBack = false;

  void _onFormValidityChanged(bool isValid) {
    setState(() {
      _isFormValid = isValid;
    });
  }

  void _onDescriptionFocusChanged(bool isFocused) {
    setState(() {
      _isFormValid  = isFocused;
    });
  }

  Future<void> _addStudentRequest() async {
    if (_formKey.currentState!.validate() && selectedRequestType != null) {
      // التحقق من الاتصال قبل الإرسال
      final isConnected = await RequestUtils.checkInternetConnection(context);
      if (!isConnected) {
        ShowWidget.showMessage(context, noNet, Colors.black,font11White);
        return;
      }

      final myUserState = context.read<MyUserBloc>().state;
      
      if (myUserState.status == MyUserStatus.success && myUserState.user != null) {
        final user = myUserState.user!;
        final requestId = Uuid().v1();
        final request = StudentRequestModel(
          id: requestId, 
          studentID: user.userID,
          name: user.name,
          requestType: selectedRequestType!,
          description: descriptionController.text,
          status: 'انتظار',
          dateTime: DateTime.now(),
        );

        print('🚀 بدء إرسال الطلب...');
        setState(() {
          _isLoading = true; // 🔥 تفعيل حالة التحميل
        });

        try {
          // إرسال الطلب
          context.read<RequestBloc>().add(SendRequestEvent(request));
          
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ShowWidget.showMessage(
            context,
            'فشل في إرسال الطلب',
            Colors.red,
            font13White,
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ShowWidget.showMessage(
        context,
        'خطأ في تحميل بيانات المستخدم',
        Colors.red,
        font13White,
      );
    }
    } else {
      ShowWidget.showMessage(
      context,
      'يرجى ملء جميع الحقول المطلوبة',
      Colors.red,
      font13White,
    );
    }
  }

  void _safePopBack() {
    if (!_hasNavigatedBack && mounted) {
      _hasNavigatedBack = true;
      Navigator.pop(context, true);
    }
  }

Widget _buildSubmitButton(BuildContext context) {
    final requestState = context.watch<RequestBloc>().state;
    final isLoading = requestState is RequestLoading;
    final hasValidData = _isFormValid;

    return Center(
      child: Column(
        children: [
          isLoading
              ? const CupertinoActivityIndicator(radius: 15)
              : ElevatedButton(
                  onPressed: hasValidData ? () {
                    print('🚀 بدء إرسال الطلب...');
                    print('📋 نوع الطلب: $selectedRequestType');
                    print('📝 الوصف: ${descriptionController.text}');
                    
                    _addStudentRequest();
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasValidData 
                        ? ColorsApp.primaryColor // أو ColorsApp.primaryColor إذا كان معرفاً
                        : ColorsApp.greylight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    _isLoading ? 'جاري الإرسال...' : 'إرسال الطلب',  
                    style: font16White,
                  ),
                ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        // 🔥 الاستماع لنتيجة الإرسال
        if (state is RequestSuccess) {
          print('✅ تم إرسال الطلب بنجاح - العودة للشاشة السابقة');
          setState(() {
            _isLoading = false;
          });
          
          ShowWidget.showMessage(
            context,
            'تم إرسال الطلب بنجاح',
            Colors.green,
            TextStyle(color: Colors.white, fontSize: 13),
          );
          
          // 🔥 استخدام دالة العودة الآمنة بعد تأخير بسيط
          Future.delayed(const Duration(milliseconds: 500), () {
            _safePopBack();
          });
        } else if (state is RequestFailure) {
          print('❌ فشل إرسال الطلب: ${state.error}');
          setState(() {
            _isLoading = false;
          });
          
          ShowWidget.showMessage(
            context,
            'فشل في إرسال الطلب: ${state.error}',
            Colors.red,
            TextStyle(color: Colors.white, fontSize: 13),
          );
        }
      },
      child: Scaffold(
      appBar: CustomAppBarTitle(title: RequestData.title),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: media.height * 0.10,
                  child: Center(
                    child: Image.asset(
                      RequestData.messagesReq,
                      width: media.width * 0.7,
                      height: media.height * 0.2,
                    ),
                  ),
                ),
                getHeight( 10),
                Text(RequestData.textbarone,style:font20blackbold ,),
                getHeight( 5),
                Text(RequestData.textbartwo,style:font15bold,),
                getHeight( 12),
                TextsSend(
                  onRequestTypeChanged: (value) {
                    setState(() {
                      selectedRequestType = value;
                    });
                  },
                  descriptionController: descriptionController,
                  onValidityChanged: _onFormValidityChanged,
                  onDescriptionFocusChanged: _onDescriptionFocusChanged,
                  ),
                getHeight(40),
                _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}