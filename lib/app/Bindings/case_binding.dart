import 'package:apx_cars_repair/app/Bindings/CustomerBinding.dart';
import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSourceImpl.dart';
import 'package:apx_cars_repair/features/cases/domain/CaseRepositoryImpl.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/AddCascUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/BindImagesWithCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditServiceToCaseUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/addCaseServiceNote.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/addServiceToCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/changeCaseServiceStatus.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/getAllService_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/show_cases_useCase.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

class CaseBinding extends Bindings {
  @override
  void dependencies() {
    CustomerBinding().dependencies();
    Get.lazyPut<TokenService>(() => TokenService(Get.find()));

    Get.lazyPut<DioClient>(() => DioClient(Get.find<TokenService>()));

    Get.lazyPut<CaseRemoteDataSource>(
      () => CaseRemoteDataSourceImpl(Get.find<DioClient>()),
    );

    Get.lazyPut<CaseRepository>(() => CaseRepositoryImpl(Get.find()));

    Get.lazyPut<ShowCasesUsecase>(
      () => ShowCasesUsecase(Get.find<CaseRepository>()),
    );

    Get.lazyPut<AddCaseUseCase>(
      () => AddCaseUseCase(Get.find<CaseRepository>()),
    );

    Get.lazyPut<EditCaseUseCase>(
      () => EditCaseUseCase(Get.find<CaseRepository>()),
    );
    Get.lazyPut<BindImagesWithCaseUseCase>(
      () => BindImagesWithCaseUseCase(Get.find<CaseRepository>()),
    );
    Get.lazyPut<GetAllServiceUseCase>(
      () => GetAllServiceUseCase(Get.find<CaseRepository>()),
    );

    Get.lazyPut<AddServiceToCaseUseCase>(
      () => AddServiceToCaseUseCase(Get.find<CaseRepository>()),
    );

    Get.lazyPut<EditServiceToCaseUseCase>(
      () => EditServiceToCaseUseCase(Get.find<CaseRepository>()),
    );

    Get.lazyPut<AddCaseServiceNote>(
      () => AddCaseServiceNote(Get.find<CaseRepository>()),
    );

    Get.lazyPut<ChangeCaseServiceStatus>(
      () => ChangeCaseServiceStatus(Get.find<CaseRepository>()),
    );

    Get.lazyPut<CaseController>(
      () => CaseController(
        Get.find<ShowCasesUsecase>(),
        Get.find<AddCaseUseCase>(),
        Get.find<EditCaseUseCase>(),
        Get.find<BindImagesWithCaseUseCase>(),
        Get.find<GetAllServiceUseCase>(),
        Get.find<AddServiceToCaseUseCase>(),
        Get.find<EditServiceToCaseUseCase>(),
        Get.find<AddCaseServiceNote>(),
        Get.find<ChangeCaseServiceStatus>(),
      ),
    );
  }
}
