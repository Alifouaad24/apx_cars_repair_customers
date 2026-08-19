import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class DeleteOrderUsecase {
  CaseRepository repository;

  DeleteOrderUsecase(this.repository);

  Future<Either<Failure, GlobalOrderModel>> call(int orderId) async {
    return await repository.deleteOrder(orderId);
  }
}