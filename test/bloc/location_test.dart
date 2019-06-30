import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/model/location.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/location.dart';
import 'package:sleep_destroyer/bloc/location.dart';

class MockHomeRepository extends Mock implements HomeRepository {}
class MockLocationRepository extends Mock implements LocationRepository {}

main() {
  MockHomeRepository homeRepository;
  MockLocationRepository locationRepository;

  setUp(() {
    homeRepository = MockHomeRepository();
    locationRepository = MockLocationRepository();
  });

  group('getLocations', () {
    test('Happy path', () async {
      final mockCurrentLocation = LatLng(50.0, 12.2);
      final mockLocation = Location(latitude: 51.1, longitude: 13.2);
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(locationRepository.getCurrentLocation()).thenAnswer((_) => Future.value(mockCurrentLocation));
      when(locationRepository.getLocation()).thenAnswer((_) => Future.value(mockLocation));

      expectLater(
        bloc.location,
        emitsInOrder(
            <dynamic>[
            LocationLoadingState(),
            LocationLoadSuccessState(currentLocation: mockCurrentLocation, storedLocation: mockLocation)
          ]
        )
      );

      bloc.getLocations();
    });

    test('Should emit LocationLoadFailureState when fail to get current location', () async {
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(locationRepository.getCurrentLocation()).thenThrow((_) => Future.value(Exception));

      expectLater(
        bloc.location,
        emitsInOrder(
          <dynamic>[
            LocationLoadingState(),
            LocationLoadFailureState()
          ]
        )
      );

      bloc.getLocations();
      verifyNever(locationRepository.getLocation());
    });

    test('Should emit LocationLoadFailureState when fail to get a stored location', () async {
      final mockCurrentLocation = LatLng(50.0, 12.2);
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(locationRepository.getCurrentLocation()).thenAnswer((_) => Future.value(mockCurrentLocation));
      when(locationRepository.getLocation()).thenThrow((_) => Future.value(Exception));

      expectLater(
        bloc.location,
        emitsInOrder(
          <dynamic>[
            LocationLoadingState(),
            LocationLoadFailureState()
          ]
        )
      );

      bloc.getLocations();
    });
  });

  group('saveLocation', () {
    test('Happy path', () async {
      final mockLocation = Location(latitude: 51.1, longitude: 13.2);
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(locationRepository.updateLocation(mockLocation)).thenAnswer((_) => Future.value(true));

      final actual = await bloc.saveLocation(mockLocation);
      final expected = true;
      expect(actual, expected);
    });

    test('Should return false when fail to store data', () async {
      final mockLocation = Location(latitude: 51.1, longitude: 13.2);
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(locationRepository.updateLocation(mockLocation)).thenAnswer((_) => Future.value(false));

      final actual = await bloc.saveLocation(mockLocation);
      final expected = false;
      expect(actual, expected);
    });
  });

  group('updateLocationSetOfHomeScreen', () {
    test('Happy path when a "locationSet" has not been set before', () async {
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: false, ringtoneSet: false);
      final updatedMockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: true, ringtoneSet: false);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedMockHomeScreen)).thenAnswer((_) => Future.value(true));

      expectLater(
        bloc.locationSetOfHomeScreenMutation,
        emitsInOrder(
          <dynamic>[
            LocationMutationWaitingState(),
            LocationMutationSuccessState()
          ]
        )
      );

      bloc.updateLocationSetOfHomeScreen();
    });

    test('Happy path when a "locationSet" is already set', () async {
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: true, ringtoneSet: false);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));

      expectLater(
        bloc.locationSetOfHomeScreenMutation,
        emitsInOrder(
          <dynamic>[
            LocationMutationWaitingState(),
            LocationMutationSuccessState()
          ]
        )
      );

      bloc.updateLocationSetOfHomeScreen();
      verifyNever(homeRepository.updateHomeScreen(mockHomeScreen));
    });

    test('Should emit LocationMutationFailureState when fail to update', () async {
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: false, ringtoneSet: false);
      final updatedMockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: true, ringtoneSet: false);
      when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
      when(homeRepository.updateHomeScreen(updatedMockHomeScreen)).thenAnswer((_) => Future.value(false));

      expectLater(
        bloc.locationSetOfHomeScreenMutation,
        emitsInOrder(
          <dynamic>[
            LocationMutationWaitingState(),
            LocationMutationFailureState()
          ]
        )
      );

      bloc.updateLocationSetOfHomeScreen();
    });

    test('Should emit LocationMutationFailureState when fail to get home-screen', () async {
      final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
      when(homeRepository.getHomeScreen()).thenThrow((_) => Future.value(Exception));

      expectLater(
        bloc.locationSetOfHomeScreenMutation,
        emitsInOrder(
          <dynamic>[
            LocationMutationWaitingState(),
            LocationMutationFailureState(),
          ]
        )
      );

      bloc.updateLocationSetOfHomeScreen();
    });
  });

  test('Should emit LocationMutationFailureState when fail to update home-screen', () async {
    final bloc = LocationBloc(homeRepository: homeRepository, locationRepository: locationRepository);
    final mockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: false, ringtoneSet: false);
    final updatedMockHomeScreen = HomeScreen(turnedOn: false, timeSet: true, locationSet: true, ringtoneSet: false);
    when(homeRepository.getHomeScreen()).thenAnswer((_) => Future.value(mockHomeScreen));
    when(homeRepository.updateHomeScreen(updatedMockHomeScreen)).thenThrow((_) => Future.value(Exception));

    expectLater(
      bloc.locationSetOfHomeScreenMutation,
      emitsInOrder(
        <dynamic>[
          LocationMutationWaitingState(),
          LocationMutationFailureState(),
        ]
      )
    );

    bloc.updateLocationSetOfHomeScreen();
  });
}