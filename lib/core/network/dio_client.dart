import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  late Dio dio;
  final Logger logger = Logger();
  final TokenService tokenService;
  DioClient(this.tokenService) {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://apxapi.somee.com/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = tokenService.token;

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          // 🟢 LOG REQUEST
          logger.i("➡️ REQUEST");
          logger.i("URL: ${options.uri}");
          logger.i("METHOD: ${options.method}");
          logger.i("HEADERS: ${options.headers}");
          logger.i("DATA: ${options.data}");

          handler.next(options);
        },

        onResponse: (response, handler) {
          // 🔵 LOG RESPONSE
          logger.i("✅ RESPONSE");
          logger.i("URL: ${response.requestOptions.uri}");
          logger.i("STATUS: ${response.statusCode}");
          logger.i("DATA: ${response.data}");

          handler.next(response);
        },

        onError: (DioException e, handler) {
          // 🔴 LOG ERROR
          logger.e("❌ ERROR");
          logger.e("URL: ${e.requestOptions.uri}");
          logger.e("MESSAGE: ${e.message}");
          logger.e("STATUS: ${e.response?.statusCode}");
          logger.e("DATA: ${e.response?.data}");

          handler.next(e);
        },
      ),
    );
  }
}
