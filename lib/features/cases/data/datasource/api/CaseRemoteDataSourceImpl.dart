import 'dart:io';
import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderStatusModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:dio/dio.dart';

class CaseRemoteDataSourceImpl implements CaseRemoteDataSource {
  final DioClient client;

  CaseRemoteDataSourceImpl(this.client);

  @override
  Future<GlobalOrderModel> addCase(Map<String, dynamic> caseData) async {
    final response = await client.dio.post(
      "/Orders/AddGlobalOrder",
      data: caseData,
    );
    return GlobalOrderModel.fromJson(response.data);
  }

  @override
  Future<List<GlobalOrderModel>> showCases() async {
    final response = await client.dio.get("/Orders/40");
    return (response.data as List)
        .map((json) => GlobalOrderModel.fromJson(json))
        .toList();
  }

  @override
  Future<CarsDataModel> getAllCarsData() async {
    final response = await client.dio.get("/Car");
    print(response.data);
    print(response.data['models']);
    return CarsDataModel.fromJson(response.data);
  }

  @override
  Future<List<ServiceModel>> getAllServices() async {
    final response = await client.dio.get("/Service/40");
    return (response.data as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  @override
  Future<GlobalOrderModel> editCase(
    int caseId,
    Map<String, dynamic> caseData,
  ) async {
    final response = await client.dio.put(
      "/Orders/$caseId",
      data: caseData,
      options: Options(contentType: "application/json"),
    );
    return GlobalOrderModel.fromJson(response.data);
  }

  @override
  Future<List<OrderImage>> bindImagesWithCase(
    int orderTd,
    List<File> images,
  ) async {
    if (images.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/Orders/BindImagesWithOrder/$orderTd',
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

    var response = await client.dio.put(
      "/Orders/BindImagesWithOrder/$orderTd",
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    List<OrderImage> data = response.data;
    return data;
  }

  @override
  Future<OrderServiceModel> addServiceToCase(Map<String, dynamic> data) async {
    int globalOrderId = data['globalOrderId'];
    final response = await client.dio.post(
      "/Orders/AddDetailForOrder?orderId=${globalOrderId}",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return OrderServiceModel.fromJson(response.data);
  }

  @override
  Future<OrderServiceModel> editServiceToCase(
    int orderServicId,
    Map<String, dynamic> data,
  ) async {
    final response = await client.dio.put(
      "/Orders/EditDetailForOrder?orderDetailId=$orderServicId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return OrderServiceModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> addCaseServiceNote(
    int caseServiceId,
    Map<String, dynamic> data,
  ) async {
    final response = await client.dio.post(
      "/Orders/AddServiceCaseNote?caseServicId=$caseServiceId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return response.data;
  }

  @override
  Future<OrderServiceModel> changCaseServiceStatus(
    int caseServiceId,
    Map<String, dynamic> data,
  ) async {
    final response = await client.dio.put(
      "/Orders/changeStatusOrderService?caseServicId=$caseServiceId",
      data: data,
      options: Options(contentType: "application/json"),
    );
    return OrderServiceModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> deleteCaseService(int caseServiceId) async {
    final response = await client.dio.delete(
      "/Orders/DeleteOrderDetail?orderDetailId=$caseServiceId",
    );
    return response.data;
  }

  @override
  Future<CarInfoModel> addCarToOrder(Map<String, dynamic> carData) async {
    final response = await client.dio.post(
      "/Orders/AddCarGlobalOrder",
      data: carData,
      options: Options(contentType: "application/json"),
    );

    return CarInfoModel.fromJson(response.data);
  }

  @override
  Future<List<OrderStatusModel>> getOrderStatus() async {
    final response = await client.dio.get(
      "/UniversalOrder/40",
      options: Options(contentType: "application/json"),
    );

    return (response.data as List)
        .map((el) => OrderStatusModel.fromJson(el))
        .toList();
  }

  @override
  Future<GlobalOrderModel> deleteOrder(int orderId) async {
    final response = await client.dio.delete(
      "/Orders/${orderId}",
      options: Options(contentType: "application/json"),
    );

    return GlobalOrderModel.fromJson(response.data);
  }
}
