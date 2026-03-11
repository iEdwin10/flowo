import 'package:intl/intl.dart';

class FlowoFormatters {
  static final _currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
  static final _currencyCompact = NumberFormat.compactCurrency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  static final _month = DateFormat('MMMM yyyy', 'fr_FR');
  static final _short = DateFormat('dd MMM', 'fr_FR');
  static final _full = DateFormat('dd MMMM yyyy', 'fr_FR');

  static String currency(double amount) => _currency.format(amount);
  static String currencyCompact(double amount) => _currencyCompact.format(amount);
  static String month(DateTime date) => _month.format(date);
  static String shortDate(DateTime date) => _short.format(date);
  static String fullDate(DateTime date) => _full.format(date);
  static String percent(double value) => '${(value * 100).toStringAsFixed(0)} %';
}
