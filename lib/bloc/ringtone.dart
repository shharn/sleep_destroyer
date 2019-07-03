import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/model/ringtone.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/ringtone.dart';

class RingtoneBloc extends BlocBase {
  RingtoneBloc({
    @required HomeRepository homeRepository,
    @required RingtoneRepository ringtoneRepository
  }) : _homeRepository = homeRepository,
    _ringtoneRepository = ringtoneRepository;

  final HomeRepository _homeRepository;
  final RingtoneRepository _ringtoneRepository;

  final _ringtone = StreamController<RingtoneState>();
  Stream<RingtoneState> get ringtone => _ringtone.stream;

  final _ringtoneMutation = StreamController<RingtoneMutationState>();
  Stream<RingtoneMutationState> get ringtoneMutation => _ringtoneMutation.stream;

  final _ringtoneSetOfHomeMutation = StreamController<RingtoneMutationState>();
  Stream<RingtoneMutationState> get ringtoneSetOfHomeMutation => _ringtoneSetOfHomeMutation.stream;

  Future loadData() async {
    debugPrint('[RingtoneBloc] loadData');
    _ringtone.sink.add(RingtoneState._loading());
    try {
      final ringtone = await _ringtoneRepository.getRingtone();
      _ringtone.sink.add(RingtoneState._success(ringtone));
    } catch (e) {
      debugPrint(e.toString());
      _ringtone.sink.add(RingtoneState._failure());
    }
  }

  Future updateVibrate(bool vibrate) async {
    debugPrint('[RingtoneBloc] updateVibrate - vibrate: $vibrate');
    _ringtoneMutation.sink.add(RingtoneMutationState._updateVibrateWaiting());
    try {
      var ringtone = await _ringtoneRepository.getRingtone();
      ringtone.vibrate = vibrate;
      final ok = await _ringtoneRepository.updateRingtone(ringtone);
      if (!ok) {
        _ringtoneMutation.sink.add(RingtoneMutationState._updateVibrateFailure());
        return;
      }
      _ringtoneMutation.sink.add(RingtoneMutationState._updateVibrateSuccess(vibrate));
    } catch (e) {
      debugPrint(e.toString());
      _ringtoneMutation.sink.add(RingtoneMutationState._updateVibrateFailure());
    }
  }

  Future updateRingtoneSetOfHomeScreen() async {
    debugPrint('[RingtoneBloc] updateRingtoneSetOfHomeScreen');
    _ringtoneSetOfHomeMutation.sink.add(RingtoneMutationState._updateRingtoneSetOfHomeScreenWaiting());
    try {
      var homeScreen = await _homeRepository.getHomeScreen();
      if (homeScreen.ringtoneSet) {
        _ringtoneSetOfHomeMutation.sink.add(RingtoneMutationState._updateRingtoneSetOfHomeScreenSuccess());
        return;
      }
      homeScreen.ringtoneSet = true;
      final ok = await _homeRepository.updateHomeScreen(homeScreen);
      if (ok) {
        _ringtoneSetOfHomeMutation.sink.add(RingtoneMutationState._updateRingtoneSetOfHomeScreenSuccess());
        return;
      }
      _ringtoneSetOfHomeMutation.sink.add(RingtoneMutationState._updateRingtoneSetOfHomeScreenFailure());
    } catch (e) {
      debugPrint(e.toString());
      _ringtoneSetOfHomeMutation.sink.add(RingtoneMutationState._updateRingtoneSetOfHomeScreenFailure());
    }
  }

  @override
  void init() {
    debugPrint('[RingtoneBloc] init');
    loadData();
  }

  @override
  void dispose() {
    _ringtone.close();
    _ringtoneMutation.close();
    _ringtoneSetOfHomeMutation.close();
  }
}

class RingtoneState {
  RingtoneState();
  factory RingtoneState._loading() => RingtoneLoadingState();
  factory RingtoneState._success(final Ringtone ringtone) => RingtoneLoadSuccessState(ringtone: ringtone);
  factory RingtoneState._failure() => RingtoneLoadFailureState();
}

class RingtoneLoadingState extends RingtoneState {
  @override
  bool operator==(Object other) => other is RingtoneLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class RingtoneLoadSuccessState extends RingtoneState {
  RingtoneLoadSuccessState({
    @required this.ringtone
  });

  final Ringtone ringtone;

  @override
  bool operator==(Object other) => other is RingtoneLoadSuccessState;

  @override
  int get hashCode => super.hashCode;
}

class RingtoneLoadFailureState extends RingtoneState {
  @override
  bool operator==(Object other) => other is RingtoneLoadFailureState;

  @override
  int get hashCode => super.hashCode;
}

class RingtoneMutationState {
  RingtoneMutationState();
  factory RingtoneMutationState._updateVibrateWaiting() => UpdateVibrateLoadingState();
  factory RingtoneMutationState._updateVibrateSuccess(final bool vibrate) => UpdateVibrateSuccessState(vibrate: vibrate);
  factory RingtoneMutationState._updateVibrateFailure() => UpdateVibrateFailureState();
  factory RingtoneMutationState._updateRingtoneSetOfHomeScreenWaiting() => UpdateRingtoneSetOfHomeScreenWaitingState();
  factory RingtoneMutationState._updateRingtoneSetOfHomeScreenSuccess() => UpdateRingtoneSetOfHomeScreenSuccessState();
  factory RingtoneMutationState._updateRingtoneSetOfHomeScreenFailure() => UpdateRingtoneSetOfHomeScreenFailureState();
}

class UpdateVibrateLoadingState extends RingtoneMutationState {
  @override
  bool operator==(Object other) => other is UpdateVibrateLoadingState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateVibrateSuccessState extends RingtoneMutationState {
  UpdateVibrateSuccessState({@required this.vibrate});

  final bool vibrate;
  
  @override
  bool operator==(Object other) => 
    other is UpdateVibrateSuccessState &&
    vibrate == other.vibrate;

  @override
  int get hashCode => hashValues(super.hashCode, vibrate);
}

class UpdateVibrateFailureState extends RingtoneMutationState {
  @override
  bool operator==(Object other) => other is UpdateVibrateFailureState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateRingtoneSetOfHomeScreenWaitingState extends RingtoneMutationState {
  @override
  bool operator==(Object other) => other is UpdateRingtoneSetOfHomeScreenWaitingState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateRingtoneSetOfHomeScreenSuccessState extends RingtoneMutationState {
  @override
  bool operator==(Object other) => other is UpdateRingtoneSetOfHomeScreenSuccessState;

  @override
  int get hashCode => super.hashCode;
}

class UpdateRingtoneSetOfHomeScreenFailureState extends RingtoneMutationState {
  @override
  bool operator==(Object other) => other is UpdateRingtoneSetOfHomeScreenFailureState;

  @override
  int get hashCode => super.hashCode;
}