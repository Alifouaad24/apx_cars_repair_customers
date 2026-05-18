import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class AddCaseServiceNote {
  final CaseRepository repository;

  AddCaseServiceNote(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int caseServiceId, Map<String, dynamic> data) {
    return repository.addCaseServiceNote(caseServiceId, data);
  }
}