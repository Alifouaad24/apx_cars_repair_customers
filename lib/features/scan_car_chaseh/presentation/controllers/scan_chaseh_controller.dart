import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ScanChasehController extends GetxController {
  final DioClient _client;

  ScanChasehController(this._client);

  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic> carData = <String, dynamic>{};
  String lastScannedValue = '';
  String lastScanType = '';

  // Update this path if backend uses a different route.
  static const String _scanEndpoint = '/CarsInfo';

  Future<bool> requestDetailsFromScan({
    required String scannedValue,
  }) async {
    final cleaned = scannedValue.trim();
    if (cleaned.isEmpty) {
      errorMessage = 'Scanned value is empty';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = '';
    update();

    try {
      final response = await _client.dio.get(
        _scanEndpoint,
        queryParameters: {'chaseh': cleaned},
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        carData = Map<String, dynamic>.from(data);
      } else {
        carData = {'result': data};
      }
      update();

      return true;
    } on DioException catch (e) {
      errorMessage =
          e.response?.data?.toString() ??
          e.message ??
          'Failed to fetch car details';
      update();
      return false;
    } catch (_) {
      errorMessage = 'Failed to fetch car details';
      update();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
