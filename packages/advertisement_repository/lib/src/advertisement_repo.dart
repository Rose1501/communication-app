import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:user_repository/user_repository.dart';

abstract class AdvertisementRepository {
  Future<AdvertisemenModel> addAdvertisement(AdvertisemenModel advertisement);
  Future<void> updateAdvertisement(AdvertisemenModel advertisement);
  Future<void> deleteAdvertisement(String id);
  Future<List<AdvertisemenModel>> getAdvertisements();
  Future<String> uploadAdvertisementImage(File imageFile, String advertisementId);
  Future<String> uploadAdvertisementFile(File file, String advertisementId);
  Future<String> uploadAdvertisementImageAsBase64(File imageFile, String advertisementId);
  Future<void> removeAdvertisementImage(String advertisementId);
  Future<AdvertisemenModel> republishAdvertisement({
  required AdvertisemenModel originalAdvertisement,required String newDescription,
  required String newCustom,required UserModels currentUser,File? newImage,bool removeImage = false,
  });
}