import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sleep_destroyer/model/home.dart';
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

    Time get currentTime => _timeRepository.time;

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
        debugPrint(e);
        _dataLoadSubject.add(TimeState._failToLoadDataState());
      }
    }

    Future updateTimeOfDay(TimeOfDay time) async {
      final ok = await _timeRepository.updateTime(time);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._timeOfDaySuccess(time));
        return;
      }
      _dataMutationSubject.add(TimeMutationState._timeOfDayFailure(currentTime.timeOfDay));
    }

    Future updateDayOfWeeks(List<bool> dayOfWeeks) async {
      final ok = await _timeRepository.updateDayOfWeeks(dayOfWeeks);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._dayOfWeeksSuccess(dayOfWeeks));
        return;
      }
      _dataMutationSubject.add(TimeMutationState._dayOfWeeksFailure(currentTime.dayOfWeeks));
    }

    Future updateRepeat(bool repeat) async {
      final ok = await _timeRepository.updateRepeat(repeat);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._repeatSuccess(repeat));
        return;
      }
      _dataMutationSubject.add(TimeMutationState._repeatFailure(currentTime.repeat));
    }

    Future updateTimeSetOfHome() async {
      var homeScreen = await _homeRepository.getHomeScreen();
      if (homeScreen.timeSet) {
        _dataMutationSubject.add(TimeMutationState._homeTimeSetSuccess());
        return;
      }

      homeScreen.timeSet = true;
      final ok = await _homeRepository.updateHomeScreen(homeScreen);
      if (ok) {
        _dataMutationSubject.add(TimeMutationState._homeTimeSetSuccess());
        return;
      }
      _dataMutationSubject.add(TimeMutationState._homeTimeSetFailure());
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
  factory TimeState._dataLoadedState(Time data) = TimeDataLoadedState;
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
  factory TimeMutationState._timeOfDaySuccess(TimeOfDay updated) => UpdateTimeOfDaySuccess(updated);
  factory TimeMutationState._timeOfDayFailure(TimeOfDay updated) => UpdateTimeOfDayFailure(updated);
  factory TimeMutationState._dayOfWeeksSuccess(List<bool> updated) => UpdateDayOfWeeksSuccess(updated);
  factory TimeMutationState._dayOfWeeksFailure(List<bool> updated) => UpdateDayOfWeeksFailure(updated);
  factory TimeMutationState._repeatSuccess(bool updated) => UpdateRepeatSuccess(updated);
  factory TimeMutationState._repeatFailure(bool updated) => UpdateRepeatFailure(updated);
  factory TimeMutationState._homeTimeSetSuccess() = UpdateHomeTimeSetSuccess;
  factory TimeMutationState._homeTimeSetFailure() = UpdateHomeTimeSetFailure;
}

class UpdateTimeOfDaySuccess extends TimeMutationState {
  UpdateTimeOfDaySuccess(TimeOfDay updated)
    : assert(updated != null),
      this.updated = updated;

    final TimeOfDay updated;

    @override
    bool operator==(Object other) =>
      other is UpdateTimeOfDaySuccess &&
      this.updated == other.updated;

    @override
    int get hashCode => hashValues(super.hashCode, updated);
}

class UpdateTimeOfDayFailure extends TimeMutationState {
  UpdateTimeOfDayFailure(TimeOfDay updated)
    : assert(updated != null),
      this.updated = updated;

  final TimeOfDay updated;

  @override
  bool operator==(Object other) =>
    other is UpdateTimeOfDayFailure &&
    this.updated == other.updated;

  @override
  int get hashCode => hashValues(super.hashCode, updated);
}

class UpdateDayOfWeeksSuccess extends TimeMutationState {
  UpdateDayOfWeeksSuccess(List<bool> updated)
    : assert(updated != null),
      this.updated = updated;
  
  final List<bool> updated;

  @override
  bool operator==(Object other) =>
    other is UpdateDayOfWeeksSuccess &&
    DeepCollectionEquality().equals(updated, other.updated);

  @override
  int get hashCode => hashValues(super.hashCode, updated);
}

 class UpdateDayOfWeeksFailure extends TimeMutationState {
   UpdateDayOfWeeksFailure(List<bool> updated)
    : assert(updated != null),
      this.updated = updated;
  
  final List<bool> updated;

  @override
  bool operator==(Object other) =>
    other is UpdateDayOfWeeksFailure &&
    DeepCollectionEquality().equals(updated, other.updated);

  @override
  int get hashCode => hashValues(super.hashCode, updated);
 }

class UpdateRepeatSuccess extends TimeMutationState {
  UpdateRepeatSuccess(bool updated)
    : assert(updated != null),
      this.updated = updated;
    
  final bool updated;

  @override
  bool operator==(Object other) =>
    other is UpdateRepeatSuccess &&
    updated == other.updated;

  @override
  int get hashCode => super.hashCode;
}

class UpdateRepeatFailure extends TimeMutationState {
  UpdateRepeatFailure(bool updated)
    : assert(updated != null),
      this.updated = updated;
  
  final bool updated;

  @override
  bool operator==(Object other) =>
    other is UpdateRepeatFailure &&
    updated == other.updated;

  @override
  int get hashCode => super.hashCode;
}

class UpdateHomeTimeSetSuccess extends TimeMutationState {
  @override
  bool operator==(Object other) => other is UpdateHomeTimeSetSuccess;

  @override
  int get hashCode => super.hashCode;
}

class UpdateHomeTimeSetFailure extends TimeMutationState {
  @override
  bool operator==(Object other) => other is UpdateHomeTimeSetFailure;

  @override
  int get hashCode => super.hashCode;
}