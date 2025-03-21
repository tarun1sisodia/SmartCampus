import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final isPasswordVisible = false.obs;
  final password = ''.obs;
  final email = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}