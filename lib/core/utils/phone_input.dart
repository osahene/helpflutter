import 'package:flutter/services.dart';

/// Cleans a raw phone entry into an E.164-ready **national** number.
///
///   "0244123456"      -> "244123456"
///   "024 412 3456"    -> "244123456"
///   "+233244123456"   -> "244123456"   (when dialCode is '+233')
///   "00233244123456"  -> "244123456"   (when dialCode is '+233')
String sanitizePhoneInput(String input, {String? dialCode}) {
  final trimmed = input.trim();

  // Only treat it as an international paste if it was *explicitly* marked as
  // one. Typing "233..." as a local Ghanaian number must stay untouched.
  final isInternational = trimmed.startsWith('+') || trimmed.startsWith('00');

  var digits = trimmed.replaceAll(RegExp(r'\D'), '');

  if (isInternational) {
    digits = digits.replaceFirst(RegExp(r'^00'), '');
    final cc = (dialCode ?? '').replaceAll(RegExp(r'\D'), '');
    if (cc.isNotEmpty && digits.startsWith(cc)) {
      digits = digits.substring(cc.length);
    }
  }

  // Trunk prefix — never part of an E.164 national significant number.
  digits = digits.replaceFirst(RegExp(r'^0+'), '');

  return digits;
}

/// Live formatter: digits only, no leading zero, capped length.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter({this.dialCode, this.maxLength = 15});

  final String? dialCode;
  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = sanitizePhoneInput(newValue.text, dialCode: dialCode);

    if (text.length > maxLength) text = text.substring(0, maxLength);

    // Keep the caret where the user expects it after characters are dropped.
    final removed = newValue.text.length - text.length;
    final offset = (newValue.selection.end - removed).clamp(0, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
