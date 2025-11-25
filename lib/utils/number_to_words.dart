class NumberToWords {
  static String convert(String numberText) {
    // حذف کاما و تبدیل به عدد
    String cleanNumber = numberText.replaceAll(',', '');
    if (cleanNumber.isEmpty) return '';
    
    try {
      int number = int.parse(cleanNumber);
      return _convertToWords(number);
    } catch (e) {
      return '';
    }
  }

  static String _convertToWords(int number) {
    if (number == 0) return 'صفر تومان';

    List<String> result = [];

    // میلیارد
    int billions = number ~/ 1000000000;
    if (billions > 0) {
      result.add('${_convertHundreds(billions)} میلیارد');
      number %= 1000000000;
    }

    // میلیون
    int millions = number ~/ 1000000;
    if (millions > 0) {
      result.add('${_convertHundreds(millions)} میلیون');
      number %= 1000000;
    }

    // هزار
    int thousands = number ~/ 1000;
    if (thousands > 0) {
      result.add('${_convertHundreds(thousands)} هزار');
      number %= 1000;
    }

    // باقیمانده
    if (number > 0) {
      result.add(_convertHundreds(number));
    }

    return '${result.join(' و ')} تومان';
  }

  static String _convertHundreds(int number) {
    if (number == 0) return '';

    List<String> ones = [
      '', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه'
    ];
    
    List<String> tens = [
      '', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود'
    ];
    
    List<String> teens = [
      'ده', 'یازده', 'دوازده', 'سیزده', 'چهارده', 'پانزده',
      'شانزده', 'هفده', 'هجده', 'نوزده'
    ];
    
    List<String> hundreds = [
      '', 'یکصد', 'دویست', 'سیصد', 'چهارصد', 'پانصد',
      'ششصد', 'هفتصد', 'هشتصد', 'نهصد'
    ];

    List<String> result = [];

    // صدها
    int h = number ~/ 100;
    if (h > 0) {
      result.add(hundreds[h]);
    }

    number %= 100;

    // ده‌ها و یکان
    if (number >= 10 && number < 20) {
      result.add(teens[number - 10]);
    } else {
      int t = number ~/ 10;
      int o = number % 10;
      
      if (t > 0) {
        result.add(tens[t]);
      }
      if (o > 0) {
        result.add(ones[o]);
      }
    }

    return result.join(' و ');
  }
}
