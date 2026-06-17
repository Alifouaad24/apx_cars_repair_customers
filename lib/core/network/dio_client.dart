import 'dart:io';

import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DioClient {
  late Dio dio;
  final Logger logger = Logger();
  final TokenService tokenService;
  DioClient(this.tokenService) {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://apxapi.somee.com/api",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // ⚠️ مؤقّت للتطوير فقط: سيرفر somee لا يرسل سلسلة الشهادة كاملة،
    // فنتجاوز التحقق من شهادة SSL. أزل هذا قبل الإطلاق للـ production.
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
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

          if (kDebugMode) {
            logger.i("➡️ ${options.method} ${options.uri}"
                "${options.data != null ? "\nDATA: ${options.data}" : ""}");
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            logger.i("✅ ${response.statusCode} ${response.requestOptions.uri}"
                "\nDATA: ${response.data}");
          }
          handler.next(response);
        },

        onError: (DioException e, handler) {
          if (kDebugMode) {
            logger.e("❌ ${e.type} ${e.requestOptions.uri}"
                "\nSTATUS: ${e.response?.statusCode}"
                "\nMESSAGE: ${e.message}"
                "\nERROR: ${e.error}"
                "\nDATA: ${e.response?.data}");
          }
          handler.next(e);
        },
      ),
    );
  }
}
