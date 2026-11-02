import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:el_nada_market/core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final String? label;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final FormFieldValidator<String>? validator;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextDirection? textDirection;
  final TextAlign textAlign;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  final bool obscureText;
  final bool enabled;

  final ValueChanged<String>? onFieldSubmitted;

  static final _enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(color: AppColors.border),
  );

  static final _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  );

  static final _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(color: AppColors.error),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 9),
        ],

        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textDirection: textDirection,
          textAlign: textAlign,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          enableSuggestions: !obscureText,
          autocorrect: !obscureText,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: maxLength == null ? null : '',
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.text, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: _enabledBorder,
            focusedBorder: _focusedBorder,
            errorBorder: _errorBorder,
            focusedErrorBorder: _errorBorder,
          ),
        ),
      ],
    );
  }
}
