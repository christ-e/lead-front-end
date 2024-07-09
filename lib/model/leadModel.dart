// ignore_for_file: file_names

class Lead {
  final int id;
  final String name;
  final String contactNumber;
  final String address;
  final String state;
  final String district;
  final String city;
  final String locationCoordinates;
  final String followUp;
  final String leadPriority;

  Lead({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.locationCoordinates,
    required this.followUp,
    required this.leadPriority,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      address: json['address'],
      state: json['state'],
      district: json['district'],
      city: json['city'],
      locationCoordinates: json['location_coordinates'],
      followUp: json['follow_up'],
      leadPriority: json['lead_priority'],
    );
  }
}
