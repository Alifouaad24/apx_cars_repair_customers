import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetAllServiceUseCase {
    final CaseRepository repository;

  GetAllServiceUseCase(this.repository);

    Future<Either<Failure, List<ServiceModel>>> call() {
    return repository.getAllServices();
  }
}