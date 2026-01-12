import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

class AdvertisementEntity extends Equatable {
  final String id;
  final String description;
  final DateTime timeAdv;
  final String? fileUrl;
  final String? advlImg;
  final String custom;
  final UserModels user;

  const AdvertisementEntity({
    required this.id,
    required this.description,
    required this.timeAdv,
    this.fileUrl,
    this.advlImg,
    required this.custom,
    required this.user,
  });

  // تحويل الكيان إلى Map لتخزينه في Firestore
  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'description': description,
      'timeAdv': timeAdv,
      'fileUrl': fileUrl,
      'advlImg': advlImg,
      'custom': custom,
      'user': user.toEntity().toDocument(),
    };
  }

  // إنشاء كيان من Map (من Firestore)
  static AdvertisementEntity fromDocument(Map<String, dynamic> doc) {
    return AdvertisementEntity(
      id: doc['id'] as String,
      description: doc['description'] as String,
      timeAdv: (doc['timeAdv'] as Timestamp).toDate(),
      fileUrl: doc['fileUrl'] as String?,
      advlImg: doc['advlImg'] as String?,
      custom: doc['custom'] as String,
      user: UserModels.fromEntity(UserEntities.fromDocument(doc['user'] as Map<String, dynamic>),),
    );
  }

  @override
  List<Object?> props() => [
        id,
        description,
        timeAdv,
        fileUrl,
        advlImg,
        custom,
        user,
      ];

  @override
  String toString() {
    return 'AdvertisementEntity{id: $id, description: $description, timeAdv: $timeAdv, fileUrl: $fileUrl, advlImg: $advlImg, custom: $custom, user: $user}';
  }
}