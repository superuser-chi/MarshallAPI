class User {
  String id;
  String routeId;
  String role;
  String username;
  String firstname;
  String lastname;
  String phoneNumber;

  User(
      {this.id,
      this.routeId,
      this.role,
      this.username,
      this.firstname,
      this.phoneNumber,
      this.lastname});

  @override
  String toString() => '$firstname $lastname';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        role: json['role'],
        routeId: json['routeId'],
        phoneNumber: json['phoneNumber'],
        username: json['userName']);
  }

  Map<String, dynamic> toJson() => 
  {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'role': role,
    'routeId': routeId,
    'phoneNumber': phoneNumber,
    'userName': username,
  };
}
