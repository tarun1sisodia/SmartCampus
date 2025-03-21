import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../navigation_menu.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  final supabase = Supabase.instance.client;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (response.user != null) {
        Get.offAll(() => const NavigationMenu());
      } else {
        errorMessage.value = 'Authentication failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signUpWithEmail(String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {'name': name},
      );
      
      if (response.user != null) {
        Get.offAll(() => const NavigationMenu());
      } else {
        errorMessage.value = 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
