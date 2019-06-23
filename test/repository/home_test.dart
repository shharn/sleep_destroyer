import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/home.dart';

class MockFileStorage extends Mock implements FileStorage {}

main() {
  group('getHomeScreen', () {
    test('should return HomeScreen object with default properties when no configuration', () async {
      final fileStorage = MockFileStorage();
      final repository = HomeRepository(fileStorage: fileStorage);

      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(''));

      final actual = await repository.getHomeScreen();
      final expected = HomeScreen.withDefault();
      expect(actual, expected);
    });

    test('Should return HomeScreen object with properties mapped to string content', () async {
      final fileStorage = MockFileStorage();
      final repository = HomeRepository(fileStorage: fileStorage);

      when(fileStorage.getContent(repository.filename))
        .thenAnswer((_) => Future.value('{"turnedOn":true,"timeSet":false,"locationSet":true,"ringtoneSet":false}'));

      final actual = await repository.getHomeScreen();
      final expected = HomeScreen(turnedOn: true, timeSet: false, locationSet: true, ringtoneSet: false);
      expect(actual, expected);
    });
  });

  group('updateHomeScreen', () {
    test('Should call FileStorage.writeContent', () async {
      final fileStorage = MockFileStorage();
      final repository = HomeRepository(fileStorage: fileStorage);

      final homeScreen = HomeScreen(turnedOn: true, timeSet: false, locationSet: true, ringtoneSet: true);
      final expectedArg = '{"turnedOn":true,"timeSet":false,"locationSet":true,"ringtoneSet":true}';
      await repository.updateHomeScreen(homeScreen);

      verify(fileStorage.writeContent(repository.filename, expectedArg)).called(1);
    });
  });
}