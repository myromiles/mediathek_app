import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/mediathek_item.dart';

class MediathekService {
  static const String _directApiUrl = 'https://mediathekviewweb.de/api/query';
  static const String _proxyUrl = 'http://localhost:7000/api/mediathek';

  /// Bekannte deutsche öffentlich-rechtliche Sender
  static const List<String> availableChannels = [
    'Alle',
    'ARD',
    'ZDF',
    'Arte',
    '3sat',
    'KiKa',
    'BR',
    'MDR',
    'NDR',
    'WDR',
    'SWR',
    'HR',
    'RBB',
    'SR',
    'DW',
    'PHOENIX',
    'FUNK',
  ];

  /// Lädt Sendungen von der MediathekViewWeb API
  Future<List<MediathekItem>> fetchItems({
    String query = '',
    String channel = 'Alle',
    int size = 30,
    int offset = 0,
  }) async {
    if (kIsWeb) {
      return await _fetchViaProxy(query: query, channel: channel, size: size);
    } else {
      return await _fetchDirect(
        query: query,
        channel: channel,
        size: size,
        offset: offset,
      );
    }
  }

  /// Lädt Sendungen für eine spezifische Haupt- und Unterkategorie
  Future<List<MediathekItem>> fetchCategoryItems({
    required MediathekCategory category,
    String subcategory = '',
    String channel = 'Alle',
    int size = 30,
  }) async {
    String searchQuery = '';

    if (subcategory.isNotEmpty && !subcategory.toLowerCase().startsWith('alle')) {
      searchQuery = subcategory;
    } else {
      searchQuery = category.searchTerms.isNotEmpty ? category.searchTerms.first : '';
    }

    return await fetchItems(
      query: searchQuery,
      channel: channel,
      size: size,
    );
  }

  /// Lädt parallel Sendungen für die Startseiten-Kategorien (wie ARD/ZDF Homepage)
  Future<Map<MediathekCategory, List<MediathekItem>>> fetchCategorySections({
    String channel = 'Alle',
  }) async {
    final Map<MediathekCategory, List<MediathekItem>> sections = {};

    final mainCats = MediathekCategory.categories
        .where((c) => c.id != 'all')
        .toList();

    final results = await Future.wait(
      mainCats.map((cat) async {
        try {
          final items = await fetchCategoryItems(
            category: cat,
            channel: channel,
            size: 10,
          );
          return MapEntry(cat, items);
        } catch (_) {
          return MapEntry(cat, <MediathekItem>[]);
        }
      }),
    );

    for (final entry in results) {
      if (entry.value.isNotEmpty) {
        sections[entry.key] = entry.value;
      }
    }

    return sections;
  }

  Future<List<MediathekItem>> _fetchViaProxy({
    required String query,
    required String channel,
    required int size,
  }) async {
    try {
      final uri = Uri.parse(_proxyUrl).replace(queryParameters: {
        'q': query.trim(),
        'channel': channel,
        'size': size.toString(),
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
        List rawResults = decoded['result']?['results'] ?? [];
        return rawResults
            .map((item) => MediathekItem.fromJson(item))
            .where((item) => item.bestVideoUrl.isNotEmpty)
            .toList();
      } else {
        throw Exception('Proxy-Server Fehler (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Proxy-Verbindungsfehler: Stelle sicher, dass der Server läuft. ($e)');
    }
  }

  Future<List<MediathekItem>> _fetchDirect({
    required String query,
    required String channel,
    required int size,
    required int offset,
  }) async {
    final List<Map<String, dynamic>> queries = [];

    final cleanQuery = query.trim();
    if (cleanQuery.isNotEmpty) {
      queries.add({
        'fields': ['title', 'topic'],
        'query': cleanQuery,
      });
    }

    if (channel.isNotEmpty && channel != 'Alle') {
      queries.add({
        'fields': ['channel'],
        'query': channel,
      });
    }

    final body = {
      'queries': queries,
      'sortBy': 'timestamp',
      'sortOrder': 'desc',
      'future': false,
      'offset': offset,
      'size': size,
    };

    final response = await http.post(
      Uri.parse(_directApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
      List rawResults = [];

      if (decoded['result'] is Map && decoded['result']['results'] is List) {
        rawResults = decoded['result']['results'];
      } else if (decoded['results'] is List) {
        rawResults = decoded['results'];
      }

      return rawResults
          .map((item) => MediathekItem.fromJson(item))
          .where((item) => item.bestVideoUrl.isNotEmpty)
          .toList();
    } else {
      throw Exception('Server-Fehler (${response.statusCode})');
    }
  }
}
