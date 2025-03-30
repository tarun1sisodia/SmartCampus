import 'package:get/get.dart';
import '../controllers/all_sessions_controller.dart';
import '../controllers/attendance_controller.dart';

class AllSessionsBinding implements Bindings {
  @override
  void dependencies() {
    // Make sure the attendance controller is available
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }
    
    // Initialize the all sessions controller
    Get.put(AllSessionsController());
  }
}
