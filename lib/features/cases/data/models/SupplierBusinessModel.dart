import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';

class SupplierBusinessModel {
  final int? supplierId;

  final BusinessModel? providerBusiness;
  final int? providerId;

  final BusinessModel? consumerBusiness;
  final int? consumerId;

  final dynamic service;
  final int? serviceId;

  final dynamic platform;
  final dynamic platformId;

  SupplierBusinessModel({
    this.supplierId,
    this.providerBusiness,
    this.providerId,
    this.consumerBusiness,
    this.consumerId,
    this.service,
    this.serviceId,
    this.platform,
    this.platformId,
  });

  factory SupplierBusinessModel.fromJson(Map<String, dynamic> json) {
    return SupplierBusinessModel(
      supplierId: json['supplierId'],

      providerBusiness: json['providerBusiness'] != null
          ? BusinessModel.fromJson(json['providerBusiness'])
          : null,

      providerId: json['providerId'],

      consumerBusiness: json['consumerBusiness'] != null
          ? BusinessModel.fromJson(json['consumerBusiness'])
          : null,

      consumerId: json['consumerId'],

      service: json['service'],
      serviceId: json['serviceId'],

      platform: json['platform'],
      platformId: json['platform_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'providerBusiness': providerBusiness?.toJson(),
      'providerId': providerId,
      'consumerBusiness': consumerBusiness?.toJson(),
      'consumerId': consumerId,
      'service': service,
      'serviceId': serviceId,
      'platform': platform,
      'platform_id': platformId,
    };
  }
}