import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class ShowCustomersUsecase {
    final CustomerRepository repository;

  ShowCustomersUsecase(this.repository);

    Future<Either<Failure, List<CustomerModel>>> call() {
    return repository.showCustomers();
  }
}