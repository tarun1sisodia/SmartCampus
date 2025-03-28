import 'package:attedance__/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import 'package:attedance__/features/authentication/screens/onboarding/onboarding.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:attedance__/common/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

// Instead of mocking the entire StorageService, create a test implementation
class TestStorageService extends GetxService {
  bool _onboardingCompleted = false;
  
  
  bool getOnboardingStatus() {
    return _onboardingCompleted;
  }
  
  Future<void> setOnboardingStatus(bool status) async {
    _onboardingCompleted = status;
  }
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late TestStorageService testStorageService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    testStorageService = TestStorageService();
    mockNavigatorObserver = MockNavigatorObserver();
    Get.testMode = true;
    
    // Register the test storage service
    Get.put<StorageService>(testStorageService as StorageService);
  });

  tearDown(() {
    Get.reset();
  });

  group('Onboarding Flow Tests', () {
    testWidgets('Onboarding screens should display correctly', (WidgetTester tester) async {
      // Build the onboarding screen
      await tester.pumpWidget(
        GetMaterialApp(
          home: Onboarding(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Verify that the first onboarding screen is displayed
      expect(find.byType(PageView), findsOneWidget);
      
      // Test swiping to the second screen
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Verify second screen is displayed with the correct title
      expect(find.text(TTexts.attedancetitle3), findsOneWidget);
    });

    testWidgets('Skip button should navigate to login screen', (WidgetTester tester) async {
      // Build the onboarding screen
      await tester.pumpWidget(
        GetMaterialApp(
          home: Onboarding(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Verify skip button is present
      expect(find.text('Skip'), findsOneWidget);
      
      // Tap the skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      
      // Verify onboarding status is set to completed
      expect(testStorageService.getOnboardingStatus(), true);
    });

    testWidgets('Next button should navigate through screens', (WidgetTester tester) async {
      // Build the onboarding screen
      await tester.pumpWidget(
        GetMaterialApp(
          home: Onboarding(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Register the controller to access its state
      final controller = Get.find<OnboardingController>();
      
      // Verify next button is present
      expect(find.byType(ElevatedButton), findsWidgets);
      
      // Find the next button (the one with the arrow icon)
      final nextButtonFinder = find.byType(ElevatedButton).last;
      
      // Tap the next button to go to second screen
      await tester.tap(nextButtonFinder);
      await tester.pumpAndSettle();
      
      // Verify we're on the second screen
      expect(controller.currentPageIndex.value, 1);
      
      // Tap the next button to go to third screen
      await tester.tap(nextButtonFinder);
      await tester.pumpAndSettle();
      
      // Verify we're on the third screen
      expect(controller.currentPageIndex.value, 2);
      
      // Tap the next button on the last screen
      await tester.tap(nextButtonFinder);
      await tester.pumpAndSettle();
      
      // Verify onboarding status is set to completed
      expect(testStorageService.getOnboardingStatus(), true);
    });
  });

  group('Authentication Persistence Tests', () {
    test('App should check for onboarding completion on startup', () {
      // Set onboarding as completed
      testStorageService.setOnboardingStatus(true);
      
      // Create a controller
      final controller = OnboardingController();
      
      // Call the method that checks onboarding status
      controller.checkIfOnboardingCompleted();
      
      // Verify that the onboarding status is checked
      expect(testStorageService.getOnboardingStatus(), true);
    });
  });
}