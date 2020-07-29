class KombiRoute {
  String routeId;
  String from;
  String to;

  KombiRoute({this.routeId, this.from, this.to});
  @override
  String toString() => '$from to $to';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is KombiRoute && o.from == from && o.to == from;
  }

  @override
  int get hashCode => to.hashCode ^ from.hashCode;
  
  factory KombiRoute.fromJson(Map<String, dynamic> json) {
    return KombiRoute(routeId: json['routeId'], from: json['from'], to: json['to']);
  }

  Map<String, dynamic> toJson() => {'routeId': routeId, 'from': from, 'to': to};


}
