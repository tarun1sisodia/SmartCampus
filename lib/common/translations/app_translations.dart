import 'package:get/get.dart';
import 'en_us.dart';
import 'hi_in.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'hi_IN': hiIN};
}
