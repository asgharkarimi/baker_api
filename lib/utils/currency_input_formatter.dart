import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // حذف کاماها و فقط نگه داشتن اعداد
    String digitsOnly = newValue.text.replaceAll(',', '');

    // اگر چیزی غیر از عدد وارد شده، قبولش نکن
    if (digitsOnly.isEmpty) {
      return oldValue;
    }

    // فرمت کردن با کاما
    String formatted = _formatWithComma(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithComma(String number) {
    String result = '';
    int counter = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = ',$result';
        counter = 0;
      }
      result = number[i] + result;
      counter++;
    }

    return result;
  }
}
