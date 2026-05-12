import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSourceImpl.dart';
import 'package:apx_cars_repair/features/cases/domain/CaseRepositoryImpl.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/AddCascUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/BindImagesWithCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/show_cases_useCase.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSourceImpl.dart';
import 'package:apx_cars_repair/features/customers/domain/CustomerRepositoryImpl.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/AddCustomerUseCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/EditCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/bindCustomerWithImage.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/deleteCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/show_customers_useCase.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<TokenService>(() => TokenService(Get.find()));
    Get.lazyPut<DioClient>(() => DioClient(Get.find<TokenService>()));

    // ================= CUSTOMERS =================

    Get.lazyPut<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(Get.find<DioClient>()),
    );

    Get.lazyPut<CustomerRepository>(() => CustomerRepositoryImpl(Get.find()));

    Get.lazyPut(() => AddCustomerUseCase(Get.find()));
    Get.lazyPut(() => ShowCustomersUsecase(Get.find()));
    Get.lazyPut(() => EditCustomerUseCase(Get.find()));
    Get.lazyPut(() => DeleteCustomerUseCase(Get.find()));
    Get.lazyPut(() => BindCustomerWithImageUseCase(Get.find()));

    // ================= CASES =================

    Get.lazyPut<CaseRemoteDataSource>(
      () => CaseRemoteDataSourceImpl(Get.find<DioClient>()),
    );

    Get.lazyPut<CaseRepository>(() => CaseRepositoryImpl(Get.find()));

    Get.lazyPut(() => AddCaseUseCase(Get.find()));

    // إذا عندك usecases أخرى للكيس
    // Get.lazyPut(() => ShowCasesUseCase(Get.find()));

    // ================= CONTROLLERS =================

    Get.lazyPut<CustomerController>(
      () => CustomerController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),fenix: true,
    );

    // ================= CASES =================

    Get.lazyPut(() => ShowCasesUsecase(Get.find()));
    Get.lazyPut(() => EditCaseUseCase(Get.find()));
    Get.lazyPut(() => AddCaseUseCase(Get.find()));
    Get.lazyPut(() => BindImagesWithCaseUseCase(Get.find()));

    Get.lazyPut<CaseController>(
      () => CaseController(Get.find(), Get.find(), Get.find(), Get.find()),fenix: true,
    );
  }
}
