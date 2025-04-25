import 'package:intl/intl.dart';

class Formatters {
  Formatters._() {
    ////print('Formatters initialized');
  }
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phonenumber) {
    if (phonenumber.length == 10) {
      return '(${phonenumber.substring(0, 3)}) ${phonenumber.substring(3, 6)} ${phonenumber.substring(6)}';
    } else if (phonenumber.length == 11) {
      return '(${phonenumber.substring(0, 4)}) ${phonenumber.substring(4, 7)} ${phonenumber.substring(7)}';
    }
    return phonenumber;
  }

  // static Future<String?> formatInternationalPhoneNumber(
  //   String phoneNumber,
  //   String isoCode,
  // ) async {
  //   try {
  //     return await PhoneNumberUtil.formatAsYouType(
  //       phoneNumber: phoneNumber,
  //       isoCode: isoCode,
  //     );
  //   } catch (e) {
  //     return phoneNumber;
  //   }
  // }
}
