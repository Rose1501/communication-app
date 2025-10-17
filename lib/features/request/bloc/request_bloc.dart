import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:request_repository/request_repository.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository _requestRepository;

  RequestBloc({required RequestRepository requestRepository})
      : _requestRepository = requestRepository,
        super(RequestInitial()) {
    on<SendRequestEvent>(_onSendRequest);
    on<LoadStudentRequestsEvent>(_onLoadStudentRequests);
    on<LoadAllRequestsEvent>(_onLoadAllRequests);
    on<UpdateRequestStatusEvent>(_onUpdateRequestStatus);
    on<DeleteRequestEvent>(_onDeleteRequest);
    on<DeleteAllRequestsEvent>(_onDeleteAllRequests);
  }

  Future<void> _onSendRequest(
    SendRequestEvent event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      final savedRequest = await _requestRepository.sendRequest(event.request);
      print('✅ تم إرسال الطلب بنجاح: ${savedRequest.id}');
      emit(RequestSuccess());
      // إعادة تحميل الطلبات بعد الإرسال
      add(LoadStudentRequestsEvent(event.request.studentID));
    } catch (e) {
    print('❌ فشل إرسال الطلب: $e');
      emit(RequestFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadStudentRequests(
    LoadStudentRequestsEvent event,
    Emitter<RequestState> emit,
  ) async {
    if (state is StudentRequestsLoaded) {
    final currentState = state as StudentRequestsLoaded;
    if (currentState.requests.isNotEmpty) {
      print('🔄 البيانات موجودة بالفعل، جاري التحديث...');
    }
  }

  emit(RequestLoading());
  try {
    final requests = await _requestRepository.getStudentRequests(event.studentID);
    print('✅ تم جلب ${requests.length} طلب للطالب: ${event.studentID}');
    
    // 🔥 تحقق من التكرار
    final uniqueRequests = _removeDuplicateRequests(requests);
    if (uniqueRequests.length != requests.length) {
      print('⚠️ تم إزالة ${requests.length - uniqueRequests.length} طلب مكرر');
    }
    
    emit(StudentRequestsLoaded(requests: uniqueRequests));
    } catch (e) {
    print('❌ فشل جلب الطلبات: $e');
      emit(RequestFailure(error: e.toString()));
    }
  }

  // 🔥 دالة لإزالة الطلبات المكررة
List<StudentRequestModel> _removeDuplicateRequests(List<StudentRequestModel> requests) {
  final seen = <String>{};
  final uniqueRequests = <StudentRequestModel>[];
  
  for (final request in requests) {
    if (!seen.contains(request.id)) {
      seen.add(request.id);
      uniqueRequests.add(request);
    } else {
      print('🚫 طلب مكرر تم تجاهله: ${request.id}');
    }
  }
  
  return uniqueRequests;
}

  Future<void> _onLoadAllRequests(
    LoadAllRequestsEvent event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      final requests = await _requestRepository.getAllRequests();
      emit(AllRequestsLoaded(requests: requests));
    } catch (e) {
      emit(RequestFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateRequestStatus(
    UpdateRequestStatusEvent event,
    Emitter<RequestState> emit,
  ) async {
    try {
      await _requestRepository.updateRequestStatus(event.requestId, event.status,adminReply: event.adminReply,);
      // إعادة تحميل الطلبات بعد التحديث
        add(LoadAllRequestsEvent());
    } catch (e) {
      emit(RequestFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteRequest(
    DeleteRequestEvent event,
    Emitter<RequestState> emit,
  ) async {
    try {
      await _requestRepository.deleteRequest(event.requestId);
      // إعادة تحميل الطلبات بعد الحذف
      if (state is StudentRequestsLoaded) {
        add(LoadStudentRequestsEvent(event.studentID));
      } else if (state is AllRequestsLoaded) {
        add(LoadAllRequestsEvent());
      }
    } catch (e) {
      emit(RequestFailure(error: e.toString()));
    }
  }

  // 🔥 دالة جديدة لحذف جميع الطلبات
  Future<void> _onDeleteAllRequests(
    DeleteAllRequestsEvent event,
    Emitter<RequestState> emit,
  ) async {
    try {
      await _requestRepository.deleteAllRequests();
      
      // إعادة تحميل الطلبات بعد الحذف
      add(LoadAllRequestsEvent());
    } catch (e) {
      emit(RequestFailure(error: e.toString()));
    }
  }
}