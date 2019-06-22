import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/model/time.dart';

class TimeRepository {
  TimeRepository({FileStorage fileStorage, Time time}) 
    : assert(fileStorage != null), 
      _fileStorage = fileStorage,
      _data = time;

  final String filename = "time.json";
  Time _data;

  final FileStorage _fileStorage;

  Future<Time> getTime() async {
    if (_data != null) {
      return _data;
    }

    final stringContent = await _fileStorage.getContent(filename);
    if (stringContent.isEmpty) {
      return Time.withDefault();
    }
    final jsonMap = json.decode(stringContent);
    final time = Time.fromJson(jsonMap);
    _data = time;
    return time;
  }

  Future<bool> updateTime(TimeOfDay time) async {
    var futureData = Time.clone(_data);
    futureData.timeOfDay = time;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _data.timeOfDay = time;
    }
    return ok;
  }

  Future<bool> updateDayOfWeeks(List<bool> dayOfWeeks) async {
    var futureData = Time.clone(_data);
    futureData.dayOfWeeks = dayOfWeeks;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _data.dayOfWeeks = dayOfWeeks;
    }
    return ok;
  }

  Future<bool> updateRepeat(bool repeat) async {
    var futureData = Time.clone(_data);
    futureData.repeat = repeat;
    final ok = await _updateTemplate(futureData);
    if (ok) {
      _data.repeat = repeat;
    }
    return ok;
  }

  Future<bool> _updateTemplate<T>(Time time)  async {
    final stringContent = json.encode(time);
    final ok = await _fileStorage.writeContent(filename, stringContent);
    return ok;
  }
}