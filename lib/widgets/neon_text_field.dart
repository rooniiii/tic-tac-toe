import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class NeonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String tooltip;
  final IconData icon;
  final bool isPassword;
  final int? maxLength;

  /// Shows a live "12/254" character counter under the field.
  final bool showCounter;
  final String? helperText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool validateOnBlur;
  final bool validateWhileTyping;
  final GlobalKey<FormFieldState<String>>? fieldKey;

  const NeonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.tooltip,
    required this.icon,
    this.isPassword = false,
    this.maxLength,
    this.showCounter = false,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.validateOnBlur = false,
    this.validateWhileTyping = false,
    this.fieldKey,
  });

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  bool _hidden = true;
  bool _hasBeenBlurred = false;

  final FocusNode _focusNode = FocusNode();

  final GlobalKey<FormFieldState<String>> _fieldKey =
  GlobalKey<FormFieldState<String>>();

  GlobalKey<FormFieldState<String>> get _activeFieldKey =>
      widget.fieldKey ?? _fieldKey;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.validateOnBlur) {
      final value = widget.controller.text.trim();

      // Empty field ko blur par validate nahi karna.
      if (value.isEmpty) {
        _hasBeenBlurred = false;
        return;
      }

      _hasBeenBlurred = true;
      _activeFieldKey.currentState?.validate();
    }
  }

  void _handleChanged(String value) {
    if (value.trim().isNotEmpty &&
        (_hasBeenBlurred ||
            (widget.validateWhileTyping && value.isNotEmpty))) {
      _activeFieldKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: TextFormField(
        key: _activeFieldKey,
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.isPassword && _hidden,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.disabled,
        onChanged: _handleChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          helperStyle: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          counterText: widget.showCounter ? null : '',
          counterStyle: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          filled: true,
          fillColor: const Color(0x337B2FF7),
          prefixIcon: Icon(
            widget.icon,
            color: AppTheme.neonCyan,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            tooltip: _hidden ? 'Show password' : 'Hide password',
            icon: Icon(
              _hidden
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppTheme.neonPink,
            ),
            onPressed: () {
              setState(() {
                _hidden = !_hidden;
              });
            },
          )
              : null,
          enabledBorder: _border(AppTheme.purple),
          focusedBorder: _border(AppTheme.neonCyan),
          errorBorder: _border(Colors.redAccent),
          focusedErrorBorder: _border(Colors.redAccent),
        ),
      ),
    );
  }
}