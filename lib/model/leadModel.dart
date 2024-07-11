// ignore_for_file: file_names, non_constant_identifier_names
class Lead {
  final int id;
  final String? name;
  final String? contactNumber;
  final String? address;
  final int? whatsapp;
  final String? state_name;
  final String? district_name;
  final String? city_name;
  final String? locationCoordinates;
  final String? leadPriority;
  final String? followUp;

  Lead({
    required this.id,
    this.name,
    this.contactNumber,
    this.address,
    this.whatsapp,
    this.state_name,
    this.district_name,
    this.city_name,
    this.locationCoordinates,
    this.leadPriority,
    this.followUp,
  });
  // "district_name": "Kollam",

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      address: json['address'],
      whatsapp: json['whats_app'],
      state_name: json['state_name'],
      district_name: json['district_name'],
      city_name: json['city_name'],
      locationCoordinates: json['location_coordinates'],
      leadPriority: json['lead_priority'],
      followUp: json['follow_up'],
    );
  }

  get emailAddress => null;
}
