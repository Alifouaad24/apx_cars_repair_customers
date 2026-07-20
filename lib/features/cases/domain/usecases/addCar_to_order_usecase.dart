import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AddCarToOrderUseCase {
  final CaseRepository repository;

  AddCarToOrderUseCase(this.repository);

  Future<Either<Failure, CarInfoModel>> call(Map<String, dynamic> caseData) {
    return repository.addCarToOrder(caseData);
  }
}