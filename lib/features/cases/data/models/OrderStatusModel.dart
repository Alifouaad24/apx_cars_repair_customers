class OrderStatusModel {
  final int orderStatusId;
  final String statusAr;
  final String statusEn;

  OrderStatusModel({
    required this.orderStatusId,
    required this.statusAr,
    required this.statusEn,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      orderStatusId: json['orderStatusId'],
      statusAr: json['statusAr'],
      statusEn: json['statusEn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderStatusId': orderStatusId,
      'statusAr': statusAr,
      'statusEn': statusEn,
    };
  }
}