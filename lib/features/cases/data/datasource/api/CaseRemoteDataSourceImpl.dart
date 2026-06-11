import 'dart:io';
import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dio/dio.dart';

class CaseRemoteDataSourceImpl implements CaseRemoteDataSource {
  final DioClient client;

  CaseRemoteDataSourceImpl(this.client);

  @override
  Future<CaseModel> addCase(Map<String, dynamic> caseData) async {
    final response = await client.dio.post("/Case", data: caseData);
    return CaseModel.fromJson(response.data);
  }

  @override
  Future<List<CaseModel>> showCases() async {
    final response = await client.dio.get("/Case");
    return (response.data as List)
        .map((json) => CaseModel.fromJson(json))
        .toList();
  }

    @override
  Future<List<ServiceModel>> getAllServices() async {
    final response = await client.dio.get("/Service");
    return (response.data as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  @override
  Future<CaseModel> editCase(int caseId, Map<String, dynamic> caseData) async {
    final response = await client.dio.put(
      "/Case/$caseId",
      data: caseData,
      options: Options(contentType: "application/json"),
    );
    return CaseModel.fromJson(response.data);
  }

  @override
  Future<void> bindImagesWithCase(int caseId, List<File> images) async {
    if (images.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/Case/BindImagesWithCase/$caseId',
        ),
        error: 'No images selected',
      );
    }

    final formData = FormData();
    for (final image in images) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    await client.dio.put(
      "/Case/BindImagesWithCase/$caseId",
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  Future<CaseService> addServiceToCase(int caseId, Map<String, dynamic> data) async {
    final response = await client.dio.post(
      "/Case/AddCaseServiceToCase?caseId=$caseId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return CaseService.fromJson(response.data);
  }

  @override
  Future<CaseService> editServiceToCase(int caseServiceId, Map<String, dynamic> data) async {
    final response = await client.dio.put(
      "/Case/EditCaseService?caseServicId=$caseServiceId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return CaseService.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> addCaseServiceNote(int caseServiceId, Map<String, dynamic> data) async {
    final response = await client.dio.post(
      "/Case/AddServiceCaseNote?caseServicId=$caseServiceId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return response.data;
  }

  @override
  Future<CaseService> changCaseServiceStatus(int caseServiceId, Map<String, dynamic> data) async {
    final response = await client.dio.put(
      "/Case/changeStatusCaseService?caseServicId=$caseServiceId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return CaseService.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> deleteCaseService(int caseServiceId) async {
    final response = await client.dio.delete(
      "/Case/DeletetCaseService?caseServicId=$caseServiceId",
    );
    return response.data;
  }
}
