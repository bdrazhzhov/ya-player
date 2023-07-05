import 'station.dart';

class StationsDashboard {
  final String id;
  final List<Station> stations;

  StationsDashboard(this.id, this.stations);

  factory StationsDashboard.fromJson(Map<String, dynamic> json) {
    List<Station> stations = [];
    json['stations'].forEach((item) {
      stations.add(Station.fromJson(item['station']));
    });

    return StationsDashboard(json['dashboardId'], stations);
  }
}
