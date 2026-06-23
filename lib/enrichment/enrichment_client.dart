import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import 'enrichment_models.dart';

class EnrichmentException implements Exception {
  EnrichmentException(this.message);
  final String message;
  @override
  String toString() => 'EnrichmentException: $message';
}

/// HTTP client for the LAN enrichment service (`/health`, `/enrich`), with a
/// retry interceptor for transient network failures.
class EnrichmentClient {
  EnrichmentClient(this.baseUrl)
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 60),
            // librosa + ONNX can take a few seconds per track.
            receiveTimeout: const Duration(seconds: 120),
          ),
        ) {
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 2,
        retryDelays: const [Duration(seconds: 1), Duration(seconds: 3)],
      ),
    );
  }

  final String baseUrl;
  final Dio _dio;

  /// Whether the service answers `/health` (used to gate enrichment when the
  /// PC is unreachable — the app then stays fully offline).
  Future<bool> ping() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Upload one audio file for enrichment. Throws [EnrichmentException] on
  /// transport/parse failure so callers can leave the song un-enriched.
  Future<EnrichmentResult> enrichFile(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    String? genre,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'title': ?title,
        'artist': ?artist,
        'album': ?album,
        'genre': ?genre,
      });
      final resp = await _dio.post<Map<String, dynamic>>('/enrich', data: form);
      final data = resp.data;
      if (data == null) {
        throw EnrichmentException('empty response from /enrich');
      }
      return EnrichmentResult.fromJson(data);
    } on DioException catch (e) {
      throw EnrichmentException(e.message ?? e.toString());
    }
  }

  void close() => _dio.close(force: true);
}
