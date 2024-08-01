class Mapmodel {
  double? location_lat;
  double? location_log;

  Mapmodel({this.location_lat, this.location_log});

  factory Mapmodel.fromJson(Map<String, dynamic> json) {
    return Mapmodel(
      location_lat: json['location_lat'],
      location_log: json['location_log'],
    );
  }
}
