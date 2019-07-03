import 'package:flutter/material.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/bloc/home.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/model/home.dart';
import 'package:sleep_destroyer/presentation/common.dart';
import 'package:sleep_destroyer/presentation/time.dart';
import 'package:sleep_destroyer/presentation/location.dart';
import 'package:sleep_destroyer/presentation/ringtone.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = HomeBloc(HomeRepository(fileStorage: fileStorage));
    return BlocProvider(
      bloc: bloc,
      child: HomePageBlocContainer()
    );
  }
}

class HomePageBlocContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('[HomePageBlocContainer] build');
    return StreamBuilder(
      stream: BlocProvider.of<HomeBloc>(context).homeScreen,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data as HomeState;
          switch (state.runtimeType) {
            case HomeLoadingState:
              return LoadingIndicator();
            case HomeDataLoadedState:
              final homeScreen = (state as HomeDataLoadedState).data;
              debugPrint('[HomeDataLoadedState] ${homeScreen.toString()}');
              return HomePageContainer(homeScreen: homeScreen);
            default:
              final fallbackData = HomeScreen.withDefault();
              debugPrint('${state.runtimeType.toString()}');
              return HomePageContainer(homeScreen: fallbackData);
          }
        } else {
          return LoadingIndicator();
        }
     }
    );
  }
}

class HomePageContainer extends StatelessWidget {
  HomePageContainer({@required HomeScreen homeScreen}) : _homeScreen = homeScreen;

  final HomeScreen _homeScreen;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      actions: <Widget>[
          StreamBuilder(
            stream: BlocProvider.of<HomeBloc>(context).homeScreenMutation,
            builder: (BuildContext context, AsyncSnapshot mutationSnapshot) {
              if (mutationSnapshot.hasData) {
                final state = mutationSnapshot.data as HomeMutationState;
                switch (state.runtimeType) {
                  case UpdateAlarmSwitchSuccess:
                    debugPrint('[UpdateAlarmSwitchSuccess]');
                    final turnedOn = (state as UpdateAlarmSwitchSuccess).updatedValue;
                    return AlarmSwitch(turnedOn: turnedOn);
                  case UpdateAlarmSwitchFailure:
                    debugPrint('[UpdateAlarmSwitchFailure]');
                    final turnedOn = (state as UpdateAlarmSwitchFailure).updatedValue;
                    return AlarmSwitch(turnedOn: turnedOn);
                  case UpdateAlarmSwitchBadPrerequisite:
                    debugPrint('[UpdateAlarmSwitchBadPrerequisite]');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final snackBar = SnackBar(
                        content: Text('모든 설정값을 등록해주세요.'),
                        duration: Duration(seconds: 2)
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                      BlocProvider.of<HomeBloc>(context).initMutationState();
                    });
                    return AlarmSwitch(turnedOn: _homeScreen.turnedOn);
                  default:
                    return AlarmSwitch(turnedOn: _homeScreen.turnedOn);
                }
              }
              return AlarmSwitch(
                turnedOn: _homeScreen.turnedOn,
              );
            }
          )
      ]
    ),
    body: MenuContainer(
        timeSet: _homeScreen.timeSet,
        locationSet: _homeScreen.locationSet,
        ringtoneSet: _homeScreen.ringtoneSet,
      ),
    );
  }
}

class AlarmSwitch extends StatelessWidget {
  AlarmSwitch({ @required this.turnedOn });

  final bool turnedOn;
  
  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: Colors.blue[600],
      value: turnedOn,
      onChanged:(bool turnedOn) {
        debugPrint('[AlarmSwitch] onChanged with $turnedOn');
        BlocProvider.of<HomeBloc>(context).updateAlarmSwitch(turnedOn);
      }
    );
  }
}

class MenuContainer extends StatelessWidget {
  MenuContainer({
    @required this.timeSet,
    @required this.locationSet,
    @required this.ringtoneSet
  });

  final bool timeSet;
  final bool locationSet;
  final bool ringtoneSet;
  final dividerHeight = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TimeMenu(timeSet: timeSet),
        Divider(height: dividerHeight),
        LocationMenu(locationSet: locationSet),
        Divider(height: dividerHeight),
        RingtoneMenu(ringtoneSet: ringtoneSet),
      ]
    );
  }
}

abstract class CenteredLargeMenu extends StatelessWidget{
  final iconSize = 70.0;
  static final turnOffColor = Colors.grey[600];
  static final turnOnColor = Colors.white;
  final Icon icon;

  CenteredLargeMenu(this.icon);
    
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        iconSize: iconSize,
        icon: icon,
        onPressed: onPressed(context),
      ),
    );
  }

  VoidCallback onPressed(BuildContext context);
}

class TimeMenu extends CenteredLargeMenu {
  TimeMenu({
    @required this.timeSet
  }) : 
  super(Icon(
    Icons.alarm,
    color: timeSet ? CenteredLargeMenu.turnOnColor: CenteredLargeMenu.turnOffColor
  ));

  final timeSet;

  @override
  VoidCallback onPressed(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimeSettingPage(),
        )
      );
    };
  }
}

class LocationMenu extends CenteredLargeMenu {
  LocationMenu({
    @required this.locationSet
  }) : 
  super(Icon(
    Icons.place,
    color: locationSet ? CenteredLargeMenu.turnOnColor : CenteredLargeMenu.turnOffColor
  ));

  final locationSet;

  @override
  VoidCallback onPressed(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationSettingPage()
        ),
      );
    };
  }
}

class RingtoneMenu extends CenteredLargeMenu {
  RingtoneMenu({
    @required this.ringtoneSet
  }) : 
  super(Icon(
    Icons.audiotrack,
    color: ringtoneSet ? CenteredLargeMenu.turnOnColor: CenteredLargeMenu.turnOffColor
  ));

  final ringtoneSet;

  @override
  VoidCallback onPressed(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RingtoneSettingPage()
        ),
      );
    };
  }
}