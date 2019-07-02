import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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
}