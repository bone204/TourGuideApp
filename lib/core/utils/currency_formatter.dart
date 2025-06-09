class CurrencyFormatter {
  static String format(double amount) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = amount.toStringAsFixed(0);
    result = result.replaceAllMapped(formatter, (Match m) => '${m[1]},');
    return '$result ₫';
  }
} 