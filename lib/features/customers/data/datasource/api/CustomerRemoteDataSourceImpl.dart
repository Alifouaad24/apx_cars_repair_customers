import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';

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
      "/customers/$customerId",
      data: customerData,
    );
    return CustomerModel.fromJson(response.data);
  }
}