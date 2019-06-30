import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sleep_destroyer/model/location.dart';
import 'package:sleep_destroyer/repository/file.dart';

class LocationRepository {
  LocationRepository({
    @required FileStorage fileStorage,
    Location data
  }) : _fileStorage = fileStorage,
    _data = data;

  final String filename = "location.json";
  Location _data;

  final FileStorage _fileStorage;

  Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final latlng = LatLng(position.latitude, position.longitude);
    return latlng;
  }

  Future<Location> getLocation() async {
    if (_data != null) {
      return _data;
    }

    final stringContent = await _fileStorage.getContent(filename);
    if (stringContent.isEmpty) {
      _data = Location.withDefault();
      return _data;
    }

    final jsonMap = json.decode(stringContent);
    final location = Location.fromJson(jsonMap);
    _data = location;
    return _data;
  }

  Future<bool> updateLocation(Location location) async {
    final stringContent = json.encode(location);
    final ok = await _fileStorage.writeContent(filename, stringContent);
    return ok;
  }
}