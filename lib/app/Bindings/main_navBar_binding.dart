import 'package:apx_cars_repair/features/maim_navBar/controllers/nav_bar_controller.dart';
import 'package:get/get.dart';

class MainNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavBarController>(() => MainNavBarController());
  }
}