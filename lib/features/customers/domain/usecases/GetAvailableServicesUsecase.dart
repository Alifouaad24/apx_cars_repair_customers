import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetAvailableServicesUsecase {
  final CustomerRepository repository;

  GetAvailableServicesUsecase(this.repository);

  Future<Either<Failure, List<ServiceModel>>> call() {
    return repository.getAvailableServices();
  }
}