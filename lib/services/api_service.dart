import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  /// Sends URL + query to backend and returns list of extracted data objects
  static Future<List<Map<String, dynamic>>> extractData({
    required String url,
    required String query,
  }) async {
    final uri = Uri.parse('$_baseUrl/extract');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url, 'query': query}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final rawData = decoded['data'];

      if (rawData is List) {
        return rawData.map<Map<String, dynamic>>((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return {'value': item.toString()};
        }).toList();
      } else if (rawData is Map) {
        return [Map<String, dynamic>.from(rawData)];
      } else {
        return [{'result': rawData.toString()}];
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Unknown server error');
    }
  }

  /// Checks if the backend is reachable
  static Future<bool> isBackendReachable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
