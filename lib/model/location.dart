import 'package:flutter/material.dart';

class Location {
  Location({
    this.latitude,
    this.longitude
  });

  Location.withDefault() {
    latitude = 0.0;
    longitude = 0.0;
  }

  Location.fromJson(Map<String, dynamic> jsonMap)
    : latitude = jsonMap['latitude'],
      longitude = jsonMap['longitude'];

  double latitude;
  double longitude;

  bool  operator== (other) => 
    other is Location &&
    latitude == other.latitude &&
    longitude == other.longitude;

  int get hashCode => hashValues(latitude, longitude);
}