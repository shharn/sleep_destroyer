import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  Location({
    this.latitude,
    this.longitude
  });

  Location.withDefault() {
    latitude = -1.0;
    longitude = -1.0;
  }

  Location.fromJson(Map<String, dynamic> jsonMap)
    : latitude = jsonMap['latitude'],
      longitude = jsonMap['longitude'];

  Location.fromLatLng(LatLng latlng)
    : latitude = latlng.latitude,
      longitude = latlng.longitude;

  Location.clone(Location src) :
    this.latitude = src.latitude,
    this.longitude = src.longitude;

  double latitude;
  double longitude;

  bool get isValid => latitude >= 0.0 && longitude > 0.0;
  bool get isInvalid => !isValid;

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  Map<String, dynamic> toJson() => 
    {
      'latitude': latitude,
      'longitude': longitude,
    };

  bool  operator== (other) => 
    other is Location &&
    latitude == other.latitude &&
    longitude == other.longitude;

  int get hashCode => hashValues(latitude, longitude);
}