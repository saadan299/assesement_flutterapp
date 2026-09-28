import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  static String formatAmount(double price) {
    return _amountFormat.format(price);
  }
}
