import 'dart:io';

import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dio/dio.dart';

abstract class CaseRemoteDataSource {
  Future<CaseModel> addCase(Map<String, dynamic> caseData);
  Future<List<CaseModel>> showCases();
  Future<List<ServiceModel>> getAllServices();
  Future<CaseModel> editCase(int caseId, Map<String, dynamic> caseData);
  Future<void> bindImagesWithCase(int caseId, List<File> images);
  Future<CaseService> addServiceToCase(int caseId, Map<String, dynamic> data);
  Future<CaseService> editServiceToCase(int caseServiceId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> addCaseServiceNote(int caseServiceId, Map<String, dynamic> data);
}
