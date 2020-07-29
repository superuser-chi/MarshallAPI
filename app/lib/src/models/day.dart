class Day {
  String dayId;
  String dateKey;
  
  Day({this.dayId, this.dateKey});
  @override
  String toString() => '$dateKey';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Day && o.dateKey == dateKey;
  }

  @override
  int get hashCode => dateKey.hashCode ^ dayId.hashCode;
  
  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(dayId: json['dayId'], dateKey: json['dateKey']);
  }

  Map<String, dynamic> dateKeyJson() => {'dayId': dayId, 'dateKey': dateKey};
}
