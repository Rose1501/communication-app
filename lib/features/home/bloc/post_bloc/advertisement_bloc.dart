// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:advertisement_repository/advertisement_repository.dart';

part 'advertisement_events.dart';
part 'advertisement_states.dart';

class AdvertisementBloc extends Bloc<AdvertisementEvent, AdvertisementState> {
  final AdvertisementRepository advertisementRepository;
  
  StreamSubscription? _advertisementSubscription;

  AdvertisementBloc({required this.advertisementRepository})
      : super(AdvertisementInitial()) {
    on<LoadAdvertisementsEvent>(_onLoadAdvertisements);
    on<AddAdvertisementEvent>(_onAddAdvertisement);
    on<UpdateAdvertisementEvent>(_onUpdateAdvertisement);
    on<DeleteAdvertisementEvent>(_onDeleteAdvertisement);
    on<RefreshAdvertisementsEvent>(_onRefreshAdvertisements);
    on<RemoveAdvertisementImageEvent>(_onRemoveAdvertisementImage);
  }

  // معالجة حدث تحميل الإعلانات
  Future<void> _onLoadAdvertisements(
    LoadAdvertisementsEvent event,
    Emitter<AdvertisementState> emit,
  ) async {
    try {
      emit(AdvertisementLoading());
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
    } catch (e) {
      emit(AdvertisementError(message: e.toString()));
    }
  }

  // معالجة حدث إضافة إعلان
  Future<void> _onAddAdvertisement(
    AddAdvertisementEvent event,
    Emitter<AdvertisementState> emit,
  ) async {
    try {
      final newAdvertisement =
          await advertisementRepository.addAdvertisement(event.advertisement);
      emit(AdvertisementAdded(advertisement: newAdvertisement));
      
      // إعادة تحميل الإعلانات بعد الإضافة
      add(LoadAdvertisementsEvent());
    } catch (e) {
      emit(AdvertisementError(message: e.toString()));
    }
  }

  // معالجة حدث تحديث إعلان
Future<void> _onUpdateAdvertisement(
  UpdateAdvertisementEvent event,
  Emitter<AdvertisementState> emit,
) async {
  try {
    // التحقق من أن الحالة الحالية تحتوي على الإعلانات
    if (state is AdvertisementLoaded) {
      emit(AdvertisementLoading()); // عرض التحميل
      print('🔄 جاري تحديث الإعلان في الـ Bloc: ${event.advertisement.id}');
      print('🖼️ صورة الإعلان بعد التحديث: ${event.advertisement.advlImg ?? "NULL"}');
      await advertisementRepository.updateAdvertisement(event.advertisement);
      
      // تحديث القائمة بدون إعادة تحميل كاملة من الخادم
      final currentState = state as AdvertisementLoaded;
      final updatedAdvertisements = currentState.advertisements.map((adv) {
        return adv.id == event.advertisement.id ? event.advertisement : adv;
      }).toList();
      
      emit(AdvertisementLoaded(advertisements: updatedAdvertisements));
      print('🔄 إعادة تحميل البيانات من الخادم للتأكد من الاتساق');
      // إعادة تحميل الإعلانات بعد الحذف
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
      print('✅ تم تحديث الإعلان بنجاح في الـ Bloc');
    }
  } catch (e) {
    print('❌ خطأ في الـ Bloc أثناء التحديث: $e');
    try {
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
    } catch (_) {
      emit(AdvertisementError(message: 'فشل في تحديث الإعلان: ${e.toString()}'));
    }
  }
}

  // معالجة حدث حذف إعلان
  Future<void> _onDeleteAdvertisement(
    DeleteAdvertisementEvent event,
    Emitter<AdvertisementState> emit,
  ) async {
    try {
        emit(AdvertisementLoading());
      
      // تنفيذ الحذف من قاعدة البيانات
      await advertisementRepository.deleteAdvertisement(event.advertisementId);
      // إعادة تحميل الإعلانات بعد الحذف
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
      
    } catch (e) {
      emit(AdvertisementError(message: 'فشل في حذف الإعلان: ${e.toString()}'));
      
      // محاولة إعادة تحميل البيانات للحفاظ على الاتساق
    try {
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
    } catch (_) {}
    }
  }

  // معالجة حدث تحديث الإعلانات
  Future<void> _onRefreshAdvertisements(
    RefreshAdvertisementsEvent event,
    Emitter<AdvertisementState> emit,
  ) async {
    try {
      add(LoadAdvertisementsEvent());
    } catch (e) {
      emit(AdvertisementError(message: e.toString()));
    }
  }

  // 🔥 معالجة حدث إزالة الصورة
  Future<void> _onRemoveAdvertisementImage(
    RemoveAdvertisementImageEvent event,
    Emitter<AdvertisementState> emit,
  ) async {
    try {
      print('🗑️ بدء إزالة صورة الإعلان في الـ Bloc: ${event.advertisementId}');
      
      emit(AdvertisementLoading());
      
      // استدعاء دالة إزالة الصورة من الـ Repository
      await advertisementRepository.removeAdvertisementImage(event.advertisementId);
      
      // إعادة تحميل البيانات للتأكد من الاتساق
      final advertisements = await advertisementRepository.getAdvertisements();
      emit(AdvertisementLoaded(advertisements: advertisements));
      
      print('✅ تم إزالة صورة الإعلان بنجاح في الـ Bloc');
      
    } catch (e) {
      print('❌ خطأ في إزالة صورة الإعلان في الـ Bloc: $e');
      
      // محاولة استعادة البيانات
      try {
        final advertisements = await advertisementRepository.getAdvertisements();
        emit(AdvertisementLoaded(advertisements: advertisements));
      } catch (_) {
        emit(AdvertisementError(message: 'فشل في إزالة الصورة: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _advertisementSubscription?.cancel();
    return super.close();
  }
}