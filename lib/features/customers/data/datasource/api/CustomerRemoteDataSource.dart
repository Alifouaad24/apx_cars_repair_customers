import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:image_picker/image_picker.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> addCustomer(Map<String, dynamic> customerData);
  Future<List<CustomerModel>> showCustomers();
  Future<CustomerModel> editCustomer(int customerId, Map<String, dynamic> customerData);
  Future<CustomerModel> deleteCustomer(int customerId);
  Future<CustomerModel> bindCustomerWithImage(int customerId, XFile image);
}