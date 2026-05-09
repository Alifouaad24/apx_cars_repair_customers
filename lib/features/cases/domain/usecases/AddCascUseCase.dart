import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AddCaseUseCase {
  final CaseRepository repository;

  AddCaseUseCase(this.repository);

  Future<Either<Failure, CaseModel>> call(Map<String, dynamic> caseData) {
    return repository.addCase(caseData);
  }
}