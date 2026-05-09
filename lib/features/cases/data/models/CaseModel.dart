import 'package:apx_cars_repair/app/Bindings/CustomerBinding.dart';
import 'package:apx_cars_repair/features/cases/domain/entities/Case.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';

class CaseModel {
  final int id;
  final CustomerModel? customer;
  final int? customerId;
  final List<CaseImage>? images;
  final CarInfo carInfo;

  CaseModel({
    required this.id,
    required this.customer,
    required this.customerId,
    required this.carInfo,
    required this.images,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      // ✅ الصحيح
      id: json['caseId'],
      customer: json['customer'] != null ? CustomerModel.fromJson(json['customer']) : null,
      // ✅ الصحيح
      carInfo: CarInfo.fromJson(json['carInfoTbl']),

      customerId: json['customerId'],

      // ✅ الصحيح
      images:
          json['caseImages'] != null
              ? List<CaseImage>.from(
                json['caseImages'].map((x) => CaseImage.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': id,
      'customer': customer?.toJson(),
      'carInfoTbl': carInfo.toJson(),
      'customerId': customerId,
      'caseImages':
          images != null
              ? List<dynamic>.from(images!.map((x) => x.toJson()))
              : [],
    };
  }
}

class CaseImage {
  final int id;
  final String imageUrl;
  final int caseId;

  CaseImage({required this.id, required this.imageUrl, required this.caseId});

  factory CaseImage.fromJson(Map<String, dynamic> json) {
    return CaseImage(
      id: json['caseImageId'],
      imageUrl: json['imageUrl'],
      caseId: json['caseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'caseImageId': id, 'imageUrl': imageUrl, 'caseId': caseId};
  }
}

class CarInfo {
  final int id;
  final String brand;
  final String vinNumber;
  final String model;
  final String year;

  CarInfo({
    required this.id,
    required this.vinNumber,
    required this.brand,
    required this.model,
    required this.year,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['carInfoTblId'],
      vinNumber: json['vinNumber'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carInfoTblId': id,
      'vinNumber': vinNumber,
      'brand': brand,
      'model': model,
      'year': year,
    };
  }
}
