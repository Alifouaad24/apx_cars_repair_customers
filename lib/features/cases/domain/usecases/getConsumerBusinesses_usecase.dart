import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/SupplierBusinessModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetconsumerbusinessesUsecase {
  final CaseRepository repository;

  GetconsumerbusinessesUsecase(this.repository);

  Future<Either<Failure, List<SupplierBusinessModel>>> call() {
    return repository.getAllBusinesses();
  }
}