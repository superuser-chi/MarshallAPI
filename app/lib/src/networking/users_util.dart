import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/models/user.dart';


Future<List<User>> fetchUsers(http.Client client) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/users');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseUsers, response.body);
}

// A function that converts a response body into a List<Photo>.
List<User> parseUsers(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}
Future<User> login(String username, String password) async {
  final reponse = await http.post(
    'https://marshalapi.herokuapp.com/api/Users/Login',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{"username": username, "password": password}),
  );
  if (reponse.statusCode == 200) {
    return User.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not log user $username with password: $password ");
  }
}

Future<User> register(
    {String username,
    String password,
    String phoneNumber,
    String firstname,
    String lastname,
    String routeId}) async {
  final reponse = await http.post(
    'https://marshalapi.herokuapp.com/api/Users/register',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "username": username,
      "password": password,
      "routeId": routeId,
      "phoneNumber": phoneNumber,
      "firstname": firstname,
      "lastname": lastname
    }),
  );
  if (reponse.statusCode == 200) {
    return User.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not log user $username with password: $password ");
  }
}
