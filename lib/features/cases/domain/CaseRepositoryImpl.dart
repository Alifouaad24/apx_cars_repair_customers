import 'dart:io';

import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CaseRepositoryImpl implements CaseRepository {
  final CaseRemoteDataSource remoteDataSource;

  CaseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CaseModel>> addCase(
    Map<String, dynamic> caseData,
  ) async {
    try {
      CaseModel model = await remoteDataSource.addCase(caseData);

      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to add case"));
    }
  }

  @override
  Future<Either<Failure, List<CaseModel>>> showCases() async {
    try {
      List<CaseModel> cases = await remoteDataSource.showCases();
      return Right(cases);
    } catch (e) {
      return Left(Failure("Failed to fetch cases"));
    }
  }

  @override
  Future<Either<Failure, CaseModel>> editCase(
    int caseId,
    Map<String, dynamic> caseData,
  ) async {
    try {
      CaseModel model = await remoteDataSource.editCase(caseId, caseData);
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to edit case"));
    }
  }

  @override
  Future<Either<Failure, void>> bindImagesWithCase(
    int caseId,
    List<File> images,
  ) async {
    try {
      await remoteDataSource.bindImagesWithCase(caseId, images);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Failed to bind images with case')
          : 'Failed to bind images with case';
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure("Failed to bind images with case"));
    }
  }
}
