import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
class BindCustomerWithImageUseCase {
  final CustomerRepository repository;

  BindCustomerWithImageUseCase(this.repository);

  Future<Either<Failure, CustomerModel>> call(int customerId, XFile image) {
    return repository.bindCustomerWithImage(customerId, image);
  }
}