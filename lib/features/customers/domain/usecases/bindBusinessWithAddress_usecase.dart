import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';

class BindBusinessWithAddressUsecase {
  final CustomerRepository repository;

  BindBusinessWithAddressUsecase(this.repository);

  /// data: { businessId, line1, line2, postCode, usCity }
  Future<Either<Failure, void>> call(Map<String, dynamic> data) {
    return repository.bindBusinessWithNewAddress(data);
  }
}
