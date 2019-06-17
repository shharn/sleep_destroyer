import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/model/time.dart';

class TimeRepository {
  TimeRepository({FileStorage fileStorage, Time time}) 
    : assert(fileStorage != null), 
      _fileStorage = fileStorage,
      _time = time ?? Time.withDefault();

  final String filename = "time.json";
  Time _time;
  Time get time => _time;

  final FileStorage _fileStorage;

  Future<Time> getTime() async {
    final stringContent = await _fileStorage.getContent(filename);
    if (stringContent.isEmpty) {
      return Time.withDefault();
    }
    final jsonMap = json.decode(stringContent);
    final time = Time.fromJson(jsonMap);
    _time = time;
    return time;
  }

  Future<bool> updateTime(TimeOfDay time) async {
    var futureData = Time.clone(_time);
    futureData.timeOfDay = time;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _time.timeOfDay = time;
    }
    return ok;
  }

  Future<bool> updateDayOfWeeks(List<bool> dayOfWeeks) async {
    var futureData = Time.clone(_time);
    futureData.dayOfWeeks = dayOfWeeks;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _time.dayOfWeeks = dayOfWeeks;
    }
    return ok;
  }

  Future<bool> updateRepeat(bool repeat) async {
    var futureData = Time.clone(_time);
    futureData.repeat = repeat;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _time.repeat = repeat;
    }
    return ok;
  }

  Future<bool> _updateTemplate<T>(Time time)  async {
    final stringContent = json.encode(time);
    final ok = await _fileStorage.writeContent(filename, stringContent);
    return ok;
  }
}