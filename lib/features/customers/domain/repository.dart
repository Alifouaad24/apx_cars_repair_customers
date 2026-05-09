import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerModel>> addCustomer(Map<String, dynamic> customerData);
  Future<Either<Failure, List<CustomerModel>>> showCustomers();
  Future<Either<Failure, CustomerModel>> editCustomer(int customerId, Map<String, dynamic> customerData);
  Future<Either<Failure, CustomerModel>> deleteCustomer(int customerId);
  Future<Either<Failure, CustomerModel>> bindCustomerWithImage(int customerId, XFile image);
}