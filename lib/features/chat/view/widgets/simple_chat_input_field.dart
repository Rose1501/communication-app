// lib/features/chat/view/widgets/simple_chat_input_field.dart
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class SimpleChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePick;
  
  const SimpleChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePick,
  });
  
  @override
  State<SimpleChatInputField> createState() => _SimpleChatInputFieldState();
}

class _SimpleChatInputFieldState extends State<SimpleChatInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // زر الإرسال
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: widget.onSend,
            child: Icon(
              Icons.send,
              color: ColorsApp.white,
            ),
          ),
          
          // زر المرفقات
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: ColorsApp.primaryColor,
            ),
            onPressed: widget.onImagePick,
          ),
          
          // حقل النص
          Expanded(
            child: TextField(
              controller: widget.controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: ColorsApp.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) {
                if (widget.controller.text.trim().isNotEmpty) {
                  widget.onSend();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}