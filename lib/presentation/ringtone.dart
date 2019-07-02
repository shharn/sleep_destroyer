import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class RingtoneSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.vibration), 
          onPressed: () async {
            final result = await Vibration.hasVibrator();
            if (result) {
              Vibration.vibrate();
            }
          },
          color: Colors.grey[600],
          iconSize: 60.0
        )
      ),
    );
  }
}