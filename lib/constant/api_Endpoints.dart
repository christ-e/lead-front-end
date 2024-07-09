// ignore_for_file: prefer_const_declarations, library_private_types_in_public_api

class ApiEndPoints {
  static final String baseUrl = 'http://127.0.0.1:8000/api/';
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String login = '';
  final String fetchState = 'states';
  final String fetchDistrict = 'districts/{state_id}';
  final String fetchcity = 'cities/{district_id}';
  final String storeData = 'store';
  final String leadData = 'lead';
}
