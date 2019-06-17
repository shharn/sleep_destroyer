import 'package:flutter/material.dart';

class Ringtone {
  Ringtone({
    this.name,
    this.volume,
    this.vibrate
  });

  Ringtone.withDefault() {
    this.volume = 10;
    this.vibrate = false;
  }

  Ringtone.fromJson(Map<String, dynamic> jsonMap)
    : name = jsonMap['name'],
      volume = jsonMap['volume'],
      vibrate = jsonMap['vibrate'];

  String name;
  int volume;
  bool vibrate;

  @override
  bool operator==(other) => 
    other is Ringtone &&
    name == other.name &&
    volume == other.volume &&
    vibrate == other.vibrate;

  @override
  int get hashCode => hashValues(name, volume, vibrate);
}