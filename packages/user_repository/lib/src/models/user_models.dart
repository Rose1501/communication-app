import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/entities.dart';

class UserModels extends Equatable {
  final String userID;
  final String name;
  final String email;
  final String password;
  final String role;
  final String gender;
  final String haveAccount;
  final String na_Number;
  final String? urlImg;
  final String? firebaseUID;

  UserModels({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.gender,
    required this.haveAccount,
    required this.na_Number,
    this.urlImg,
    this.firebaseUID,
  });
// المستخدم الفارغ
  static final empty = UserModels(
    userID: '',
    name: '',
    email: '',
    password: '',
    role: '',
    gender: '',
    haveAccount: '',
    na_Number: '',
    urlImg: null,
  );
// دالة مساعدة للتحقق
  bool get isEmpty => this == UserModels.empty;
// دالة مساعدة للتحقق من وجود مستخدم
  bool get isNotEmpty => this != UserModels.empty;

UserModels copyWith({
  String? userID,
  String? name,
  String? email,
  String? password,
  String? role,
  String? gender,
  String? haveAccount,
  String? na_Number,
  String? urlImg,
  String? firebaseUID,
}) {
  return UserModels(
    userID: userID ?? this.userID,
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    role: role ?? this.role,
    gender: gender ?? this.gender,
    haveAccount: haveAccount ?? this.haveAccount,
    na_Number: na_Number ?? this.na_Number,
    urlImg: urlImg ?? this.urlImg,
    firebaseUID: firebaseUID ?? this.firebaseUID,
  );
}

UserEntities toEntity() {
  return UserEntities(
    userID: userID,
    name: name,
    email: email,
    password: password,
    role: role,
    gender: gender,
    haveAccount: haveAccount,
    na_Number: na_Number,
    urlImg: urlImg,
  );
}

static UserModels fromEntity(UserEntities entities) {
  return UserModels(
    userID: entities.userID,
    name: entities.name,
    email: entities.email,
    password: entities.password,
    role: entities.role,
    gender: entities.gender,
    haveAccount: entities.haveAccount,
    na_Number: entities.na_Number,
    urlImg: entities.urlImg,
  );
}

  @override
  List<Object?> get props => [
        userID,
        name,
        email,
        password,
        role,
        gender,
        haveAccount,
        na_Number,
        urlImg,
      ];
}
