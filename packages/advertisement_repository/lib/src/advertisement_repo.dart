import 'dart:io';
import 'package:advertisement_repository/advertisement_repository.dart';

abstract class AdvertisementRepository {
  Future<AdvertisementModel> addAdvertisement(AdvertisementModel advertisement);
  Future<void> updateAdvertisement(AdvertisementModel advertisement);
  Future<void> deleteAdvertisement(String id);
  Future<List<AdvertisementModel>> getAdvertisements();
  Future<String> uploadAdvertisementImage(File imageFile, String advertisementId);
  Future<String> uploadAdvertisementFile(File file, String advertisementId);
  Future<String> uploadAdvertisementImageAsBase64(File imageFile, String advertisementId);
  Future<void> removeAdvertisementImage(String advertisementId);
}