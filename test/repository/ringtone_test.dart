import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/ringtone.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/ringtone.dart';

class MockFileStorage extends Mock implements FileStorage {}

main() {
  FileStorage fileStorage;

  setUp(() {
    fileStorage = MockFileStorage();
  });

  group('getRingtone', () {
    test('Happy path with an empty content', () async {
      final repository = RingtoneRepository(fileStorage: fileStorage);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(''));

      final actual = await repository.getRingtone();
      final expected = Ringtone.withDefault();
      expect(actual, expected);
    });

    test('Happy path with content', () async {
      final repository = RingtoneRepository(fileStorage: fileStorage);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value('{"vibrate":true}'));

      final actual = await repository.getRingtone();
      final expected = Ringtone(vibrate: true);
      expect(actual, expected);
    });

    test('Should return default ringtone instance when the file content is invalid', () async {
      final repository = RingtoneRepository(fileStorage: fileStorage);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value('{"vivrate":1}'));

      final actual = await repository.getRingtone();
      final expected = Ringtone.withDefault();
      expect(actual, expected);
    });
  });

  group('updateRingtone', () {
    test('Happy path', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final repository = RingtoneRepository(fileStorage: fileStorage);
      when(fileStorage.writeContent(repository.filename, '{"vibrate":true}')).thenAnswer((_) => Future.value(true));

      final actual = await repository.updateRingtone(mockRingtone);
      final expected = true;
      expect(actual, expected);
    });

    test('Should return false when fileStorage return false', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final repository = RingtoneRepository(fileStorage: fileStorage);
      when(fileStorage.writeContent(repository.filename, '{"vibrate":true}')).thenAnswer((_) => Future.value(false));

      final actual = await repository.updateRingtone(mockRingtone);
      final expected = false;
      expect(actual, expected);
    });
  });
}