import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm', 'id_ID').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(date);
}

String formatShortDate(DateTime date) {
  return DateFormat('dd/MM/yy', 'id_ID').format(date);
}

String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy', 'id_ID').format(date);
}
