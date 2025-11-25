class NumberFormatter {
  static String formatPrice(int price) {
    String priceStr = price.toString();
    String result = '';
    int counter = 0;

    for (int i = priceStr.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = ',$result';
        counter = 0;
      }
      result = '${priceStr[i]}$result';
      counter++;
    }

    return '$result تومان';
  }

  static String formatPriceInMillions(int price) {
    final millions = price / 1000000;
    if (millions == millions.toInt()) {
      return '${millions.toInt()} میلیون تومان';
    }
    return '${millions.toStringAsFixed(1)} میلیون تومان';
  }
}
