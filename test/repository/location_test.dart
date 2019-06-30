import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/location.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/location.dart';

class MockFileStorage extends Mock implements FileStorage {}

main() {
  FileStorage fileStorage;

  setUp(() {
    fileStorage = MockFileStorage();
  });

  group('getLocation', () {
    test('Should get default property of Location when no file or exists but empty content', () async {
      final repository = LocationRepository(fileStorage: fileStorage);
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(''));

      final actual = await repository.getLocation();
      final expected = Location.withDefault();
      expect(actual, expected);
    });

    test('Should be "Location" object from json string', () async {
      final repository = LocationRepository(fileStorage: fileStorage);
      final mockString ='{"latitude":30.023411234,"longitude":110.234123423}';
      when(fileStorage.getContent(repository.filename)).thenAnswer((_) => Future.value(mockString));

      final actual = await repository.getLocation();
      final expected = Location(latitude: 30.023411234, longitude: 110.234123423);
      expect(actual, expected);
    });

    test('Should return data in memory not from file when data already was loaded', () async {
      final mockLocation = Location(latitude: 30.023411234, longitude: 110.234123423);
      final repository = LocationRepository(fileStorage: fileStorage, data: mockLocation);

      final actual = await repository.getLocation();
      expect(actual, mockLocation);
      verifyNever(fileStorage.getContent(repository.filename));
    });
  });
}