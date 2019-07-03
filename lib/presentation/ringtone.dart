import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'package:sleep_destroyer/model/ringtone.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/bloc/ringtone.dart';
import 'package:sleep_destroyer/presentation/common.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/ringtone.dart';

class RingtoneSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = RingtoneBloc(
      homeRepository: HomeRepository(fileStorage: fileStorage),
      ringtoneRepository: RingtoneRepository(fileStorage: fileStorage)
    );
    return BlocProvider(
      bloc: bloc,
      child: RingtonePageBlocContainer()
    );
  }
}

class RingtonePageBlocContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<RingtoneBloc>(context).ringtone,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data as RingtoneState;
          switch (state.runtimeType) {
            case RingtoneLoadingState:
              return LoadingIndicator();
            case RingtoneLoadSuccessState:
              final ringtone = (state as RingtoneLoadSuccessState).ringtone;
              return RingtoneMenus(ringtone: ringtone);
            case RingtoneLoadFailureState:
            default:
              return RingtoneMenus(ringtone: Ringtone.withDefault());
          }
        }
        return LoadingIndicator();
      }
    );
  }
}

class RingtoneMenus extends StatelessWidget {
  RingtoneMenus({
    this.ringtone
  });

  final Ringtone ringtone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          StreamBuilder(
            stream: BlocProvider.of<RingtoneBloc>(context).ringtoneSetOfHomeMutation,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ConfirmIconButton();
              }

              final state = snapshot.data as RingtoneMutationState;
              switch (state.runtimeType) {
                case UpdateRingtoneSetOfHomeScreenWaitingState:
                  return LoadingIndicator();
                case UpdateRingtoneSetOfHomeScreenSuccessState:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint('[UpdateRingtoneSetOfHomeScreenSuccessState] pop');
                  Navigator.pop(context);
                });
                  return ConfirmIconButton();
                case UpdateRingtoneSetOfHomeScreenFailureState:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    debugPrint('[UpdateRingtoneSetOfHomeScreenFailureState] pop');
                    Navigator.pop(context);
                  });
                  return ConfirmIconButton();
              }
            }
          )
        ],
      ),
      body: Center(
        child: VibrateMenuBlocContainer(vibrate: ringtone.vibrate)
      ),
    );
  }
}

class ConfirmIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done),
      onPressed: () => BlocProvider.of<RingtoneBloc>(context).updateRingtoneSetOfHomeScreen()
    );
  }
}

class VibrateMenuBlocContainer extends StatelessWidget {
  VibrateMenuBlocContainer({
    this.vibrate
  });

  final bool vibrate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<RingtoneBloc>(context).ringtoneMutation,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data as RingtoneMutationState;
          switch (state.runtimeType) {
            case UpdateVibrateLoadingState:
              return LoadingIndicator();
            case UpdateVibrateSuccessState:
              return VibrateMenu(vibrate: (state as UpdateVibrateSuccessState).vibrate);
            case UpdateVibrateFailureState:
              return VibrateMenu(vibrate: vibrate);
          }
        }
        return VibrateMenu(vibrate: vibrate);
      }
    );
  }
}

class VibrateMenu extends StatelessWidget {
  VibrateMenu({
    this.vibrate
  });

  final bool vibrate;
  final _size = 70.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.vibration), 
      onPressed: () async {
        final result = await Vibration.hasVibrator();
        if (result) {
          Vibration.vibrate();
        }
        BlocProvider.of<RingtoneBloc>(context).updateVibrate(!vibrate);
      },
      color: vibrate ? Colors.white : Colors.grey[600],
      iconSize: _size
    );
  }
}