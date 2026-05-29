import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'logging_interceptor.dart';

/// 공용 [Dio] 인스턴스 팩토리.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }

    return dio;
  }
}
