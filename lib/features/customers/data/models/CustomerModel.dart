import '../../domain/entities/Customer.dart';

class CustomerModel {
  final int globalCustomerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final int countryId;
  final int addressId;
  final int businessId;
  final String? imageUrl;

  final AddressModel? address;
  final CountryModel? country;

  CustomerModel({
    required this.globalCustomerId,
    required this.customerName,
    required this.customerMobile,
    required this.countryId,
    required this.addressId,
    required this.businessId,
    required this.customerEmail,
    this.address,
    this.country,
    this.imageUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      globalCustomerId: json['globalCustomerId'],
      customerName: json['customerName'],
      customerMobile: json['customerMobile'],
      customerEmail: json['customerEmail'] ?? "",
      countryId: json['country_id'],
      addressId: json['addressId'],
      businessId: json['business_id'],
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'])
          : null,
      imageUrl: json['customerImage'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "customerMobile": customerMobile,
      "country_id": countryId,
      "addressId": addressId,
      "business_id": businessId,
    };
  }
}

class AddressModel {
  final int addressId;
  final String line1;
  final String line2;
  final int stateId;
  final String postCode;
  final String usCity;
  final String landMark;
  final int countryId;

  AddressModel({
    required this.addressId,
    required this.line1,
    required this.line2,
    required this.stateId,
    required this.postCode,
    required this.usCity,
    required this.landMark,
    required this.countryId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['address_id'],
      line1: json['line_1'],
      line2: json['line_2'] ?? "",
      stateId: json['stateId'] ?? 0,
      postCode: json['post_code'],
      usCity: json['us_City'] ?? "",
      landMark: json['land_Mark'] ?? "",
      countryId: json['countryId'],
    );
  }
}

class CountryModel {
  final int countryId;
  final String name;

  CountryModel({
    required this.countryId,
    required this.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      countryId: json['countryId'],
      name: json['name'],
    );
  }
}

