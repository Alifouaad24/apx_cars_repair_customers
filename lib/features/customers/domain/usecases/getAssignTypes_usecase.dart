import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/AssignTypeModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetassigntypesUsecase {
  final CaseRepository repository;

  GetassigntypesUsecase(this.repository);

  Future<Either<Failure, List<AssignTypeModel>>> call() {
    return repository.getAllAssignTypes();
  }
}