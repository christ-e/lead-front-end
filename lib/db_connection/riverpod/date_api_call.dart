// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lead_application/model/follow_upDateModel.dart';

// class FollowUpService {
//   static const String baseUrl = 'http://127.0.0.1:8000/api';

//   Future<List<FollowUp>> fetchFollowUps(int leadId) async {
//     final response = await http.get(Uri.parse('$baseUrl/follow-ups/$leadId'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => FollowUp.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load follow-up dates');
//     }
//   }
// }
