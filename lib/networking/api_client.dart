import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'token_store.dart';

/// Fires `true` whenever any API call is rejected with HTTP 401 so the app
/// shell can return to the login screen. Consumption only, never set freely.
final ValueNotifier<bool> authExpired = ValueNotifier<bool>(false);

class ApiClient {
  ApiClient({TokenStore? tokenStore})
    : _tokenStore = tokenStore ?? TokenStore(),
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(_AuthInterceptor(_tokenStore));
  }

  final Dio _dio;
  final TokenStore _tokenStore;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (options.method == 'POST' || options.method == 'PUT') {
      options.headers['Content-Type'] = 'application/json';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _tokenStore.clear();
      authExpired.value = true;
    }
    handler.next(err);
  }
}
