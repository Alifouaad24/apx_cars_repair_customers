import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> addCustomer(Map<String, dynamic> customerData);
  Future<List<CustomerModel>> showCustomers();
  Future<CustomerModel> editCustomer(int customerId, Map<String, dynamic> customerData);
}