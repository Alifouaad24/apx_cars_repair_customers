import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';
class EditCaseUseCase {
  final CaseRepository repository;

  EditCaseUseCase(this.repository);

  Future<Either<Failure, CaseModel>> call(int caseId, Map<String, dynamic> caseData) {
    return repository.editCase(caseId, caseData);
  }
}