import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderStatusModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetorderstatusUsecase {
  final CaseRepository repository;

  GetorderstatusUsecase(this.repository);

  Future<Either<Failure, List<OrderStatusModel>>> call() async {
    return await repository.getOrderStatus();
  }
}