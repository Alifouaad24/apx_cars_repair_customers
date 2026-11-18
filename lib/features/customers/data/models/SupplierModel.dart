class SupplierFilterModel {
  final int supplierId;
  final BusinessFilterModel providerBusiness;
  final BusinessFilterModel consumerBusiness;
  final ServiceFilterModel service;

  SupplierFilterModel({
    required this.supplierId,
    required this.providerBusiness,
    required this.consumerBusiness,
    required this.service,
  });

  factory SupplierFilterModel.fromJson(Map<String, dynamic> json) {
    return SupplierFilterModel(
      supplierId: json['supplierId'] ?? 0,
      providerBusiness: BusinessFilterModel.fromJson(
        json['providerBusiness'] ?? {},
      ),
      consumerBusiness: BusinessFilterModel.fromJson(
        json['consumerBusiness'] ?? {},
      ),
      service: ServiceFilterModel.fromJson(
        json['service'] ?? {},
      ),
    );
  }
}

class BusinessFilterModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  BusinessFilterModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
  });

  factory BusinessFilterModel.fromJson(Map<String, dynamic> json) {
    return BusinessFilterModel(
      id: json['business_id'] ?? 0,
      name: json['business_name'] ?? '',
      email: json['business_email'] ?? '',
      phone: (json['business_phone'] ?? json['phone'] ?? '').toString(),
      address: (json['business_address'] ?? json['address'] ?? '').toString(),
    );
  }
}

class ServiceFilterModel {
  final int id;
  final String name;

  ServiceFilterModel({
    required this.id,
    required this.name,
  });

  factory ServiceFilterModel.fromJson(Map<String, dynamic> json) {
    return ServiceFilterModel(
      id: json['service_id'] ?? 0,
      name: json['description'] ?? '',
    );
  }
}