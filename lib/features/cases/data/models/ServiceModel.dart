class ServiceModel {
  final int serviceId;
  final String description;
  final String serviceIcon;
  final String serviceRoute;
  final bool isPublic;
  final List<dynamic> activityServices;
  final List<BusinessServiceModel> businessServices;
  final dynamic caseServices;
  final String insertOn;
  final String? insertBy;
  final bool visible;

  ServiceModel({
    required this.serviceId,
    required this.description,
    required this.serviceIcon,
    required this.serviceRoute,
    required this.isPublic,
    required this.activityServices,
    required this.businessServices,
    required this.caseServices,
    required this.insertOn,
    required this.insertBy,
    required this.visible,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] ?? 0,
      description: json['description'] ?? '',
      serviceIcon: json['service_icon'] ?? '',
      serviceRoute: json['service_Route'] ?? '',
      isPublic: json['isPublic'] ?? false,
      activityServices: json['activity_Services'] ?? [],
      businessServices: json['business_Services'] != null
          ? List<BusinessServiceModel>.from(
              json['business_Services']
                  .map((x) => BusinessServiceModel.fromJson(x)),
            )
          : [],
      caseServices: json['case_Services'],
      insertOn: json['insert_on'] ?? '',
      insertBy: json['insert_by'],
      visible: json['visible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'description': description,
      'service_icon': serviceIcon,
      'service_Route': serviceRoute,
      'isPublic': isPublic,
      'activity_Services': activityServices,
      'business_Services':
          businessServices.map((x) => x.toJson()).toList(),
      'case_Services': caseServices,
      'insert_on': insertOn,
      'insert_by': insertBy,
      'visible': visible,
    };
  }
}

class BusinessServiceModel {
  final int businessId;
  final int serviceId;

  BusinessServiceModel({
    required this.businessId,
    required this.serviceId,
  });

  factory BusinessServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BusinessServiceModel(
      businessId: json['business_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'service_id': serviceId,
    };
  }
}