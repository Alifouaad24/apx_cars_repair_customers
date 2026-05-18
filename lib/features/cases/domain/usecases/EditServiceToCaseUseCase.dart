import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class EditServiceToCaseUseCase {
  final CaseRepository repository;

  EditServiceToCaseUseCase(this.repository);

  Future<Either<Failure, CaseService>> call(int caseServiceId, Map<String, dynamic> data) async {
    return await repository.editServiceToCase(caseServiceId, data);
  }
}