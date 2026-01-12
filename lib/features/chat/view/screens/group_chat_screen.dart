// lib/features/chat/view/screens/group_chat_screen.dart
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
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/members_bottom_sheet.dart';

class GroupChatScreen extends StatefulWidget {
  final String userId;
  final String groupId;
  final String title;
  final CoursesModel? course;
  final GroupModel? groupModel;
  final String userRole;
  
  const GroupChatScreen({
    super.key,
    required this.userId,
    required this.groupId,
    required this.title,
    this.course,
    this.groupModel,
    required this.userRole,
  });
  
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _members = [];
  GroupModel? _groupDetails;
  List<StudentModel> _students = [];
  String? _doctorName;
  UserModels? _currentUser;
  
  bool _isLoading = true;
  bool _isConnected = true;
  File? _selectedImage;
  bool _showConnectionAlert = false;
  bool _messagesLoaded = false;
  List<MessageModel> _currentMessages = [];
  
  @override
  void initState() {
    super.initState();
    print('🚀 GroupChatScreen initState');
    print('📌 userId: ${widget.userId}');
    print('📌 groupId: ${widget.groupId}');
    print('📌 userRole: ${widget.userRole}');
    // إعادة تعيين علامة التحميل لضمان التحميل عند فتح الشاشة
    _messagesLoaded = false;
    _currentMessages = [];
    _initializeScreen();
    _loadCurrentUserData();
  }

  Future<void> _initializeScreen() async {
    try {
      print('🔄 بدء تهيئة الشاشة');
      
      // 1. تحميل بيانات المجموعة أولاً
      await _loadGroupDetails();
      // 2. ✅ إرسال حدث للمزامنة مع الريبوستوري 
      // ✅ تعديل: فقط قم بمزامنة البيانات (Update) إذا كان groupModel متوفر
      if (_groupDetails != null && _groupDetails!.isNotEmpty) {
        print('🔄 جاري مزامنة الأعضاء مع Firestore...');
        context.read<ChatBloc>().add(EnsureGroupData(
          groupId: widget.groupId,
          groupModel: widget.groupModel,
          courseName: widget.course?.name,
        ));
      } else {
        print('⚠️ groupModel غير متوفر، سيتم جلب الأعضاء فقط (Read-Only)');
      }
      // 3. تحميل الأعضاء
      await _loadGroupMembers();
      // 4. البدء في مراقبة الاتصال
      _startConnectionMonitoring();
      // 5. تحميل الرسائل بعد تهيئة الشاشة
      _loadMessages();
      
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
  
  void _loadMessages() {
    if (_messagesLoaded) {
      print('⚠️ الرسائل تم تحميلها بالفعل');
      return;
    }
    
    print('🔍 تحميل الرسائل للمجموعة: ${widget.groupId}');
    
    try {
      if (mounted) {
        final chatBloc = context.read<ChatBloc>();
        print('✅ إرسال حدث LoadGroupMessages');
        chatBloc.add(LoadGroupMessages(widget.groupId));
        _messagesLoaded = true;
      } else {
        print('⚠️ context غير متاح');
      }
    } catch (e) {
      print('❌ خطأ في تحميل الرسائل: $e');
    }
  }

  Future<void> _loadGroupDetails() async {
    try {
      print('🔍 جلب تفاصيل المجموعة');
      
      if (widget.groupModel != null) {
        _groupDetails = widget.groupModel;
        print('✅ تم استخدام groupModel الممرر');
      } else if (widget.course != null) {
        final groups = widget.course!.groups;
        _groupDetails = groups.firstWhere(
          (group) => group.id == widget.groupId,
          orElse: () => GroupModel.empty,
        );
        print('✅ تم البحث عن المجموعة في المادة');
      }
      
      if (_groupDetails != null && _groupDetails!.isNotEmpty) {
        _doctorName = _groupDetails!.nameDoctor;
        _students = _groupDetails!.students;
        print('✅ تم تحميل تفاصيل المجموعة: ${_groupDetails!.name}');
        print('👨‍🏫 الدكتور: $_doctorName');
        print('👥 عدد الطلاب: ${_students.length}');
      } else {
        print('⚠️ لم يتم العثور على تفاصيل المجموعة');
      }
    } catch (e) {
      print('❌ خطأ في تحميل تفاصيل المجموعة: $e');
    }
  }
  
      Future<void> _loadGroupMembers() async {
    try {
      print('🔍 تحضير قائمة الأعضاء للعرض');

      // --- الحالة 1: البيانات متوفرة محلياً (من Widget) ---
      if (_groupDetails != null && _groupDetails!.isNotEmpty) {
        print('✅ استخدام بيانات groupModel المحلية');
        List<Map<String, dynamic>> loadedMembers = [];
        
        // إضافة الدكتور
        if (_groupDetails!.idDoctor.isNotEmpty) {
          loadedMembers.add({
            'Name': _groupDetails!.nameDoctor,
            'userID': _groupDetails!.idDoctor,
            'Role': 'Doctor',
            'url_img': '',
            'gender': '',
          });
        }
        
        // إضافة الطلاب
        for (final student in _groupDetails!.students) {
          loadedMembers.add({
            'Name': student.name,
            'userID': student.studentId,
            'Role': 'Student',
            'url_img': '',
            'gender': '',
            'studentId': student.studentId,
          });
        }

        if (mounted) {
          setState(() {
            _members = loadedMembers;
          });
        }
      } 
      // --- الحالة 2: البيانات غير متوفرة (جلب من الريبوستوري) ---
      else {
        print('⚠️ groupModel فارغ، جلب الأعضاء من الريبوستوري...');
        // نستخدم BlocListener لاستقبال النتيجة لاحقاً، لكن نرسل الطلب هنا
        if (mounted) {
          context.read<ChatBloc>().add(LoadGroupMembersFallback(widget.groupId));
        }
      }
      
    } catch (e) {
      print('❌ خطأ في تحضير الأعضاء: $e');
    }
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
          
          // إعادة تحميل الرسائل عند استعادة الاتصال
          _loadMessages();
        }
      }
    });
  }
  
  void _sendMessage() async {
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

    // ✅ خطوة تحويل الصورة
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
    
    // استخدام اسم المستخدم الحقيقي من UserRepository، أو الافتراضي إذا لم يتوفر
    final senderName = _currentUser?.name ?? _getCurrentUserName();

    final message = MessageModel(
      id: '',
      message: _controller.text.trim(),
      senderId: widget.userId,
      senderName: senderName,
      groupId: widget.groupId,
      messageAttachment: base64Image ?? '',
      timeMessage: DateTime.now().toIso8601String(),
      timestamp: DateTime.now(),
      isDeleted: false,
      chatType:'educational_group',
    );
    
    print('📤 إرسال رسالة بواسطة: $senderName');
    print('📤 إرسال رسالة: ${message.message}');
    print('📎 هل الصورة موجودة؟ ${base64Image != null}');
    
    context.read<ChatBloc>().add(SendMessage(message));
    
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
  
  String _getCurrentUserName() {
    String? name;
    if (widget.userRole == 'Doctor') {
      name = _doctorName ?? widget.groupModel!.nameDoctor ;
    } else {
      // البحث عن الطالب في القائمة المحملة
      try {
        final student = _students.firstWhere(
          (s) => s.id == widget.userId,
          orElse: () => StudentModel.empty,
        );
        
        if (student.isNotEmpty && student.name.isNotEmpty) {
          name = student.name;
        }
      } catch (e) {
        print('⚠️ خطأ في العثور على اسم الطالب: $e');
      }
    }
    // ✅ في حال لم نجد الاسم، نرجع اسم افتراضي لتجنب الحفظ فارغ
    return name ?? (widget.userRole == 'Doctor' ? 'دكتور' : 'طالب');
  }
// ✅ دالة عرض خيارات التعديل والحذف
  void _showMessageOptions(MessageModel message) {
    // المستخدم الحالي فقط يمكنه تعديل أو حذف رسائله
    final isMyMessage = message.senderId == widget.userId;
    if (!isMyMessage) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: ColorsApp.primaryColor),
              title: Text('تعديل الرسالة', style: font16black),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('حذف الرسالة', style: font16black.copyWith(color: Colors.red)),
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
          decoration: InputDecoration(hintText: 'اكتب الرسالة الجديدة'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: font14grey),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                final updatedMessage = message.copyWith(
                  message: _controller.text.trim(),
                  timestamp: DateTime.now(), // تحديث الوقت محلياً للعرض الفوري
                );
                
                // إرسال حدث التعديل مع groupId لضمان التعديل في المكان الصحيح
                context.read<ChatBloc>().add(
                  UpdateMessage(updatedMessage, groupId: widget.groupId)
                );
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
        // ✅ تمرير groupId هنا هو الحل لمشكلة الحذف الخاطئ
        context.read<ChatBloc>().add(
          DeleteMessage(message, groupId: widget.groupId)
        );
        ShowWidget.showMessage(context, 'تم حذف الرسالة', Colors.green, font13White);
      }
    });
  }

  void _showGroupInfo() {
    if (_groupDetails == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات المجموعة', style: font18blackbold),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.course != null) ...[
                Text('المادة: ${widget.course!.name}', style: font16black),
                const SizedBox(height: 8),
                Text('الكود: ${widget.course!.codeCs}', style: font14grey),
                const Divider(),
              ],
              
              Text('اسم المجموعة: ${_groupDetails!.name}', style: font16black),
              const SizedBox(height: 8),
              Text('الأستاذ: ${_groupDetails!.nameDoctor}', style: font14black),
              const SizedBox(height: 8),
              Text('عدد الطلاب: ${_students.length}', style: font14grey),
              
              const SizedBox(height: 16),
              Text('دورك: ${_getRoleText(widget.userRole)}', 
                style: font14black.copyWith(
                  color: ColorsApp.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: font15primary),
          ),
        ],
      ),
    );
  }
  
  String _getRoleText(String role) {
    switch (role) {
      case 'Doctor': return 'أستاذ';
      case 'Student': return 'طالب';
      default: return 'عضو';
    }
  }
  
  void _showMembers() {
    if (_members.isEmpty) {
      ShowWidget.showMessage(
        context,
        'لا يوجد أعضاء في المجموعة',
        ColorsApp.primaryColor,
        font13White,
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MembersBottomSheet(members: _members),
    );
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
  
  void _onImageTap(String imageUrl) {
    if (imageUrl.isNotEmpty && imageUrl != 'image') {
      AdvancedImagePreviewDialog.show(
        context,
        imageUrl,
        tag: 'group_chat_${widget.groupId}_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    // إعادة تعيين جميع الحالات عند الخروج
    _messagesLoaded = false;
    print('♻️ GroupChatScreen disposed');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    print('🏗️ بناء GroupChatScreen - الـ ChatBloc متاح: true');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: font15White.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_groupDetails != null)
              Text(
                '${_members.length} عضو',
                style: font11White,
              ),
          ],
        ),
        actions: [
          if(widget.groupModel != null)
          IconButton(
            icon: Icon(Icons.info_outline, color: ColorsApp.white),
            onPressed: _showGroupInfo,
            tooltip: 'معلومات المجموعة',
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.group, color: ColorsApp.white),
                if (_members.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_members.length}',
                        style: font10Primary.copyWith(
                          fontSize: 8,
                          color: ColorsApp.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showMembers,
            tooltip: 'أعضاء المجموعة',
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          print('📡 استقبال حالة ChatBloc: ${state.runtimeType}');
          
          if (state is ChatError) {
            print('❌ خطأ في ChatBloc: ${state.message}');
            ShowWidget.showMessage(
              context,
              state.message,
              ColorsApp.red,
              font13White,
            );
          }
          
          if (state is ChatMessageSent) {
            print('✅ تم إرسال الرسالة بنجاح');
            _scrollToBottom();
          }
          
          if (state is GroupMessagesLoaded) {
            print('✅ تم تحميل ${state.messages.length} رسالة للمجموعة');
            // تحديث قائمة الرسائل الحالية باستخدام WidgetsBinding
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentMessages.length != state.messages.length) {
                setState(() {
                  _currentMessages = state.messages;
                });
              }
            });
            _scrollToBottom();
          }
           // ✅ لحالة جلب الأعضاء الاحتياطية
          if (state is GroupMembersLoaded) {
            print('✅ تم استقبال الأعضاء من الريبوستوري: ${state.members.length}');
            if (mounted) {
              setState(() {
                _members = state.members;
              });
            }
          }
        },
        child: Stack(
          children: [
            // المحتوى الرئيسي
            Column(
              children: [
                // تنبيه فقدان الاتصال
                if (_showConnectionAlert)
                  _buildConnectionAlert(),
                
                // قائمة الرسائل
                Expanded(
                  child: _buildChatContent(),
                ),
                
                // معاينة الصورة المختارة
                if (_selectedImage != null)
                  _buildSelectedImagePreview(),
                
                // حقل الإدخال
                SimpleChatInputField(
                  controller: _controller,
                  onSend: _sendMessage,
                  onImagePick: _pickImage,
                ),
              ],
            ),
            
            // مؤشر التحميل الرئيسي
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(color: ColorsApp.primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('🔄 بناء محتوى الدردشة - الحالة: ${state.runtimeType}');
         // 1. حالة التحميل
        if (state is ChatLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: ColorsApp.primaryColor),
                const SizedBox(height: 16),
                Text('جاري تحميل الرسائل...', style: font14grey),
              ],
            ),
          );
        }
        // 2. حالة تحميل الرسائل الناجحة
        if (state is GroupMessagesLoaded) {
          final messages = state.messages;
          
          // التحقق من أن الرسائل المحملة تخص هذه المجموعة
          bool isStaleState = false;
          if (messages.isNotEmpty) {
            if (messages.first.groupId != widget.groupId) {
              isStaleState = true;
              print('⚠️ بيانات المحفوظ لمطابقة لهذه المجموعة: ${messages.first.groupId} != ${widget.groupId}');
            }
          }
          
          // إذا كانت البيانات قديمة (Stale)، قم بإجبار التحميل وإظهار مؤشر تحميل
          if (isStaleState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadMessages();
            });
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ColorsApp.primaryColor),
                  const SizedBox(height: 16),
                  Text('جاري تحديث الدردشة...', style: font14grey),
                ],
              ),
            );
          }
          // تحديث القائمة المحلية
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _currentMessages.length != state.messages.length) {
              setState(() {
                _currentMessages = state.messages;
              });
            }
          });
          // ✅ تصفية الرسائل: عرض رسائل هذه المجموعة فقط
          final validMessages = messages
              .where((msg) => msg.groupId == widget.groupId && !msg.isDeleted)
              .toList();
          
          if (validMessages.isEmpty) {
            return _buildEmptyChatState();
          }
          
          return _buildMessagesContent(validMessages);
        }
        // 4. حالة الإرسال
        if (state is ChatSending) {
          return _buildMessagesContent(_currentMessages);
        }
         // ✅ 3. حالة وصول الأعضاء (GroupMembersLoaded)
        if (state is GroupMembersLoaded) {
          print('✅ وصول حالة GroupMembersLoaded، عرض الرسائل الحالية');
          return _buildMessagesContent(_currentMessages);
        }
         // 5. حالة الخطأ
        if (state is ChatError) {
          print('❌ خطأ في ChatBloc: ${state.message}');
          
          // محاولة إعادة التحميل في حالة الخطأ
          if (!_messagesLoaded) {
            _loadMessages();
          }
          
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
                  onPressed: () {
                    _loadMessages();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.primaryColor),
                  child: Text('إعادة المحاولة', style: font15White),
                ),
              ],
            ),
          );
        }
         // 6. الحالة الافتراضية (Initial)
        if (state is ChatInitial && !_messagesLoaded) {
          print('🔍 تحميل الرسائل للمرة الأولى');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _loadMessages();
          });
        }
        
        print("حالة افتراضية");
        return Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor));
      },
    );
  }

  Widget _buildMessagesContent(List<MessageModel> messages) {
    print('📨 بناء قائمة الرسائل للمجموعة: ${widget.groupId}');
    
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
      return _buildEmptyChatState();
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

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: ColorsApp.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'بداية المحادثة',
              style: font18blackbold.copyWith(color: ColorsApp.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'مرحباً المحادثة مع الأعضاء الآن',
              style: font14grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}