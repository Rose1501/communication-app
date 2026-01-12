import 'package:equatable/equatable.dart';

class UserEntities extends Equatable {
  final String userID;
  final String name;
  final String email;
  final String role;
  final String gender;
  final String haveAccount;
  final String na_Number;
  final String? urlImg;
  final String? firebaseUID;

  UserEntities({
    required this.userID,
    required this.name,
    required this.email,
    required this.role,
    required this.gender,
    required this.haveAccount,
    required this.na_Number,
    this.urlImg,
    this.firebaseUID,
  });
  Map<String,dynamic> toDocument() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'role': role,
      'gender': gender,
      'haveAccount': haveAccount,
      'na_Number': na_Number,
      'urlImg': urlImg,
      'firebaseUID': firebaseUID,
    };
  }

  static UserEntities fromDocument(Map<String, dynamic> doc) {
    return UserEntities(
      userID: doc['userID'] as String,
      name: doc['name'] as String,
      email: doc['email'] as String,
      role: doc['role'] as String,
      gender: doc['gender'] as String,
      haveAccount: doc['haveAccount'] is int 
      ? doc['haveAccount'].toString()
      : doc['haveAccount'] as String? ?? '0',
      na_Number: doc['na_Number'] as String,
      urlImg: doc['urlImg'] as String?,
      firebaseUID: doc['firebaseUID'] as String?,
    );
  }

  @override
  List<Object?> props() => [
        userID,
        name,
        email,
        role,
        gender,
        haveAccount,
        na_Number,
        urlImg,
      ];
}
