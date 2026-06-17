import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final DioClient client;

  CustomerRemoteDataSourceImpl(this.client);

  @override
  Future<CustomerModel> addCustomer(Map<String, dynamic> customerData) async {
    final response = await client.dio.post(
      "/customers",
      data: customerData,
    );
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<List<CustomerModel>> showCustomers() async {
    final response = await client.dio.get("/Customers/40");
    return (response.data as List).map((json) => CustomerModel.fromJson(json)).toList();
  }

  @override
  Future<CustomerModel> editCustomer(int customerId, Map<String, dynamic> customerData) async {
    final response = await client.dio.put(
      "/Customers/$customerId",
      data: customerData,
    );
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<CustomerModel> deleteCustomer(int customerId) async {
    final response = await client.dio.delete("/Customers/$customerId");
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<CustomerModel> bindCustomerWithImage(int customerId, XFile image) async {
    var formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path, filename: image.name),
    });
    final response = await client.dio.put(
      "/Customers/BindImagesWithCustomer/$customerId",
      data: formData,
    );
    return CustomerModel.fromJson(response.data);
  }
}