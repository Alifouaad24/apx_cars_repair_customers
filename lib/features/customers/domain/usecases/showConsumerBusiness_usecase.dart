import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/SupplierModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
class ShowconsumerbusinessUsecase {
  final CustomerRepository repository;

  ShowconsumerbusinessUsecase(this.repository);

  Future<Either<Failure, List<SupplierFilterModel>>> call() {
    return repository.showconsumerbusiness();
  }
}