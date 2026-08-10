import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';

class GlobalOrderDetailModel {
  final int globalOrderDetailId;
  final int? serviceId;
  final int? itemId;
  final int? globalOrderId;
  final String? notes;
  final double? cost;
  final double? discount;
  final double? paid;
  final ServiceModel? service;
  final ItemModel? item;
  final List<CaseServiceNotesModel>? caseServiceNotes;

  GlobalOrderDetailModel({
    required this.globalOrderDetailId,
    this.serviceId,
    this.itemId,
    this.globalOrderId,
    this.notes,
    this.cost,
    this.discount,
    this.paid,
    this.service,
    this.item,
    // this.globalOrder,
    this.caseServiceNotes,
  });

  factory GlobalOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return GlobalOrderDetailModel(
      globalOrderDetailId: json['globalOrderDetailId'] ?? 0,
      serviceId: json['service_id'],
      itemId: json['itemId'] ?? 0,
      globalOrderId: json['globalOrderId'],
      notes: json['notes'] ?? '',
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      paid: json['paid'] != null ? (json['paid'] as num).toDouble() : null,

      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,

      item: json['item'] != null ? ItemModel.fromJson(json['item']) : null,

      caseServiceNotes: json['case_Service_Notes'] != null
          ? (json['case_Service_Notes'] as List)
                .map((e) => CaseServiceNotesModel.fromJson(e))
                .toList()
          : null,
    );
  }
}

class ItemModel {
  final int itemId;
  final String? itemDescription;

  ItemModel({required this.itemId, this.itemDescription});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json['itemId'] ?? 0,
      itemDescription: json['itemDescription'],
    );
  }
}

class CaseServiceNotesModel {
  final int caseServiceNotesId;
  final String? notes;
  final int? oredesServicesId;

  CaseServiceNotesModel({
    required this.caseServiceNotesId,
    this.notes,
    this.oredesServicesId,
  });

  factory CaseServiceNotesModel.fromJson(Map<String, dynamic> json) {
    return CaseServiceNotesModel(
      caseServiceNotesId: json['case_ServiceNotesId'] ?? 0,
      notes: json['notes'],
      oredesServicesId: json['oredesServicesId'],
    );
  }
}
