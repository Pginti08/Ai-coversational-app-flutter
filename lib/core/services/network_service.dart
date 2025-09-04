import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart' as dioClient;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum BaseUrl { base, none }

class MethodType {
  static const String post = 'POST';
  static const String get = 'GET';
  static const String put = 'PUT';
  static const String delete = 'DELETE';
  static const String patch = 'PATCH';
}

class NetworkClient {
  // Singleton instance
  static final NetworkClient instance = NetworkClient._internal();

  // Expose Dio
  late final Dio _dio;

  // Private constructor
  NetworkClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      if (kDebugMode)
        AwesomeDioInterceptor(
          logRequestTimeout: false,
          logResponseHeaders: false,
        ),
    ]);
  }

  // Factory constructor for accessing the singleton
  factory NetworkClient() => instance;

  // Getter to expose Dio instance
  Dio get dio => _dio;

  Future<Result<dioClient.Response<dynamic>>> callApi(
    String endpoint,
    String method, {
    required BaseUrl baseUrlType,
    dynamic params,
    Map<String, dynamic>? headers,
  }) async {
    final fullUrl = _getBaseUrl(baseUrlType) + endpoint;

    // Retrieve access token from storage
    final accessToken = await _getAccessToken();

    // Merge headers with the access token, if available
    final mergedHeaders = {
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      ...?headers,
    };

    final options = Options(method: method, headers: mergedHeaders);

    try {
      final response = await _dio.request(
        fullUrl,
        data: method != MethodType.get ? params : null,
        queryParameters: method == MethodType.get ? params : null,
        options: options,
      );
      return Result.success(response);
    } on DioException catch (dioError) {
      // if (dioError.response?.statusCode == 401) {
      //   await _handleUnauthorized();
      // }
      final errorMessage = _mapDioError(dioError);
      return Result.error(errorMessage);
    } catch (e) {
      return Result.error('Something went wrong');
    }
  }

  String _getBaseUrl(BaseUrl type) {
    switch (type) {
      case BaseUrl.base:
        return ApiConstants.authURL;

      case BaseUrl.none:
        return '';
    }
  }

  // Future<void> _handleUnauthorized() async {
  //   // Clear local storage
  //   await LocalStorageService.instance.clear();
  //   Get.offAllNamed(Routes.login);
  // }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again later.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please check your connection.';
      case DioExceptionType.badResponse:
        final errorData = error.response?.data;
        if (errorData is String) {
          return errorData.toString();
        } else if (errorData is Map<String, dynamic>) {
          if (isNotNullOrEmpty(errorData['message'])) {
            return errorData['message'].toString();
          } else if (isNotNullOrEmpty(errorData['detail'])) {
            final detail = errorData['detail'];
            if (detail is Map<String, dynamic> &&
                isNotNullOrEmpty(detail['errors'])) {
              return detail['errors'].toString();
            } else if (detail is String) {
              return detail;
            }
          }
        }
        return 'Something went wrong';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Something went wrong';
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final token = await LocalStorageService.instance.getString(
        StorageConstants.accessToken,
      );
      return isNotNullOrEmpty(token) ? token : null;
    } catch (e) {
      debugPrint('Error retrieving access token: $e');
      return null;
    }
  }
}

class Result<T> {
  Result._({this.data, this.error});

  factory Result.success(T data) => Result._(data: data);
  factory Result.error(String error) => Result._(error: error);

  final T? data;
  final String? error;

  bool get isSuccess => data != null;
}
