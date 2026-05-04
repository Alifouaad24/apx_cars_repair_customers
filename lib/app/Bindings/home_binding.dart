import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/controllers/scan_chaseh_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
   if (!Get.isRegistered<TokenService>()) {
      Get.lazyPut<TokenService>(() => TokenService(Get.find()));
    }
    if (!Get.isRegistered<DioClient>()) {
      Get.lazyPut<DioClient>(() => DioClient(Get.find<TokenService>()));
    }
    Get.lazyPut(() => ScanChasehController(Get.find<DioClient>()));
  }
}