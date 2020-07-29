class Slot {
  int slotId;
  String kombiId;
  String dayId;
  String routeId;
  String ownerName;
  String kombiPlate;
  String routeName;
  String time;

  Slot(
      {this.routeId,
      this.slotId,
      this.dayId,
      this.kombiId,
      this.ownerName,
      this.kombiPlate,
      this.routeName,
      this.time});
  @override
  String toString() => '$time $kombiPlate owned by $ownerName';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Slot && o.slotId == slotId;
  }

  @override
  int get hashCode => slotId.hashCode;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
        slotId: json['slotId'],
        routeId: json['routeId'],
        kombiId: json['kombiId'],
        ownerName: json['ownerName'],
        routeName: json['routeName'],
        time: json['time'],
        kombiPlate: json['kombiPlate']);
  }

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'routeId': routeId,
        'kombiId': kombiId,
        'ownerName': ownerName,
        'routeName': routeName,
        'kombiPlate': kombiPlate,
        'time': time
      };
}
