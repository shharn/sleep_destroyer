import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Time {
  Time({
    this.timeOfDay,
    this.dayOfWeeks, 
    this.repeat
  });

  Time.withDefault() {
    this.timeOfDay = TimeOfDay.now();
    this.dayOfWeeks = <bool>[ false, false, false, false, false, false, false ];
    this.repeat = false;
  }

  Time.fromJson(Map<String, dynamic> jsonMap) {
    String hhmm = jsonMap["timeOfDay"];
    final splitted = hhmm.split(":");
    timeOfDay = TimeOfDay(hour: int.parse(splitted[0]), minute: int.parse(splitted[1]));
    dayOfWeeks = jsonMap["dayOfWeeks"].cast<bool>();
    repeat = jsonMap["repeat"];
  }

  Time.clone(Time source) {
      timeOfDay = TimeOfDay(hour: source.timeOfDay.hour, minute: source.timeOfDay.minute);
      dayOfWeeks = source.dayOfWeeks.map((val) => val).toList();
      repeat = source.repeat;
  }

  Map<String, dynamic> toJson() {
    final hour = timeOfDay.hour < 10 ? '0${timeOfDay.hour.toString()}' : timeOfDay.hour.toString();
    final minute = timeOfDay.minute < 10 ? '0${timeOfDay.minute.toString()}' : timeOfDay.minute.toString();
    return {
      'timeOfDay': '$hour:$minute',
      'dayOfWeeks': dayOfWeeks,
      'repeat': repeat,
    };
  }

  static final dayOfWeekColumns = <String>[ "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday" ];
  
  TimeOfDay timeOfDay;
  List<bool> dayOfWeeks;
  bool repeat;

  @override
  bool operator==(other) => 
    other is Time && 
    timeOfDay == other.timeOfDay &&
    DeepCollectionEquality().equals(dayOfWeeks, other.dayOfWeeks) &&
    repeat == other.repeat;
  
  @override
  int get hashCode => hashValues(timeOfDay, DeepCollectionEquality().hash(dayOfWeeks), repeat);

  @override
  String toString() {
    return '${timeOfDay.toString()}, ${dayOfWeeks.map((item) => item.toString()).join(', ')}, $repeat';
  }
}