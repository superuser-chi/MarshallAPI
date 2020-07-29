import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/models/kombi.dart';

Future<List<Kombi>> fetchKombis(http.Client client) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/kombis');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseKombis, response.body);
}
Future<List<Kombi>> fetchKombisByRoute(http.Client client, String id) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/kombis/byroute?id=$id');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseKombis, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Kombi> parseKombis(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Kombi>((json) => Kombi.fromJson(json)).toList();
}

Future<Kombi> addKombi({String userId, String plate}) async {
  final reponse = await http.post(
    'https://marshalapi.herokuapp.com/api/kombis',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{"userId": userId, "plate": plate}),
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Kombi.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not add kombi with plate $plate");
  }
}

Future<Kombi> deleteKombi(Kombi kombi) async{
final reponse = await http.delete(
    'https://marshalapi.herokuapp.com/api/kombis/${kombi.kombiId}',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Kombi.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not delete kombi with plate ${kombi.plate}");
  }
}
Future<Kombi> editKombi(Kombi kombi) async{
final reponse = await http.put(
    'https://marshalapi.herokuapp.com/api/kombis/${kombi.kombiId}',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(kombi.toJson()),
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Kombi.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not delete kombi with plate ${kombi.plate}");
  }
}
