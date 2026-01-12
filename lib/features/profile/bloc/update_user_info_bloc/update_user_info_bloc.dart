import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'update_user_info_event.dart';
part 'update_user_info_state.dart';

class UpdateUserInfoBloc extends Bloc<UpdateUserInfoEvent, UpdateUserInfoState> {
  final UserRepository _userRepository;

  UpdateUserInfoBloc({
		required UserRepository userRepository
	}) : 	_userRepository = userRepository, 
	super(UpdateUserInfoInitial()) {
    // أضف هذا للتحقق من استقبال الأحداث
    on<UpdateUserInfoEvent>((event, emit) {
      print('🎯 UpdateUserInfoBloc received event: ${event.runtimeType}');
    });
    
    // التعامل مع حدث رفع الصورة
    on<UploadPicture>((event, emit) async {
      print('🎯 === UPLOAD PICTURE EVENT STARTED ===');
      print('🎯 Event details - File: ${event.file}, UserId: ${event.userModel.userID}');
      emit(UploadPictureLoading());
      print('🔄 State changed to: UploadPictureLoading');
      try {
        print('🔄 Calling uploadPicture in repository...');
				String userImage = await _userRepository.uploadPicture(event.file, event.userModel);
        print('✅ Repository returned: ${userImage.length} characters');

        // 🔥 إضافة تأخير بسيط للتأكد من اكتمال العملية
        await Future.delayed(const Duration(milliseconds: 500));

        emit(UploadPictureSuccess(userImage));
        print('🎉 State changed to: UploadPictureSuccess');
      } catch (e) {
        print('❌ uploadPicture error: $e');
        emit(UploadPictureFailure());
        print('💥 State changed to: UploadPictureFailure');
      }
      print('🎯 === UPLOAD PICTURE EVENT COMPLETED ===');
    });

    // 🔥 حدث جديد: إزالة الصورة الشخصية
    on<RemoveProfilePicture>((event, emit) async {
      print('🗑️ === REMOVE PROFILE PICTURE EVENT STARTED ===');
      print('🗑️ Removing profile picture for user: ${event.userId}');
      
      emit(RemovePictureLoading());
      print('🔄 State changed to: RemovePictureLoading');
      
      try {
        // 🔥 إزالة الصورة من بيانات المستخدم
        print('🔄 Removing picture from user profile...');
        await _userRepository.removeProfilePicture(event.userId);
        
        // 🔥 إزالة الصورة من جميع إعلانات المستخدم
        print('🔄 Removing picture from user advertisements...');
        await _userRepository.removePictureFromUserAdvertisements(event.userId);
        // 🔥 إضافة تأخير للتأكد من اكتمال جميع العمليات
    await Future.delayed(const Duration(milliseconds: 1000));
    
        emit(RemovePictureSuccess());
        print('🎉 State changed to: RemovePictureSuccess');
        print('🗑️ تم إزالة الصورة الشخصية بنجاح - هذا النص يظهر بعد معالجة الحدث');
        print('🗑️ === REMOVE PROFILE PICTURE EVENT COMPLETED SUCCESSFULLY ===');
        print('🔥 تم تنفيذ الحدث الجديد: إزالة الصورة الشخصية');
      } catch (e) {
        print('❌ removeProfilePicture error: $e');
        // تصنيف الأخطاء لعرض رسائل مناسبة
    String errorMessage;
    if (e.toString().contains('not-found') || e.toString().contains('غير موجود')) {
      errorMessage = 'المستخدم غير موجود في قاعدة البيانات';
    } else if (e.toString().contains('permission')) {
      errorMessage = 'ليس لديك صلاحية لتعديل البيانات';
    } else if (e.toString().contains('network') || e.toString().contains('اتصال')) {
      errorMessage = 'خطأ في الاتصال بالإنترنت';
    } else {
      errorMessage = 'فشل في إزالة الصورة: ${e.toString()}';
    }
    
    emit(RemovePictureFailure(error: errorMessage));
    print('💥 State changed to: RemovePictureFailure');
  }
      print('🗑️ === REMOVE PROFILE PICTURE EVENT COMPLETED ===');
    });
  
  // 🔥 حدث جديد: البحث عن مستخدم باستخدام رقم القيد
    on<SearchUserByUserID>((event, emit) async {
      print('🔍 === SEARCH USER BY USERID EVENT STARTED ===');
      print('🔍 Searching for user with ID: ${event.userID}');
      
      emit(SearchUserLoading());
      print('🔄 State changed to: SearchUserLoading');
      
      try {
        final user = await _userRepository.getUserByUserID(event.userID);
        print('✅ User found: ${user.name}');
        
        emit(SearchUserSuccess(user: user));
        print('🎉 State changed to: SearchUserSuccess');
      } catch (e) {
        print('❌ Search user error: $e');
        String errorMessage;
        
        if (e.toString().contains('غير موجود') || 
            e.toString().contains('not found') ||
            e.toString().contains('المستخدم غير موجود')) {
          errorMessage = 'المستخدم غير موجود';
        } else if (e.toString().contains('فارغ')) {
          errorMessage = 'رقم القيد لا يمكن أن يكون فارغاً';
        } else if (e.toString().contains('network') || e.toString().contains('اتصال')) {
          errorMessage = 'خطأ في الاتصال بالإنترنت';
        } else {
          errorMessage = 'فشل في البحث عن المستخدم: ${e.toString()}';
        }
        
        emit(SearchUserFailure(error: errorMessage));
        print('💥 State changed to: SearchUserFailure');
      }
      print('🔍 === SEARCH USER BY USERID EVENT COMPLETED ===');
    });
    
  // 🔥 حدث جديد: إعادة تعيين حالة البحث
    on<ResetSearchState>((event, emit) async {
      print('🔄 إعادة تعيين حالة البحث');
      emit(UpdateUserInfoInitial());
    });
  }
}