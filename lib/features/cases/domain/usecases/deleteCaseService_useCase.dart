import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class DeletecaseserviceUsecase {
  CaseRepository repository;

  DeletecaseserviceUsecase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int caseServiceId) async {
    return await repository.deleteCaseService(caseServiceId);
  }
}