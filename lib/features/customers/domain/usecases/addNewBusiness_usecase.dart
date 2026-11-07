import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
class AddnewbusinessUsecase {
  final CustomerRepository repository;

  AddnewbusinessUsecase(this.repository);

  Future<Either<Failure, BusinessModel>> call(Map<String, dynamic> businessData) {
    return repository.addNewBusiness(businessData);
  }
}