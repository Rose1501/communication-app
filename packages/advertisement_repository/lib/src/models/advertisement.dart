import 'package:advertisement_repository/src/entities/entities.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

class AdvertisementModel extends Equatable {
  final String id;
  final String description;
  final DateTime timeAdv;
  final String? fileUrl;
  final String? advlImg;
  final String custom;
  final UserModels user; 

  const AdvertisementModel({
    required this.id,
    required this.description,
    required this.timeAdv,
    this.fileUrl,
    this.advlImg,
    required this.custom,
    required this.user,
  });

  // نموذج إعلان فارغ
  static final empty = AdvertisementModel(
    id: '',
    description: '',
    timeAdv: DateTime.now(),
    fileUrl: null,
    advlImg: null,
    custom: 'الكل',
    user: UserModels.empty,
  );

  // التحقق إذا كان النموذج فارغاً
  bool get isEmpty => this == AdvertisementModel.empty;
  
  // التحقق إذا كان النموذج غير فارغ
  bool get isNotEmpty => this != AdvertisementModel.empty;

  // نسخ النموذج مع إمكانية تعديل بعض الخصائص
  AdvertisementModel copyWith({
    String? id,
    String? description,
    DateTime? timeAdv,
    String? fileUrl,
    String? advlImg,
    String? custom,
    UserModels? user,
  }) {
    return AdvertisementModel(
      id: id ?? this.id,
      description: description ?? this.description,
      timeAdv: timeAdv ?? this.timeAdv,
      fileUrl: fileUrl ?? this.fileUrl,
      advlImg: advlImg ?? this.advlImg,
      custom: custom ?? this.custom,
      user: user ?? this.user,
    );
  }

  // تحويل النموذج إلى كيان
  AdvertisementEntity toEntity() {
    return AdvertisementEntity(
      id: id,
      description: description,
      timeAdv: timeAdv,
      fileUrl: fileUrl,
      advlImg: advlImg,
      custom: custom,
      user: user,
    );
  }

  // إنشاء نموذج من كيان
  static AdvertisementModel fromEntity(AdvertisementEntity entity) {
    return AdvertisementModel(
      id: entity.id,
      description: entity.description,
      timeAdv: entity.timeAdv,
      fileUrl: entity.fileUrl,
      advlImg: entity.advlImg,
      custom: entity.custom,
      user: entity.user,
    );
  }

  @override
  List<Object?> get props => [
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
    return 'AdvertisementModel{id: $id, description: $description, timeAdv: $timeAdv, fileUrl: $fileUrl, advlImg: $advlImg, custom: $custom, user: $user}';
  }
}