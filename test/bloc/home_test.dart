import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/bloc/home.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

main() {
  MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
  });

  group('loadData', () {
    test('No exception from repository', () async {
      final homeBloc = HomeBloc(repository);
      final mockHomeScreenData = HomeScreen(turnedOn: true, timeSet: false, locationSet: true, ringtoneSet: true);
      when(repository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreenData));

      expectLater(
        homeBloc.homeScreen,
        emitsInOrder(
          <dynamic>[
            HomeLoadingState(),
            HomeDataLoadedState(mockHomeScreenData),
          ]
        ),
      );
      homeBloc.loadData();
    });

    test('Exception from repository', () async {
      final homeBloc = HomeBloc(repository);
      when(repository.getHomeScreen()).thenThrow((_) => Future.value(Exception));

      expectLater(
        homeBloc.homeScreen,
        emitsInOrder(
            <dynamic>[
            HomeLoadingState(),
            HomeDataLoadFailureState(),
          ]
        )
      );
      homeBloc.loadData();
    });
  });

  group('updateAlarmSwitch', () {
    test('Happy path', () async {
      final homeBloc = HomeBloc(repository);
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: true, ringtoneSet: true);
      homeBloc.data = mockHomeScreen;
      final mockValue = true;
      final updatedHomeScreen = HomeScreen(turnedOn: mockValue, timeSet: true, locationSet: true, ringtoneSet: true);
      when(repository.updateHomeScreen(updatedHomeScreen)).thenAnswer((_) => Future.value(true));
      
      expectLater(
        homeBloc.homeScreenMutation,
        emitsInOrder(
          <dynamic>[
            UpdateAlarmSwitchSuccess(updatedValue: mockValue),
          ]
        )
      );

      homeBloc.updateAlarmSwitch(mockValue);
    });

    test('Should not update \'turnedOn\' to on when all of the required configuration aren\'t on', () async {
      final homeBloc = HomeBloc(repository);
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet: true);
      homeBloc.data = mockHomeScreen;
      final mockValue = true;

      expectLater(
        homeBloc.homeScreenMutation,
        emitsInOrder(
          <dynamic>[
            UpdateAlarmSwitchBadPrerequisite(),
          ]
        )
      );

      homeBloc.updateAlarmSwitch(mockValue);
    });

    test('Exception from repository', () async {
      final homeBloc = HomeBloc(repository);
      final mockHomeScreen = HomeScreen(turnedOn: true, timeSet: true, locationSet: true, ringtoneSet: true);
      homeBloc.data = mockHomeScreen;
      final mockValue = true;
      final updatedHomeScreen = HomeScreen(turnedOn: mockValue, timeSet: true, locationSet: true, ringtoneSet: true);
      when(repository.updateHomeScreen(updatedHomeScreen)).thenAnswer((_) => Future.value(false));

      expectLater(
        homeBloc.homeScreenMutation,
        emitsInOrder(
          <dynamic>[
            UpdateAlarmSwitchFailure(updatedValue: !mockValue),
          ]
        )
      );

      homeBloc.updateAlarmSwitch(mockValue);
    });
  });
}