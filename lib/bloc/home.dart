import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/repository/home.dart';

class HomeBloc extends BlocBase {
  HomeBloc(HomeRepository repository) 
    : assert(repository != null),
    _repository = repository;

  final HomeRepository _repository;

  final _dataLoadSubject = new PublishSubject<HomeState>();
  Stream<HomeState> get dataLoadStream => _dataLoadSubject.stream;

  final _dataMutationSubject = new PublishSubject<HomeMutationState>();
  Stream<HomeMutationState> get dataMutationStream => _dataMutationSubject.stream;

  HomeScreen data;
  
  Future loadData() async {
    _dataLoadSubject.add(HomeState._loadingState());
    try {
      data = await _repository.getHomeScreen();
      _dataLoadSubject.add(HomeState._dataLoadedState(data));
    } catch (e) {
      _dataLoadSubject.add(HomeState._failToLoadDataState());
    }
  }

  Future updateAlarmSwitch(bool turnedOn) async {
    data.turnedOn = turnedOn;
    final ok = await _repository.updateHomeScreen(data);
    if (ok) {
      _dataMutationSubject.add(HomeMutationState._success(turnedOn));
    } else {
      data.turnedOn = !turnedOn;
      _dataMutationSubject.add(HomeMutationState._failure(!turnedOn));
    }
  }

  @override
  void dispose() {
    _dataLoadSubject.close();
    _dataMutationSubject.close();
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
  factory HomeMutationState._success(bool updatedValue) => UpdateAlarmSwitchSuccess(updatedValue: updatedValue);
  factory HomeMutationState._failure(bool updatedValue) => UpdateAlarmSwitchFailure(updatedValue: updatedValue);
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
