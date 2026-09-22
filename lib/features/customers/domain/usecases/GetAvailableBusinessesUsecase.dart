import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetAvailableBusinessesUsecase {
  final CustomerRepository repository;

  GetAvailableBusinessesUsecase(this.repository);

  Future<Either<Failure, List<BusinessModel>>> call() {
    return repository.getAvailableBusinesses();
  }
}