import 'package:flutter/material.dart';

class AppTextField extends TextField {
  const AppTextField({
    super.key,
    super.controller,
    super.decoration,
    super.keyboardType,
    super.onChanged,
    super.textAlign,
    super.style,
    super.maxLines,
    super.autocorrect = false,
    super.enableSuggestions = false,
    super.smartQuotesType = SmartQuotesType.disabled,
    super.smartDashesType = SmartDashesType.disabled,
  });
}
