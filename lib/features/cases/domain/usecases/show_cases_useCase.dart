import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class ShowCasesUsecase {
    final CaseRepository repository;

  ShowCasesUsecase(this.repository);

    Future<Either<Failure, List<GlobalOrderModel>>> call() {
    return repository.showCases();
  }
}