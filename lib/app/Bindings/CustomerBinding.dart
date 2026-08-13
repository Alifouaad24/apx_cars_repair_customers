import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:apx_cars_repair/features/customers/domain/CustomerRepositoryImpl.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSourceImpl.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/AddCustomerUseCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/EditCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/bindCustomerWithImage.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/deleteCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/show_customers_useCase.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TokenService>(() => TokenService(Get.find()));
    Get.lazyPut<DioClient>(() => DioClient(Get.find<TokenService>()));
    Get.lazyPut<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(Get.find<DioClient>()),
    );

    Get.lazyPut<CustomerRepository>(() => CustomerRepositoryImpl(Get.find()));
    Get.put(AddCustomerUseCase(Get.find()));
    Get.put(ShowCustomersUsecase(Get.find()));
    Get.put(EditCustomerUseCase(Get.find()));
    Get.put(DeleteCustomerUseCase(Get.find()));
    Get.put(BindCustomerWithImageUseCase(Get.find()));
    Get.lazyPut(
      () => CustomerController(
        Get.find<AddCustomerUseCase>(),
        Get.find<ShowCustomersUsecase>(),
        Get.find<EditCustomerUseCase>(),
        Get.find<DeleteCustomerUseCase>(),
        Get.find<BindCustomerWithImageUseCase>(),
      ),

    );
  }
}
