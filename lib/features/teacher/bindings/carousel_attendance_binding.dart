import 'package:get/get.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../controllers/attendance_controller.dart';

class CarouselAttendanceBinding implements Bindings {
  @override
  void dependencies() {
    // Make sure the attendance controller is available
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    } else {
      // If it's already registered, find it
      Get.find<AttendanceController>();
    }
    
    // Initialize the carousel attendance controller
    Get.put(CarouselAttendanceController());
  }
}
