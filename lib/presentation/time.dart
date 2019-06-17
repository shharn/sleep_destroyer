import 'package:flutter/material.dart';
import '../model/time.dart';
import './common.dart';

class TimeSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool loaded = true;
    final time = Time.withDefault();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              if (!loaded) return;
            }
          ),
        ],
      ),
      body: loaded ? 
        Padding(
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
                  padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _Time(time: time.timeOfDay),
                      _DayOfWeeks(dayOfWeeks: time.dayOfWeeks),
                      _Repeat(repeat: time.repeat),
                    ]
                  ),
                ),
              ),
            ]
          )
        ) :
        LoadingIndicator()
    );
  }
}

class _Time extends StatelessWidget {
  _Time({
    @required TimeOfDay time
  }) : this._time = time;

  final TimeOfDay _time;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay updatedTime = await showTimePicker(
          context: context,
          initialTime: _time,
        );
        var timeString = updatedTime == null ? "Canceled" : updatedTime.toString();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(timeString)));
        if (updatedTime != null) {
          // update time
        }
      },
      child: _TimeDisplay(timeToShow: _time),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final TimeOfDay timeToShow;
  final double _fontSize = 60.0;

  _TimeDisplay({
      @required this.timeToShow
    });

  @override
  Widget build(BuildContext context) {
    final hourOfPeriod = timeToShow.hourOfPeriod;
    final minute = timeToShow.minute;
    final period = timeToShow.period;
    String formattedHour = hourOfPeriod < 10 ? "0${hourOfPeriod.toString()}" : hourOfPeriod.toString();
    String formattedMinute = minute < 10 ? "0${minute.toString()}" : minute.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _TimeDisplayItem(
          displayText: period == DayPeriod.am ? "AM" : "PM",
          fontSize: _fontSize
        ),
        _TimeDisplayItem(
          displayText: '$formattedHour : $formattedMinute',
          fontSize: _fontSize,
        ),
      ]
    );
  }
}

class _TimeDisplayItem extends StatelessWidget {
  final _displayText;
  final _fontSize;
  final _expanded;

  _TimeDisplayItem({
    @required String displayText,
    @required double fontSize,
    bool expanded = true
  }):
  _displayText = displayText,
  _fontSize = fontSize,
  _expanded = expanded;

  @override
  Widget build(BuildContext context) {
    var column = Column(
        children: <Widget>[
          Text(
            _displayText,
            style: TextStyle(fontSize: _fontSize)
          ),
          // Center(
          //   child: Text(
          //     _displayText,
          //     style: TextStyle(
          //       fontSize: _fontSize
          //     ),
          //   ),
          // ),
        ],
      );
    return _expanded ? 
      Expanded(
        child: column
      ) : 
      column;
  }
}

class _DayOfWeeks extends StatelessWidget {
  _DayOfWeeks({
    @required List<bool> dayOfWeeks
  }) : this._dayOfWeeks = dayOfWeeks;

  final List<bool> _dayOfWeeks;
  final _daysOfWeekDisplayText = <String>[ "일", "월", "화", "수", "목", "금", "토" ];

  @override
  Widget build(BuildContext context) {
    var columns = <Widget>[];
    for (var i = 0; i < _dayOfWeeks.length; i++) {
      var column = _DayOfWeekItem(
        position: i,
        selected: _dayOfWeeks[i],
        displayText: _daysOfWeekDisplayText[i],
      );
      columns.add(column);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: columns
    );
  }
}

class _DayOfWeekItem extends StatelessWidget {
  final _position;
  final _selected;
  final _displayText;
  final _width = 40.0;
  final _height = 40.0;

  _DayOfWeekItem({
    @required int position,
    @required bool selected,
    @required String displayText,
  }) :
  _position = position,
  _selected = selected,
  _displayText = displayText;
  
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

  void _onPressed(final BuildContext context, final int index) {

  }
}

class _Repeat extends StatelessWidget {
  _Repeat({
    @required bool repeat
  }) :
  this._repeat = repeat;

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

    };
  }
}
