import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:dartz/dartz.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerModel>> addCustomer(Map<String, dynamic> customerData);
  Future<Either<Failure, List<CustomerModel>>> showCustomers();
  Future<Either<Failure, CustomerModel>> editCustomer(int customerId, Map<String, dynamic> customerData);
}