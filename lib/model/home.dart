import 'package:flutter/material.dart';

class HomeScreen {
  HomeScreen({
    this.turnedOn,
    this.timeSet,
    this.locationSet,
    this.ringtoneSet
  });

  HomeScreen.withDefault() {
    turnedOn = false;
    timeSet = false;
    locationSet = false;
    ringtoneSet = false;
  }

  HomeScreen.fromJson(Map<String, dynamic> jsonMap)
    : turnedOn = jsonMap['turnedOn'],
      timeSet = jsonMap['timeSet'],
      locationSet = jsonMap['locationSet'],
      ringtoneSet = jsonMap['ringtoneSet'];

  bool turnedOn;
  bool timeSet;
  bool locationSet;
  bool ringtoneSet;

  Map<String, dynamic> toJson() => 
    {
      'turnedOn': turnedOn,
      'timeSet': timeSet,
      'locationSet': locationSet,
      'ringtoneSet': ringtoneSet,
    };

  bool  operator== (other) => 
    other is HomeScreen &&
    turnedOn == other.turnedOn &&
    timeSet == other.timeSet &&
    locationSet == other.locationSet &&
    ringtoneSet == other.ringtoneSet;

  int get hashCode => hashValues(turnedOn, timeSet, locationSet, ringtoneSet);
}