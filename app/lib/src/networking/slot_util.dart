import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rank_marshal/src/models/day.dart';
import 'package:rank_marshal/src/models/slot.dart';

Future<List<Slot>> fetchSlots(http.Client client) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/slots');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseSlots, response.body);
}

Future<List<Slot>> fetchSlotsByRoute(http.Client client, String routeId) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/slots/byroute?id=$routeId');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseSlots, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Slot> parseSlots(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Slot>((json) => Slot.fromJson(json)).toList();
}
Future<List<Day>> fetchDays(http.Client client) async {
  final response =
      await client.get('https://marshalapi.herokuapp.com/api/slots/days');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseDays, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Day> parseDays(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Day>((json) => Day.fromJson(json)).toList();
}

Future<Slot> addSlot({String kombiId, String routeId, String dayId, String time}) async {
  final reponse = await http.post(
    'https://marshalapi.herokuapp.com/api/Slots',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{"kombiId": kombiId, 
            "routeId": routeId, "dayId": dayId, "time": time}),
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Slot.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not add Slot");
  }
}

Future<Slot> deleteSlot(Slot slot) async{
final reponse = await http.delete(
    'https://marshalapi.herokuapp.com/api/Slots/${slot.slotId}',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Slot.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not delete ${slot}");
  }
}
Future<Slot> editSlot(Slot slot) async{
final reponse = await http.put(
    'https://marshalapi.herokuapp.com/api/Slots/${slot.slotId}',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(slot.toJson()),
  );
  if (reponse.statusCode == 200 || reponse.statusCode == 201 ) {
    return Slot.fromJson(json.decode(reponse.body));
  } else {
    throw Exception("Could not delete $slot");
  }
}
