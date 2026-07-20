import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';



class GlobalOrderModel {
  final int? globalOrderId;
  final int? globalCustomerId;
  final int? carInfoTblId;
  final CustomerModel? customer;
  final int businessId;
  final String insertDate;
  final String scheduleDt;
  final String scheduleTime;
  CarInfoModel? carInfo;
  final String status;
  final String? notes;
  final List<OrderServiceModel>? oredesServices;
  List<OrderImage>? orderImages;

  GlobalOrderModel({
    this.globalOrderId,
    this.globalCustomerId,
    required this.businessId,
    this.carInfoTblId,
    required this.insertDate,
    required this.scheduleDt,
    required this.scheduleTime,
    required this.status,
    this.carInfo,
    this.orderImages,
    this.customer,
    this.notes,
    this.oredesServices,
  });

  factory GlobalOrderModel.fromJson(Map<String, dynamic> json) {
    return GlobalOrderModel(
      globalOrderId: json['globalOrderId'],
      carInfoTblId: json['carInfoTblId'] ?? null,
      orderImages: json['orderImages'] != null
          ? (json['orderImages'] as List)
                .map((el) => OrderImage.fromJson(el))
                .toList()
          : null,
      globalCustomerId: json['globalCustomerId'],
      businessId: json['business_id'],
      insertDate: json['insertDate'] ?? '',
      scheduleDt: json['schedule_dt'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
      status: json['status'] ?? '',
      carInfo: json['carInfoTbl'] != null
          ? CarInfoModel.fromJson(json['carInfoTbl'])
          : null,
      notes: json['notes'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      oredesServices: json['oredesServicess'] != null
          ? List<OrderServiceModel>.from(
              json['oredesServicess'].map((x) => OrderServiceModel.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'globalOrderId': globalOrderId,
      'globalCustomerId': globalCustomerId,
      'business_id': businessId,
      'insertDate': insertDate,
      'schedule_dt': scheduleDt,
      'schedule_time': scheduleTime,
      'status': status,
      'notes': notes,
    };
  }
}

/// الطلب نفسه لا يحتوي سيارة مباشرة (تصميم عام: قد يكون شحن/توصيل بلا سيارة).
/// السيارة موجودة داخل كل OrderServiceModel. هذا الـ extension يجيب لك
/// "السيارة الرئيسية" لعرضها بأعلى صفحة تفاصيل الطلب (أول خدمة مرتبطة بسيارة).
extension GlobalOrderCarInfo on GlobalOrderModel {
  CarInfoModel? get primaryCarInfo {
    final services = oredesServices;
    if (services == null) return null;
    for (final s in services) {
      if (s.carInfo != null) return s.carInfo;
    }
    return null;
  }

  bool get hasCarImages =>
      primaryCarInfo?.images != null && primaryCarInfo!.images!.isNotEmpty;
}

class CarBrandModel {
  final int carBrandId;
  final String carBrandName;
  final String? carBrandImgUrl;
  final List<CarModel>? carModels;

  CarBrandModel({
    required this.carBrandId,
    required this.carBrandName,
    this.carBrandImgUrl,
    this.carModels,
  });

  factory CarBrandModel.fromJson(Map<String, dynamic> json) {
    return CarBrandModel(
      carBrandId: json['carBrandId'],
      carBrandName: json['carBrandName'],
      carBrandImgUrl: json['carBrandImgUrl'],
      carModels: json['carModels'] != null
          ? List<CarModel>.from(
              json['carModels'].map((x) => CarModel.fromJson(x)),
            )
          : null,
    );
  }
}

class CarModel {
  final int carModelId;
  final String carModelName;
  final int carBrandId;
  final CarBrandModel? carBrand;

  CarModel({
    required this.carModelId,
    required this.carModelName,
    required this.carBrandId,
    this.carBrand,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      carModelId: json['carModelId'],
      carModelName: json['carModelName'],
      carBrandId: json['carBrandId'],
      carBrand: json['carBrand'] != null
          ? CarBrandModel.fromJson(json['carBrand'])
          : null,
    );
  }
}

class CarYear {
  final int carYearId;
  final String carYearNumber;

  CarYear({required this.carYearId, required this.carYearNumber});

  factory CarYear.fromJson(Map<String, dynamic> json) {
    return CarYear(
      carYearId: json['carYearId'],
      carYearNumber: json['carYearNumber'],
    );
  }
}

class CarImage {
  final int carImageId;
  final String imageUrl;

  CarImage({required this.carImageId, required this.imageUrl});

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(carImageId: json['carImageId'], imageUrl: json['imageUrl']);
  }
}

class CarInfoModel {
  final int carInfoTblId;
  final String? vinNumber;
  final int globalCustomerId;
  final int? carYearId;
  final int? carBrandId;
  final int? carModelId;
  final CarYear? carYear;
  final CarBrandModel? carBrand;
  final CarModel? carModel;
  final List<CarImage>? images;

  CarInfoModel({
    required this.carInfoTblId,
    this.vinNumber,
    required this.globalCustomerId,
    this.carYearId,
    this.carBrandId,
    this.carModelId,
    this.carYear,
    this.carBrand,
    this.carModel,
    this.images,
  });

  factory CarInfoModel.fromJson(Map<String, dynamic> json) {
    return CarInfoModel(
      carInfoTblId: json['carInfoTblId'],
      vinNumber: json['vinNumber'],
      globalCustomerId: json['globalCustomerId'],
      carYearId: json['carYearId'],
      carBrandId: json['carBrandId'],
      carModelId: json['carModelId'],
      carYear: json['carYear'] != null
          ? CarYear.fromJson(json['carYear'])
          : null,
      carBrand: json['carBrand'] != null
          ? CarBrandModel.fromJson(json['carBrand'])
          : null,
      carModel: json['carModel'] != null
          ? CarModel.fromJson(json['carModel'])
          : null,
      images: json['images'] != null
          ? List<CarImage>.from(json['images'].map((x) => CarImage.fromJson(x)))
          : null,
    );
  }
}

class OrderServiceModel {
  int oredesServicesId;
  int? serviceId;
  int? globalOrderId;
  int? carInfoId;
  ServiceModel? service;
  CarInfoModel? carInfo;

  bool? resolved;
  String? notes;
  double? cost;
  double? discount;
  double? paid;

  OrderServiceModel({
    required this.oredesServicesId,
    this.serviceId,
    this.globalOrderId,
    this.carInfoId,
    this.service,
    this.carInfo,
    this.resolved,
    this.notes,
    this.cost,
    this.discount,
    this.paid,
  });

  factory OrderServiceModel.fromJson(Map<String, dynamic> json) {
    return OrderServiceModel(
      oredesServicesId: json['oredesServicesId'],
      serviceId: json['serviceId'],
      globalOrderId: json['globalOrderId'],
      carInfoId: json['carInfoId'],
      resolved: json['resolved'],
      notes: json['notes'],
      cost: json['cost'],
      discount: json['discount'],
      paid: json['paid'],
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      carInfo: json['carInfoTbl'] != null
          ? CarInfoModel.fromJson(json['carInfoTbl'])
          : null,
    );
  }
}

class OrderImage {
  int caseImageId;
  String ImageUrl;

  OrderImage({required this.caseImageId, required this.ImageUrl});

  factory OrderImage.fromJson(Map<String, dynamic> json) {
    return OrderImage(
      caseImageId: json['caseImageId'],
      ImageUrl: json['imageUrl'],
    );
  }
}
