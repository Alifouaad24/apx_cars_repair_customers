import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
class AddCustomerUseCase {
  final CustomerRepository repository;

  AddCustomerUseCase(this.repository);

  Future<Either<Failure, CustomerModel>> call(Map<String, dynamic> customerData) {
    return repository.addCustomer(customerData);
  }
}