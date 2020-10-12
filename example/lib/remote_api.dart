import 'dart:convert';
import 'dart:io';

import 'package:breaking_bapp/character_summary.dart';
import 'package:http/http.dart' as http;

class RemoteApi {
  static Future<List<CharacterSummary>> getCharacterList(
    int offset,
    int limit, {
    String searchTerm,
  }) async =>
      http
          .get(
            _ApiUrlBuilder.characterList(offset, limit, searchTerm: searchTerm),
          )
          .mapFromResponse(
            (jsonArray) => _parseItemListFromJsonArray(
              jsonArray,
              (jsonObject) => CharacterSummary.fromJson(jsonObject),
            ),
          );

  static List<T> _parseItemListFromJsonArray<T>(
    List<dynamic> jsonArray,
    T Function(dynamic object) mapper,
  ) =>
      jsonArray.map(mapper).toList();
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}

class _ApiUrlBuilder {
  static const _baseUrl = 'https://www.breakingbadapi.com/api/';
  static const _charactersResource = 'characters/';

  static String characterList(
    int offset,
    int limit, {
    String searchTerm,
  }) =>
      '$_baseUrl$_charactersResource?'
      'offset=$offset'
      '&limit=$limit'
      '${_buildSearchTermQuery(searchTerm)}';

  static String _buildSearchTermQuery(String searchTerm) =>
      searchTerm?.isEmpty == false
          ? '&name=${searchTerm.replaceAll(' ', '+').toLowerCase()}'
          : '';
}

extension on Future<http.Response> {
  Future<R> mapFromResponse<R, T>(R Function(T) jsonParser) async {
    try {
      final response = await this;
      if (response.statusCode == 200) {
        return jsonParser(jsonDecode(response.body));
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}
