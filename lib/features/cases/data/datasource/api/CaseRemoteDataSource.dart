import 'dart:io';

import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:dio/dio.dart';

abstract class CaseRemoteDataSource {
  Future<CaseModel> addCase(Map<String, dynamic> caseData);
  Future<List<CaseModel>> showCases();
  Future<CaseModel> editCase(int caseId, Map<String, dynamic> caseData);
  Future<void> bindImagesWithCase(int caseId, List<File> images);
}
