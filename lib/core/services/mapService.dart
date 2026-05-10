// import 'package:dio/dio.dart';

// class AddressSearchService {
//   final Dio dio = Dio();

//   Future<List<dynamic>> searchAddress(String query) async {
//     if (query.trim().length < 2) return [];

//     final response = await dio.get(
//       "https://nominatim.openstreetmap.org/search",
//       queryParameters: {
//         "q": query.trim(),
//         "format": "jsonv2",
//         "addressdetails": 1,
//         "limit": 10,
//       },
//       options: Options(
//         headers: {"User-Agent": "ApxCarsRepair/1.0 (alifouaad24@gmail.com)"},
//       ),
//     );

//     return response.data;
//   }
// }

import 'package:dio/dio.dart';

class AddressSearchService {
  final Dio dio = Dio();

  final String apiKey = "AIzaSyDmfqkmgv8liZLw7tHg6R_Etl3B6fnRAE8";

  Future<List<dynamic>> searchAddress(String query) async {
    if (query.trim().length < 2) return [];

    final response = await dio.get(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      queryParameters: {
        "input": query,
        "types": "address",
        "components": "country:us",
        "key": apiKey,
      },
    );

    return response.data["predictions"];
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final response = await dio.get(
      "https://maps.googleapis.com/maps/api/place/details/json",
      queryParameters: {"place_id": placeId, "key": apiKey},
    );

    final result = response.data["result"];

    final components = result["address_components"] as List;

    print(components);

    String streetNumber = '';
    String route = '';
    String city = '';
    String state = '';
    String postalCode = '';
    String country = '';

    for (final c in components) {
      final types = List<String>.from(c["types"]);

      if (types.contains("street_number")) {
        streetNumber = c["long_name"];
      }

      if (types.contains("route")) {
        route = c["long_name"];
      }

      if (types.contains("locality")) {
        city = c["long_name"];
      }

      if (types.contains("administrative_area_level_1")) {
        state = c["short_name"];
      }

      if (types.contains("postal_code")) {
        postalCode = c["long_name"];
      }

      if (types.contains("country")) {
        country = c["long_name"];
      }
    }

    final line1 = "${streetNumber.isNotEmpty ? "$streetNumber " : ""}$route";

    final line2 =
        "${city.isNotEmpty ? city : ""}"
        "${state.isNotEmpty ? ", $state" : ""}"
        "${country.isNotEmpty ? ", $country" : ""}";

    return {
      "line1": "${streetNumber.isNotEmpty ? "$streetNumber " : ""}$route",

      "line2":
          "${city.isNotEmpty ? city : ""}"
          "${state.isNotEmpty ? ", $state" : ""}"
          "${country.isNotEmpty ? ", $country" : ""}",

      "postalCode": postalCode,
      "city": city,
      "state": state,
      "country": country,
      "streetNumber": streetNumber,

      "location": result["formatted_address"] ?? '',

      "latitude": result["geometry"]?["location"]?["lat"],

      "longitude": result["geometry"]?["location"]?["lng"],

      "fullAddress": result["formatted_address"] ?? '',
    };
  }
}
