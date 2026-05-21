import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

abstract class CaseRepository {
  Future<Either<Failure, CaseModel>> addCase(Map<String, dynamic> caseData);
  Future<Either<Failure, List<CaseModel>>> showCases();
  Future<Either<Failure, CaseService>> editServiceToCase(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, CaseModel>> editCase(
    int caseId,
    Map<String, dynamic> caseData,
  );
  Future<Either<Failure, void>> bindImagesWithCase(
    int caseId,
    List<File> images,
  );
  Future<Either<Failure, List<ServiceModel>>> getAllServices();
  Future<Either<Failure, CaseService>> addServiceToCase(int caseId, Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> addCaseServiceNote(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, CaseService>> changeCaseServiceStatus(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> deleteCaseService(int caseServiceId);
}
