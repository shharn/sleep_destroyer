import 'package:flutter/material.dart';

class Ringtone {
  Ringtone({
    this.vibrate
  });

  Ringtone.withDefault() {
    this.vibrate = false;
  }

  Ringtone.fromJson(Map<String, dynamic> jsonMap)
     : vibrate = jsonMap['vibrate'] ?? false;

  Ringtone.clone(Ringtone other) : vibrate = other.vibrate;

  Map<String, dynamic> toJson() => 
    {
      'vibrate': vibrate
    };

  bool vibrate;

  @override
  bool operator==(other) => 
    other is Ringtone &&
    vibrate == other.vibrate;

  @override
  int get hashCode => hashValues(super.hashCode, vibrate);
}