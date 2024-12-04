import 'dart:convert';
import 'package:http/http.dart' as http;

class StoreService {
  /// Fetches the zone ID based on latitude and longitude.
  /// Returns the first zone ID in the list if available.
  static const String baseZoneUrl =
      'https://nearbiie.com/api/v1/config/get-zone-id';
  static const String baseStoresUrl =
      'https://nearbiie.com/api/v1/stores/latest';
  static const String baseStoresSearchUrl =
      'https://nearbiie.com/api/v1/stores/search';

  Future<int?> fetchZoneId(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
          'https://nearbiie.com/api/v1/config/get-zone-id?lat=$latitude&lng=$longitude'),
      headers: {'X-localization': 'en'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final zoneIdList = json.decode(data['zone_id']);
      return 1;
      // return zoneIdList.isNotEmpty ? zoneIdList[0] : null;
    } else {
      throw Exception('Failed to fetch zone ID');
    }
  }

  /// Fetches a paginated list of stores for the specified zone ID.
  Future<Map<String, dynamic>> fetchStores({
    required int zoneId,
    required int limit,
    required int offset,
  }) async {
    try {
      print("Fetching stores API called...");
      print("Zone ID: $zoneId, Limit: $limit, Offset: $offset");

      final Uri uri = Uri.parse(
        'https://nearbiie.com/api/v1/stores/latest?type=all',
      );

      // Set up the headers for the request
      final Map<String, String> headers = {
        'zoneId': '[$zoneId]',
        'moduleId': "1",
        'X-localization': 'en',
        'limit': '$limit', // Adding limit as header
        'offset': '$offset', // Adding offset as header
      };

      // Make the HTTP request
      final response = await http.get(
        uri,
        headers: headers,
      );

      // Print the response status code
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("API call successful. Parsing response...");
        final data = json.decode(response.body);
        print("Parsed response data: $data");

        return {
          'stores': data['stores'] ?? [],
          'total_size': data['total_size'] ?? 0,
        };
      } else {
        print("Failed API request: ${response.body}");
        print("Request URL: '$uri'");
        throw Exception('Failed to fetch stores');
      }
    } catch (e) {
      print("Error fetching stores: $e");
      throw Exception('Error fetching stores: $e');
    }
  }

  /// Searches for stores based on the name query.
  Future<Map<String, dynamic>> searchStores(
      {required String name, required int zoneId}) async {
    try {
      if (name.length < 2) {
        return {
          'stores': [],
          'total_size': 0
        }; // Do not call API if less than 2 chars
      }
      print("Searching stores API called...");
      print("Name: $name, Zone ID: $zoneId");

      // Construct the URL with the search query and other parameters
      final Uri uri = Uri.parse(
        '$baseStoresSearchUrl?name=$name',
      );

      print("Request URL: $uri");

      // Set up the headers for the request
      final Map<String, String> headers = {
        'zoneId': '[$zoneId]',
        'moduleId': "1",
        'X-localization': 'en'
      };

      // Print the curl-like request for debugging
      print("Curl command:");
      print('curl --location "$uri"');
      headers.forEach((key, value) {
        print("--header '$key: $value'");
      });

      // Make the HTTP request
      final response = await http.get(
        uri,
        headers: headers,
      );

      // Print the response status code
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("API call successful. Parsing response...");
        final data = json.decode(response.body);
        print("Parsed response data: $data");

        return {
          'stores': data['stores'] ?? [],
          'total_size': data['total_size'] ?? 0,
        };
      } else {
        print("Failed API request: ${response.body}");
        print("Request URL: '$uri'");
        throw Exception('Failed to search stores');
      }
    } catch (e) {
      print("Error searching stores: $e");
      throw Exception('Error searching stores: $e');
    }
  }
}
