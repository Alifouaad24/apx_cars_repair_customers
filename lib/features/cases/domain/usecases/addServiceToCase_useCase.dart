import 'dart:io';
import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class AddServiceToCaseUseCase {
  final CaseRepository repository;

  AddServiceToCaseUseCase(this.repository);

  Future<Either<Failure, CaseService>> call(int caseId, Map<String, dynamic> data) {
    return repository.addServiceToCase(caseId, data);
  }
}
