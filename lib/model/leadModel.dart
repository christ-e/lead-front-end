// ignore_for_file: file_names, non_constant_identifier_names
class Lead {
  final int id;
  final String? name;
  final String? contactNumber;
  final String? address;
  final String? email;
  final int? whatsapp;
  final String? state_name;
  final String? state_id;
  final String? district_name;
  final String? district_id;
  final String? city_name;
  final String? city_id;
  final String? locationCoordinates;
  // final String? current_location;
  final String? leadPriority;
  final String? followUp;
  final String? follow_up_date;

  Lead({
    required this.id,
    this.name,
    this.contactNumber,
    this.address,
    this.email,
    this.whatsapp,
    this.state_name,
    this.district_name,
    this.city_name,
    this.state_id,
    this.district_id,
    this.city_id,
    this.locationCoordinates,
    // this.current_location,
    this.leadPriority,
    this.followUp,
    this.follow_up_date,
  });
  // "district_name": "Kollam",

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      address: json['address'],
      email: json['email'],
      whatsapp: json['whats_app'],
      state_name: json['state_name'],
      district_name: json['district_name'],
      city_name: json['city_name'],
      state_id: json['state'],
      district_id: json['district'],
      city_id: json['city'],
      locationCoordinates: json['location_coordinates'],
      // current_location: json['current_location'],
      leadPriority: json['lead_priority'],
      followUp: json['follow_up'],
      follow_up_date: json['follow_up_date'],
    );
  }
}
