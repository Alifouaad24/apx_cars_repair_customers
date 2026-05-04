import 'package:apx_cars_repair/app/Bindings/CustomerBinding.dart';
import 'package:apx_cars_repair/app/Bindings/home_binding.dart';
import 'package:apx_cars_repair/app/Bindings/scan_chaseh_binding.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/addEditCustomes_view.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:apx_cars_repair/features/home/presentation/pages/home_page.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/pages/camera_scan_view.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/widgets/result_vin_dialog.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.addCustomer,
      page: () => AddeditcustomesView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.showCustomers,
      page: () => ShowCustomers(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.scanChaseh,
      page: () => CameraScanView(),
      binding: ScanChasehBinding(),
    ),
    GetPage(
      name: AppRoutes.resultVinDialog,
      page: () => ResultVinDialog(),
      binding: ScanChasehBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
