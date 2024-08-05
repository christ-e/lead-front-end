class Usermodels {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;

  Usermodels({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory Usermodels.fromJson(Map<String, dynamic> json) => Usermodels(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        phone: json["phone"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
