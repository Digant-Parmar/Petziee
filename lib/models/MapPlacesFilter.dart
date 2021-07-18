// @dart=2.9

class PlaceFilter {
  final List html_attributions;
  final List results;
  final String place_id;
  final String status;


  PlaceFilter({this.html_attributions, this.results, this.place_id, this.status});

  factory PlaceFilter.fromJson(Map<String, dynamic> json) {
    return PlaceFilter(
      html_attributions: json['html_attributions'],
      results: json['results'],
      place_id: json['place_id'],
      status: json['status'],
    );
  }
}
