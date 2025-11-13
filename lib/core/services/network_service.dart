import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart' as dioClient;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum BaseUrl { base, chat, none }

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
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response != null) {
            // Handle 401 Unauthorized - Token Refresh
            if ((e.response?.statusCode == 401 ||
                    e.response?.statusCode == 403) &&
                (e.response?.data["error"].toString().toLowerCase() ==
                        "access token has expired" ||
                    e.response?.data["error"].toString().toLowerCase() ==
                        "invalid or expired token")) {
              // Skip refresh if it's the refresh endpoint itself
              if (e.requestOptions.path.contains(ApiConstants.refreshToken)) {
                await _clearStorageAndLogout();
                return handler.next(e);
              }

              // Attempt to refresh the access token
              final refreshSuccess = await _refreshAccessToken();

              if (refreshSuccess) {
                // Get the new access token
                final newAccessToken = await LocalStorageService.instance
                    .getString(StorageConstants.accessToken);

                // Update the request header with the new access token
                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                // Retry the original request with the updated header
                return handler.resolve(await _dio.fetch(e.requestOptions));
              } else {
                // Refresh failed, logout user
                await _clearStorageAndLogout();
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
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
    ResponseType? responseType, // Add this parameter
  }) async {
    final fullUrl = _getBaseUrl(baseUrlType) + endpoint;

    final accessToken = await _getAccessToken();

    final mergedHeaders = {
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      ...?headers,
    };

    final options = Options(
      method: method,
      headers: mergedHeaders,
      responseType: responseType ??
          ResponseType.json, // Use provided type or default to JSON
    );

    try {
      final response = await _dio.request(
        fullUrl,
        data: method != MethodType.get ? params : null,
        queryParameters: method == MethodType.get ? params : null,
        options: options,
      );
      return Result.success(response);
    } on DioException catch (dioError) {
      final errorMessage = _mapDioError(dioError);
      return Result.error(errorMessage);
    } catch (e) {
      return Result.error('Something went wrong');
    }
  }

  String _getBaseUrl(BaseUrl type) {
    switch (type) {
      case BaseUrl.base:
        return ApiConstants.baseURL;
      case BaseUrl.chat:
        return ApiConstants.chatURL;
      case BaseUrl.none:
        return '';
    }
  }

  Future<bool> _refreshAccessToken() async {
    try {
      // Get refresh token from storage

      // Call refresh token API using the same NetworkClient
      final result = await _callRefreshTokenApi();

      if (result.isSuccess && result.data != null) {
        final data = result.data!.data;

        // Save new access token
        if (isNotNullOrEmpty(data["data"]['token'])) {
          await LocalStorageService.instance.saveString(
            StorageConstants.accessToken,
            data["data"]['token'],
          );
        } else {
          return false;
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Direct API call for refresh token to bypass interceptor
  Future<Result<dioClient.Response<dynamic>>> _callRefreshTokenApi() async {
    final fullUrl = ApiConstants.baseURL + ApiConstants.refreshToken;

    final accessToken = await _getAccessToken();
    try {
      final response = await _dio.post(
        fullUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) {
            // Accept any status code to handle it manually
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        return Result.success(response);
      } else {
        return Result.error('Failed to refresh token');
      }
    } on DioException catch (dioError) {
      final errorMessage = _mapDioError(dioError);
      return Result.error(errorMessage);
    } catch (e) {
      return Result.error('Something went wrong');
    }
  }

  Future<void> _clearStorageAndLogout() async {
    // Clear local storage
    await LocalStorageService.instance.clear();
    Get.offAllNamed(Routes.login);

    debugPrint('Session expired. Please login again.');
  }

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
      final token = await LocalStorageService.instance
          .getString(StorageConstants.accessToken);
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
