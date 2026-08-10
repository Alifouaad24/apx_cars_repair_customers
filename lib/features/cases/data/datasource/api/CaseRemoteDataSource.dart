import 'dart:io';

import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderStatusModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dio/dio.dart';

abstract class CaseRemoteDataSource {
  Future<GlobalOrderModel> addCase(Map<String, dynamic> caseData);
  Future<CarInfoModel> addCarToOrder(Map<String, dynamic> carData);
  Future<List<OrderStatusModel>> getOrderStatus();
  Future<List<GlobalOrderModel>> showCases();
  Future<List<ServiceModel>> getAllServices();
  Future<GlobalOrderModel> editCase(int caseId, Map<String, dynamic> caseData);
  Future<List<OrderImage>> bindImagesWithCase(int caseId, List<File> images);
  Future<OrderServiceModel> addServiceToCase(Map<String, dynamic> data);
  Future<OrderServiceModel> editServiceToCase(int caseServiceId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> addCaseServiceNote(int caseServiceId, Map<String, dynamic> data);
  Future<OrderServiceModel> changCaseServiceStatus(int caseServiceId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteCaseService(int caseServiceId);
  Future<CarsDataModel> getAllCarsData();
}
