import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:infinite_example/remote/item.dart';
import 'package:http/http.dart' as http;

class RemoteApi {
  static Future<List<Photo>> getPhotos(
    int page, {
    int limit = 20,
    String? search,
  }) {
    if (Random().nextInt(10) == 0) {
      throw RandomChanceException();
    }

    return http
        .get(
          _ApiUrlBuilder.photos(page, limit, search),
        )
        .mapFromResponse<List<Photo>, List<dynamic>>(
          (jsonArray) => _parseItemListFromJsonArray(
            jsonArray,
            Photo.fromPlaceholderJson,
          ),
        );
  }

  static List<T> _parseItemListFromJsonArray<T>(
    List<dynamic> jsonArray,
    T Function(dynamic object) mapper,
  ) =>
      jsonArray.map(mapper).toList();
}

class GenericHttpException implements Exception {
  const GenericHttpException({
    this.message,
    this.statusCode,
  });

  final String? message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode != null) {
      return 'HTTP $statusCode: $message';
    } else {
      return message ?? 'Unknown error';
    }
  }
}

class NoConnectionException implements Exception {
  @override
  String toString() => 'No connection';
}

class RandomChanceException implements Exception {
  @override
  String toString() => 'Random chance';
}

class _ApiUrlBuilder {
  static const _baseUrl = 'jsonplaceholder.typicode.com';
  static const _photosResource = 'photos';

  static Uri photos(int page, int limit, String? search) => Uri(
        scheme: 'https',
        host: _baseUrl,
        path: '/$_photosResource',
        queryParameters: {
          '_start': '${(page - 1) * limit}',
          '_limit': limit.toString(),
          'q': search,
        },
      );
}

extension on Future<http.Response> {
  Future<R> mapFromResponse<R, T>(R Function(T) jsonParser) async {
    try {
      final response = await this;
      if (response.statusCode == 200) {
        return jsonParser(jsonDecode(response.body));
      } else {
        throw GenericHttpException(
          message: response.reasonPhrase,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NoConnectionException();
    } on Object catch (e, s) {
      Zone.current.handleUncaughtError(e, s);
      rethrow;
    }
  }
}
