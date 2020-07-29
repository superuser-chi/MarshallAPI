import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/models/route.dart';

Future<List<KombiRoute>> fetchRoutes(http.Client client) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/Routes');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseRoutes, response.body);
}

// A function that converts a response body into a List<Photo>.
List<KombiRoute> parseRoutes(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<KombiRoute>((json) => KombiRoute.fromJson(json)).toList();
}
