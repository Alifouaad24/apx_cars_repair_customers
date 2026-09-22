import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/SupplierModel.dart';
import 'package:image_picker/image_picker.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> addCustomer(Map<String, dynamic> customerData);
  Future<List<CustomerModel>> showCustomers();
  Future<CustomerModel> editCustomer(int customerId, Map<String, dynamic> customerData);
  Future<CustomerModel> deleteCustomer(int customerId);
  Future<CustomerModel> bindCustomerWithImage(int customerId, XFile image);
  Future<List<SupplierFilterModel>> showConsumerBusiness();
  Future<SupplierFilterModel> addConsumerBusiness(Map<String, dynamic> data);
    Future<List<BusinessModel>> getAvailableBusinesses();
  Future<List<ServiceModel>> getAvailableServices();
}