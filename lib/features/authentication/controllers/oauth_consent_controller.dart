import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthConsentController extends GetxController {
  static OAuthConsentController get instance => Get.find();

  final RxBool isLoading = true.obs;
  final Rxn<Map<String, dynamic>> authDetails = Rxn<Map<String, dynamic>>();
  final RxnString error = RxnString();

  String? authorizationId;

  @override
  void onInit() {
    super.onInit();
    _handleRoute();
  }

  void _handleRoute() {
    // Extract authorization_id from query parameters
    // In GetX, parameters are available via Get.parameters
    authorizationId = Get.parameters['authorization_id'];

    if (authorizationId == null || authorizationId!.isEmpty) {
      error.value = 'Invalid authorization request: Missing authorization_id';
      isLoading.value = false;
      return;
    }

    fetchAuthorizationDetails();
  }

  Future<void> fetchAuthorizationDetails() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Note: As of late 2024, the OAuth 2.1 server methods are available in the Supabase SDKs.
      // If the specific method is not yet in the Dart SDK version used, 
      // a raw REST call to the auth endpoint would be used here.
      
      // For now, we simulate the fetch to demonstrate the UI implementation.
      // In a real environment with the latest SDK:
      // final details = await Supabase.instance.client.auth.oauthServer.getAuthorizationDetails(authorizationId!);
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      
      // Mock data for demonstration
      authDetails.value = {
        'client': {
          'name': 'SmartCampus Partner App',
          'icon_url': null,
        },
        'scopes': [
          {'name': 'profile', 'description': 'Access your basic profile information'},
          {'name': 'email', 'description': 'View your email address'},
          {'name': 'attendance:read', 'description': 'Read your attendance records'},
        ],
      };
      
    } catch (e) {
      error.value = 'Failed to load authorization details. Please try again.';
      //print('OAuth Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve() async {
    try {
      isLoading.value = true;
      
      // In a real environment:
      // final response = await Supabase.instance.client.auth.oauthServer.approveAuthorization(authorizationId!);
      // Use the returned redirect URL to send the user back to the client app.
      
      await Future.delayed(const Duration(seconds: 1));
      
      Get.snackbar(
        'Authorized',
        'Access granted successfully. Redirecting...',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // In a real app, you would use url_launcher to go to the redirect URI
      // For now, just go back
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve authorization: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deny() async {
    try {
      isLoading.value = true;
      
      // In a real environment:
      // await Supabase.instance.client.auth.oauthServer.denyAuthorization(authorizationId!);
      
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to deny authorization: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // UI Facade compatibility methods
  Future<void> grantConsent() => approve();
  Future<void> denyConsent() => deny();
}
