import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/model/ringtone.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/ringtone.dart';
import 'package:sleep_destroyer/bloc/ringtone.dart';

class MockHomeRepository extends Mock implements HomeRepository {}
class MockRingtoneRepository extends Mock implements RingtoneRepository {}

main() {
  MockHomeRepository homeRepository;
  MockRingtoneRepository ringtoneRepository;

  setUp(() {
    homeRepository = MockHomeRepository();
    ringtoneRepository = MockRingtoneRepository();
  });

  group('loadData', () {
    test('Happy path', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(ringtoneRepository.getRingtone()).thenAnswer((_) => Future.value(mockRingtone));

    expectLater(
      bloc.ringtone,
      emitsInOrder(
        <dynamic>[
          RingtoneLoadingState(),
          RingtoneLoadSuccessState(ringtone: mockRingtone)
        ]
      )
    );

      bloc.loadData();
    });

    test('Should emit RingtoneLoadFailureState when a repository throws exception', () async {
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(ringtoneRepository.getRingtone()).thenThrow((_) => Future.value(Exception));

      expectLater(
        bloc.ringtone,
        emitsInOrder(
          <dynamic>[
            RingtoneLoadingState(),
            RingtoneLoadFailureState()
          ]
        )
      );

      bloc.loadData();
    });
  });

  group('updateVibrate', () {
    test('Happy path', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final updatedRingtone = Ringtone(vibrate: false);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(ringtoneRepository.getRingtone()).thenAnswer((_) => Future.value(mockRingtone));
      when(ringtoneRepository.updateRingtone(updatedRingtone)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.ringtoneMutation,
        emitsInOrder(
         <dynamic>[
           UpdateVibrateLoadingState(),
           UpdateVibrateSuccessState(vibrate: false)
         ] 
        )
      );

      bloc.updateVibrate(false);
    });

    test('Should emit UpdateVibrateFailureState when a repository fail to store it', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final updatedRingtone = Ringtone(vibrate: false);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(ringtoneRepository.getRingtone()).thenAnswer((_) => Future.value(mockRingtone));
      when(ringtoneRepository.updateRingtone(updatedRingtone)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.ringtoneMutation,
        emitsInOrder(
         <dynamic>[
           UpdateVibrateLoadingState(),
           UpdateVibrateFailureState()
         ] 
        )
      );

      bloc.updateVibrate(false);
    });

    test('Should emit UpdateVibrateFailureState whena repository throws exception', () async {
      final mockRingtone = Ringtone(vibrate: true);
      final updatedRingtone = Ringtone(vibrate: false);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(ringtoneRepository.getRingtone()).thenAnswer((_) => Future.value(mockRingtone));
      when(ringtoneRepository.updateRingtone(updatedRingtone)).thenThrow((_) => Future.value(Exception));

      expectLater(
        bloc.ringtoneMutation,
        emitsInOrder(
         <dynamic>[
           UpdateVibrateLoadingState(),
           UpdateVibrateFailureState()
         ] 
        )
      );

      bloc.updateVibrate(false);
    });
  });

  group('updateRingtoneSetOfHomeScreen', () {
    test('Happy path when ringtoneSet is not set', () async {
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet : false);
      final updatedHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet : true);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedHomeScreen)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.ringtoneSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateRingtoneSetOfHomeScreenWaitingState(),
            UpdateRingtoneSetOfHomeScreenSuccessState()
          ]
        )
      );

      await bloc.updateRingtoneSetOfHomeScreen();
      verify(homeRepository.updateHomeScreen(updatedHomeScreen)).called(1);
    });

    test('Happy path when ringtoneSet is set', () async {
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet : true);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));

      expectLater(
        bloc.ringtoneSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateRingtoneSetOfHomeScreenWaitingState(),
            UpdateRingtoneSetOfHomeScreenSuccessState()
          ]
        )
      );

      await bloc.updateRingtoneSetOfHomeScreen();
      verifyNever(homeRepository.updateHomeScreen(mockHomeScreen));
    });

    test('Should emit UpdateRingtoneSetOfHomeScreenFailureState when fail to update', () async {
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet : false);
      final updatedHomeScreen = HomeScreen(turnedOn: false, timeSet: false, locationSet: true, ringtoneSet : true);
      final bloc = RingtoneBloc(homeRepository: homeRepository, ringtoneRepository: ringtoneRepository);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedHomeScreen)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.ringtoneSetOfHomeMutation,
        emitsInOrder(
          <dynamic>[
            UpdateRingtoneSetOfHomeScreenWaitingState(),
            UpdateRingtoneSetOfHomeScreenFailureState()
          ]
        )
      );

      await bloc.updateRingtoneSetOfHomeScreen();
      verify(homeRepository.updateHomeScreen(updatedHomeScreen)).called(1);
    });
  });
}