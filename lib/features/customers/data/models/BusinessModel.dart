class BusinessModel {
  final int businessId;
  final String businessName;

  BusinessModel({
    required this.businessId,
    required this.businessName,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: json['business_id'],
      businessName: json['business_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'business_name': businessName,
    };
  }
}