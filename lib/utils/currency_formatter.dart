import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatCurrencyCompact(double amount) {
  final formatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

double parseCurrency(String value) {
  if (value.isEmpty) return 0;
  final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
  return double.tryParse(cleanValue) ?? 0;
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll('Rp', '');
    if (newText.isEmpty) return newValue.copyWith(text: '');
    int value = int.tryParse(newText) ?? 0;
    String formatted = _formatter.format(value).trim();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
