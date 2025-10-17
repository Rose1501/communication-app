import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/src/models/models.dart';

abstract class UserRepository {
  Stream<User?> get user; // تيار المستخدم
  Future<void> login(String email, String password);
  Future<void> logOut();
  Future<void> signUp(String userID, String email,String password);
  Future<UserModels> getCurrentUser();// إذا كنت تحتاج بيانات المستخدم بعد التسجيل
  Future<void> setUserData(UserModels user);
  Future<String> uploadPicture(String userID, UserModels userModel);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> reauthenticate(String password);
  Future<void> sendResetCode(String email);
  Future<bool> verifyResetCode(String email, String code);
  Future<void> resetPasswordWithCode(String email, String code, String newPassword);
  Future<void> removeProfilePicture(String userId);
  Future<void> removePictureFromUserAdvertisements(String userId);
  
}
