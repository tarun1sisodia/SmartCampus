import 'package:get/get.dart';
import '../services/secure_storage_service.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await SecureStorageService.getAccessToken();
    isLoggedIn.value = token != null;
  }

  Future<void> logout() async {
    await SecureStorageService.clearTokens();
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
