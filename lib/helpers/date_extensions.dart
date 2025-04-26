import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toUtcString() {
    return '${toUtc().toFormatString('y-MM-ddTHH:mm:ss.S')}Z';
  }

  String toFormatString(String format) {
    return DateFormat(format).format(this);
  }
}
