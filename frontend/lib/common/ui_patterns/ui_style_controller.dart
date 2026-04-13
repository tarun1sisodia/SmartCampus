import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'ui_style.dart';

class UIStyleController extends GetxController {
  static UIStyleController get instance => Get.find();

  final _storage = GetStorage();
  final _key = 'selected_ui_style';

  final Rx<UIStyle> currentStyle = UIStyle.industrialCorporate.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStyle();
  }

  void _loadStyle() {
    final storedStyleIndex = _storage.read<int>(_key);
    if (storedStyleIndex != null && storedStyleIndex < UIStyle.values.length) {
      currentStyle.value = UIStyle.values[storedStyleIndex];
    }
  }

  void setStyle(UIStyle style) {
    currentStyle.value = style;
    _storage.write(_key, style.index);
  }
}
