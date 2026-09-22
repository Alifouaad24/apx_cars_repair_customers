import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/SupplierModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
class AddconsumerbusinessUsecase {
  final CustomerRepository repository;

  AddconsumerbusinessUsecase(this.repository);

  Future<Either<Failure, SupplierFilterModel>> call(Map<String, dynamic> data) {
    return repository.addConsumerBusiness(data);
  }
}