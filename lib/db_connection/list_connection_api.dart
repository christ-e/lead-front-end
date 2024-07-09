import 'package:http/http.dart' as http;
import 'dart:convert';

class Functions {
  Future<List<String>> fetchStates(states) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));

    if (response.statusCode == 200) {
      List<dynamic> statesJson = json.decode(response.body);
      List<String> states =
          statesJson.map((state) => state.toString()).toList();
      return states;
    } else {
      throw Exception('Failed to load states');
    }
  }
}
