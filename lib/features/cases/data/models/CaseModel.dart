import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';

class CaseModel {
  final int id;

  final CustomerModel? customer;

  final int? customerId;

  final List<CaseImage>? images;

  final CarInfo carInfo;

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

      carInfo: CarInfo.fromJson(json['carInfoTbl']),

      images: json['caseImages'] != null
          ? List<CaseImage>.from(
              json['caseImages']
                  .map((x) => CaseImage.fromJson(x)),
            )
          : [],

      caseServices: json['case_Services'] != null
          ? List<CaseService>.from(
              json['case_Services']
                  .map((x) => CaseService.fromJson(x)),
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

      'carInfoTbl': carInfo.toJson(),

      'caseImages': images != null
          ? List<dynamic>.from(
              images!.map((x) => x.toJson()),
            )
          : [],

      'case_Services': caseServices != null
          ? List<dynamic>.from(
              caseServices!.map((x) => x.toJson()),
            )
          : [],

      'date': date,
    };
  }
}

class CaseImage {
  final int id;

  final String imageUrl;

  final int caseId;

  CaseImage({
    required this.id,
    required this.imageUrl,
    required this.caseId,
  });

  factory CaseImage.fromJson(
    Map<String, dynamic> json,
  ) {
    return CaseImage(
      id: json['caseImageId'] ?? 0,

      imageUrl: json['imageUrl'] ?? '',

      caseId: json['caseId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseImageId': id,
      'imageUrl': imageUrl,
      'caseId': caseId,
    };
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

  factory CarInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return CarInfo(
      id: json['carInfoTblId'] ?? 0,

      vinNumber: json['vinNumber'] ?? '',

      brand: json['brand'] ?? '',

      model: json['model'] ?? '',

      year: json['year'] ?? '',
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

  factory CaseService.fromJson(
    Map<String, dynamic> json,
  ) {
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
      caseServiceNotes:
          json['case_Service_Notes'] != null
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
      'serviceId': serviceId,
      'resolved': resolved,
      'notes': notes,
      'cost': cost,
      'discount': discount,
      'paid': paid,
      'service': service?.toJson(),
      'case_Service_Notes':
          caseServiceNotes?.map((x) => x.toJson()).toList(),
    };
  }
}

class CaseServiceNote {
  final int caseServiceNotesId;

  final String? notes;

  final int? caseServiceId;

  CaseServiceNote({
    required this.caseServiceNotesId,
    required this.notes,
    required this.caseServiceId,
  });

  factory CaseServiceNote.fromJson(
    Map<String, dynamic> json,
  ) {
    return CaseServiceNote(
      caseServiceNotesId:
          json['case_ServiceNotesId'] ?? 0,

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

  factory ServiceModel1.fromJson(
    Map<String, dynamic> json,
  ) {
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