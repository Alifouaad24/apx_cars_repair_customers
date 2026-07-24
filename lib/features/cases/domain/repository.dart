import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

abstract class CaseRepository {
  Future<Either<Failure, GlobalOrderModel>> addCase(Map<String, dynamic> caseData);
  Future<Either<Failure, CarInfoModel>> addCarToOrder(Map<String, dynamic> caseData);
  Future<Either<Failure, List<GlobalOrderModel>>> showCases();
  Future<Either<Failure, CarsDataModel>> getAllCarsData();
  Future<Either<Failure, OrderServiceModel>> editServiceToCase(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, GlobalOrderModel>> editCase(
    int caseId,
    Map<String, dynamic> caseData,
  );
  Future<Either<Failure, List<OrderImage>>> bindImagesWithCase(
    int caseId,
    List<File> images,
  );
  Future<Either<Failure, List<ServiceModel>>> getAllServices();
  Future<Either<Failure, OrderServiceModel>> addServiceToCase(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> addCaseServiceNote(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, OrderServiceModel>> changeCaseServiceStatus(int caseServiceId, Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> deleteCaseService(int caseServiceId);
}
