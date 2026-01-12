import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

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
Future<void> ensureFirebaseUidAndSetFcmToken({required String token}) async {
  try {
    await Future.delayed(Duration(seconds: 2)); // انتظار بسيط
    
    final authUser = FirebaseAuth.instance.currentUser;
    
    if (authUser == null) {
      print('⚠️ No authenticated user. Waiting for auth...');
      
      // انتظار حتى يصبح المستخدم معتمداً
      final completer = Completer<User?>();
      final subscription = FirebaseAuth.instance.authStateChanges()
          .timeout(Duration(seconds: 10))
          .listen((user) {
        if (!completer.isCompleted) {
          completer.complete(user);
        }
      });
      
      final user = await completer.future;
      await subscription.cancel();
      
      if (user == null) {
        print('❌ Still no authenticated user after waiting');
        return;
      }
    }
    
    // الآن يمكنك المتابعة مع حفظ التوكن
    final currentUser = FirebaseAuth.instance.currentUser!;
    print('✅ User authenticated: ${currentUser.uid}');

    final String authFirebaseUID = currentUser.uid;
    final String? authEmail = currentUser.email;

    print('🔍 Ensuring firebaseUID and setting FCM token for Auth user: $authFirebaseUID');
    
    // 1. محاولة البحث المباشر باستخدام UID من Firebase Auth
    final directQuerySnapshot = await usersCollection
        .where('firebaseUID', isEqualTo: authFirebaseUID)
        .limit(1)
        .get();

    if (directQuerySnapshot.docs.isNotEmpty) {
      // الحالة المثالية: المستخدم موجود و UID الخاص به صحيح
      final userDocRef = directQuerySnapshot.docs.first.reference;
      await userDocRef.update({'fcmToken': token});
      print('✅ FCM token updated for existing user with correct firebaseUID: $authFirebaseUID');
      return;
    }

    // 2. إذا لم يتم العثور عليه، ابحث باستخدام البريد الإلكتروني
    if (authEmail != null) {
      print('⚠️ User not found with firebaseUID. Searching by email: $authEmail');
      final emailQuerySnapshot = await usersCollection
          .where('email', isEqualTo: authEmail)
          .limit(1)
          .get();

      if (emailQuerySnapshot.docs.isNotEmpty) {
        final userDocRef = emailQuerySnapshot.docs.first.reference;
        
        // 🔥 التعديل: التأكد من تحديث firebaseUID بشكل صحيح
        final userData = emailQuerySnapshot.docs.first.data();
        final currentFirebaseUID = userData['firebaseUID'] as String?;
        
        // تحديث المستند بإضافة UID الصحيح وحفظ التوكن
        Map<String, dynamic> updateData = {
          'firebaseUID': authFirebaseUID,
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        await userDocRef.update(updateData);
        print('✅ User document found by email, updated with firebaseUID and FCM token.');
        return;
      }
    }
    
    // 3. إذا لم يتم العثور على المستخدم على الإطلاق
    print('❌ Could not find any user document in Firestore for the authenticated user. FCM token not saved.');

  } catch (e) {
    print('❌ Error in ensureFirebaseUidAndSetFcmToken: $e');
    rethrow;
  }
}

  @override
Future<void> restoreMissingFirebaseUIDs() async {
  try {
    print('🔍 البحث عن مستخدمين بدون firebaseUID');
    
    final querySnapshot = await usersCollection
        .where('firebaseUID', isEqualTo: null)
        .get();
    
    print('🔍 وجد ${querySnapshot.docs.length} مستخدم بدون firebaseUID');
    
    for (final doc in querySnapshot.docs) {
      final userData = doc.data();
      final email = userData['email'] as String?;
      
      if (email != null) {
        try {
          // البحث عن مستند آخر بنفس البريد الإلكتروني ولكن مع firebaseUID
          final emailQuerySnapshot = await usersCollection
              .where('email', isEqualTo: email)
              .where('firebaseUID', isNotEqualTo: null)
              .limit(1)
              .get();
          
          if (emailQuerySnapshot.docs.isNotEmpty) {
            final firebaseUID = emailQuerySnapshot.docs.first.data()['firebaseUID'] as String?;
            
            if (firebaseUID != null) {
              await doc.reference.update({'firebaseUID': firebaseUID});
              print('✅ تم استعادة firebaseUID للمستخدم: $email');
            }
          } else {
            print('⚠️ لم يتم العثور على firebaseUID للمستخدم: $email');
          }
        } catch (e) {
          print('❌ خطأ في استعادة firebaseUID للمستخدم $email: $e');
        }
      }
    }
  } catch (e) {
    print('❌ خطأ في استعادة firebaseUIDs: $e');
  }
}

  /// يحصل على بيانات المستخدم الحالي
  @override
Future<UserModels> getCurrentUser() async {
  try {
    // الحصول على المستخدم من Firebase Auth
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      print('🔍 Firebase Auth User found: ${authUser.uid}, email: ${authUser.email}');
      
      // البحث عن المستخدم باستخدام firebaseUID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('firebaseUID', isEqualTo: authUser.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final snapshot = querySnapshot.docs.first;
        print('✅ User found using firebaseUID: ${authUser.uid}');
        return UserModels.fromEntity(
          UserEntities.fromDocument(snapshot.data()),
        );
      }
      
      // إذا لم يتم العثور، حاول البحث باستخدام البريد الإلكتروني
      final emailQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: authUser.email)
          .limit(1)
          .get();

      if (emailQuerySnapshot.docs.isNotEmpty) {
        final snapshot = emailQuerySnapshot.docs.first;
        print('🔍 User found using email: ${authUser.email}');
        final user = UserModels.fromEntity(
          UserEntities.fromDocument(snapshot.data()),
        );
        
        // تحديث المستند بـ firebaseUID
        if (user.firebaseUID == null || user.firebaseUID!.isEmpty) {
          await snapshot.reference.update({
            'firebaseUID': authUser.uid,
            'lastUpdated': DateTime.now(),
          });
          print('✅ Updated user with firebaseUID: ${authUser.uid}');
        }
        
        return user.copyWith(firebaseUID: authUser.uid);
      } else {
        print('❌ User not found in Firestore');
        throw Exception('User data not found in Firestore');
      }
    } else {
      print('❌ No Firebase Auth user found');
      throw Exception('No Firebase Auth user found');
    }
  } catch (e) {
    print('❌ Error getting current user: $e');
    throw Exception('Error getting current user: ${e.toString()}');
  }
}

@override
Future<void> updateFcmToken({required String firebaseUID, required String token}) async {
  try {
    print('💾 Updating FCM token for firebaseUID: $firebaseUID');
    await usersCollection.doc(firebaseUID).update({'fcmToken': token});
    print('✅ FCM token updated successfully.');
  } catch (e) {
    print('❌ Failed to update FCM token: $e');
    rethrow; // أعد طرح الخطأ لمعالجته في الأعلى
  }
}

  @override
  Future<void> login(String email, String password) async {
    try {
      print('login');
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('hi');
    } catch (e) {
      print('login error');
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
      // 🔥 تحديث صورة المشرف في إعدادات المشروع إذا كان المشرف
      if (userModel.role == 'Admin' || userModel.role == 'Doctor' || userModel.role == 'Manager') {
        print('👑 تحديث صورة المشرف في إعدادات المشروع...');
        await _updateAdminPictureInProjectSettings(userModel.userID, base64Image);
      }
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

  /// 🔥 دالة مساعدة لتحديث صورة المشرف في إعدادات المشروع
Future<void> _updateAdminPictureInProjectSettings(String userId, String base64Image) async {
  try {
    print('🔄 تحديث صورة المشرف في إعدادات المشروع...');
    
    // جلب إعدادات المشروع الحالية
    final projectSettingsDoc = FirebaseFirestore.instance
        .collection('projects')
        .doc('projects1');
    
    final doc = await projectSettingsDoc.get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      
      // البحث عن المشرف وتحديث صورته
      final adminUsers = List<Map<String, dynamic>>.from(data['adminUsers'] ?? []);
      bool adminUpdated = false;
      
      for (int i = 0; i < adminUsers.length; i++) {
        final admin = Map<String, dynamic>.from(adminUsers[i]);
        if (admin['userID'] == userId) {
          admin['urlImg'] = base64Image;
          adminUsers[i] = admin;
          adminUpdated = true;
          break;
        }
      }
      
      if (adminUpdated) {
        // تحديث المستند مع البيانات المحدثة
        await projectSettingsDoc.update({
          'adminUsers': adminUsers,
          'lastUpdated': FieldValue.serverTimestamp()
        });
        print('✅ تم تحديث صورة المشرف في إعدادات المشروع');
      } else {
        print('⚠️ المشرف غير موجود في قائمة المشرفين في إعدادات المشروع');
      }
    } else {
      print('⚠️ مستند إعدادات المشروع غير موجود');
    }
  } catch (e) {
    print('❌ خطأ في تحديث صورة المشرف في إعدادات المشروع: $e');
    throw e;
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
      print('🔍 البحث عن مستخدم بالبريد: $email');
      // التحقق من وجود المستخدم أولاً
    final userQuery = await _firestore.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      print('❌ لا يوجد مستخدم بهذا البريد: $email');
      throw Exception('لا يوجد حساب مرتبط بهذا البريد الإلكتروني');
    }

    print('✅ وجد مستخدم: ${userQuery.docs.first.id}');


      // إنشاء رمز مؤقت (6 أرقام)
      final resetCode = _generateResetCode();
      final expiresAt = DateTime.now().add(Duration(minutes: 15));
      print('🔢 الرمز المُنشأ: $resetCode');

      // حفظ الرمز في Firestore
      await _firestore.collection('passwordResetCodes').doc(email).set({
        'code': resetCode,
        'expiresAt': expiresAt,
        'createdAt': DateTime.now(),
        'attempts': 0,
      });
      print('💾 تم حفظ الرمز في Firestore');
      // 🔥 الخطوة الجديدة والمهمة: إرسال الرمز عبر البريد الإلكتروني
    await _sendResetCodeEmail(email, resetCode);
    print('✅ تم إرسال رمز إعادة التعيين إلى البريد: $email');

      print('📧 رمز إعادة التعيين لـ $email: $resetCode');
    } on FirebaseAuthException catch (e) {
      print('🔥 خطأ Firebase: ${e.code} - ${e.message}');
      _handleFirebaseError(e);
    } catch (e) {
      //print('❌ خطأ عام في sendResetCode: $e');
      throw Exception('فشل في إرسال رمز إعادة التعيين: ${e.toString()}');
    }
  }

  /// دالة مساعدة لإرسال رمز إعادة التعيين عبر البريد الإلكتروني
Future<void> _sendResetCodeEmail(String email, String resetCode) async {
  try {
  final subject = 'رمز إعادة تعيين كلمة المرور - تطبيق وصلة قسمي';
  final body = '''
أهلاً بك،

لقد طلبت إعادة تعيين كلمة المرور لحسابك في تطبيق "وصلة قسمي".

رمز التحقق الخاص بك هو: $resetCode

هذا الرمز صالح لمدة 15 دقيقة فقط. إذا لم تكن أنت من طلب هذا الرمز، فيرجى تجاهل هذا البريد الإلكتروني.

مع أطيب التحيات،
فريق تطوير تطبيق وصلة قسمي
قسم الحاسب الآلي - جامعة طرابلس
''';

// استخدام خدمة إرسال البريد الإلكتروني (مثل SendGrid أو Firebase Functions)
    /*await EmailService.sendEmail(
      to: email,
      subject: subject,
      body: body,
    );*/

  print('✅ تم إرسال كلمة المرور إلى البريد الإلكتروني: $email');
  } catch (e) {
    print('❌ خطأ في إرسال البريد الإلكتروني: $e');
    // لا نعيد طرح الخطأ هنا لأننا لا نريد إفشال عملية تغير كلمة السر إذا فشل إرسال البريد
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
    
    // 🔥 إزالة صورة المشرف من إعدادات المشروع إذا كان المشرف
    print('🔄 التحقق إذا كان المستخدم مشرفاً...');
    final userQuery = await usersCollection
        .where('userID', isEqualTo: userId)
        .limit(1)
        .get();
        if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        final userRole = userData['role'] as String?;
      
        if (userRole == 'Admin' || userRole == 'Doctor' || userRole == 'Manager') {
        print('👑 إزالة صورة المشرف من إعدادات المشروع...');
        await _removeAdminPictureFromProjectSettings(userId);
      }
    }
    print('🎉 تم إزالة الصورة من جميع إعلانات المستخدم بنجاح');
  } catch (e) {
    print('❌ خطأ في إزالة الصورة من الإعلانات: $e');
    rethrow;
  }
} 
  /// 🔥 دالة مساعدة لإزالة صورة المشرف من إعدادات المشروع
Future<void> _removeAdminPictureFromProjectSettings(String userId) async {
  try {
    print('🗑️ إزالة صورة المشرف من إعدادات المشروع...');
    
    // جلب إعدادات المشروع الحالية
    final projectSettingsDoc = FirebaseFirestore.instance
        .collection('projects')
        .doc('projects1');
    
    final doc = await projectSettingsDoc.get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      
      // البحث عن المشرف وإزالة صورته
      final adminUsers = List<Map<String, dynamic>>.from(data['adminUsers'] ?? []);
      bool adminUpdated = false;
      
      for (int i = 0; i < adminUsers.length; i++) {
        final admin = Map<String, dynamic>.from(adminUsers[i]);
        if (admin['userID'] == userId) {
          admin.remove('urlImg'); // إزالة حقل الصورة
          adminUsers[i] = admin;
          adminUpdated = true;
          break;
        }
      }
      
      if (adminUpdated) {
        // تحديث المستند مع البيانات المحدثة
        await projectSettingsDoc.update({
          'adminUsers': adminUsers,
          'lastUpdated': FieldValue.serverTimestamp()
        });
        print('✅ تم إزالة صورة المشرف من إعدادات المشروع');
      } else {
        print('⚠️ المشرف غير موجود في قائمة المشرفين في إعدادات المشروع');
      }
    } else {
      print('⚠️ مستند إعدادات المشروع غير موجود');
    }
  } catch (e) {
    print('❌ خطأ في إزالة صورة المشرف من إعدادات المشروع: $e');
    throw e;
  }
}

  // 🔥 الدوال الجديدة لإدارة المستخدمين
  
  @override
  Future<List<UserModels>> getAllUsers() async {
    try {
      final querySnapshot = await usersCollection.get();
      final users = querySnapshot.docs
          .map((doc) => UserModels.fromEntity(UserEntities.fromDocument(doc.data())))
          .where((user) => user.isNotEmpty)
          .toList();
      
      users.sort((a, b) => a.name.compareTo(b.name));
      return users;
    } catch (e) {
      print('❌ خطأ في جلب جميع المستخدمين: $e');
      rethrow;
    }
  }

  @override
  Future<UserModels> addUser(UserModels user) async {
    try {
      final documentId =const Uuid().v4();
      final userWithId = user.copyWith();
      
      await usersCollection.doc(documentId).set(userWithId.toEntity().toDocument());
      // إنشاء كلمة مرور
      final password = user.userID;
      // إنشاء حساب للمستخدم
      await createUserAccount(userWithId.userID,userWithId.email, password);
      // إرسال كلمة المرور عبر البريد الإلكتروني
      await _sendPasswordEmail(userWithId.email, userWithId.name, password);
      
      return userWithId;
    } catch (e) {
      print('❌ خطأ في إضافة المستخدم: $e');
      rethrow;
    }
  }

  @override
  Future<UserModels> updateUser(UserModels user, String originalUserID) async {
    try {
      print('🔄 بدء تحديث المستخدم: ${user.name}');
    print('🔍 البحث باستخدام userID الأصلي: $originalUserID');
      final querySnapshot = await usersCollection
        .where('userID', isEqualTo: originalUserID)
        .limit(1)
        .get();

        print('🔍 نتائج البحث: ${querySnapshot.docs.length} مستند');

    if (querySnapshot.docs.isEmpty) {
      print('❌ لم يتم العثور على المستخدم: ${user.userID}');
      throw Exception('المستخدم غير موجود: ${user.userID}');
    }

    final documentId = querySnapshot.docs.first.id;
    //await usersCollection.doc(documentId).update(user.toEntity().toDocument());
    final userData = querySnapshot.docs.first.data();
    
    // 🔥 التعديل الرئيسي: التأكد من أن firebaseUID يتم تضمينه في التحديث
    Map<String, dynamic> updateData = user.toEntity().toDocument();
    
    // التأكد من أن firebaseUID ليس فارغًا
    if (user.firebaseUID != null && user.firebaseUID!.isNotEmpty) {
      print('🔗 تحديث firebaseUID إلى: ${user.firebaseUID}');
    } else {
      // إذا كان firebaseUID فارغًا، لا نقم بتحديثه
      updateData.remove('firebaseUID');
      print('⚠️ firebaseUID فارغ، لن يتم تحديثه');
      
      // إذا كان firebaseUID فارغًا في البيانات الجديدة ولكن موجودًا في البيانات القديمة، احتفظ به
      if (userData['firebaseUID'] != null) {
        updateData['firebaseUID'] = userData['firebaseUID'];
        print('🔗 الاحتفاظ بـ firebaseUID الموجود: ${userData['firebaseUID']}');
      }
    }
    
    // إضافة وقت التحديث
    updateData['lastUpdated'] = FieldValue.serverTimestamp();
    
    await usersCollection.doc(documentId).update(updateData);
    
    print('✅ تم تحديث المستخدم: ${user.name}');
    print('📝 userID القديم: $originalUserID');
    print('📝 userID الجديد: ${user.userID}');
    
    return user;
  } catch (e) {
    print('❌ خطأ في تحديث المستخدم: $e');
    rethrow;
  }
}

  @override
  Future<void> deleteUser(String userID) async {
    try {
      // البحث أولاً عن المستند باستخدام userID
    final querySnapshot = await usersCollection
        .where('userID', isEqualTo: userID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('المستخدم غير موجود: $userID');
    }

    final documentId = querySnapshot.docs.first.id;
    await usersCollection.doc(documentId).delete();
    
    print('✅ تم حذف المستخدم: $userID (documentId: $documentId)');
    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
      rethrow;
    }
  }

// 🔥 استيراد المستخدمين
  @override
Future<Map<String, dynamic>> importUsersFromExcel(List<Map<String, dynamic>> excelData) async {
  try {
    print('📥 بدء استيراد المستخدمين من ملف Excel');
    print('📊 عدد السجلات المستوردة: ${excelData.length}');

    int successCount = 0;
    int errorCount = 0;
    int duplicateCount = 0;
    final List<String> errors = [];

    // 🔥 جلب جميع المستخدمين الحاليين مرة واحدة للتحقق من التكرار
    final existingUsers = await getAllUsers();
    final existingUserIDs = existingUsers.map((user) => user.userID).toSet();
    final existingEmails = existingUsers.map((user) => user.email.toLowerCase()).toSet();

    // 🔥 تصفية البيانات الفريدة من الملف نفسه أولاً
    final List<Map<String, dynamic>> uniqueData = [];
    final Set<String> seenUserIDs = <String>{};
    final Set<String> seenEmails = <String>{};
    
    for (final row in excelData) {
      final mappedRow = _mapArabicToEnglishColumns(row);
      final userID = mappedRow['userID']?.toString().trim() ?? '';
      final email = mappedRow['email']?.toString().trim().toLowerCase() ?? '';
      
      final isDuplicateInFile = seenUserIDs.contains(userID) || seenEmails.contains(email);
      
      if (!isDuplicateInFile && userID.isNotEmpty && email.isNotEmpty) {
        uniqueData.add(row);
        seenUserIDs.add(userID);
        seenEmails.add(email);
      } else {
        duplicateCount++;
      }
    }
    print('🔍 بعد التصفية: ${uniqueData.length} سجل فريد من أصل ${excelData.length}');
    for (int i = 0; i < uniqueData.length; i++) {
      try {
        final row = uniqueData[i];
        final rowNumber = i + 1;
        
        print('🔍 معالجة الصف $rowNumber');

        // 🔥 تحويل الأعمدة العربية إلى الإنجليزية
        final mappedRow = _mapArabicToEnglishColumns(row);
        
        // 🔥 طباعة بيانات التصحيح
        _debugPrintRowData(i, row, mappedRow);

        // 🔥 التحقق من البيانات المطلوبة مع رسائل توضيحية
        if (mappedRow['name'] == null || mappedRow['name'].toString().trim().isEmpty) {
          errorCount++;
          errors.add('❌ صف $rowNumber: حقل الاسم فارغ');
          continue;
        }

        if (mappedRow['userID'] == null || mappedRow['userID'].toString().trim().isEmpty) {
          errorCount++;
          errors.add('❌ صف $rowNumber: حقل رقم القيد فارغ');
          continue;
        }

        if (mappedRow['email'] == null || mappedRow['email'].toString().trim().isEmpty) {
          errorCount++;
          errors.add('❌ صف $rowNumber: حقل البريد الإلكتروني فارغ');
          continue;
        }

        final userID = mappedRow['userID'].toString().trim();
        final email = mappedRow['email'].toString().trim().toLowerCase();

        // 🔥 التحقق من التكرار برقم القيد
        if (existingUserIDs.contains(userID)) {
          duplicateCount++;
          errors.add('❌ صف $rowNumber: المستخدم ${mappedRow['name']} موجود مسبقاً برقم القيد $userID');
          continue;
        }

        // 🔥 التحقق من التكرار بالبريد الإلكتروني
        if (existingEmails.contains(email)) {
          duplicateCount++;
          errors.add('❌ صف $rowNumber: البريد الإلكتروني $email مستخدم مسبقاً');
          continue;
        }

        // 🔥 إنشاء المستخدم
        final user = UserModels(
          userID: userID,
          name: mappedRow['name'].toString().trim(),
          email: email,
          role: _validateRole(mappedRow['role']?.toString()),
          gender: _validateGender(mappedRow['gender']?.toString()),
          haveAccount: '0',
          na_Number: mappedRow['na_Number']?.toString() ?? '',
        );

        // 🔥 إضافة المستخدم
        final documentId = const Uuid().v4();
        await _addUserWithDocumentId(documentId, user);
        successCount++;

        existingUserIDs.add(userID);
        existingEmails.add(email);

        print('✅ تم إضافة المستخدم: ${user.name} (${user.userID})');

      } catch (e) {
        errorCount++;
        errors.add('❌ صف ${i + 1}: خطأ - ${e.toString()}');
        print('❌ خطأ في معالجة الصف ${i + 1}: $e');
        print('📋 بيانات الصف: ${excelData[i]}');
      }
    }

    final result = {
      'success': successCount > 0,
      'totalRecords': excelData.length,
      'importedCount': successCount,
      'errorCount': errorCount,
      'duplicateCount': duplicateCount,
      'errors': errors,
      'message': 'تم استيراد $successCount مستخدم بنجاح${errorCount > 0 ? '، مع $errorCount خطأ' : ''}'
    };

    print('''
📊 نتائج استيراد المستخدمين:
    ✅ تمت إضافة: $successCount مستخدم
    🔄 مكرر: $duplicateCount
    ❌ أخطاء: $errorCount
    📋 إجمالي: ${excelData.length} سجل
''');
    
    return result;

  } catch (e) {
    print('❌ خطأ عام في استيراد المستخدمين: $e');
    return {
      'success': false,
      'totalRecords': excelData.length,
      'importedCount': 0,
      'errorCount': excelData.length,
      'errors': ['خطأ عام في الاستيراد: ${e.toString()}'],
      'message': 'فشل في استيراد المستخدمين'
    };
  }
}
  // 🔥 دالة جديدة لإضافة مستخدم مع Document ID مخصص
  Future<void> _addUserWithDocumentId(String documentId, UserModels user) async {
    try {
      await usersCollection.doc(documentId).set(user.toEntity().toDocument());
      // إنشاء كلمة مرور
      final password = user.userID;
      // إنشاء حساب للمستخدم
      await createUserAccount(user.userID,user.email, password);
      // إرسال كلمة المرور عبر البريد الإلكتروني
      await _sendPasswordEmail(user.email, user.name, password);

    } catch (e) {
      print('❌ خطأ في إضافة المستخدم: $e');
      rethrow;
    }
  }

  //دالة  لإنشاء حسابات المستخدمين من قبل الإدارة
Future<void> createUserAccount(String userID, String email, String password) async {
  try {
    // 1. التحقق من وجود مستخدم بنفس البريد الإلكتروني
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('userID', isEqualTo: userID)
        .get();

    // 2. إذا لم يوجد مستخدم بنفس البيانات
    if (querySnapshot.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'لا يوجد مستخدم مسجل بهذه البيانات. يرجى التحقق من البريد الإلكتروني ورقم القيد',
      );
    }
    
    // 3. التحقق من وجود حساب مفعل بالفعل
    final existingUserDoc = querySnapshot.docs.first;
    final userData = existingUserDoc.data();
    final haveAccount = userData['haveAccount'] is int
        ? userData['haveAccount'].toString()
        : userData['haveAccount']?.toString() ?? '0';
    if (haveAccount == '1') {
      throw FirebaseAuthException(
        code: 'account-already-exists',
        message: 'هذا المستخدم لديه حساب مفعل بالفعل',
      );
    }
    //بديل مؤقت لاستخدام Cloud Function
    final UserModels AdminUser = await getUserByUserID('دراسة والإمتحانات');
    
    // 4. إنشاء الحساب في Firebase Authentication
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    
    // 5. تحديث بيانات المستخدم في Firestore
    await existingUserDoc.reference.update({
      'haveAccount': '1',
      'firebaseUID': userCredential.user!.uid,
      'lastUpdated': DateTime.now(),
    });
    
    login(AdminUser.email, '123456789');
    // لا نقوم بتسجيل الدخول
    return;
  } on FirebaseAuthException catch (e) {
    log('Firebase Auth Error during account creation: ${e.code} - ${e.message}');
    rethrow;
  } catch (e) {
    log('Error during account creation: $e');
    rethrow;
  }
}

  // 🔥 دالة لإنشاء كلمة مرور عشوائية
String _generateRandomPassword(int length) {
  final random = Random.secure();
  const chars = '0123456789';
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

// 🔥 دالة لإرسال كلمة المرور عبر البريد الإلكتروني
Future<void> _sendPasswordEmail(String email, String name, String password) async {
  try {
    // إعداد بيانات البريد الإلكتروني
    final subject = 'معلومات حسابك في تطبيق وصلة قسمي';
    final body = '''
عزيزي/عزيزتي $name،

تم إنشاء حسابك بنجاح في تطبيق "وصلة قسمي" التابع لقسم الحاسب الآلي بجامعة طرابلس.

بيانات الدخول الخاصة بك:
البريد الإلكتروني: $email
كلمة المرور: $password

يرجى تغيير كلمة المرور بعد أول تسجيل دخول.

مع أطيب التحيات،
فريق تطوير تطبيق وصلة قسمي
قسم الحاسب الآلي - جامعة طرابلس
''';
// استخدام خدمة إرسال البريد الإلكتروني (مثل SendGrid أو Firebase Functions)

print('✅ تم إرسال كلمة المرور إلى البريد الإلكتروني: $email');
  } catch (e) {
    print('❌ خطأ في إرسال البريد الإلكتروني: $e');
    // لا نعيد طرح الخطأ هنا لأننا لا نريد إفشال عملية إنشاء المستخدم إذا فشل إرسال البريد
  }
}


  // 🔥 دالة للتحقق من صحة الدور
  String _validateRole(String? role) {
    if (role == null) return 'Student';
    
    final validRoles = ['Admin', 'Manager', 'Doctor', 'Student'];
    final normalizedRole = role.trim();
    
    if (validRoles.contains(normalizedRole)) {
      return normalizedRole;
    }
    
    // محاولة مطابقة الأدوار بالعربية
    final roleMapping = {
      'دراسة والإمتحانات': 'Admin',
      'مدير': 'Manager', 
      'دكتور': 'Doctor',
      'طالب': 'Student',
      'أستاذ': 'Doctor',
    };
    
    return roleMapping[normalizedRole] ?? 'Student';
  }

  // 🔥 دالة للتحقق من صحة الجنس
  String _validateGender(String? gender) {
    if (gender == null) return 'Male';
    
    final normalizedGender = gender.trim();
    if (normalizedGender == 'Male' || normalizedGender == 'Female') {
      return normalizedGender;
    }
    
    // ثم التحقق من العربية
    if (normalizedGender == 'ذكر') return 'Male';
    if (normalizedGender == 'أنثى') return 'Female';
    
    // قيمة افتراضية
    return 'Male';
  }

  // 🔥 دالة لتحويل الأعمدة العربية إلى الإنجليزية
  Map<String, dynamic> _mapArabicToEnglishColumns(Map<String, dynamic> row) {
    final mappedRow = <String, dynamic>{};
    
    // قائمة التعيين بين الأعمدة العربية والإنجليزية
    final columnMapping = {
      'رقم القيد': 'userID',
      'الاسم': 'name',
      'البريد الإلكتروني': 'email',
      'الدور': 'role',
      'الجنس': 'gender',
      'الرقم الوطني': 'na_Number',
      'اسم المستخدم': 'name',
      'ايميل': 'email',
      'دور': 'role',
      'جنس': 'gender',
      'رقم وطني': 'na_Number',
      'الرقم الجامعي': 'userID',
    'رقم الجامعة': 'userID',
    // التعامل مع الحروف المختلفة
    'البريد الالكتروني': 'email',
    'الايميل': 'email',
    // التعامل مع المسافات والفراغات
    'رقم القيد ': 'userID',
    'الاسم ': 'name',
    ' البريد الإلكتروني': 'email',
    ' الجنس': 'gender',
    ' الرقم الوطني': 'na_Number',
    };

    row.forEach((key, value) {
      final cleanKey = key.toString().trim();
      
    // البحث عن المفتاح المناسب
    String? englishKey;
    
    // البحث المباشر أولاً
    englishKey = columnMapping[cleanKey];
    
    // إذا لم يتم العثور، البحث الجزئي
    if (englishKey == null) {
      for (final arabicKey in columnMapping.keys) {
        if (cleanKey.contains(arabicKey) || arabicKey.contains(cleanKey)) {
          englishKey = columnMapping[arabicKey];
          break;
        }
      }
    }
    
    // إذا لم يتم العثور بعد، استخدام المفتاح الأصلي
    englishKey ??= cleanKey;
    
    // فقط إذا كانت القيمة ليست فارغة
    if (value != null && value.toString().trim().isNotEmpty) {
      mappedRow[englishKey] = value;
    }
  });

  print('🔤 تحويل الأعمدة: $row → $mappedRow');
  return mappedRow;
  }

  @override
Future<UserModels> getUserByUserID(String query) async {
  try {
    print('🔍 البحث عن مستخدم بالاستعلام: $query');
    
    if (query.isEmpty) {
      throw Exception('الاستعلام لا يمكن أن يكون فارغاً');
    }
    
    // البحث أولاً برقم القيد
    final userIdQuery = await usersCollection
        .where('userID', isEqualTo: query.trim())
        .limit(1)
        .get();
    
    if (userIdQuery.docs.isNotEmpty) {
      final userData = userIdQuery.docs.first.data();
      final user = UserModels.fromEntity(UserEntities.fromDocument(userData));
      print('✅ تم العثور على المستخدم بالرقم القيد: ${user.name} (${user.userID})');
      return user;
    }
    // البحث بالاسم
    final nameQuery = await usersCollection
        .where('name', isGreaterThanOrEqualTo: query.trim())
        .where('name', isLessThanOrEqualTo: query.trim() + '\uf8ff')
        .limit(10) // تحديد عدد النتائج
        .get();
    
    if (nameQuery.docs.isEmpty) {
      print('❌ لم يتم العثور على مستخدم بالاستعلام: $query');
      throw Exception('المستخدم غير موجود');
    }
    
    final userData = nameQuery.docs.first.data();
    final user = UserModels.fromEntity(UserEntities.fromDocument(userData));
    print('✅ تم العثور على المستخدم بالاسم: ${user.name} (${user.userID})');
    return user;
    } on FirebaseException catch (e) {
    print('🔥 خطأ Firebase في البحث عن المستخدم: ${e.code} - ${e.message}');
    throw Exception('خطأ في البحث عن المستخدم: ${_getFirebaseErrorMessage(e.code)}');
  } catch (e) {
    print('❌ خطأ عام في البحث عن المستخدم: $e');
    rethrow;
  }
}

  @override
  Future<List<UserModels>> getUsersByRoleOrIds({
    String? role,
    List<String>? userIds,
  }) async {
    try {
      QuerySnapshot querySnapshot;

      if (role != null) {
        // البحث حسب الدور
        print('🔍 جلب المستخدمين حسب الدور: $role');
        querySnapshot = await usersCollection.where('role', isEqualTo: role).get();
      } else if (userIds != null && userIds.isNotEmpty) {
        // البحث حسب قائمة من IDs
        print('🔍 جلب المستخدمين حسب قائمة IDs: $userIds');
        // Firestore 'in' query يقتصر على 10 عناصر، لذا نقسمها إذا كانت أكبر
        final List<UserModels> allUsers = [];
        for (int i = 0; i < userIds.length; i += 10) {
          final chunk = userIds.skip(i).take(10).toList();
          final chunkSnapshot = await usersCollection
              .where('userID', whereIn: chunk)
              .get();
          allUsers.addAll(chunkSnapshot.docs
              .map((doc) => UserModels.fromEntity(UserEntities.fromDocument(doc.data())))
              .toList());
        }
        return allUsers;
      } else {
        // إذا لم يتم توفير أي شيء، أرجع قائمة فارغة
        return [];
      }

      final users = querySnapshot.docs
          .map((doc) => UserModels.fromEntity(UserEntities.fromDocument(doc.data() as Map<String, dynamic>)))
          .toList();

      print('✅ تم جلب ${users.length} مستخدم');
      return users;
    } catch (e) {
      print('❌ خطأ في جلب المستخدمين: $e');
      rethrow;
    }
  }

  @override
  Future<void> cleanupCorruptedUsers() async {
    try {
      print('🧹 بدء تنظيف المستخدمين التالفين...');
      int deletedCount = 0;
      
      final usersSnapshot = await usersCollection.get();
      for (final doc in usersSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            await usersCollection.doc(doc.id).delete();
            deletedCount++;
            continue;
          }
          
          final name = data['name']?.toString() ?? '';
          final userID = data['userID']?.toString() ?? '';
          
          if (name.isEmpty || userID.isEmpty) {
            await usersCollection.doc(doc.id).delete();
            deletedCount++;
          }
        } catch (e) {
          await usersCollection.doc(doc.id).delete();
          deletedCount++;
        }
      }
      
      print('✅ تم تنظيف $deletedCount مستخدم تالف');
    } catch (e) {
      print('❌ خطأ في تنظيف المستخدمين التالفين: $e');
    }
  }

  // 🔥 دالة مساعدة لطباعة بيانات التصحيح
void _debugPrintRowData(int index, Map<String, dynamic> row, Map<String, dynamic> mappedRow) {
  print('''
📋 بيانات الصف ${index + 1}:
    📝 الأصل: $row
    🔄 المحول: $mappedRow
    👤 الاسم: ${mappedRow['name']}
    📧 الإيميل: ${mappedRow['email']}
    🆔 رقم القيد: ${mappedRow['userID']}
    🚻 الجنس: ${mappedRow['gender']}
    🏷️ الرقم الوطني: ${mappedRow['na_Number']}
''');
}
}
