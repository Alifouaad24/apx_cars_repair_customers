import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class Setordercompletedusecase {
  final CaseRepository repository;
  Setordercompletedusecase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call(int id) async {
    return await repository.SetOrderCompleted(id);
  }
}
