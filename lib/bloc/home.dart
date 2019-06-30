import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/repository/home.dart';

class HomeBloc extends BlocBase {
  HomeBloc(HomeRepository repository) 
    : assert(repository != null),
    _repository = repository;

  final HomeRepository _repository;

  final _homeScreen = StreamController<HomeState>();
  Stream<HomeState> get homeScreen => _homeScreen.stream;

  final _homeScreenMutation = StreamController<HomeMutationState>();
  Stream<HomeMutationState> get homeScreenMutation => _homeScreenMutation.stream;

  HomeScreen data;
  
  Future loadData() async {
    debugPrint('[HomeBloc] loadData');
    _homeScreen.sink.add(HomeState._loadingState());
    try {
      data = await _repository.getHomeScreen();
      _homeScreen.sink.add(HomeState._dataLoadedState(data));
    } catch (e) {
      _homeScreen.sink.add(HomeState._failToLoadDataState());
    }
  }

  Future updateAlarmSwitch(bool turnedOn) async {
    debugPrint('[HomeBloc] updateAlarmSwitch - turnedOn - $turnedOn');
    if (data == null) {
      data = await _repository.getHomeScreen();
    }
    
    if (turnedOn && !(data.timeSet && data.locationSet && data.ringtoneSet)) {
      _homeScreenMutation.sink.add(HomeMutationState._badPrerequisite());
      return;
    }
    
    data.turnedOn = turnedOn;
    final ok = await _repository.updateHomeScreen(data);
    if (ok) {
      _homeScreenMutation.sink.add(HomeMutationState._success(turnedOn));
    } else {
      data.turnedOn = !turnedOn;
      _homeScreenMutation.sink.add(HomeMutationState._failure(!turnedOn));
    }
  }

  Future initMutationState() async {
    debugPrint('[HomeBloc] initMutationState');
    _homeScreenMutation.sink.add(HomeMutationState._noop());
  }

  @override
  void dispose() {
    _homeScreen.close();
    _homeScreenMutation.close();
  }
}

class HomeState {
  HomeState();
  factory HomeState._loadingState() = HomeLoadingState;  
  factory HomeState._dataLoadedState(HomeScreen data) => HomeDataLoadedState(data);
  factory HomeState._failToLoadDataState() = HomeDataLoadFailureState;
}

class  HomeInitState extends HomeState {}

class HomeLoadingState extends HomeState {
  @override
  bool operator==(Object other) => other is HomeLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class HomeDataLoadedState extends HomeState {
  HomeDataLoadedState(this.data);
  final HomeScreen data;

  @override
  bool operator==(Object other) => 
    other is HomeDataLoadedState &&
    data == other.data;

  @override
  int get hashCode => hashValues(super.hashCode, data);
}

class HomeDataLoadFailureState extends HomeState {
  @override
  bool operator==(Object other) => other is HomeDataLoadFailureState;

  @override
  int get hashCode => super.hashCode;
}

class HomeMutationState {
  HomeMutationState();
  factory HomeMutationState._noop() => NoopMutationState();
  factory HomeMutationState._badPrerequisite() => UpdateAlarmSwitchBadPrerequisite();
  factory HomeMutationState._success(bool updatedValue) => UpdateAlarmSwitchSuccess(updatedValue: updatedValue);
  factory HomeMutationState._failure(bool updatedValue) => UpdateAlarmSwitchFailure(updatedValue: updatedValue);
}

class NoopMutationState extends HomeMutationState {
  @override
  bool operator==(Object other) => other is NoopMutationState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateAlarmSwitchBadPrerequisite extends HomeMutationState {
  @override
  bool operator==(Object other) => other is UpdateAlarmSwitchBadPrerequisite;

  @override
  int get hashCode => super.hashCode;
}

class UpdateAlarmSwitchSuccess extends HomeMutationState {
  UpdateAlarmSwitchSuccess({bool updatedValue}) 
  : assert(updatedValue != null), 
    this.updatedValue = updatedValue;

  final bool updatedValue;

  @override
  bool operator==(Object other) => 
    other is UpdateAlarmSwitchSuccess && 
    this.updatedValue == other.updatedValue;

  @override
  int get hashCode => hashValues(super.hashCode, updatedValue);
}

class UpdateAlarmSwitchFailure extends HomeMutationState {
  UpdateAlarmSwitchFailure({bool updatedValue}) 
  : assert(updatedValue != null), 
    this.updatedValue = updatedValue;

  final bool updatedValue;

  @override
  bool operator==(Object other) => 
    other is UpdateAlarmSwitchFailure && 
    this.updatedValue == other.updatedValue;

  @override
  int get hashCode => hashValues(super.hashCode, updatedValue);
}
