class BusinessModel {
  final int businessId;
  final String businessName;

  /// Optional location info — only filled if the API returns it.
  final String? address;
  final double? latitude;
  final double? longitude;

  /// `address_id`s from `businessAddresses`. The /Business API usually sends
  /// only these ids (no address text), so the data source looks them up in
  /// /Address to fill [address] / [latitude] / [longitude].
  final List<int> addressIds;

  BusinessModel({
    required this.businessId,
    required this.businessName,
    this.address,
    this.latitude,
    this.longitude,
    this.addressIds = const [],
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final linked = json['businessAddresses'];
    final linkedList = linked is List ? linked : const [];

    // A nested address object inside businessAddresses, if the API sends one.
    Map? nested;
    for (final e in linkedList) {
      if (e is Map && e['address'] is Map) {
        nested = e['address'] as Map;
        break;
      }
    }

    return BusinessModel(
      businessId: json['business_id'],
      businessName: json['business_name'],
      address: _parseAddress(json) ?? (nested != null ? formatAddress(nested) : null),
      latitude: _parseDouble(
        json['latitude'] ?? json['lat'] ?? nested?['latTute'],
      ),
      longitude: _parseDouble(
        json['longitude'] ?? json['lng'] ?? json['lon'] ?? nested?['lognTute'],
      ),
      addressIds: linkedList
          .whereType<Map>()
          .map((e) => e['address_id'])
          .whereType<int>()
          .toList(),
    );
  }

  BusinessModel copyWith({String? address, double? latitude, double? longitude}) {
    return BusinessModel(
      businessId: businessId,
      businessName: businessName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressIds: addressIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'business_name': businessName,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Joins line_1, line_2, us_City, post_code of an /Address object.
  /// Skips empty parts and Swagger placeholders ("string"). Returns null when
  /// nothing usable is left.
  static String? formatAddress(Map raw) {
    final parts = [
      raw['line_1'],
      raw['line_2'],
      raw['us_City'],
      raw['post_code'],
    ]
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'string')
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Accepts `business_address` / `address` as a plain string, a single
  /// address object, or a list of address objects (line_1, us_City, post_code).
  static String? _parseAddress(Map<String, dynamic> json) {
    dynamic raw = json['business_address'] ?? json['address'];
    if (raw is List) raw = raw.isNotEmpty ? raw.first : null;

    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (raw is Map) return formatAddress(raw);

    return null;
  }
}
