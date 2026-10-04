import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class EditCarInfoUseCase {
  final CaseRepository repository;

  EditCarInfoUseCase(this.repository);

  Future<Either<Failure, CarInfoModel>> call(int id,Map<String, dynamic> data) async {
    return repository.editCarInfo(id, data);
  }
}