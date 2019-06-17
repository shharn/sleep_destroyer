import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/time.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/time.dart';

class MockFileStorage extends Mock implements FileStorage {}

main() {
  FileStorage fileStorage;
  setUp(() {
    fileStorage = MockFileStorage();
  });

  group('getTime', () {
    test('Should get default property of Time when no file or exists but empty content', () async {
      final repository = TimeRepository(fileStorage: fileStorage);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(""));

      final actual = await repository.getTime();
      final expected = Time.withDefault();
      expect(actual, expected);
    });

    test('Should "Time" object from json string', () async {
      final repository = TimeRepository(fileStorage: fileStorage);
      final mockString = '{"timeOfDay":"16:44","dayOfWeeks":[true,false,true,false,true,false,true],"repeat":true}';
      final expected = Time(timeOfDay: TimeOfDay(hour: 16, minute: 44), dayOfWeeks: <bool>[true, false, true, false, true, false, true], repeat: true);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(mockString));

      final actual = await repository.getTime();
      expect(actual, expected);
    });
  });

  group('updateTime', () {
    test('HappyPath', ()  async {
      final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockTimeOfDay = TimeOfDay(hour: 23, minute: 23);
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"23:23","dayOfWeeks":[false,true,false,true,false,true,false],"repeat":true}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(true));

      final result = await repository.updateTime(mockTimeOfDay);
      var expectedTime = Time.clone(mockTime);
      expectedTime.timeOfDay = mockTimeOfDay;
      expect(result, true);
      expect(repository.time, expectedTime);
    });

    test('Should not change original data when fail to store', () async {
      final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockTimeOfDay = TimeOfDay(hour: 22, minute: 22);
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"22:22","dayOfWeeks":[false,true,false,true,false,true,false],"repeat":true}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(false));

      final result = await repository.updateTime(mockTimeOfDay);
      expect(result, false);
      expect(repository.time, mockTime);
    });
  });

  group('updateDayOfWeeks', () {
    test('HappyPath', ()  async {
      final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockDayOfWeeks = <bool>[true, true, true, false, false, false, false];
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"16:33","dayOfWeeks":[true,true,true,false,false,false,false],"repeat":true}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(true));

      final result = await repository.updateDayOfWeeks(mockDayOfWeeks);
      var expectedTime = Time.clone(mockTime);
      expectedTime.dayOfWeeks = mockDayOfWeeks;
      expect(result, true);
      expect(repository.time, expectedTime);
    });

    test('Should not change original data when fail to store', () async {
      final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockDayOfWeeks = <bool>[true, true, true, false, false, false, false];
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"16:33","dayOfWeeks":[true,true,true,false,false,false,false],"repeat":true}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(false));

      final result = await repository.updateDayOfWeeks(mockDayOfWeeks);
      expect(result, false);
      expect(repository.time, mockTime);
    });
  });

  group('updateRepeat', () {
    test('HappyPath', ()  async {
      final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockRepeat = false;
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"16:33","dayOfWeeks":[false,true,false,true,false,true,false],"repeat":false}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(true));

      final result = await repository.updateRepeat(mockRepeat);
      var expectedTime = Time.clone(mockTime);
      expectedTime.repeat = mockRepeat;
      expect(result, true);
      expect(repository.time, expectedTime);
    });

    test('Should not change original data when fail to store', () async {
        final mockTime = Time(
        timeOfDay: TimeOfDay(hour: 16, minute: 33),
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );
      final mockRepeat = false;
      final repository = TimeRepository(fileStorage: fileStorage, time: mockTime);
      final mockStringContent = '{"timeOfDay":"16:33","dayOfWeeks":[false,true,false,true,false,true,false],"repeat":false}';
      when(fileStorage.writeContent(repository.filename, mockStringContent)).thenAnswer((_) => Future.value(false));

      final result = await repository.updateRepeat(mockRepeat);
      expect(result, false);
      expect(repository.time, mockTime);
    });
  });
}