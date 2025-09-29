import 'package:intl/intl.dart';

class Format {
  /// Format angka jadi Rupiah
  static String currency(int value) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return f.format(value);
  }

  /// Format tanggal dari string ISO ke tampilan lebih rapi
  static String date(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }
}
