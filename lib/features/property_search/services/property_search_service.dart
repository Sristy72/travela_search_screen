import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/property_item_model.dart';
import '../models/search_filter_model.dart';

class SseEvent {
  final String event;
  final dynamic data;

  SseEvent({required this.event, required this.data});
}

class PropertySearchService {
  static const String baseUrl = 'https://search.travela.xyz/api';

  /// Fetches popular locations matching [query]
  Future<List<LocationModel>> fetchPopularLocations({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/popular-locations').replace(
        queryParameters: query != null && query.trim().isNotEmpty
            ? {'q': query.trim()}
            : null,
      );

      debugPrint('🌐 [API REQUEST] GET $uri');

      final response = await http.get(uri);
      debugPrint('📩 [API RESPONSE ${response.statusCode}] $uri');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as List<dynamic>? ?? [];
        debugPrint('✅ [API SUCCESS] Loaded ${data.length} locations');
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => LocationModel.fromJson(json))
            .toList();
      } else {
        debugPrint('❌ [API ERROR ${response.statusCode}] ${response.body}');
        throw Exception('Failed to load locations (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('💥 [API EXCEPTION] Error fetching popular locations: $e');
      rethrow;
    }
  }

  /// Streams property search results line-by-line via SSE.
  /// Returns an [http.Client] so caller can cancel/close the connection.
  http.Client streamSearchResults({
    required SearchFilterModel filter,
    required Function(SseEvent event) onEvent,
    Function(Object error)? onError,
    Function()? onDone,
  }) {
    final client = http.Client();
    final queryParams = filter.toQueryParams();
    final uri = Uri.parse('$baseUrl/search/stream').replace(queryParameters: queryParams);

    debugPrint('🌐 [API STREAM REQUEST] GET $uri');

    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    client.send(request).then((response) {
      debugPrint('📡 [API STREAM CONNECTED ${response.statusCode}] $uri');

      if (response.statusCode != 200) {
        debugPrint('❌ [API STREAM ERROR] Server returned status code ${response.statusCode}');
        onError?.call('Server returned status code ${response.statusCode}');
        client.close();
        return;
      }

      String? currentEvent;
      final StringBuffer dataBuffer = StringBuffer();

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            // End of SSE frame dispatch event if ready
            if (currentEvent != null && dataBuffer.isNotEmpty) {
              _dispatchSseEvent(currentEvent!, dataBuffer.toString(), onEvent, onError);
              currentEvent = null;
              dataBuffer.clear();
            }
            return;
          }

          if (trimmed.startsWith('event:')) {
            // Dispatch previous event if there's any pending
            if (currentEvent != null && dataBuffer.isNotEmpty) {
              _dispatchSseEvent(currentEvent!, dataBuffer.toString(), onEvent, onError);
              dataBuffer.clear();
            }
            currentEvent = trimmed.substring(6).trim();
          } else if (trimmed.startsWith('data:')) {
            final dataContent = trimmed.substring(5).trim();
            if (dataBuffer.isNotEmpty) {
              dataBuffer.write('\n');
            }
            dataBuffer.write(dataContent);
          }
        },
        onError: (error) {
          debugPrint('💥 [API STREAM ERROR] $error');
          onError?.call(error);
        },
        onDone: () {
          // Flush final pending frame if present
          if (currentEvent != null && dataBuffer.isNotEmpty) {
            _dispatchSseEvent(currentEvent!, dataBuffer.toString(), onEvent, onError);
          }
          debugPrint('🏁 [API STREAM COMPLETED] $uri');
          onDone?.call();
          client.close();
        },
        cancelOnError: true,
      );
    }).catchError((error) {
      debugPrint('💥 [API STREAM CONNECTION EXCEPTION] $error');
      onError?.call(error);
      client.close();
    });

    return client;
  }

  void _dispatchSseEvent(
    String event,
    String rawData,
    Function(SseEvent event) onEvent,
    Function(Object error)? onError,
  ) {
    try {
      final decodedData = jsonDecode(rawData);
      debugPrint('⚡ [SSE EVENT DISPATCHED] Event: "$event"');
      onEvent(SseEvent(event: event, data: decodedData));
    } catch (e) {
      debugPrint('⚠️ [SSE PARSE ERROR] Event: "$event" | Error: $e');
      onError?.call('Failed to parse event data: $e');
    }
  }

  /// Fetches next page of property search results using [nextUrl] from pagination meta
  Future<List<PropertyItemModel>> fetchNextPage(String nextUrl) async {
    try {
      final uri = Uri.parse(nextUrl);
      debugPrint('🌐 [API LOAD MORE REQUEST] GET $uri');
      final response = await http.get(uri);
      debugPrint('📩 [API LOAD MORE RESPONSE ${response.statusCode}] $uri');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as List<dynamic>? ?? [];
        debugPrint('✅ [API LOAD MORE SUCCESS] Loaded ${data.length} additional properties');
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => PropertyItemModel.fromJson(json))
            .toList();
      } else {
        debugPrint('❌ [API LOAD MORE ERROR ${response.statusCode}] ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 [API LOAD MORE EXCEPTION] $e');
    }
    return [];
  }
}
