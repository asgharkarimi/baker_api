import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  // تبدیل اعداد فارسی به انگلیسی
  String _convertPersianToEnglish(String input) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String result = input;
    for (int i = 0; i < persian.length; i++) {
      result = result.replaceAll(persian[i], english[i]);
    }
    return result;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // تبدیل اعداد فارسی به انگلیسی
    String converted = _convertPersianToEnglish(newValue.text);
    
    // حذف کاماها و فقط نگه داشتن اعداد
    String digitsOnly = converted.replaceAll(RegExp(r'[^0-9]'), '');

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
