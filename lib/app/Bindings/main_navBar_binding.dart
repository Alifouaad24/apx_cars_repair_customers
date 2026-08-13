import 'package:apx_cars_repair/app/Bindings/CustomerBinding.dart';
import 'package:apx_cars_repair/app/Bindings/case_binding.dart';
import 'package:apx_cars_repair/features/maim_navBar/controllers/nav_bar_controller.dart';
import 'package:get/get.dart';

class MainNavBarBinding extends Bindings {
  @override
  void dependencies() {
    // Customer dependencies
    CustomerBinding().dependencies();

    // Case dependencies
    CaseBinding().dependencies();

    // Main NavBar
    Get.lazyPut<MainNavBarController>(
      () => MainNavBarController(),
    );
  }
}