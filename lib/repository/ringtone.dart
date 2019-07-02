import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:sleep_destroyer/model/ringtone.dart';
import 'package:sleep_destroyer/repository/file.dart';

class RingtoneRepository {
  RingtoneRepository({
    @required FileStorage fileStorage
  }) : _fileStorage = fileStorage;

  final String filename = "ringtone.json";
  Ringtone _data;

  final FileStorage _fileStorage;

  Future<Ringtone> getRingtone() async {
    final stringContent = await _fileStorage.getContent(filename);
    if (stringContent.isEmpty) {
      _data = Ringtone.withDefault();
      return _data;
    }

    final jsonMap = json.decode(stringContent);
    final ringtone = Ringtone.fromJson(jsonMap);
    _data = ringtone;
    return ringtone;
  }

  Future<bool> updateRingtone(Ringtone ringtone) async {
    final stringContent = json.encode(ringtone);
    final ok = await _fileStorage.writeContent(filename, stringContent);
    return ok;
  }
}