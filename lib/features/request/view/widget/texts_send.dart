import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/customTextField.dart';
import 'package:myproject/components/widget/text_field_box.dart';
import 'package:myproject/features/request/view/request_data.dart';

class TextsSend extends StatefulWidget {
  final Function(String?) onRequestTypeChanged;
  final TextEditingController descriptionController;
  final ValueChanged<bool> onValidityChanged;
  final ValueChanged<bool> onDescriptionFocusChanged;
  const TextsSend({
    super.key,
    required this.onRequestTypeChanged,
    required this.descriptionController,
    required this.onValidityChanged,
    required this.onDescriptionFocusChanged,
    });

  @override
  State<TextsSend> createState() => _TextsSendState();
}

class _TextsSendState extends State<TextsSend> {
  String? _selectedRequestType;
  bool _isDescriptionValid = false;
  final FocusNode _descriptionFocusNode = FocusNode();
  bool _isDescriptionFocused = false;

  @override
  void initState() {
    super.initState();
    // 🔥 مراقبة تغييرات النص في حقل الوصف
    widget.descriptionController.addListener(_checkValidity);
    _descriptionFocusNode.addListener(_onDescriptionFocusChange);
  }

  @override
  void dispose() {
    widget.descriptionController.removeListener(_checkValidity);
    super.dispose();
  }

  void _onDescriptionFocusChange() {
    final isFocused = _descriptionFocusNode.hasFocus;
    setState(() {
      _isDescriptionFocused = isFocused;
    });
    widget.onDescriptionFocusChanged(isFocused); 
  }

  void _checkValidity() {
    final description = widget.descriptionController.text;
    final isDescriptionValid = description.length >= 5;
    
    final isValid = _selectedRequestType != null && isDescriptionValid;
    
    if (_isDescriptionValid != isDescriptionValid) {
      setState(() {
        _isDescriptionValid = isDescriptionValid;
      });
    }
    
    widget.onValidityChanged(isValid);
  }

  void _onRequestTypeChanged(String? value) {
    setState(() {
      _selectedRequestType = value;
    });
    widget.onRequestTypeChanged(value);
    _checkValidity();
  }

  String? _descriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return RequestData.validatorone;
    }
    if (value.length < 5) {
      return RequestData.validatortwo;
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        CustomDropdown(
          items: RequestData.liset,
          hint: '',
          onChanged: _onRequestTypeChanged,
        ),
        getHeight( 12),
        TextFieldBox(
          hintText: RequestData.textField,
          controller: widget.descriptionController,
          maxLines: 5,
          validator: _descriptionValidator,
          focusNode: _descriptionFocusNode,
        ),
        // 🔥 عرض حالة الصحة (اختياري)
        if (_isDescriptionFocused) ...[
        if (_selectedRequestType == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '⚠️ يرجى اختيار نوع الطلب',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        if (_selectedRequestType != null && !_isDescriptionValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '⚠️ الوصف يجب أن يكون 5 أحرف على الأقل',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ] ,
      ],
    );
  }
}
