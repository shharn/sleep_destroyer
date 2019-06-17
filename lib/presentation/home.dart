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
    final bloc = HomeBloc(HomeRepository(fileStorage));
    bloc.loadData();
    return BlocProvider(
      bloc: bloc,
      child: HomePageContainer(),
    );
  }
}

class HomePageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<HomeBloc>(context).dataLoadStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data as HomeState;
          var homeScreen = HomeScreen.withDefault();
          switch (state.runtimeType) {
            case HomeLoadingState:
              return LoadingIndicator();
            case HomeDataLoadedState:
              homeScreen = (state as HomeDataLoadedState).data;
              break;
            default:
              break;
          }
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                  StreamBuilder(
                    stream: BlocProvider.of<HomeBloc>(context).dataMutationStream,
                    builder: (BuildContext context, AsyncSnapshot mutationSnapshot) {
                      var turnedOn = homeScreen.turnedOn;
                      if (mutationSnapshot.hasData) {
                        final state = mutationSnapshot.data as HomeMutationState;
                        switch (state.runtimeType) {
                          case UpdateAlarmSwitchSuccess:
                            turnedOn = (state as UpdateAlarmSwitchSuccess).updatedValue;
                            break;
                          case UpdateAlarmSwitchFailure:
                            turnedOn = (state as UpdateAlarmSwitchFailure).updatedValue;
                            break;
                          default:
                            break;
                        }
                      }
                      return AlarmSwitch(
                        turnedOn: turnedOn,
                      );
                    }
                  )
              ]
            ),
            body: MenuContainer(
                timeSet: homeScreen.timeSet,
                locationSet: homeScreen.locationSet,
                ringtoneSet: homeScreen.ringtoneSet,
              ),
            );
        } else {
          return LoadingIndicator();
        }
     }
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
      onChanged:_updateSwitch(context),
    );
  }

  ValueChanged<bool> _updateSwitch(BuildContext context) {
    return (bool turnedOn) {
      BlocProvider.of<HomeBloc>(context).updateAlarmSwitch(turnedOn);
    };
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