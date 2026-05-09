import 'dart:io';

import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';

class BindImagesWithCaseUseCase {
  final CaseRepository repository;

  BindImagesWithCaseUseCase(this.repository);

  Future<Either<Failure, void>> call(int caseId, List<File> images) {
    return repository.bindImagesWithCase(caseId, images);
  }
}
