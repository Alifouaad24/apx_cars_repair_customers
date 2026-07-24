import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class GetCarInfoUsecase {
  final CaseRepository repository;

  GetCarInfoUsecase(this.repository);

  Future<Either<Failure, CarsDataModel>> call() async {
    return await repository.getAllCarsData();
  }
}