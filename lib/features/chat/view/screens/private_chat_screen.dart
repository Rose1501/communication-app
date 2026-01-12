// lib/features/chat/view/screens/private_chat_screen.dart
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
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/chat/view/widgets/simple_chat_input_field.dart';
import 'package:user_repository/user_repository.dart';
import '../../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';

class PrivateChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;
  final String title;
  
  const PrivateChatScreen({
    super.key,
    required this.userId,
    required this.receiverId,
    required this.title,
  });
  
  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  UserModels? _currentUser;
  File? _selectedImage;
  bool _isConnected = true;
  bool _showConnectionAlert = false;
  bool _messagesLoaded = false;
  List<MessageModel> _currentMessages = [];
  String _currentUserId = '';
  
  @override
  void initState() {
    super.initState();
    _currentMessages = [];
    _messagesLoaded = false;
    
    // تهيئة معرف المستخدم الحالي
    _currentUserId = widget.userId;
    
    // التحقق من أن userId و receiverId غير فارغين قبل تحميل الرسائل
    if (_currentUserId.isNotEmpty && widget.receiverId.isNotEmpty) {
      _loadMessages();
    } else {
      print('❌ خطأ: userId أو receiverId فارغ في PrivateChatScreen');
      print('userId: ${widget.userId}');
      print('receiverId: ${widget.receiverId}');
      
      // محاولة جلب معرف المستخدم الحالي إذا كان فارغاً
      if (_currentUserId.isEmpty) {
        _getCurrentUserId();
      }
    }
    
    _loadCurrentUserData();
    _startConnectionMonitoring();
  }

  // دالة جديدة لجلب معرف المستخدم الحالي
  Future<void> _getCurrentUserId() async {
    try {
      final userRepo = context.read<UserRepository>();
      final user = await userRepo.getCurrentUser();
      if (user.userID.isNotEmpty) {
        setState(() {
          _currentUserId = user.userID;
        });
        // الآن بعد الحصول على المعرف، قم بتحميل الرسائل
        _loadMessages();
      }
    } catch (e) {
      print('❌ خطأ في جلب معرف المستخدم: $e');
    }
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final userRepo = context.read<UserRepository>();
      final user = await userRepo.getCurrentUser();
      if (mounted) {
        setState(() => _currentUser = user);
      }
    } catch (e) {
      print('❌ خطأ في جلب المستخدم: $e');
    }
  }
  
  void _loadMessages() {
    context.read<ChatBloc>().add(LoadPrivateMessages(
      userId: widget.userId,
      receiverId: widget.receiverId,
    ));
  }

  void _startConnectionMonitoring() async {
    // التحقق الأولي
    _isConnected = await checkInternetconnection();
    print('📶 حالة الاتصال الأولية: $_isConnected');
    
    if (!_isConnected && mounted) {
      setState(() {
        _showConnectionAlert = true;
      });
    }
    
    // التحقق الدوري كل 30 ثانية
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

    // التحقق من أن userId و receiverId غير فارغين
    if (_currentUserId.isEmpty || widget.receiverId.isEmpty) {
      ShowWidget.showMessage(
        context,
        'خطأ: معرف المستخدم غير صالح',
        ColorsApp.red,
        font13White,
      );
      return;
    }

    // ✅ تحويل الصورة
    String? base64Image;
    if (_selectedImage != null) {
      try {
        base64Image = await ImageUtils.fileToBase64(_selectedImage!);
      } catch (e) {
      print('❌ خطأ في تحويل الصورة: $e');
      ShowWidget.showMessage(
        context,
        'فشل في معالجة الصورة',
        ColorsApp.red,
        font13White,
      );
      return;
    }
    }

    final senderName = _currentUser?.name ?? 'مستخدم';
    
    // إنشاء رسالة مؤقتة لعرضها فوراً
    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      message: _controller.text.trim(),
      senderId: _currentUserId,
      senderName: senderName,
      receiverId: widget.receiverId,
      messageAttachment: base64Image ?? '',
      timeMessage: DateTime.now().toIso8601String(),
      timestamp: DateTime.now(),
      isDeleted: false,
      chatType: 'private',
    );
    
    print('🚀� محاولة إرسال رسالة من المستخدم: $_currentUserId إلى ${widget.receiverId}');
    print('📤 إرسال رسالة بواسطة: $senderName');
    print('📤 إرسال رسالة: ${tempMessage.message}');
    print('📎 هل الصورة موجودة؟ ${base64Image != null}');
    
    // إضافة الرسالة محلياً فوراً
    if (mounted) {
      setState(() {
        _currentMessages = [tempMessage, ..._currentMessages];
      });
    }
    
    // إرسال الرسالة عبر الـ Bloc
    context.read<ChatBloc>().add(SendMessage(tempMessage));
    
    // مسح الحقول
    _controller.clear();
    if (_selectedImage != null) {
      setState(() => _selectedImage = null);
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      await ImagePickerService.pickImage(
        context,
        (File imageFile) {
          if (mounted) {
            setState(() {
              _selectedImage = imageFile;
            });
          }
        },
      );
    } catch (e) {
      print('❌ خطأ في اختيار الصورة: $e');
      ShowWidget.showMessage(
        context,
        'فشل في اختيار الصورة',
        ColorsApp.red,
        font13White,
      );
    }
  }
  
  void _onImageTap(String imageUrl) {
    if (imageUrl.isNotEmpty && imageUrl != 'image') {
      AdvancedImagePreviewDialog.show(
        context,
        imageUrl,
        tag: 'private_${widget.receiverId}_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  void _showMessageOptions(MessageModel message) {
    // المستخدم الحالي فقط يمكنه تعديل أو حذف رسائله
    final isMyMessage = message.senderId == _currentUserId;
    if (!isMyMessage) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل الرسالة'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف الرسالة'),
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

  // ✅ تنفيذ تعديل الرسالة
  void _editMessage(MessageModel message) {
    _controller.text = message.message;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل الرسالة', style: font18blackbold),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'اكتب الرسالة الجديدة'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                final updatedMessage = message.copyWith(
                  message: _controller.text.trim(),
                  timestamp: DateTime.now(),
                );
                // 2. ✅ الحل: فرض إعادة تحميل الرسائل لتحديث الواجهة والكاش
                context.read<ChatBloc>().add(LoadPrivateMessages(
                  userId: widget.userId,
                  receiverId: widget.receiverId,
                ));
                context.read<ChatBloc>().add(UpdateMessage(updatedMessage , groupId: null));
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

  // ✅ تأكيد الحذف
  void _confirmDeleteMessage(MessageModel message) {
    CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الرسالة',
      message: 'هل أنت متأكد من حذف هذه الرسالة؟',
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<ChatBloc>().add(DeleteMessage(message, groupId: null));
        ShowWidget.showMessage(context, 'تم حذف الرسالة', Colors.green, font13White);
      }
    });
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
            child: Text('إعادة المحاولة', style: font13White),
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
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _messagesLoaded = false;
    print('♻️ PrivateChatScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: widget.title),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ShowWidget.showMessage(
              context,
              state.message,
              ColorsApp.red,
              font13White,
            );
          }
          if (state is ChatMessageSent || state is PrivateMessagesLoaded) {
            _scrollToBottom();
          }
          // إضافة حالة لإيقاف التحميل بعد الإرسال
          if (state is ChatSending) {
            // لا تفعل شيئاً، فقط انتظر الحالة التالية
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading && !(state is ChatSending)) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PrivateMessagesLoaded) {
              final messages = state.messages;
              
              // تحديث قائمة الرسائل الحالية باستخدام WidgetsBinding
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _currentMessages.length != messages.length) {
                  setState(() {
                    _currentMessages = messages;
                  });
                }
              });
              
              if (messages.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildMessagesList(messages);
            }
            if (state is ChatError) {
              return Center(child: Text(state.message));
            }
            // عرض قائمة الرسائل الحالية أثناء الإرسال
            if (state is ChatSending) {
              return _buildMessagesList(_currentMessages);
            }
            return const Center(child: CircularProgressIndicator());
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
    print('📨 بناء قائمة الرسائل للمستخدم: $_currentUserId');
    
    // فلترة الرسائل لإزالة الرسائل المكررة
    final uniqueMessages = <MessageModel>[];
    final seenIds = <String>{};
    
    for (final message in messages) {
      if (!seenIds.contains(message.id) && !message.isDeleted) {
        seenIds.add(message.id);
        uniqueMessages.add(message);
      }
    }
    
    if (uniqueMessages.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: () async {
        print('🔃 سحب للتحديث');
        _messagesLoaded = false;
        _loadMessages();
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(8),
        itemCount: uniqueMessages.length,
        itemBuilder: (context, index) {
          final message = uniqueMessages[index];
          final isSender = message.senderId == _currentUserId;
          
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 60, color: ColorsApp.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('لا توجد رسائل'),
          const SizedBox(height: 8),
          const Text('ابدأ المحادثة الآن'),
        ],
      ),
    );
  }
}