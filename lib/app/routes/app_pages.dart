import 'package:apx_cars_repair/app/Bindings/CustomerBinding.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/addEditCustomes_view.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:apx_cars_repair/features/home/presentation/pages/home_page.dart';
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
      name: AppRoutes.home,
      page: () => HomePage(),
    ),
  ];
}