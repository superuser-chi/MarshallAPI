class Kombi {
  String kombiId;
  String plate;
  String userId;
  String ownerName;

  Kombi({this.kombiId, this.plate, this.userId, this.ownerName});
  @override
  String toString() => '$plate owned by $ownerName';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Kombi && o.plate == plate && o.kombiId == kombiId;
  }

  @override
  int get hashCode => plate.hashCode ^ kombiId.hashCode;

  factory Kombi.fromJson(Map<String, dynamic> json) {
    return Kombi(
        kombiId: json['kombiId'], plate: json['plate'], 
        userId: json['userId'], ownerName: json['ownerName']);
  }

  Map<String, dynamic> toJson() =>
      {'kombiId': kombiId, 'plate': plate, 'userId': userId, 'ownerName': ownerName};
}
