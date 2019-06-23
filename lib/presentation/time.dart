import 'package:flutter/material.dart';

import 'package:sleep_destroyer/model/time.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/bloc/time.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/time.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/presentation/common.dart';

class TimeSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = TimeBloc(HomeRepository(fileStorage: fileStorage), TimeRepository(fileStorage: fileStorage));
    bloc.loadData();
    debugPrint('[TimePage] build');
    return BlocProvider(
      bloc: bloc,
      child: TimePageBlocContainer(),
    );
  }
}

class TimePageBlocContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<TimeBloc>(context).dataLoadStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data as TimeState;
          switch (state.runtimeType) {
            case TimeLoadingState:
              return LoadingIndicator();
            case TimeDataLoadedState:
              final time = (state as TimeDataLoadedState).data;
              return TimePageContainer(initialTime: time); 
            default:
              final time = Time.withDefault();
              return TimePageContainer(initialTime: time);
          }
        }
        return LoadingIndicator();
      }
    );
  }
}

class TimePageContainer extends StatelessWidget {
  TimePageContainer({
    @required Time initialTime
  }) : _initialTime = initialTime;

  final Time _initialTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          StreamBuilder(
            stream: BlocProvider.of<TimeBloc>(context).timeSetOfHomeMutationSubject,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data as TimeMutationState;
                switch (state.runtimeType) {
                  case UpdateTimeSetOfHomeLoadingState:
                    return LoadingIndicator();
                  case UpdateTimeSetOfHomeSuccessState:
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      debugPrint('[UpdatetimeSetOfHomeSuccessState] pop');
                      Navigator.pop(context);
                    });
                    return  LoadingIndicator();
                  case UpdateTimeSetOfHomeFailureState:
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      debugPrint('[UpdatetimeSetOfHomeFailureState] pop');
                      Navigator.pop(context);
                    });
                    return  LoadingIndicator();
                  default:
                    return ConfirmIconButton();
                }
              }
              return ConfirmIconButton();
            }
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 0.0, right: 20.0, bottom: 0.0, left: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  border: Border.all(color: Colors.grey[800]),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TimeArea(initialTimeOfDay: _initialTime.timeOfDay),
                      DayOfWeeksArea(initialDayOfWeeks: _initialTime.dayOfWeeks),
                      RepeatArea(initialRepeat: _initialTime.repeat),
                    ]
                  ),
                ),
              ),
            ]
          )
        )
      );
  }
}

class ConfirmIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done),
      onPressed: () => BlocProvider.of<TimeBloc>(context).updateTimeSetOfHome()
    );
  }
}

class TimeArea extends StatelessWidget {
  TimeArea({
    @required TimeOfDay initialTimeOfDay
  }) : _initialTimeOfDay = initialTimeOfDay;

  final TimeOfDay _initialTimeOfDay;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<TimeBloc>(context).timeOfDayMutationStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return TimeDisplay(time: _initialTimeOfDay ?? TimeOfDay.now());
        }
        final state = snapshot.data as TimeMutationState;
        switch (state.runtimeType) {
          case UpdateTimeOfDaySuccessState:
            final timeOfDay = (state as UpdateTimeOfDaySuccessState).updated;
            return TimeDisplay(time: timeOfDay);
          case UpdateTimeOfDayFailureState:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final snackbar = SnackBar(
                content: Text('저장하는 도중 오류가 발생했습니다.'),
                duration: Duration(seconds: 2)
              );
              Scaffold.of(context).showSnackBar(snackbar);
            });
            final timeOfDay = (state as UpdateTimeOfDayFailureState).updated;
            return TimeDisplay(time: timeOfDay);
          default:
            return null;
        }
      }
    );
  }
}

class TimeDisplay extends StatelessWidget {
  TimeDisplay({
    @required TimeOfDay time
  }) : this._time = time;

  final double _fontSize = 60.0;

  final TimeOfDay _time;
  int get _hourOfPeriod => _time.hourOfPeriod;
  int get _minute => _time.minute;

  String get _periodString => _time.period == DayPeriod.am ? "AM" : "PM";
  String get _formattedHour => _hourOfPeriod < 10 ? "0${_hourOfPeriod.toString()}" : _hourOfPeriod.toString();
  String get _formattedMinute => _minute < 10 ? "0${_minute.toString()}" : _minute.toString();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay updatedTime = await showTimePicker(
          context: context,
          initialTime: _time,
        );
        if (updatedTime != null) {
          BlocProvider.of<TimeBloc>(context).updateTimeOfDay(updatedTime);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                '$_periodString  $_formattedHour : $_formattedMinute',
                style: TextStyle(fontSize: _fontSize)
              ),
            ],
          ),
        ]
      )
    );
  }
}

class DayOfWeeksArea extends StatelessWidget {
  DayOfWeeksArea({
    @required List<bool> initialDayOfWeeks
  }) : _inintialDayOfWeeks = initialDayOfWeeks;

  final List<bool> _inintialDayOfWeeks;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<TimeBloc>(context).dayOfWeeksMutationStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return DayOfWeeksDisplay(dayOfWeeks: _inintialDayOfWeeks ?? <bool>[false, false, false, false, false, false, false]);
        }

        final state = snapshot.data as TimeMutationState;
        switch (state.runtimeType) {
          case UpdateDayOfWeeksSuccessState:
            final dayOfWeeks = (state as UpdateDayOfWeeksSuccessState).updated;
            return DayOfWeeksDisplay(dayOfWeeks: dayOfWeeks);
          case UpdateDayOfWeeksFailureState:
            final dayOfWeeks = (state as UpdateDayOfWeeksFailureState).updated;
            return DayOfWeeksDisplay(dayOfWeeks: dayOfWeeks);
          default:
            return null;
        }
      }
    );
  }
}

class DayOfWeeksDisplay extends StatelessWidget {
  DayOfWeeksDisplay({
    @required List<bool> dayOfWeeks
  }) : this._dayOfWeeks = dayOfWeeks;

  final List<bool> _dayOfWeeks;
  final _daysOfWeekDisplayText = <String>[ "일", "월", "화", "수", "목", "금", "토" ];

  @override
  Widget build(BuildContext context) {
    var columns = <Widget>[];
    for (var i = 0; i < _dayOfWeeks.length; i++) {
      var column = DayOfWeekItem(
        position: i,
        selected: _dayOfWeeks[i],
        displayText: _daysOfWeekDisplayText[i],
        onPressed: _updateItem
      );
      columns.add(column);
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: columns
      )
    );
  }

  void _updateItem(BuildContext context, int position) {
    var copy = _dayOfWeeks.map((item) => item).toList();
    copy[position] = !copy[position];
    BlocProvider.of<TimeBloc>(context).updateDayOfWeeks(copy);
  }
}

typedef DayOfWeekItemCallback = void Function(BuildContext, int);

class DayOfWeekItem extends StatelessWidget {
  final _position;
  final _selected;
  final _displayText;
  final _width = 40.0;
  final _height = 40.0;
  final DayOfWeekItemCallback _onPressed;

  DayOfWeekItem({
    @required int position,
    @required bool selected,
    @required String displayText,
    @required DayOfWeekItemCallback onPressed
  }) : _position = position,
    _selected = selected,
    _displayText = displayText,
    _onPressed = onPressed;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: _height,
        width: _width,
        margin: EdgeInsets.all(3.0),
        child: Center(
          child: Text(
            _displayText,
            style: TextStyle(
              color: _selected ? Colors.white : Colors.grey,
              fontSize: 22.0
            )
          ),
        ),
        decoration: BoxDecoration(
          color: _selected ? Colors.blue[700] : Colors.grey[800],
          border: Border.all(
            width: 1.0,
            color: Colors.grey[800],
          ),
          borderRadius: BorderRadius.all(Radius.circular(40.0))
        )
      ),
      onTap: () =>_onPressed(context, _position)
    );
  }
}

class RepeatArea extends StatelessWidget {
  RepeatArea({
    @required bool initialRepeat
  }) : _initialRepeat = initialRepeat;

  final bool _initialRepeat;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<TimeBloc>(context).repeatMutationStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return RepeatDisplay(repeat: _initialRepeat ?? false);
        }
        final state = snapshot.data as TimeMutationState;
        switch (state.runtimeType) {
          case UpdateRepeatSuccessState:
            final repeat = (state as UpdateRepeatSuccessState).updated;
            return RepeatDisplay(repeat: repeat);
          case UpdateRepeatFailureState:
            final repeat = (state as UpdateRepeatFailureState).updated;
            return RepeatDisplay(repeat: repeat);
          default:
            return null;
        }
      }
    );
  }
}

class RepeatDisplay extends StatelessWidget {
  RepeatDisplay({
    @required bool repeat
  }) : this._repeat = repeat;

  final bool _repeat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 35.0, left: 0.0),
      alignment: Alignment(1.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: _repeat,
            onChanged: _onChangedWrapper(context),
            activeColor: Colors.blue[700],
          ),
          Text("반복"),
        ],
      ),
    );
  }

  ValueChanged<bool> _onChangedWrapper(BuildContext context) {
    return (final bool value) {
      BlocProvider.of<TimeBloc>(context).updateRepeat(!_repeat);
    };
  }
}
