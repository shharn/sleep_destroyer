import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/model/time.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/time.dart';
import 'package:sleep_destroyer/bloc/time.dart';

class MockHomeRepository extends Mock implements HomeRepository {}
class MockTimeRepository extends Mock implements TimeRepository {}

main() {
  MockHomeRepository homeRepository;
  MockTimeRepository timeRepository;
  Time mockTime = Time(
        timeOfDay: TimeOfDay(hour: 12, minute: 12), 
        dayOfWeeks: <bool>[false, true, false, true, false, true, false],
        repeat: true
      );

  setUp(() {
    homeRepository = MockHomeRepository();
    timeRepository = MockTimeRepository();
  });

  group('loadData', () {
    test('Happy path', ()  async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));

      expectLater(
        bloc.time,
        emitsInOrder(
          <dynamic>[
            TimeLoadingState(),
            TimeDataLoadedState(mockTime),
          ]
        ),
      );

      bloc.loadData();
    });

    test('Should emit TimeDataLoadFailureState when fail to update', () async {
        final bloc = TimeBloc(homeRepository, timeRepository);
        when(timeRepository.getTime()).thenThrow((_) => Future.value(Exception));

        expectLater(
          bloc.time,
          emitsInOrder(
            <dynamic>[
              TimeLoadingState(),
              TimeDataLoadFailureState(),
            ]
          )
        );

        bloc.loadData();
    });
  });

  group('updateTimeOfDay', () {
    test('Happy path', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockTimeOfDay = TimeOfDay(hour: 21, minute: 21);
      when(timeRepository.updateTime(mockTimeOfDay)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.timeOfDayMutation,
        emitsInOrder(
          <dynamic>[
            UpdateTimeOfDaySuccessState(mockTimeOfDay),
          ]
        )
      );

      bloc.updateTimeOfDay(mockTimeOfDay);
    });

    test('Should emit UpdateTimeOfDayFailure when fail to update', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockTimeOfDay = TimeOfDay(hour: 21, minute: 21);
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));
      when(timeRepository.updateTime(mockTimeOfDay)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.timeOfDayMutation,
        emitsInOrder(
          <dynamic>[
            UpdateTimeOfDayFailureState(mockTime.timeOfDay),
          ]
        )
      );

      bloc.updateTimeOfDay(mockTimeOfDay);
    });
  });

  group('updateDayOfWeeks', () {
    test('Happy path', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockDayOfWeeks = <bool>[true, true, true, true, true, true, true];
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));
      when(timeRepository.updateDayOfWeeks(mockDayOfWeeks)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.dayOfWeeksMutation,
        emitsInOrder(
          <dynamic>[
            UpdateDayOfWeeksSuccessState(mockDayOfWeeks),
          ]
        ),
      );

      bloc.updateDayOfWeeks(mockDayOfWeeks);
    });

    test('Should emit UpdateDayOfWeeksFailure when fail to update', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockDayOfWeeks = <bool>[true, true, true, true, true, true, true];
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));
      when(timeRepository.updateDayOfWeeks(mockDayOfWeeks)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.dayOfWeeksMutation,
        emitsInOrder(
          <dynamic>[
            UpdateDayOfWeeksFailureState(mockTime.dayOfWeeks),
          ]
        ),
      );

      bloc.updateDayOfWeeks(mockDayOfWeeks);
    });
  });

  group('updateRepeat', () {
    test('Happy path', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockRepeat = false;
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));
      when(timeRepository.updateRepeat(mockRepeat)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.repeatMutation,
        emitsInOrder(
          <dynamic>[
            UpdateRepeatSuccessState(mockRepeat),
          ],
        ),
      );

      bloc.updateRepeat(mockRepeat);
    });

    test('Should emit UpdateRepeatFailure when fail to update', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockRepeat = false;
      when(timeRepository.getTime()).thenAnswer((_) => Future.value(mockTime));
      when(timeRepository.updateRepeat(mockRepeat)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.repeatMutation,
        emitsInOrder(
          <dynamic>[
            UpdateRepeatFailureState(mockTime.repeat),
          ],
        ),
      );

      bloc.updateRepeat(mockRepeat);
    });
  });

  group('updateTimeSetOfHome', () {
    test('Should pass through repository when the "timeSet" is false', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockHomeScreen = HomeScreen.withDefault();
      var updatedMockHomeScreen = HomeScreen.clone(mockHomeScreen);
      updatedMockHomeScreen.timeSet = true;
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedMockHomeScreen)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.timeSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateTimeSetOfHomeLoadingState(),
            UpdateTimeSetOfHomeSuccessState(),
          ],
        )
      );

      bloc.updateTimeSetOfHome();
    });

    test('Should emit UpdateTimeSetOfHomeFailureState when fail to update', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockHomeScreen = HomeScreen.withDefault();
      var updatedMockHomeScreen = HomeScreen.clone(mockHomeScreen);
      updatedMockHomeScreen.timeSet = true;
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedMockHomeScreen)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.timeSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateTimeSetOfHomeLoadingState(),
            UpdateTimeSetOfHomeFailureState(),
          ],
        )
      );

      bloc.updateTimeSetOfHome();
    });

    test('Should not pass through repository when the "timeSet" is true', () async {
      final bloc = TimeBloc(homeRepository, timeRepository);
      final mockHomeScreen = HomeScreen(timeSet: true);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));

      expectLater(
        bloc.timeSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateTimeSetOfHomeLoadingState(),
            UpdateTimeSetOfHomeSuccessState(),
          ],
        )
      );

      bloc.updateTimeSetOfHome();
      verifyNever(homeRepository.updateHomeScreen(mockHomeScreen));
    });
  });
}