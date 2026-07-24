import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';

class CarsDataModel {
  List<CarBrandModel> brands;
  List<CarModel> models;
  List<CarYearModel> years;

  CarsDataModel({
    required this.brands,
    required this.models,
    required this.years,
  });

  factory CarsDataModel.fromJson(Map<String, dynamic> json) {
    return CarsDataModel(
      brands: (json['brands'] as List)
          .map((e) => CarBrandModel.fromJson(e))
          .toList(),
      models: (json['models'] as List)
          .map((e) => CarModel.fromJson(e))
          .toList(),
      years: (json['years'] as List)
          .map((e) => CarYearModel.fromJson(e))
          .toList(),
    );
  }
}

class CarBrandModel {
  final int carBrandId;
  final String carBrandName;
  final String? carBrandImgUrl;

  CarBrandModel({
    required this.carBrandId,
    required this.carBrandName,
    this.carBrandImgUrl,
  });

  factory CarBrandModel.fromJson(Map<String, dynamic> json) {
    return CarBrandModel(
      carBrandId: json['carBrandId'],
      carBrandName: json['carBrandName'] ?? '',
      carBrandImgUrl: json['carBrandImgUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carBrandId': carBrandId,
      'carBrandName': carBrandName,
      'carBrandImgUrl': carBrandImgUrl,
    };
  }
}

class CarYearModel {
  final int carYearId;
  final String carYearNumber;

  CarYearModel({
    required this.carYearId,
    required this.carYearNumber,
  });

  factory CarYearModel.fromJson(Map<String, dynamic> json) {
    return CarYearModel(
      carYearId: json['carYearId'],
      carYearNumber: json['carYearNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carYearId': carYearId,
      'carYearNumber': carYearNumber,
    };
  }
}