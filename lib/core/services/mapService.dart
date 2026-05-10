import 'package:dio/dio.dart';

class AddressSearchService {
  final Dio dio = Dio();

  Future<List<dynamic>> searchAddress(String query) async {
    if (query.trim().length < 2) return [];

    final response = await dio.get(
      "https://nominatim.openstreetmap.org/search",
      queryParameters: {
        "q": query.trim(),
        "format": "jsonv2",
        "addressdetails": 1,
        "limit": 10,
      },
      options: Options(
        headers: {"User-Agent": "ApxCarsRepair/1.0 (alifouaad24@gmail.com)"},
      ),
    );

    return response.data;
  }
}
