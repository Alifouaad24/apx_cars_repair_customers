import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

abstract class CaseRepository {
  Future<Either<Failure, CaseModel>> addCase(Map<String, dynamic> caseData);
  Future<Either<Failure, List<CaseModel>>> showCases();
  Future<Either<Failure, CaseModel>> editCase(
    int caseId,
    Map<String, dynamic> caseData,
  );
  Future<Either<Failure, void>> bindImagesWithCase(
    int caseId,
    List<File> images,
  );
}
