import 'dart:io';

import 'package:apx_cars_repair/core/error/Failure.dart';
import 'package:apx_cars_repair/features/cases/data/datasource/api/CaseRemoteDataSource.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
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
      final model = await remoteDataSource.addCase(caseData);

      return Right(model);
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                e.message ??
                'Failed to add case')
          : (e.message ?? 'Failed to add case');

      print("DioException: $message");

      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
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
  Future<Either<Failure, List<ServiceModel>>> getAllServices() async {
    try {
      List<ServiceModel> services = await remoteDataSource.getAllServices();
      return Right(services);
    } catch (e) {
      return Left(Failure("Failed to fetch services"));
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

  @override
  Future<Either<Failure, CaseService>> addServiceToCase(
    int caseId,
    Map<String, dynamic> data,
  ) async {
    try {
      CaseService model = await remoteDataSource.addServiceToCase(caseId, data);
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to add service to case"));
    }
  }

  @override
  Future<Either<Failure, CaseService>> editServiceToCase(
    int caseServiceId,
    Map<String, dynamic> data,
  ) async {
    try {
      CaseService model = await remoteDataSource.editServiceToCase(caseServiceId, data);
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to edit service in case"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addCaseServiceNote(
    int caseServiceId,
    Map<String, dynamic> data,
  ) async {
    try {
      Map<String, dynamic> response = await remoteDataSource.addCaseServiceNote(caseServiceId, data);
      return Right(response);
    } catch (e) {
      return Left(Failure("Failed to add note to case service"));
    }
  }

  @override
  Future<Either<Failure, CaseService>> changeCaseServiceStatus(
    int caseServiceId,
    Map<String, dynamic> data,
  ) async {
    try {
      CaseService model = await remoteDataSource.changCaseServiceStatus(caseServiceId, data);
      return Right(model);
    } catch (e) {
      return Left(Failure("Failed to change case service status"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteCaseService(int caseServiceId) async {
    try {
      Map<String, dynamic> response = await remoteDataSource.deleteCaseService(caseServiceId);
      return Right(response);
    } catch (e) {
      return Left(Failure("Failed to delete case service"));
    }
  }
}
