class AssignTypeModel {
  final int? assignTypeId;
  final String? type;

  AssignTypeModel({
    this.assignTypeId,
    this.type,
  });

  factory AssignTypeModel.fromJson(Map<String, dynamic> json) {
    return AssignTypeModel(
      assignTypeId: json['assign_typeId'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assign_typeId': assignTypeId,
      'type': type,
    };
  }
}