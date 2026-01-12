import 'dart:async';
import 'dart:io';

import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/components/widget/image_picker_service.dart';
import 'package:myproject/components/widget/image_preview_dialog.dart';
import 'package:myproject/components/widget/image_utils.dart';
import 'package:myproject/features/chat/view/widgets/simple_chat_input_field.dart';
import 'package:user_repository/user_repository.dart';
import '../../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/members_bottom_sheet.dart';

class DoctorsChatScreen extends StatefulWidget {
  final String userId;
  
  const DoctorsChatScreen({
    super.key,
    required this.userId,
  });
  
  @override
  State<DoctorsChatScreen> createState() => _DoctorsChatScreenState();
}

class _DoctorsChatScreenState extends State<DoctorsChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _members = [];
  UserModels? _currentUser;
  File? _selectedImage;
  bool _isLoading = true;
  bool _messagesLoaded = false;
  bool _isConnected = true;
  bool _showConnectionAlert = false;
  bool _hasLoadedOnce = false;

  // ✅ إضافة المتغير المفقود لحفظ الرسائل محلياً
  List<MessageModel> _currentMessages = [];
  
  @override
  void initState() {
    super.initState();
    // إعادة تعيين العلامات لضمان التحميل الصحيح
    _messagesLoaded = false;
    _hasLoadedOnce = false;
    _currentMessages = [];
    
    try {
      // 1. تحميل الأعضاء
      _loadMembers();
      // 2. جلب بيانات المستخدم الحالي
      _loadCurrentUserData();
      // 3. البدء في مراقبة الاتصال
      _startConnectionMonitoring();
    } catch (e) {
      print('❌ خطأ في تهيئة الشاشة: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    print('♻️ DoctorsChatScreen disposed');
    super.dispose();
  }

  // ✅ دالة جديدة لجلب بيانات المستخدم الحالي
  Future<void> _loadCurrentUserData() async {
    try {
      final userRepo = context.read<UserRepository>();
      final user = await userRepo.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        print('✅ تم جلب بيانات المستخدم: ${user.name}');
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: $e');
    }
  }
  
  Future<void> _loadMembers() async {
    try {
      // جلب الأطباء من Repository
      final doctors = await context.read<ChatBloc>().chatRepository.getDoctors();
      if (mounted) {
        setState(() {
          _members = doctors.map((doctor) => {
            'Name': doctor['name'] ?? 'غير محدد',
            'userID': doctor['userID'] ?? '',
            'Role': doctor['Role'] ?? 'Doctor',
            'url_img': doctor['url_img'] ?? '',
            'gender': doctor['gender'] ?? '',
          }).toList();
        });
      }
      print('اعضاء مجموعة الدكاترة $_members');
      // ترتيب الأعضاء (رئيس القسم أولاً)
      _members.sort((a, b) {
        if (a['Role'] == 'Manager' && b['Role'] != 'Manager') return -1;
        if (a['Role'] != 'Manager' && b['Role'] == 'Manager') return 1;
        return 0;
      });
      print('✅ تم جلب ${_members.length} أعضاء للمجموعةالدكاترة');
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  void _loadMessages() {
    // ✅ إزالة الشرط الذي يمنع إعادة التحميل
    // if (_messagesLoaded) { ... return; } 
    
    try {
      if (mounted) {
        final chatBloc = context.read<ChatBloc>();
        print('✅ إرسال حدث LoadDoctorsMessages');
        chatBloc.add(const LoadDoctorsMessages());
        _messagesLoaded = true;
      } else {
        print('⚠️ context غير متاح');
      }
    } catch (e) {
      print('❌ خطأ في تحميل الرسائل: $e');
      _messagesLoaded = false;
    }
  }

  void _startConnectionMonitoring() async {
    _isConnected = await checkInternetconnection();
    print('📶 حالة الاتصال الأولية: $_isConnected');
    
    if (!_isConnected && mounted) {
      setState(() {
        _showConnectionAlert = true;
      });
    }
    
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final newConnection = await checkInternetconnection();
      if (newConnection != _isConnected && mounted) {
        setState(() {
          _isConnected = newConnection;
          _showConnectionAlert = !_isConnected;
        });
        
        if (_isConnected) {
          print('✅ تم استعادة الاتصال');
          ShowWidget.showMessage(
            context,
            'تم استعادة الاتصال بالإنترنت',
            ColorsApp.green,
            font13White,
          );
          // إعادة تحميل الرسائل عند استعادة الاتصال
          _loadMessages();
        }
      }
    });
  }
  
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    if (!_isConnected) {
      ShowWidget.showMessage(
        context,
        'لا يوجد اتصال بالإنترنت',
        ColorsApp.red,
        font13White,
      );
      return;
    }

    String? base64Image;
    if (_selectedImage != null) {
      try {
        base64Image = await ImageUtils.fileToBase64(_selectedImage!);
      } catch (e) {
        ShowWidget.showMessage(context, 'فشل في معالجة الصورة', Colors.red, font13White);
        return;
      }
    }
    
    final senderName = _currentUser?.name ?? 'مستخدم';
    final message = MessageModel(
      id: '',
      message: _controller.text.trim(),
      senderId: widget.userId,
      senderName: senderName,
      messageAttachment: base64Image ?? '',
      timeMessage: DateTime.now().toIso8601String(),
      groupId: 'doctors_group',
      timestamp: DateTime.now(),
      isDeleted: false,
      chatType:'doctors_group',
    );
    
    context.read<ChatBloc>().add(SendMessage(message));
    _controller.clear();
    if (_selectedImage != null) {
      setState(() => _selectedImage = null);
    }
  }

  Future<void> _pickImage() async {
    try {
      await ImagePickerService.pickImage(context, (File imageFile) {
        if (mounted) setState(() => _selectedImage = imageFile);
      });
    } catch (e) {
      print('❌ خطأ في اختيار الصورة: $e');
      ShowWidget.showMessage(context, 'فشل في اختيار الصورة', Colors.red, font13White);
    }
  }

  void _onImageTap(String imageUrl) {
    if (imageUrl.isNotEmpty && imageUrl != 'image') {
      AdvancedImagePreviewDialog.show(context, imageUrl, tag: 'doctors_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  void _showMessageOptions(MessageModel message) {
    final isMyMessage = message.senderId == widget.userId;
    if (!isMyMessage) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title:  Text('تعديل الرسالة', style: font16black),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:  Text('حذف الرسالة', style: font16black.copyWith(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteMessage(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editMessage(MessageModel message) {
    _controller.text = message.message;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('تعديل الرسالة', style: font18blackbold),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'اكتب الرسالة الجديدة'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('إلغاء', style: font14grey),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                final updatedMessage = message.copyWith(
                  message: _controller.text.trim(),
                  timestamp: DateTime.now(),
                );
                context.read<ChatBloc>().add(UpdateMessage(updatedMessage, groupId: 'doctors_group'));
                 // 2. تحديث فوري للقائمة المحلية (Optimistic Update)
                setState(() {
                  final index = _currentMessages.indexWhere((msg) => msg.id == message.id);
                  if (index != -1) {
                    _currentMessages[index] = updatedMessage;
                  }
                });
                _controller.clear();
                Navigator.pop(context);
              }
            },
            child: Text('حفظ', style: font15primary),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMessage(MessageModel message) {
    CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الرسالة',
      message: 'هل أنت متأكد من حذف هذه الرسالة؟',
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        // 1. إرسال حدث الحذف
        context.read<ChatBloc>().add(DeleteMessage(message, groupId: 'doctors_group'));
        // 2. تحديث فوري للقائمة المحلية (Optimistic Update)
        setState(() {
          _currentMessages.removeWhere((msg) => msg.id == message.id);
        });
        ShowWidget.showMessage(context, 'تم حذف الرسالة', Colors.green, font13White);
         // 3.  إعادة تحميل الرسائل بعد فترة قصيرة للتأكد من المزامنة مع السيرفر
        Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _loadMessages(); 
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  

  Widget _buildConnectionAlert() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: ColorsApp.red.withOpacity(0.9),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: ColorsApp.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'لا يوجد اتصال بالإنترنت',
              style: font13White,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _showConnectionAlert = false);
              _startConnectionMonitoring();
            },
            child:  Text('إعادة المحاولة', style: font13White),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorsApp.primaryColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'صورة مرفقة',
              style: font13black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: ColorsApp.red, size: 20),
            onPressed: () {
              setState(() => _selectedImage = null);
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.primaryColor,
        title: Column(
          children: [
            const Text('مجموعة اعضاء هيئة التدريس'),
            if (_members.isNotEmpty)
              Text(
                '${_members.length} عضو',
                style: font11White,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            onPressed: () {
              if (_members.isNotEmpty) {
                showModalBottomSheet(context: context, builder: (context) => MembersBottomSheet(members: _members));
              }
            },
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            print('❌ خطأ في ChatBloc: ${state.message}');
            ShowWidget.showMessage(context, state.message, Colors.red, font13White);
          }
          
          if (state is ChatMessageSent ) {
            _scrollToBottom();
          }
          
          // ✅ تحديث القائمة المحلية عند وصول أي تحديث للرسائل (حذف، تعديل، تحميل جديد)
          if (state is DoctorsMessagesLoaded) {
            print('✅ تم تحميل ${state.messages.length} رسالة للمجموعة');
            setState(() {
              _currentMessages = state.messages;
              _hasLoadedOnce = true;
            });
            _scrollToBottom();
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            // حالة البداية/المحادثات العامة
            if (state is MyChatsLoaded) {
              // إذا كنا في هذه الشاشة والحالة للمحادثات العامة، نحاول تحميل رسائل الأطباء
              if (!_hasLoadedOnce) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadMessages();
                });
              }
              // عرض مؤشر تحميل مبدئي
              return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
            }

            // حالة التحميل (إلا إذا تم التحميل بالفعل ونحن ننتظر التحديث)
            if (state is ChatLoading && !_hasLoadedOnce) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ColorsApp.orange),
                    const SizedBox(height: 16),
                    Text('جاري تحميل الرسائل...', style: font14grey),
                  ],
                ),
              );
            }
            
            // حالة عدم وجود رسائل
            if (state is DoctorsMessagesLoaded && state.messages.isEmpty) {
              return _buildEmptyState();
            }
            
            // حالة وجود رسائل
            if (state is DoctorsMessagesLoaded) {
              // نستخدم _currentMessages لضمان الثبات في العرض
              return _buildMessagesList(state.messages);
            }
            
            // حالة الخطأ
            if (state is ChatError) {
              print('❌ خطأ في ChatBloc: ${state.message}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: ColorsApp.grey),
                    const SizedBox(height: 16),
                    Text('حدث خطأ', style: font16blackbold),
                    const SizedBox(height: 8),
                    Text(state.message, style: font14grey),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadMessages(),
                      style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
                      child:  Text('إعادة المحاولة', style: font15White),
                    ),
                  ],
                ),
              );
            }
            
            // حالة افتراضية
            return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // معاينة الصورة
          if (_selectedImage != null)
            _buildSelectedImagePreview(),
            
          // تنبيه فقدان الاتصال
          if (_showConnectionAlert)
            _buildConnectionAlert(),
            
          // حقل الإدخال
          SimpleChatInputField(
            controller: _controller,
            onSend: _sendMessage,
            onImagePick: _pickImage,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesList(List<MessageModel> messages) {
    print('📨 بناء قائمة الرسائل للمجموعة: doctors_group');
    
    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: () async {
        print('🔃 سحب للتحديث');
        _loadMessages();
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isSender = message.senderId == widget.userId;
          
          return MessageBubble(
            key: ValueKey(message.id),
            message: message,
            isSender: isSender,
            showSenderName: !isSender && message.senderId != 'system',
            onImageTap: () => _onImageTap(message.messageAttachment),
            onLongPress: () => _showMessageOptions(message),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_outlined,
              size: 60,
              color: ColorsApp.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد رسائل بعد',
              style: font18black.copyWith(color: ColorsApp.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ المحادثة مع الأعضاء الآن',
              style: font14grey,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadMessages(),
              style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
              child:  Text('تحديث', style: font15White),
            ),
          ],
        ),
      ),
    );
  }
}