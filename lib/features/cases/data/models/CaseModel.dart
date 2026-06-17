import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';

class CaseModel {
  final int id;
  final CustomerModel? customer;
  final int? customerId;
  final CarInfo? carInfo;
  final List<CaseImage>? images;
  final List<CaseService>? caseServices;
  final String? date;

  CaseModel({
    required this.id,
    required this.customer,
    required this.customerId,
    required this.carInfo,
    required this.images,
    required this.caseServices,
    required this.date,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['caseId'] ?? 0,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      customerId: json['customerId'],
      carInfo: json['carInfoTbl'] != null
          ? CarInfo.fromJson(json['carInfoTbl'])
          : null,
      images: json['caseImages'] != null
          ? List<CaseImage>.from(
              json['caseImages'].map((x) => CaseImage.fromJson(x)),
            )
          : [],
      caseServices: json['case_Services'] != null
          ? List<CaseService>.from(
              json['case_Services'].map((x) => CaseService.fromJson(x)),
            )
          : [],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': id,
      'customer': customer?.toJson(),
      'customerId': customerId,
      'carInfoTbl': carInfo?.toJson(),
      'caseImages': images?.map((e) => e.toJson()).toList() ?? [],
      'case_Services': caseServices?.map((e) => e.toJson()).toList() ?? [],

      'date': date,
    };
  }
}

/////////////////////////////////////////////////////////

class CaseImage {
  final int id;
  final String imageUrl;
  final int caseId;

  CaseImage({required this.id, required this.imageUrl, required this.caseId});

  factory CaseImage.fromJson(Map<String, dynamic> json) {
    return CaseImage(
      id: json['caseImageId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      caseId: json['caseId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'caseImageId': id, 'imageUrl': imageUrl, 'caseId': caseId};
  }
}

/////////////////////////////////////////////////////////

class CarInfo {
  final int id;
  final String vinNumber;
  final int? carBrandId;
  final int? carModelId;
  final CarBrand? carBrand;
  final CarModel? carModel;

  CarInfo({
    required this.id,
    required this.vinNumber,
    required this.carBrandId,
    required this.carModelId,
    required this.carBrand,
    required this.carModel,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['carInfoTblId'] ?? 0,
      vinNumber: json['vinNumber'] ?? '',
      carBrandId: json['carBrandId'],
      carModelId: json['carModelId'],
      carBrand: json['carBrand'] != null
          ? CarBrand.fromJson(json['carBrand'])
          : null,
      carModel: json['carModel'] != null
          ? CarModel.fromJson(json['carModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carInfoTblId': id,
      'vinNumber': vinNumber,
      'carBrandId': carBrandId,
      'carModelId': carModelId,
      'carBrand': carBrand?.toJson(),
      'carModel': carModel?.toJson(),
    };
  }
}

/////////////////////////////////////////////////////////

class CarBrand {
  final int carBrandId;
  final String carBrandName;
  final String? carBrandImgUrl;

  CarBrand({
    required this.carBrandId,
    required this.carBrandName,
    this.carBrandImgUrl,
  });

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      carBrandId: json['carBrandId'] ?? 0,
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

/////////////////////////////////////////////////////////

class CarModel {
  final int carModelId;
  final String carModelName;
  final int carYearId;
  final CarYear? carYear;

  CarModel({
    required this.carModelId,
    required this.carModelName,
    required this.carYearId,
    required this.carYear,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      carModelId: json['carModelId'] ?? 0,
      carModelName: json['carModelName'] ?? '',
      carYearId: json['carYearId'] ?? 0,
      carYear: json['carYear'] != null
          ? CarYear.fromJson(json['carYear'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carModelId': carModelId,
      'carModelName': carModelName,
      'carYearId': carYearId,
      'carYear': carYear?.toJson(),
    };
  }
}

/////////////////////////////////////////////////////////

class CarYear {
  final int carYearId;
  final String carYearNumber;

  CarYear({required this.carYearId, required this.carYearNumber});

  factory CarYear.fromJson(Map<String, dynamic> json) {
    return CarYear(
      carYearId: json['carYearId'] ?? 0,
      carYearNumber: json['carYearNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'carYearId': carYearId, 'carYearNumber': carYearNumber};
  }
}

/////////////////////////////////////////////////////////

class CaseService {
  final int caseServiceId;
  final int caseId;
  final int serviceId;
  bool? resolved;
  final String? notes;
  final double? cost;
  final double? discount;
  final double? paid;
  final ServiceModel1? service;
  final List<CaseServiceNote>? caseServiceNotes;

  CaseService({
    required this.caseServiceId,
    required this.caseId,
    required this.serviceId,
    this.resolved,
    required this.notes,
    required this.cost,
    required this.discount,
    required this.paid,
    required this.service,
    required this.caseServiceNotes,
  });

  factory CaseService.fromJson(Map<String, dynamic> json) {
    return CaseService(
      caseServiceId: json['case_ServiceId'] ?? 0,
      caseId: json['caseID'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      resolved: json['resolved'],
      notes: json['notes'],
      cost: json['cost'] != null
          ? double.tryParse(json['cost'].toString())
          : null,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
      paid: json['paid'] != null
          ? double.tryParse(json['paid'].toString())
          : null,
      service: json['service'] != null
          ? ServiceModel1.fromJson(json['service'])
          : null,
      caseServiceNotes: json['case_Service_Notes'] != null
          ? List<CaseServiceNote>.from(
              json['case_Service_Notes'].map(
                (x) => CaseServiceNote.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_ServiceId': caseServiceId,
      'caseID': caseId,
      'service_id': serviceId,
      'resolved': resolved,
      'notes': notes,
      'cost': cost,
      'discount': discount,
      'paid': paid,
      'service': service?.toJson(),
      'case_Service_Notes': caseServiceNotes?.map((e) => e.toJson()).toList(),
    };
  }
}

/////////////////////////////////////////////////////////

class CaseServiceNote {
  final int caseServiceNotesId;
  final String? notes;
  final int? caseServiceId;

  CaseServiceNote({
    required this.caseServiceNotesId,
    required this.notes,
    required this.caseServiceId,
  });

  factory CaseServiceNote.fromJson(Map<String, dynamic> json) {
    return CaseServiceNote(
      caseServiceNotesId: json['case_ServiceNotesId'] ?? 0,
      notes: json['notes'],
      caseServiceId: json['case_ServiceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_ServiceNotesId': caseServiceNotesId,
      'notes': notes,
      'case_ServiceId': caseServiceId,
    };
  }
}

/////////////////////////////////////////////////////////

class ServiceModel1 {
  final int serviceId;
  final String description;
  final String serviceIcon;
  final String serviceRoute;

  ServiceModel1({
    required this.serviceId,
    required this.description,
    required this.serviceIcon,
    required this.serviceRoute,
  });

  factory ServiceModel1.fromJson(Map<String, dynamic> json) {
    return ServiceModel1(
      serviceId: json['service_id'] ?? 0,
      description: json['description'] ?? '',
      serviceIcon: json['service_icon'] ?? '',
      serviceRoute: json['service_Route'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'description': description,
      'service_icon': serviceIcon,
      'service_Route': serviceRoute,
    };
  }
}
