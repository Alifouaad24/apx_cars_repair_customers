import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CustomerModel>> addCustomer(
    Map<String, dynamic> customerData,
  ) async {
    try {
      CustomerModel model = await remoteDataSource.addCustomer(customerData);

      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to add customer"));
    }
  }

  @override
  Future<Either<Failure, List<CustomerModel>>> showCustomers() async {
    try {
      List<CustomerModel> customers = await remoteDataSource.showCustomers();
      return Right(customers);
    } catch (e) {
      return Left(Failure("Failed to fetch customers"));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> editCustomer(
    int customerId,
    Map<String, dynamic> customerData,
  ) async {
    try {
      CustomerModel model = await remoteDataSource.editCustomer(
        customerId,
        customerData,
      );
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to edit customer"));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> deleteCustomer(int customerId) async {
    try {
      CustomerModel model = await remoteDataSource.deleteCustomer(customerId);
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to delete customer"));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> bindCustomerWithImage(
    int customerId,
    XFile image,
  ) async {
    try {
      CustomerModel model = await remoteDataSource.bindCustomerWithImage(
        customerId,
        image,
      );
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to bind image with customer"));
    }
  }
}
