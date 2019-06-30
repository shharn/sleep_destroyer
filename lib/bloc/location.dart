import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/model/location.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/location.dart';

class LocationBloc extends BlocBase {
  LocationBloc({
    @required HomeRepository homeRepository,
    @required LocationRepository locationRepository
  })
    : _homeRepository = homeRepository,
      _locationRepository = locationRepository;

  final HomeRepository _homeRepository;
  final LocationRepository _locationRepository;

  final _location = StreamController<LocationState>();
  Stream<LocationState> get location => _location.stream;

  final _locationSetOfHomeScreenMutation = StreamController<LocationMutationState>();
  Stream<LocationMutationState> get locationSetOfHomeScreenMutation => _locationSetOfHomeScreenMutation.stream;

  Future getLocations() async {
    _location.sink.add(LocationState._waiting());
    try {
      final currentLocation = await _locationRepository.getCurrentLocation();
      final storedLocation = await _locationRepository.getLocation();
      _location.sink.add(LocationState.success(
          currentLocation: currentLocation,
          storedLocation: storedLocation
        ));
    } catch (e) {
      debugPrint(e.toString());
      _location.sink.add(LocationState._failure());
    }
  }

  Future<bool> saveLocation(Location location) async {
    try {
      final locationOk = await _locationRepository.updateLocation(location);
      return locationOk;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future updateLocationSetOfHomeScreen() async {
    _locationSetOfHomeScreenMutation.sink.add(LocationMutationState._waiting());
    try {
      var homeScreen = await _homeRepository.getHomeScreen();
      if (!homeScreen.locationSet) {
        homeScreen.locationSet = true;
        final homeOk = await _homeRepository.updateHomeScreen(homeScreen);
        if (!homeOk) {
          _locationSetOfHomeScreenMutation.sink.add(LocationMutationState._failure());
          return;
        }
      }
      _locationSetOfHomeScreenMutation.sink.add(LocationMutationState._success());
    } catch (e) {
      debugPrint(e.toString());
      _locationSetOfHomeScreenMutation.sink.add(LocationMutationState._failure());
    }
  }

  @override
  void dispose() {
    _location.close();
    _locationSetOfHomeScreenMutation.close();
  }
}

class LocationState {
  LocationState();
  factory LocationState._waiting() = LocationLoadingState;
  factory LocationState.success({ 
    @required LatLng currentLocation,
    @required Location storedLocation
  }) => LocationLoadSuccessState(currentLocation: currentLocation, storedLocation: storedLocation);
  factory LocationState._failure() = LocationLoadFailureState;
}

class LocationLoadingState extends LocationState {
  @override
  bool operator==(Object other) => other is LocationLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class LocationLoadSuccessState extends LocationState {
  LocationLoadSuccessState({
    this.currentLocation,
    this.storedLocation
  });

  final LatLng currentLocation;
  final Location storedLocation;

  @override
  bool operator==(Object other) => 
    other is LocationLoadSuccessState && 
    currentLocation == other.currentLocation && 
    storedLocation == other.storedLocation;

  @override
  int get hashCode => hashValues(super.hashCode, currentLocation, storedLocation);
}

class LocationLoadFailureState extends LocationState {
  @override
  bool operator==(Object other) => other is LocationLoadFailureState;

  @override
  int get hashCode => super.hashCode;
}


class LocationMutationState {
  LocationMutationState();
  factory LocationMutationState._waiting() = LocationMutationWaitingState;
  factory LocationMutationState._success() = LocationMutationSuccessState;
  factory LocationMutationState._failure() = LocationMutationFailureState;
}

class LocationMutationWaitingState extends LocationMutationState {
  @override
  bool operator==(Object other) => other is LocationMutationWaitingState;

  @override
  int get hashCode => super.hashCode;
}

class LocationMutationSuccessState extends LocationMutationState {
  @override
  bool operator==(Object other) => other is LocationMutationSuccessState;

  @override
  int get hashCode => super.hashCode;
}

class LocationMutationFailureState extends LocationMutationState {
  @override
  bool operator==(Object other) => other is LocationMutationFailureState;

  @override
  int get hashCode => super.hashCode;
}