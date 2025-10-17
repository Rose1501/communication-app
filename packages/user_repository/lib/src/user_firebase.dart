import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final postsCollection = FirebaseFirestore.instance.collection('advertisements');
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of [UserModels] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [UserModels.empty] if the user is not authenticated.
  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<void> signUp(String userID, String email, String password) async {
    try {
      //print('Searching for user with ID: $userID and email: $email');
      // 1. التحقق من وجود مستخدم بنفس البريد الإلكتروني
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email.toLowerCase().trim())
              .where('userID', isEqualTo: userID)
              //.where('haveAccount', isEqualTo: 0)
              .get();
      //print('Query snapshot signUp: ${querySnapshot.docs.length} documents found');

      // 2. إذا لم يوجد مستخدم بنفس البيانات
      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
              'لا يوجد مستخدم مسجل بهذه البيانات. يرجى التحقق من البريد الإلكتروني ورقم القيد',
        );
      }
      // 3. التحقق من وجود حساب مفعل بالفعل
      final existingUserDoc = querySnapshot.docs.first;
      final userData = existingUserDoc.data();
      final haveAccount =
          userData['haveAccount'] is int
              ? userData['haveAccount'].toString()
              : userData['haveAccount']?.toString() ?? '0';
      if (haveAccount == '1') {
        throw FirebaseAuthException(
          code: 'account-already-exists',
          message: 'هذا المستخدم لديه حساب مفعل بالفعل',
        );
        //print('User already has an account ->haveAccount: ${haveAccount}');
      }
      // 4. إنشاء الحساب في Firebase Authentication
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // 5. تحديث بيانات المستخدم في Firestore
      await existingUserDoc.reference.update({
        'haveAccount': '1',
        'firebaseUID': userCredential.user!.uid,
        'lastUpdated': DateTime.now(),
      });
      log('User signed up Firestore: ${userCredential.user?.uid}');
      // 6. تسجيل الدخول تلقائياً بعد إنشاء الحساب
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //print('Sign up successful for user: ${userCredential.user!.uid}');
      return;
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error during sign up: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error during sign up: $e');
      //print('Error during sign up: $e');
      rethrow;
    }
  }

  @override
  /// يحصل على بيانات المستخدم الحالي
  Future<UserModels> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // جلب البيانات من Firestore باستخدام firebaseUID
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('firebaseUID', isEqualTo: user.uid)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final snapshot = querySnapshot.docs.first;
          return UserModels.fromEntity(
            UserEntities.fromDocument(snapshot.data()),
          );
        } else {
          // إذا لم يتم العثور باستخدام firebaseUID، جرب البحث باستخدام البريد الإلكتروني
          final emailQuerySnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: user.email)
                  .get();

          if (emailQuerySnapshot.docs.isNotEmpty) {
            final snapshot = emailQuerySnapshot.docs.first;
            return UserModels.fromEntity(
              UserEntities.fromDocument(
                snapshot.data(),
              ),
            );
          } else {
            throw Exception('User data not found in Firestore');
          }
        }
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      //print('Error getting current user: $e');
      throw Exception('Error getting current user: ${e.toString()}');
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


  @override
  /// يحفظ بيانات المستخدم في Firestore
  Future<void> setUserData(UserModels user) async {
    try {
      await usersCollection.doc(user.userID).set(user.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


  @override
  /// يرفع صورة المستخدم ويحولها إلى base64
  Future<String> uploadPicture(String file, UserModels userModel) async {
    try {
      print('✅ Uploading picture for userId: ${userModel.userID} from file: $file');
      print('🔄 بدء رفع الصورة للمستخدم: ${userModel.userID}');
      File imageFile = File(file);
      // تحقق من وجود الملف
    bool fileExists = await imageFile.exists();
    print('   📄 File exists: $fileExists');
    
    if (!fileExists) {
      throw Exception('File does not exist: $file');
    }
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      print('📸 حجم الصورة: ${imageBytes.length} bytes');
      print('🔤 طول base64: ${base64Image.length}');
      // 💾 الخطوة 3: التحقق من وجود المستخدم ثم التحديث
    print('🔄 التحقق من وجود مستند المستخدم في Firestore...');

    final querySnapshot = await usersCollection.where('userID', isEqualTo: userModel.userID)
        .get();

    if (!querySnapshot.docs.isEmpty){print('⚠️ مستند المستخدم غير موجود، جاري إنشاؤه...');}
    else {print('✅ مستند المستخدم موجود، جاري التحديث...');}

       //  تحديث صورة المستخدم في مستند المستخدم في Firestore
        print('🔄 تحديث/إنشاء مستند المستخدم في Firestore...');
        final userDocRef = querySnapshot.docs.first.reference;
      await userDocRef.update({'urlImg': base64Image,'lastUpdated': FieldValue.serverTimestamp()});
      
      print('✅ تم تحديث صورة المستخدم في Firestore');
      // تحديث صورة المستخدم في جميع منشوراته أيضاً
      final postsSnapshot = await postsCollection.where('user.userID', isEqualTo: userModel.userID
      ).get();
        // تحديث حقل الصورة في كل منشور يخص هذا المستخدم
        print('📝 عدد المنشورات التي سيتم تحديثها: ${postsSnapshot.docs.length}');
        if (postsSnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      
      for (var doc in postsSnapshot.docs) {
        batch.update(doc.reference, {
          'user.urlImg': base64Image,
          'lastUpdated': FieldValue.serverTimestamp()
        });
      }
      
      await batch.commit();
      print('   ✅ All posts updated successfully');
    } else {
      print('   ℹ️ No posts found to update');
    }
        print('✅ تم تحديث صور المستخدم في جميع المنشورات');
        

      return base64Image; // Return the base64 string of the image
    } catch (e) {
      log(e.toString());
      print('❌ خطأ في رفع الصورة: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  @override
  /// يغير كلمة المرور الحالية للمستخدم
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // إعادة المصادقة أولاً للتأكد من هوية المستخدم
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  /// يعيد مصادقة المستخدم بكلمة المرور الحالية
  Future<void> reauthenticate(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  @override
  /// يرسل رمز إعادة تعيين مكون من 6 أرقام إلى البريد الإلكتروني
  Future<void> sendResetCode(String email) async {
    try {
      //print('🔍 البحث عن مستخدم بالبريد: $email');
      // التحقق من وجود المستخدم أولاً
    final userQuery = await _firestore.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      //print('❌ لا يوجد مستخدم بهذا البريد: $email');
      throw Exception('لا يوجد حساب مرتبط بهذا البريد الإلكتروني');
    }

    //print('✅ وجد مستخدم: ${userQuery.docs.first.id}');


      // إنشاء رمز مؤقت (6 أرقام)
      final resetCode = _generateResetCode();
      final expiresAt = DateTime.now().add(Duration(minutes: 15));
      //print('🔢 الرمز المُنشأ: $resetCode');

      // حفظ الرمز في Firestore
      await _firestore.collection('passwordResetCodes').doc(email).set({
        'code': resetCode,
        'expiresAt': expiresAt,
        'createdAt': DateTime.now(),
        'attempts': 0,
      });
      //print('💾 تم حفظ الرمز في Firestore');

      //print('📧 رمز إعادة التعيين لـ $email: $resetCode');
    } on FirebaseAuthException catch (e) {
      //print('🔥 خطأ Firebase: ${e.code} - ${e.message}');
      _handleFirebaseError(e);
    } catch (e) {
      //print('❌ خطأ عام في sendResetCode: $e');
      throw Exception('فشل في إرسال رمز إعادة التعيين: ${e.toString()}');
    }
  }

  @override
  /// يتحقق من صحة رمز إعادة التعيين و وقت صلاحيته
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final doc =
          await _firestore.collection('passwordResetCodes').doc(email).get();

      if (!doc.exists) {
        throw Exception('لم يتم إرسال رمز إعادة تعيين لهذا البريد');
      }

      final data = doc.data()!;
      final savedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int) + 1;

      if (expiresAt.isBefore(DateTime.now())) {
        await _firestore.collection('passwordResetCodes').doc(email).delete();
        throw Exception('انتهت صلاحية رمز إعادة التعيين');
      }
      // التحقق من عدد المحاولات
      if (attempts > 5) {
        await doc.reference.delete();
        throw Exception('تم تجاوز الحد الأقصى للمحاولات');
      }
      // زيادة عدد المحاولات
      await doc.reference.update({'attempts': attempts});

      return savedCode == code;
    } catch (e) {
      throw Exception('فشل في التحقق من الرمز: ${e.toString()}');
    }
  }

  @override
  /// يعيد تعيين كلمة المرور باستخدام الرمز المؤقت
Future<void> resetPasswordWithCode(String email, String code, String newPassword) async {
  try {
    //print('🔐 بدء إعادة تعيين كلمة المرور للبريد: $email');
    
    // 1. التحقق من صحة الرمز أولاً
    final isValid = await verifyResetCode(email, code);
    if (!isValid) {
      throw Exception('رمز إعادة التعيين غير صحيح');
    }

    // 2. البحث عن المستخدم في Firestore
    final userQuery = await _firestore.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('لا يوجد مستخدم مسجل بهذا البريد الإلكتروني');
    }

    final userDoc = userQuery.docs.first;
    final userData = userDoc.data();
    final firebaseUID = userData['firebaseUID'] as String?;
    
    //print('👤 وجد المستخدم: ${userDoc.id}, firebaseUID: $firebaseUID');

    // 3. التحقق من أن المستخدم لديه حساب في Firebase Auth
    if (firebaseUID == null || firebaseUID.isEmpty) {
      throw Exception('هذا المستخدم ليس لديه حساب مفعل في النظام');
    }
    
      // 4. محاولة إعادة تعيين كلمة المرور
    try {
      // الطريقة الآمنة: إرسال بريد إعادة التعيين
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      //print('✅ تم إرسال بريد إعادة تعيين كلمة المرور إلى: $email');
      
    } on FirebaseAuthException catch (e) {
      //print('❌ خطأ في إعادة تعيين كلمة المرور: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('لا يوجد حساب في النظام لهذا البريد الإلكتروني');
      } else {
        throw Exception('فشل في إعادة تعيين كلمة المرور: ${_getFirebaseErrorMessage(e.code)}');
      }
    }
        // 5. تحديث المستند برمز Firebase الجديد
        await userDoc.reference.update({
          'password': newPassword,
          'lastUpdated': DateTime.now(),
        });
        
        //print('✅ تم تحديث كلمة المرور في Firestore');
        
      

    // 6. حذف الرمز بعد الاستخدام الناجح
    await _firestore.collection('passwordResetCodes').doc(email).delete();
    //print('✅ تم حذف الرمز من Firestore');

  } on FirebaseAuthException catch (e) {
    //print('🔥 خطأ Firebase في resetPasswordWithCode: ${e.code} - ${e.message}');
    throw Exception('فشل في إعادة تعيين كلمة المرور: ${_getFirebaseErrorMessage(e.code)}');
  } catch (e) {
    //print('❌ خطأ عام في resetPasswordWithCode: $e');
    throw Exception('فشل في إعادة تعيين كلمة المرور: ${e.toString()}');
  }
}

  // توليد رمز مؤقت مكون من 6 أرقام
  String _generateResetCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // معالجة أخطاء Firebase
  void _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        throw Exception('البريد الإلكتروني غير صالح');
      case 'user-not-found':
        throw Exception('لا يوجد حساب مرتبط بهذا البريد الإلكتروني');
      case 'wrong-password':
        throw Exception('كلمة المرور غير صحيحة');
      case 'too-many-requests':
        throw Exception('تم إجراء many requests، يرجى المحاولة لاحقاً');
      default:
        throw Exception('حدث خطأ غير متوقع: ${e.message}');
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'invalid-email':
      return 'البريد الإلكتروني غير صالح';
    case 'user-not-found':
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة';
    case 'weak-password':
      return 'كلمة المرور ضعيفة جداً';
    case 'email-already-in-use':
      return 'البريد الإلكتروني مستخدم بالفعل';
    case 'invalid-verification-code':
      return 'رمز التحقق غير صحيح';
    case 'expired-action-code':
      return 'انتهت صلاحية رمز التحقق';
    default:
      return 'حدث خطأ غير متوقع: $errorCode';
  }
}
@override
Future<void> removeProfilePicture(String userId) async {
  try {
    print('🗑️ بدء إزالة الصورة من البروفايل للمستخدم: $userId');
    final querySnapshot = await usersCollection.where('userID', isEqualTo: userId).get();
    final userDocRef = querySnapshot.docs.first.reference;
    // تحديث المستخدم بإزالة الصورة
    await userDocRef.update({
      'urlImg': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ تم إزالة الصورة من البروفايل بنجاح');
  } catch (e) {
    print('❌ خطأ في إزالة الصورة من البروفايل: $e');
    rethrow;
  }
}

@override
Future<void> removePictureFromUserAdvertisements(String userId) async {
  try {
    print('🗑️ بدء إزالة الصورة من إعلانات المستخدم: $userId');
    
    // البحث عن جميع إعلانات المستخدم
    final advertisementsSnapshot = await FirebaseFirestore.instance
        .collection('advertisements')
        .where('user.userID', isEqualTo: userId)
        .get();

    print('📊 عدد الإعلانات التي سيتم تحديثها: ${advertisementsSnapshot.docs.length}');
    
    // تحديث كل إعلان بإزالة الصورة من بيانات المستخدم
    for (final doc in advertisementsSnapshot.docs) {
      await doc.reference.update({
        'user.urlImg': null,
        'timeAdv': FieldValue.serverTimestamp(), // تحديث وقت التعديل
      });
      print('✅ تم تحديث الإعلان: ${doc.id}');
    }
    
    print('🎉 تم إزالة الصورة من جميع إعلانات المستخدم بنجاح');
  } catch (e) {
    print('❌ خطأ في إزالة الصورة من الإعلانات: $e');
    rethrow;
  }
}

}
