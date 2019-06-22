import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sleep_destroyer/model/time.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/time.dart';

class TimeBloc extends BlocBase {
  TimeBloc(HomeRepository homeRepository, TimeRepository timeRepository)
    : assert(homeRepository != null),
      assert(timeRepository != null),
      _homeRepository = homeRepository,
      _timeRepository = timeRepository;

    final HomeRepository _homeRepository;
    final TimeRepository _timeRepository;

    final _dataLoadSubject = new PublishSubject<TimeState>();
    Stream<TimeState> get dataLoadStream => _dataLoadSubject.stream;

    final _dataMutationSubject = new PublishSubject<TimeMutationState>();
    Stream<TimeMutationState> get dataMutationStream => _dataMutationSubject.stream;

    Future loadData() async {
      _dataLoadSubject.add(TimeState._loadingState());
      try {
        final timeData = await _timeRepository.getTime();
        _dataLoadSubject.add(TimeState._dataLoadedState(timeData));
      } catch (e) {
        _dataLoadSubject.add(TimeState._failToLoadDataState());
      }
    }

    Future updateTimeOfDay(TimeOfDay time) async {
      final ok = await _timeRepository.updateTime(time);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._timeOfDaySuccess(time));
        return;
      }
      final oldTime = await _timeRepository.getTime();
      _dataMutationSubject.add(TimeMutationState._timeOfDayFailure(oldTime.timeOfDay));
    }

    Future updateDayOfWeeks(List<bool> dayOfWeeks) async {
      final ok = await _timeRepository.updateDayOfWeeks(dayOfWeeks);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._dayOfWeeksSuccess(dayOfWeeks));
        return;
      }
      final oldTime = await _timeRepository.getTime();
      _dataMutationSubject.add(TimeMutationState._dayOfWeeksFailure(oldTime.dayOfWeeks));
    }

    Future updateRepeat(bool repeat) async {
      final ok = await _timeRepository.updateRepeat(repeat);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._repeatSuccess(repeat));
        return;
      }
      final oldTime = await _timeRepository.getTime();
      _dataMutationSubject.add(TimeMutationState._repeatFailure(oldTime.repeat));
    }

    Future updateTimeSetOfHome() async {
      _dataMutationSubject.add(TimeMutationState._timeSetOfHomeLoading());
      var homeScreen = await _homeRepository.getHomeScreen();
      if (homeScreen.timeSet) {
        _dataMutationSubject.add(TimeMutationState._timeSetOfHomeSuccess());
        return;
      }

      homeScreen.timeSet = true;
      final ok = await _homeRepository.updateHomeScreen(homeScreen);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._timeSetOfHomeSuccess());
        return;
      }
      _dataMutationSubject.add(TimeMutationState._timeSetOfHomeFailure());
    }

    @override
    void dispose() {
      _dataLoadSubject.close();
      _dataMutationSubject.close();
    }
}

class TimeState {
  TimeState();
  factory TimeState._loadingState() = TimeLoadingState;
  factory TimeState._dataLoadedState(Time data) => TimeDataLoadedState(data);
  factory TimeState._failToLoadDataState() = TimeDataLoadFailureState;
}

class TimeLoadingState extends TimeState {
  @override
  bool operator==(Object other) => other is TimeLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class TimeDataLoadedState extends TimeState {
  TimeDataLoadedState(this.data);
  final Time data;

  @override
  bool operator==(Object other) => other is TimeDataLoadedState && data == other.data;

  @override
  int get hashCode => hashValues(super.hashCode, data);
}

class TimeDataLoadFailureState extends TimeState {
  @override
  bool operator==(Object other) => other is TimeDataLoadFailureState;

  @override
  int get hashCode => super.hashCode;
}

class TimeMutationState {
  TimeMutationState();
  factory TimeMutationState._timeOfDaySuccess(TimeOfDay updated) => UpdateTimeOfDaySuccessState(updated);
  factory TimeMutationState._timeOfDayFailure(TimeOfDay updated) => UpdateTimeOfDayFailureState(updated);
  factory TimeMutationState._dayOfWeeksSuccess(List<bool> updated) => UpdateDayOfWeeksSuccessState(updated);
  factory TimeMutationState._dayOfWeeksFailure(List<bool> updated) => UpdateDayOfWeeksFailureState(updated);
  factory TimeMutationState._repeatSuccess(bool updated) => UpdateRepeatSuccessState(updated);
  factory TimeMutationState._repeatFailure(bool updated) => UpdateRepeatFailureState(updated);
  factory TimeMutationState._timeSetOfHomeLoading() = UpdateTimeSetOfHomeLoadingState;
  factory TimeMutationState._timeSetOfHomeSuccess() = UpdateTimeSetOfHomeSuccessState;
  factory TimeMutationState._timeSetOfHomeFailure() = UpdateTimeSetOfHomeFailureState;
}

class UpdateTimeOfDaySuccessState extends TimeMutationState {
  UpdateTimeOfDaySuccessState(TimeOfDay updated)
    : assert(updated != null),
      this.updated = updated;

    final TimeOfDay updated;

    @override
    bool operator==(Object other) =>
      other is UpdateTimeOfDaySuccessState &&
      this.updated == other.updated;

    @override
    int get hashCode => hashValues(super.hashCode, updated);
}

class UpdateTimeOfDayFailureState extends TimeMutationState {
  UpdateTimeOfDayFailureState(TimeOfDay updated)
    : assert(updated != null),
      this.updated = updated;

  final TimeOfDay updated;

  @override
  bool operator==(Object other) =>
    other is UpdateTimeOfDayFailureState &&
    this.updated == other.updated;

  @override
  int get hashCode => hashValues(super.hashCode, updated);
}

class UpdateDayOfWeeksSuccessState extends TimeMutationState {
  UpdateDayOfWeeksSuccessState(List<bool> updated)
    : assert(updated != null),
      this.updated = updated;
  
  final List<bool> updated;

  @override
  bool operator==(Object other) =>
    other is UpdateDayOfWeeksSuccessState &&
    DeepCollectionEquality().equals(updated, other.updated);

  @override
  int get hashCode => hashValues(super.hashCode, DeepCollectionEquality().hash(updated));
}

 class UpdateDayOfWeeksFailureState extends TimeMutationState {
   UpdateDayOfWeeksFailureState(List<bool> updated)
    : assert(updated != null),
      this.updated = updated;
  
  final List<bool> updated;

  @override
  bool operator==(Object other) =>
    other is UpdateDayOfWeeksFailureState &&
    DeepCollectionEquality().equals(updated, other.updated);

  @override
  int get hashCode => hashValues(super.hashCode, DeepCollectionEquality().hash(updated));
 }

class UpdateRepeatSuccessState extends TimeMutationState {
  UpdateRepeatSuccessState(bool updated)
    : assert(updated != null),
      this.updated = updated;
    
  final bool updated;

  @override
  bool operator==(Object other) =>
    other is UpdateRepeatSuccessState &&
    updated == other.updated;

  @override
  int get hashCode => super.hashCode;
}

class UpdateRepeatFailureState extends TimeMutationState {
  UpdateRepeatFailureState(bool updated)
    : assert(updated != null),
      this.updated = updated;
  
  final bool updated;

  @override
  bool operator==(Object other) =>
    other is UpdateRepeatFailureState &&
    updated == other.updated;

  @override
  int get hashCode => super.hashCode;
}

class UpdateTimeSetOfHomeLoadingState extends TimeMutationState {
  @override
  bool operator==(Object other) => other is UpdateTimeSetOfHomeLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateTimeSetOfHomeSuccessState extends TimeMutationState {
  @override
  bool operator==(Object other) => other is UpdateTimeSetOfHomeSuccessState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateTimeSetOfHomeFailureState extends TimeMutationState {
  @override
  bool operator==(Object other) => other is UpdateTimeSetOfHomeFailureState;

  @override
  int get hashCode => super.hashCode;
}