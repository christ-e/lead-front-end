// ignore_for_file: prefer_const_declarations, library_private_types_in_public_api

class ApiEndPoints {
  static final String baseUrl = 'http://127.0.0.1:8000/api/';
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String register = 'register';
  final String login = 'login';
  final String logout = 'logout';
  final String users = 'get_users';
  final String fetchState = 'states';
  final String fetchDistrict = 'districts/';
  final String fetchcity = 'cities/';
  final String storeData = 'store';
  final String deleteData = 'lead_data/';
  final String leadData = 'lead';
  final String follow_upData = 'follow-ups/';
  final String leadImage = 'http://127.0.0.1:8000/storage/';
}
